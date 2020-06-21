import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nfsee/data/blocs/bloc.dart';
import 'package:nfsee/data/blocs/provider.dart';
import 'package:nfsee/data/card.dart';
import 'package:nfsee/ui/card_physics.dart';
import 'package:nfsee/ui/widgets.dart';
import 'package:nfsee/utilities.dart';

import 'package:nfsee/generated/l10n.dart';

const double DETAIL_OFFSET = 300;

class HomeAct extends StatefulWidget {
  final Future<bool> Function() readCard;

  HomeAct({@required this.readCard});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<HomeAct>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  CardPhysics cardPhysics;
  ScrollController cardController;
  bool dragging = false;
  bool scrolling = false;
  int scrollingTicket = 0;
  int currentIdx = 0;

  bool hidden = false;
  Animation<double> detailHide;
  double detailHideVal = 0;
  AnimationController detailHideTrans;

  bool expanded = false;
  bool expanding = false; // Expanding or collapsing
  ScrollController detailScroll;
  Animation<double> detailExpand;
  double detailExpandVal = 0;
  AnimationController detailExpandTrans;

  CardData detail;

  NFSeeAppBloc get bloc => BlocProvider.provideBloc(context);

  @override
  void initState() {
    super.initState();
    this._initSelf();
  }

  void _initSelf() {
    detailHideTrans = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);

    detailExpandTrans = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);

    this._refreshDetailScroll();

    detailHide = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: detailHideTrans,
      curve: Curves.ease,
    ));

    detailHide.addListener(() {
      this.setState(() {
        this.detailHideVal = detailHide.value;
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
      this.setState(() {
        this.detailExpandVal = detailExpand.value;
      });
    });
  }

  void _refreshPhysics(List<CardData> cards) {
    if (cards == null) return;
    if (this.cardPhysics?.cardCount == cards.length) return;
    if (this.cardController != null) this.cardController.dispose();

    this.cardPhysics = CardPhysics(cardCount: cards.length);
    this.cardController = ScrollController();
    this.cardController.addListener(() {
      final ticket = this.scrollingTicket + 1;
      this.scrollingTicket = ticket;

      Future fut = Future.delayed(const Duration(milliseconds: 100)).then((_) {
        if (this.scrollingTicket != ticket) return;
        this.setState(() {
          this.scrolling = false;
          this._updateDetailHide(cards);
        });
      });

      this.setState(() {
        this.scrolling = true;
        this._updateDetailHide(cards);
      });
    });
  }

  Widget _rerenderNavForeground(
      BuildContext context, AsyncSnapshot<List<CardData>> snapshot) {
    // log(snapshot.toString());
    final data = snapshot.data;
    this._refreshPhysics(data);
    this._updateDetailInst(data);
    CARD_WIDTH = MediaQuery.of(context).size.width * 0.9;
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
                        S.of(context).scanHistory,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headline6
                            .copyWith(fontSize: 32),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.add,
                          color:
                              Theme.of(context).primaryTextTheme.headline5.color,
                        ),
                        onPressed: () async {
                          final cardRead = await this.widget.readCard();
                          if (!cardRead) return;
                          this.addCard();
                          log("CARD read");
                        },
                      ),
                    ],
                  ),
                  Text(
                    data == null
                        ? "加载中..."
                        : S
                            .of(context)
                            .historyCount
                            .replaceAll("\$", data.length.toString()),
                    style: Theme.of(context)
                        .primaryTextTheme
                        .caption
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
                  this.setState(() {
                    this.dragging = true;
                    this._updateDetailHide(data);
                  });
                },
                onPointerUp: (_) {
                  this.setState(() {
                    this.dragging = false;
                    this._updateDetailHide(data);
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
                            onTap: this._tryExpandDetail,
                          ))
                      .toList(),
                ))),
      ],
    );
  }

  void _refreshDetailScroll() {
    this.detailScroll = ScrollController();
  }

  @override
  void reassemble() {
    this._initSelf();
    super.reassemble();
  }

  @override
  void dispose() {
    this.detailExpandTrans.dispose();
    this.detailHideTrans.dispose();
    super.dispose();
  }

  bool _tryExpandDetail() {
    if (this.expanding) return false;
    if (this.expanded) return false;

    this.expanding = true;

    this.detailExpandTrans.animateTo(1).then((_) {
      this.expanding = false;
    });
    this.setState(() {
      this.expanded = true;
    });
    return true;
  }

  bool _tryCollapseDetail() {
    if (this.expanding) return false;
    if (!this.expanded) return false;

    this.expanding = true;

    final fut1 = this.detailExpandTrans.animateBack(0);
    final fut2 = this.detailScroll.animateTo(0,
        duration: Duration(milliseconds: 100), curve: ElasticOutCurve());
    this.setState(() {
      this.expanded = false;
    });

    Future.wait([fut1, fut2]).then((_) {
      this.expanding = false;
    });

    return true;
  }

  void _updateDetailHide(List<CardData> cards) async {
    if (this.scrolling) {
      if (this.hidden) return;
      this.hidden = true;
      await Future.delayed(const Duration(milliseconds: 100));
      if (this.hidden != true) return;
      this.detailHideTrans.animateTo(1);
    } else if (!this.scrolling && !this.dragging) {
      if (!this.hidden) return;
      this.hidden = false;
      await Future.delayed(const Duration(milliseconds: 100));
      if (this.hidden != false) return;
      this.detailHideTrans.animateBack(0);
      this._updateDetailInst(cards);
    }
  }

  void _updateDetailInst(List<CardData> cards) {
    int targetIdx =
        this.cardController != null && this.cardController.hasClients
            ? this.cardPhysics.getItemIdx(this.cardController.position)
            : 0;
    final next =
        (cards == null || targetIdx >= cards.length) ? null : cards[targetIdx];
    if (next == this.detail) return;
    if (next != null && next.sameAs(this.detail)) return;
    Future.delayed(Duration(seconds: 0))
        .then((_) => setState(() => this.detail = next));
    log("TIDX: $targetIdx");
  }

  void addCard() async {
    await Future.delayed(const Duration(milliseconds: 10));
    this.cardController.animateTo(this.cardController.position.maxScrollExtent,
        duration: const Duration(seconds: 1), curve: ElasticOutCurve());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cardStream = bloc.dumpedRecords.map(
        (records) => records.map((r) => CardData.fromDumpedRecord(r)).toList());
    final navForeground = StreamBuilder(
      stream: cardStream,
      builder: this._rerenderNavForeground,
    );

    final nav = Stack(
      children: <Widget>[
        new Positioned(
          child: new CustomPaint(
            painter:
                new HomeBackgrondPainter(color: Theme.of(context).primaryColor),
          ),
          bottom: 0,
          top: 0,
          left: 0,
          right: 0,
        ),
        new SafeArea(child: navForeground),
      ],
    );

    final detail = this._buildDetail(context);

    final top = Stack(
      children: <Widget>[
        Transform.translate(
          offset: Offset(0, -DETAIL_OFFSET * this.detailExpandVal),
          child: nav,
        ),
        Transform.translate(
          offset: Offset(0, DETAIL_OFFSET * (1 - this.detailExpandVal)),
          child: Transform.translate(
              child: Opacity(child: detail, opacity: (1 - this.detailHideVal)),
              offset: Offset(0, 50 * this.detailHideVal)),
        )
      ],
    );

    return WillPopScope(
        onWillPop: () {
          return Future.value(!this._tryCollapseDetail());
        },
        child: top);
  }

  Widget _buildDetail(BuildContext ctx) {
    if (detail == null) return Container();
    var data = detail.raw;

    final detailTiles = parseCardDetails(data["detail"], context)
        .map((d) => ListTile(
              dense: true,
              title: Text(d.name),
              subtitle: Text(d.value),
              leading: Icon(d.icon ?? Icons.info),
            ))
        .toList();

    final disp = Container(
        child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
      IgnorePointer(
        ignoring: !this.expanded,
        child: Opacity(
          opacity: this.detailExpandVal,
          child: AppBar(
            primary: true,
            backgroundColor: Color.fromARGB(255, 85, 69, 177),
            title: Text(detail.name ?? S.of(context).unnamedCard,
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .apply(color: Colors.white)),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                this._tryCollapseDetail();
              },
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  this._editCardName(this.detail);
                },
              ),
              PopupMenuButton<String>(
                onSelected: (act) {
                  if (act == "delete") {
                    this._delFocused();
                  }
                },
                icon: Icon(Icons.more_vert, color: Colors.white),
                itemBuilder: (context) => [
                  PopupMenuItem(
                      value: "delete", child: Text(S.of(context).delete)),
                ],
              ),
            ],
            brightness: Brightness.light,
          ),
        ),
      ),
      NotificationListener(
        onNotification: (notif) {
          if (notif is UserScrollNotification) {
            UserScrollNotification usnotif = notif;
            if (usnotif.depth == 0 &&
                usnotif.direction == ScrollDirection.reverse) {
              this._tryExpandDetail();
            }
          }

          if (notif is OverscrollNotification) {
            OverscrollNotification onotif = notif;
            if (onotif.depth == 0 &&
                onotif.velocity == 0 &&
                onotif.metrics.pixels == 0) {
              this._tryCollapseDetail();
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
                title: Text(
                    "${S.of(context).addedAt} ${this.detail.formattedTime}"),
                subtitle: Text(S.of(context).detailHint),
                leading: Icon(Icons.access_time),
              ),
              detailTiles.length == 0 ? Container() : Divider(),
              Column(children: detailTiles),
              Divider(),
              this._buildMisc(context, data),
              SizedBox(height: this.expanded ? 0 : DETAIL_OFFSET),
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
            .map((t) => NDEFTile(data: t))
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
      accentColor: rawTdata.textTheme.subtitle1.color,
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
            title: Text(S.of(context).transactionHistory),
            subtitle: transferTiles == null
                ? Text(S.of(context).notSupported)
                : Text("${transferTiles.length} ${S.of(context).recordCount}"),
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
            title: Text(S.of(context).ndefRecords),
            subtitle: ndefTiles == null
                ? Text(S.of(context).notSupported)
                : Text("${ndefTiles.length} ${S.of(context).recordCount}"),
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
            title: Text(S.of(context).technologicalDetails),
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
            title: Text(S.of(context).memoryData),
            subtitle: data["detail"]["data"] == null
                ? Text("Unavailabile")
                : Text(
                    "${data["detail"]["data"].length >> 1} ${S.of(context).byteCount}"),
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
            title: Text(S.of(context).apduLogs),
            subtitle: Text(
                "${data["apdu_history"].length} ${S.of(context).recordCount}"),
            children: apduTiles,
          ),
        ),
      ],
    );

    return misc;
  }

  void _delFocused() async {
    final message =
        '${S.of(context).record} ${this.detail.id} ${S.of(context).deleted}';
    log('Record ${this.detail.id} deleted');

    final deleted = this.detail;

    await this.bloc.delDumpedRecord(deleted.id);

    this._tryCollapseDetail();

    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context)
        .showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(message),
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: S.of(context).undo,
              onPressed: () {},
            )))
        .closed
        .then((reason) async {
      switch (reason) {
        case SnackBarClosedReason.action:
          // user cancelled deletion, restore it
          await this.bloc.addDumpedRecord(
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
                labelText: S.of(context).cardName,
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
          FlatButton(
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
            onPressed: () {
              setState(() {
                if (pendingName == "") {
                  data.name = null;
                } else {
                  data.name = pendingName;
                }
                bloc.updateDumpedRecordConfig(data.id, data.config);
                Navigator.of(context).pop();
              });
            },
          ),
          FlatButton(
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
  final Color color;
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

    final path = new Path()..addPolygon(points, true);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = this.color;

    canvas.drawShadow(path, Colors.black, 2, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
