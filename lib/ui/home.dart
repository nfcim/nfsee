import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nfsee/data/blocs/bloc.dart';
import 'package:nfsee/data/blocs/provider.dart';
import 'package:nfsee/data/card.dart';
import 'package:nfsee/data/database/database.dart';
import 'package:nfsee/main.dart';
import 'package:nfsee/models.dart';
import 'package:nfsee/ui/card_physics.dart';
import 'package:nfsee/utilities.dart';

import 'package:nfsee/generated/l10n.dart';

const double DETAIL_OFFSET = 300;

class HomeAct extends StatefulWidget {
  final Future<void> Function() readCard;

  HomeAct({ @required this.readCard });

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<HomeAct> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  List<CardData> cards = [
    CardData(category: CardCategory.unspecified, name: '呜喵', cardType: CardType.Tsinghua, cardNo: '12345678', raw: null),
    CardData(category: CardCategory.unspecified, name: '诶嘿嘿', cardType: CardType.Tsinghua, cardNo: 'XXX', raw: null),
  ];

  ScrollPhysics cardPhysics;
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

  int focused = 0;
  DumpedRecord focusedRecord = null;

  NFSeeAppBloc get bloc => BlocProvider.provideBloc(context);

  @override
  void initState() {
    super.initState();
    this._initSelf();
  }

  void _initSelf() {
    log("State updated");

    detailHideTrans = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this
    );

    detailExpandTrans = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this
    );

    this._refreshPhysics();
    this._refreshDetailScroll();

    detailHide = Tween<double>(
      begin: 1,
      end: 0,
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

  void _refreshPhysics() {
    log(this.cards.length.toString());
    this.cardPhysics = CardPhysics(cardCount: this.cards.length);
    this.cardController = ScrollController();
    this.cardController.addListener(() {
      final ticket = this.scrollingTicket + 1;
      this.scrollingTicket = ticket;
      Future fut = Future.delayed(const Duration(milliseconds: 100)).then((_) {
        if(this.scrollingTicket != ticket) return;
        this.setState(() {
          this.scrolling = false;
          this._updateDetailHide();
        });
      });

      this.setState(() {
        this.scrolling = true;
        this._updateDetailHide();
      });
    });
  }

  void _refreshDetailScroll() {
    this.detailScroll = ScrollController();
    this.detailScroll.addListener(() {
      if(this.detailScroll.position.pixels == 0) return;
      this._tryExpandDetail();
    });
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
    if(this.expanding) return false;
    if(this.expanded) return false;

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
    if(this.expanding) return false;
    if(!this.expanded) return false;

    this.expanding = true;

    final fut1 = this.detailExpandTrans.animateBack(0);
    final fut2 = this.detailScroll.animateTo(0, duration: Duration(milliseconds: 100), curve: ElasticOutCurve());
    this.setState(() {
      this.expanded = false;
    });

    Future.wait([fut1, fut2]).then((_) {
      this.expanding = false;
    });

    return true;
  }

  void _updateDetailHide() async {
    if(this.scrolling || this.dragging) {
      if(this.hidden) return;
      this.hidden = true;
      await Future.delayed(const Duration(milliseconds: 100));
      if(this.hidden != true) return;
      this.detailHideTrans.animateBack(0);
      this.setState(() {
        this.focused = 0;
      });
    } else {
      if(!this.hidden) return;
      this.hidden = false;
      await Future.delayed(const Duration(milliseconds: 100));
      if(this.hidden != false) return;
      this.detailHideTrans.animateTo(1);
      this.setState(() {
        this.focused = 0;
      });
    }
  }

  void addCard() async {
    this.setState(() {
      this.cards += [CardData(category: CardCategory.unspecified, name: '???', cardType: CardType.Tsinghua, cardNo: '12345678', raw: null)];
    });
    this._refreshPhysics();
    await Future.delayed(const Duration(milliseconds: 10));
    this.cardController.animateTo(this.cardController.position.maxScrollExtent, duration: const Duration(seconds: 1), curve: ElasticOutCurve());
  }

  @override
  Widget build(BuildContext context) {
    final navForeground = Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text("扫描历史",
                    style: TextStyle(color: Colors.black, fontSize: 32),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
                    onPressed: () async {
                      await this.widget.readCard();
                      log("CARD read");
                    },
                  ),
                ],
              ),
              Text("共 ${cards.length} 条历史", style: TextStyle(color: Colors.black54, fontSize: 14)),
            ]
          )
        ),

        SizedBox(
          height: 20,
        ),

        Container(
          height: 240,
          child: Listener(
            onPointerDown: (_) {
              this.setState(() {
                this.dragging = true;
                this._updateDetailHide();
              });
            },
            onPointerUp: (_) {
              this.setState(() {
                this.dragging = false;
                this._updateDetailHide();
              });
            },
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: (MediaQuery.of(context).size.width - CARD_WIDTH) / 2),
              controller: cardController,
              physics: cardPhysics,
              scrollDirection: Axis.horizontal,
              children: this.cards.map((c) { return c.homepageCard(context); }).toList(),
            )
          )
        ),
      ],
    );

    final nav = Stack(
      children: <Widget>[
        new Positioned(
          child: new CustomPaint(
            painter: new HomeBackgrondPainter(color: Theme.of(context).primaryColor),
          ),
          bottom: 0,
          top: 0,
          left: 0,
          right: 0,
        ),
        new SafeArea(
          child: navForeground
        ),
      ],
    );

    final detail = this.buildDetail(context);

    final top = Stack(
      children: <Widget>[
        Transform.translate(
          offset: Offset(0, -DETAIL_OFFSET * this.detailExpandVal),
          child: nav,
        ),
        Transform.translate(
          offset: Offset(0, DETAIL_OFFSET * (1 - this.detailExpandVal)),
          child: Transform.translate(
            child: Opacity(child: detail, opacity: (1-this.detailHideVal)),
            offset: Offset(0, 50 * this.detailHideVal)
          ),
        )
      ],
    );

    return WillPopScope(
      onWillPop: () {
        return Future.value(!this._tryCollapseDetail());
      },
      child: top
    );

    // Legacy impl
    /*
    return Scaffold(
        primary: true,
        appBar: AppBar(
          title: Text(S.of(context).homeScreenTitle),
        ),
        bottomNavigationBar: this._buildBottomAppbar(context),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            this._readTag(context);
          },
          child: Icon(
            Icons.nfc,
          ),
          tooltip: S.of(context).scanTabTitle,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        body: Scrollbar(
            child: StreamBuilder<List<DumpedRecord>>(
          stream: bloc.dumpedRecords,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data.length == 0) {
              return Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Image.asset('assets/empty.png', height: 200),
                      Text(S.of(context).noHistoryFound),
                    ],
                  ));
            }
            final records = snapshot.data.toList()
              ..sort((a, b) => a.time.compareTo(b.time));
            return ListView.builder(
              padding: EdgeInsets.only(bottom: 48),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final r = records[index];
                return Dismissible(
                  direction: DismissDirection.startToEnd,
                  onDismissed: (direction) async {
                    final message =
                        '${S.of(context).record} ${r.id} ${S.of(context).deleted}';
                    log('Record ${r.id} deleted');
                    await this.bloc.delDumpedRecord(r.id);
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
                          await this
                              .bloc
                              .addDumpedRecord(r.data, r.time, r.config);
                          log('Record ${r.id} restored');
                          break;
                        default:
                          break;
                      }
                    });
                  },
                  key: Key(r.id.toString()),
                  background: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.red,
                      padding: EdgeInsets.all(18),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(Icons.delete, color: Colors.white30),
                      )),
                  child: ReportRowItem(
                      record: r,
                      onTap: () {
                        _navigateToTag(r);
                      }),
                );
              },
            );
          },
        )));
        */
  }

  Widget buildDetail(BuildContext ctx) {
    if(this.focused >= this.cards.length) return Container();

    final card = this.cards[this.focused];
    var data = card.raw;

    if(data == null) data = jsonDecode("""{
      "detail": {
        "card_number": "NUMBER",
        "card_number1": "喵喵",
        "card_number2": "这是一些测试数据",
        "card_number3": "这是一些测试数据",
        "card_number4": "这是一些测试数据",
        "card_number5": "这是一些测试数据",
        "card_number6": "这是一些测试数据",
        "card_number7": "这是一些测试数据",
        "card_number8": "这是一些测试数据",
        "card_number9": "这是一些测试数据",
        "card_number10": "这是一些测试数据",
        "card_number11": "这是一些测试数据",
        "card_number12": "这是一些测试数据",
        "card_number13": "这是一些测试数据",
        "card_number14": "这是一些测试数据"
      }
    }""");

    final disp = Container(
      child: Column(
        children: <Widget>[
          IgnorePointer(
            ignoring: !this.expanded,
            child: Opacity(
              opacity: this.detailExpandVal,
              child: AppBar(
                primary: true,
                backgroundColor: Color.fromARGB(255, 85, 69, 177),
                title: Text(card.name ?? card.cardType.getName(context), style: Theme.of(context).textTheme.title.apply(color: Colors.white)),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    this._tryCollapseDetail();
                  },
                ),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.white),
                  ),
                ],
                brightness: Brightness.light,
              ),
            ),
          ),

          Expanded(child: ListView(
              controller: detailScroll,
              padding: EdgeInsets.only(bottom: this.expanded ? 0 : DETAIL_OFFSET),

              children: parseCardDetails(data["detail"], context)
                  .map((d) => ListTile(
                        dense: true,
                        title: Text(d.name),
                        subtitle: Text(d.value),
                        leading: Icon(d.icon ?? Icons.info),
                      ))
                  .toList()
          )),
        ]
      )
    );

    return disp;
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
                if(pendingName == "") {
                  data.name = null;
                } else {
                  data.name = pendingName;
                }
                bloc.updateDumpedRecordConfig(data.id, data.generateConfig());
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
  HomeBackgrondPainter({ this.color });

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
