import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:nfsee/data/blocs/bloc.dart';
import 'package:nfsee/data/blocs/provider.dart';
import 'package:nfsee/data/card.dart';
import 'package:nfsee/ui/card_physics.dart';
import 'package:nfsee/ui/widgets.dart';
import 'package:nfsee/utilities.dart';

const double DETAIL_OFFSET = 300;

class HomeAct extends StatefulWidget {
  final Future<bool> Function() readCard;
  late final HomeState state;

  HomeAct({required this.readCard});

  @override
  HomeState createState() {
    state = HomeState();
    return state;
  }

  void scrollToNewCard() => state.addCard();
}

class HomeState extends State<HomeAct>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  CardPhysics? cardPhysics;
  ScrollController? cardController;
  bool dragging = false;
  bool scrolling = false;
  int scrollingTicket = 0;
  int currentIdx = 0;

  bool hidden = false;
  late Animation<double> detailHide;
  double detailHideVal = 0;
  late AnimationController detailHideTrans;

  bool expanded = false;
  bool expanding = false; // Expanding or collapsing
  ScrollController? detailScroll;
  late Animation<double> detailExpand;
  double detailExpandVal = 0;
  late AnimationController detailExpandTrans;

  CardData? detail;

  NFSeeAppBloc? get bloc => BlocProvider.provideBloc(context);

  @override
  void initState() {
    super.initState();
    _initSelf();
  }

  void _initSelf() {
    detailHideTrans = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);

    detailExpandTrans = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);

    _refreshDetailScroll();

    detailHide = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: detailHideTrans,
      curve: Curves.ease,
    ));

    detailHide.addListener(() {
      setState(() {
        detailHideVal = detailHide.value;
      });
    });

    detailExpand = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: detailExpandTrans,
      curve: Curves.ease,
    ));

    detailExpand.addListener(() {
      setState(() {
        detailExpandVal = detailExpand.value;
      });
    });
  }

  void _refreshPhysics(List<CardData>? cards) {
    if (cards == null) return;
    if (cardPhysics?.cardCount == cards.length) return;
    if (cardController != null) cardController!.dispose();

    cardPhysics = CardPhysics(cardCount: cards.length);
    cardController = ScrollController();
    cardController!.addListener(() {
      final ticket = scrollingTicket + 1;
      scrollingTicket = ticket;

      Future.delayed(const Duration(milliseconds: 100)).then((_) {
        if (scrollingTicket != ticket) return;
        setState(() {
          scrolling = false;
          _updateDetailHide(cards);
        });
      });

      setState(() {
        scrolling = true;
        _updateDetailHide(cards);
      });
    });
  }

  Widget _rerenderNavForeground(
      BuildContext context, AsyncSnapshot<List<CardData>> snapshot) {
    // log(snapshot.toString());
    final data = snapshot.data;
    _refreshPhysics(data);
    _updateDetailInst(data);

    return Column(
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        S(context).scanHistory,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(fontSize: 32),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.add,
                          color: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .color,
                        ),
                        onPressed: () async {
                          final cardRead = await widget.readCard();
                          if (!cardRead) return;
                          // this.addCard();
                          log("CARD read");
                        },
                      ),
                    ],
                  ),
                  Text(
                    data == null
                        ? "加载中..."
                        : S(context)
                            .historyCount
                            .replaceAll("\$", data.length.toString()),
                    style: Theme.of(context)
                        .primaryTextTheme
                        .bodySmall!
                        .copyWith(fontSize: 14),
                  ),
                ])),
        SizedBox(
          height: 20,
        ),
        Container(
            height: 240,
            child: Listener(
                onPointerDown: (_) {
                  setState(() {
                    dragging = true;
                    _updateDetailHide(data);
                  });
                },
                onPointerUp: (_) {
                  setState(() {
                    dragging = false;
                    _updateDetailHide(data);
                  });
                },
                child: ListView(
                  padding: EdgeInsets.symmetric(
                      horizontal:
                          (MediaQuery.of(context).size.width - CARD_WIDTH) / 2),
                  controller: cardController,
                  physics: cardPhysics,
                  scrollDirection: Axis.horizontal,
                  children: (data ?? [])
                      .map((c) => GestureDetector(
                            child: c.homepageCard(context),
                            onTap: _tryExpandDetail,
                          ))
                      .toList(),
                ))),
      ],
    );
  }

  void _refreshDetailScroll() {
    detailScroll = ScrollController();
  }

  @override
  void reassemble() {
    _initSelf();
    super.reassemble();
  }

  @override
  void dispose() {
    detailExpandTrans.dispose();
    detailHideTrans.dispose();
    super.dispose();
  }

  bool _tryExpandDetail() {
    if (expanding) return false;
    if (expanded) return false;

    expanding = true;

    detailExpandTrans.animateTo(1).then((_) {
      expanding = false;
    });
    setState(() {
      expanded = true;
    });
    return true;
  }

  bool _tryCollapseDetail() {
    if (expanding) return false;
    if (!expanded) return false;

    expanding = true;

    final fut1 = detailExpandTrans.animateBack(0);
    final fut2 = detailScroll!.animateTo(0,
        duration: Duration(milliseconds: 100), curve: ElasticOutCurve());
    setState(() {
      expanded = false;
    });

    Future.wait([fut1, fut2]).then((_) {
      expanding = false;
    });

    return true;
  }

  void _updateDetailHide(List<CardData>? cards) async {
    if (scrolling) {
      if (hidden) return;
      hidden = true;
      await Future.delayed(const Duration(milliseconds: 100));
      if (hidden != true) return;
      detailHideTrans.animateTo(1);
    } else if (!scrolling && !dragging) {
      if (!hidden) return;
      hidden = false;
      await Future.delayed(const Duration(milliseconds: 100));
      if (hidden != false) return;
      detailHideTrans.animateBack(0);
      _updateDetailInst(cards);
    }
  }

  void _updateDetailInst(List<CardData>? cards) {
    int targetIdx = cardController != null && cardController!.hasClients
        ? cardPhysics!.getItemIdx(cardController!.position)
        : 0;
    final next =
        (cards == null || targetIdx >= cards.length) ? null : cards[targetIdx];
    if (next == detail) return;
    if (next != null && next.sameAs(detail)) return;
    Future.delayed(Duration(seconds: 0))
        .then((_) => setState(() => detail = next));
    log("TIDX: $targetIdx");
  }

  void addCard() async {
    await Future.delayed(const Duration(milliseconds: 10));
    cardController!.animateTo(cardController!.position.maxScrollExtent,
        duration: const Duration(microseconds: 500), curve: ElasticOutCurve());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cardStream = bloc!.dumpedRecords!.map(
        (records) => records.map((r) => CardData.fromDumpedRecord(r)).toList());
    final navForeground = StreamBuilder(
      stream: cardStream,
      builder: _rerenderNavForeground,
    );

    final nav = Stack(
      children: <Widget>[
        Positioned(
          child: CustomPaint(
            painter:
                HomeBackgrondPainter(color: Theme.of(context).primaryColor),
          ),
          bottom: 0,
          top: 0,
          left: 0,
          right: 0,
        ),
        SafeArea(child: navForeground),
      ],
    );

    final detail = _buildDetail(context);

    final top = Stack(
      children: <Widget>[
        Transform.translate(
          offset: Offset(0, -DETAIL_OFFSET * detailExpandVal),
          child: nav,
        ),
        Transform.translate(
          offset: Offset(0, DETAIL_OFFSET * (1 - detailExpandVal)),
          child: Transform.translate(
              child: Opacity(child: detail, opacity: (1 - detailHideVal)),
              offset: Offset(0, 50 * detailHideVal)),
        )
      ],
    );

    return PopScope(canPop: !_tryCollapseDetail(), child: top);
  }

  Widget _buildDetail(BuildContext ctx) {
    if (detail == null) {
      return Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/empty.png', height: 200),
              Text(S(context).noHistoryFound),
            ],
          ));
    }
    var data = detail!.raw;

    final detailTiles = parseCardDetails(data["detail"], context)
        .map((d) => ListTile(
              dense: true,
              title: Text(d.name!),
              subtitle: Text(d.value!),
              leading: Icon(d.icon ?? Icons.info),
            ))
        .toList();

    final disp = Container(
        child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
      IgnorePointer(
        ignoring: !expanded,
        child: Opacity(
          opacity: detailExpandVal,
          child: AppBar(
            primary: true,
            backgroundColor: Color.fromARGB(255, 85, 69, 177),
            title: Text(detail!.name ?? S(context).unnamedCard,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .apply(color: Colors.white)),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                _tryCollapseDetail();
              },
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  _editCardName(detail!);
                },
              ),
              PopupMenuButton<String>(
                onSelected: (act) {
                  if (act == "delete") {
                    _delFocused();
                  }
                },
                icon: Icon(Icons.more_vert, color: Colors.white),
                itemBuilder: (context) => [
                  PopupMenuItem(
                      value: "delete", child: Text(S(context).delete)),
                ],
              ),
            ],
          ),
        ),
      ),
      NotificationListener(
        onNotification: (notif) {
          if (notif is UserScrollNotification) {
            UserScrollNotification usnotif = notif;
            if (usnotif.depth == 0 &&
                usnotif.direction == ScrollDirection.reverse) {
              _tryExpandDetail();
            }
          }

          if (notif is OverscrollNotification) {
            OverscrollNotification onotif = notif;
            if (onotif.depth == 0 &&
                onotif.velocity == 0 &&
                onotif.metrics.pixels == 0) {
              _tryCollapseDetail();
            }
          }
          return false;
        },
        child: Expanded(
            child: SingleChildScrollView(
          controller: detailScroll,
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text("${S(context).addedAt} ${detail!.formattedTime}"),
                subtitle: Text(S(context).detailHint),
                leading: Icon(Icons.access_time),
              ),
              detailTiles.isEmpty ? Container() : Divider(),
              Column(children: detailTiles),
              Divider(),
              _buildMisc(context, data),
              SizedBox(height: expanded ? 0 : DETAIL_OFFSET),
            ],
          ),
        )),
      ),
    ]));

    return disp;
  }

  Widget _buildMisc(BuildContext context, dynamic data) {
    final apduTiles = (data["apdu_history"] as List<dynamic>)
        .asMap()
        .entries
        .map((t) => APDUTile(data: t.value, index: t.key))
        .toList();
    final transferTiles = data["detail"]["transactions"] != null
        ? (data["detail"]["transactions"] as List<dynamic>)
            .map((t) => TransferTile(data: t))
            .toList()
        : null;
    final ndefTiles = data["detail"]["ndef"] != null
        ? (data["detail"]["ndef"] as List<dynamic>)
            .map((t) => NDEFTile(raw: NDEFRawRecord.fromJson(t)))
            .toList()
        : null;
    final technologyDetailTiles = (data["tag"] as Map<String, dynamic>)
        .entries
        .where((t) => t.value != '' && t.value != null) // filter empty values
        .map((t) =>
            TechnologicalDetailTile(name: t.key, value: t.value.toString()))
        .toList();
    final dataTiles = data["detail"]["data"] == null
        ? <Widget>[]
        : [DataTile(data: data["detail"]["data"])];

    final rawTdata = Theme.of(context);
    final tdata = rawTdata.copyWith(
      dividerColor: Colors.transparent,
    );

    final backgroundColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final iconColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;

    final misc = Column(
      children: [
        Theme(
          data: tdata,
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: backgroundColor,
              child: Icon(
                Icons.payment,
                color: iconColor,
              ),
            ),
            title: Text(S(context).transactionHistory),
            subtitle: transferTiles == null
                ? Text(S(context).notSupported)
                : Text("${transferTiles.length} ${S(context).recordCount}"),
            children: transferTiles ?? [],
          ),
        ),
        Divider(),
        Theme(
          data: tdata,
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: backgroundColor,
              child: Icon(
                Icons.note,
                color: iconColor,
              ),
            ),
            title: Text(S(context).ndefRecords),
            subtitle: ndefTiles == null
                ? Text(S(context).notSupported)
                : Text("${ndefTiles.length} ${S(context).recordCount}"),
            children: ndefTiles ?? [],
          ),
        ),
        Divider(),
        Theme(
          data: tdata,
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: backgroundColor,
              child: Icon(
                Icons.nfc,
                color: iconColor,
              ),
            ),
            title: Text(S(context).technologicalDetails),
            subtitle: Text(data['tag']['standard']),
            children: technologyDetailTiles,
          ),
        ),
        Divider(),
        Theme(
          data: tdata,
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: backgroundColor,
              child: Icon(
                Icons.chat,
                color: iconColor,
              ),
            ),
            title: Text(S(context).memoryData),
            subtitle: data["detail"]["data"] == null
                ? Text(S(context).unavailable)
                : Text(
                    "${data["detail"]["data"].length >> 1} ${S(context).byteCount}"),
            children: dataTiles,
          ),
        ),
        Divider(),
        Theme(
          data: tdata,
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: backgroundColor,
              child: Icon(
                Icons.history,
                color: iconColor,
              ),
            ),
            title: Text(S(context).apduLogs),
            subtitle: Text(
                "${data["apdu_history"].length} ${S(context).recordCount}"),
            children: apduTiles,
          ),
        ),
      ],
    );

    return misc;
  }

  void _delFocused() async {
    final message = '${S(context).record} ${detail!.id} ${S(context).deleted}';
    log('Record ${detail!.id} deleted');

    final deleted = detail;

    await bloc!.delDumpedRecord(deleted!.id);

    _tryCollapseDetail();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(message),
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: S(context).undo,
              onPressed: () {},
            )))
        .closed
        .then((reason) async {
      switch (reason) {
        case SnackBarClosedReason.action:
          // user cancelled deletion, restore it
          await bloc!.addDumpedRecord(
              jsonEncode(deleted.raw), deleted.time, deleted.config);
          log('Record ${deleted.id} restored');
          break;
        default:
          break;
      }
    });
  }

  void _editCardName(CardData data) {
    var pendingName = data.name ?? "";

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                filled: true,
                labelText: S(context).cardName,
              ),
              maxLines: 1,
              initialValue: pendingName,
              onChanged: (cont) {
                pendingName = cont;
              },
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
            onPressed: () {
              setState(() {
                if (pendingName == "") {
                  data.name = null;
                } else {
                  data.name = pendingName;
                }
                bloc!.updateDumpedRecordConfig(data.id, data.config);
                Navigator.of(context).pop();
              });
            },
          ),
          TextButton(
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class HomeBackgrondPainter extends CustomPainter {
  final Color? color;

  HomeBackgrondPainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height;
    final points = [
      size.topLeft(Offset.zero),
      size.topLeft(Offset(0, height / 3)),
      size.topRight(Offset(0, height / 4)),
      size.topRight(Offset.zero),
    ];

    final path = Path()..addPolygon(points, true);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color!;

    canvas.drawShadow(path, Colors.black, 2, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
