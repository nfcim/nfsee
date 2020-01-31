import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nfsee/generated/l10n.dart';

import '../models.dart';
import 'widgets.dart';

class CardDetailTab extends StatefulWidget {
  const CardDetailTab({ this.data });

  final dynamic data;

  @override
  CardDetailTabState createState() => CardDetailTabState(data: this.data);
}

class CardDetailTabState extends State<CardDetailTab> {
  CardDetailTabState({this.data});

  final dynamic data;
  List<bool> expanded = [false, false, false, false];

  String _getFilename() {
    switch (data['card_type'] as CardType) {
      case CardType.UPCredit:
      case CardType.UPDebit:
      case CardType.UPSecuredCredit:
        return 'union_pay';
      case CardType.MC:
        return 'mc';
      case CardType.Visa:
        return 'visa';
      case CardType.AMEX:
        return 'amex';
      case CardType.JCB:
        return 'jcb';
      case CardType.Discover:
        return 'discover';
      case CardType.BMAC:
        return 'bmac';
      case CardType.ShenzhenTong:
        return 'shenzhentong';
      case CardType.LingnanPass:
        return 'lingnanpass';
      case CardType.WuhanTong:
        return 'wuhantong';
      case CardType.CityUnion:
        return 'city_union';
      case CardType.TUnion:
        return 't_union';
      case CardType.Octopus:
        return 'octopus';
      case CardType.TMoney:
        return 't_money';
      case CardType.Tsinghua:
        return 'tsinghua';
      default:
        return '';
    }
  }

  Widget _buildCard() {
    return Card(
      margin: EdgeInsets.only(bottom: 20),
      elevation: 2,
      child: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16/9,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    const Color(0xFFFFF6B7),
                    const Color(0xFFF6416C),
                  ]
                )
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                    Image.asset(
                      'assets/cards/${_getFilename()}.png',
                      width: 150,
                    ),
                    Text(
                      data["detail"]["card_number"],
                      style: TextStyle(fontSize: 14, color: Colors.black38),
                    )
                ],
              ),
            ),
          ),

          ListTile(
            title: Text("Unamed card"),
            subtitle: Text("${(data['card_type'] as CardType).getName(context)} - ${data['detail']['card_number']}"),
            trailing: IconButton(
              onPressed: () {},
              icon: Icon(Icons.edit),
            ),
          ),
        ]
      )
    );
  }

  Widget _buildDetail() {
    final details = parseDetails(data);

    return Card(
      margin: EdgeInsets.only(bottom: 20),
      elevation: 2,
      child: Column(
        children: details.map((d) => ListTile(
          dense: true,
          title: Text(d.name),
          subtitle: Text(d.value),
          leading: Icon(d.icon ?? Icons.info),
        )).toList()
      )
    );
  }

  Widget _buildMisc() {
    final apduTiles = (data["apdu_history"] as List<dynamic>).asMap().entries.map((t) => APDUTile(data: t.value, index: t.key)).toList();
    final transferTiles = (data["detail"]["transactions"] as List<dynamic>).map((t) => TransferTile(data: t)).toList();

    return ExpansionPanelList(
      expansionCallback: (int idx, bool original) {
        setState(() { this.expanded[idx] = !original; });
      },
      children: <ExpansionPanel>[
        ExpansionPanel(
          headerBuilder: (ctx, isExp) {
            return ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.payment),
              ),
              title: Text("Transactions"),
              subtitle: Text("${transferTiles.length} transfers"),
            );
          },
          body: Column(
            children: transferTiles,
          ),
          isExpanded: this.expanded[0],
        ),
        ExpansionPanel(
          headerBuilder: (ctx, isExp) {
            return ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.nfc),
              ),
              title: Text("APDU backlog"),
              subtitle: Text("${data["apdu_history"].length} communications"),
            );
          },
          body: Container(
            child: Column(
              children: apduTiles,
            )
          ),
          isExpanded: this.expanded[1],
        ),
        ExpansionPanel(
          headerBuilder: (ctx, isExp) {
            return ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.search),
              ),
              title: Text("Raw data"),
            );
          },
          body: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Text(data.toString(), style: Theme.of(context).textTheme.caption),
          ),
          isExpanded: this.expanded[2],
        )
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              this._buildCard(),
              this._buildDetail(),
              this._buildMisc(),
            ],
          ),
        ),
      )
    );
  }

  // ===========================================================================
  // Non-shared code below because we're using different scaffolds.
  // ===========================================================================

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((data['card_type'] as CardType).getName(context)),
        backgroundColor: Color.fromARGB(0x30, 0, 0, 0),
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: _buildBody(),
    );
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text((data['card_type'] as CardType).getName(context)),
        previousPageTitle: 'Scan',
      ),
      child: _buildBody(),
    );
  }

  @override
  Widget build(context) {
    return PlatformWidget(
      androidBuilder: _buildAndroid,
      iosBuilder: _buildIos,
    );
  }
}

class APDUTile extends StatelessWidget {
  const APDUTile({ this.data, this.index });

  final dynamic data;
  final int index;

  @override
  Widget build(context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          top: Divider.createBorderSide(context),
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text("#${this.index} > TX", style: Theme.of(context).textTheme.caption),
          this.hexView(data["tx"], context, Colors.green),
          SizedBox(height: 16),
          Text("#${this.index} > RX", style: Theme.of(context).textTheme.caption),
          this.hexView(data["rx"], context, Colors.orange),
        ]
      ),
    );
  }

  Widget hexView(String str, BuildContext context, Color color) {
    var segs = List<Widget>();

    for(int i = 0; i<str.length; i+=2) {
      final slice = str.substring(i, i+2);
      final seg = Container(
        width: 20,
        margin: EdgeInsets.only(right: 5),
        child: Text(
          slice,
          style: Theme.of(context).textTheme.body1.apply(color: color),
        )
      );
      segs.add(seg);
    }

    return Wrap(children: segs);
  }
}

class TransferTile extends StatelessWidget {
  const TransferTile({ this.data });

  final dynamic data;

  @override
  Widget build(context) {
    return ExpansionTile(
      title: Text("${getSign(data["type"])}${formatMoney(data["amount"])}"),
      subtitle: Text("${formatDate(data["date"])} - ${data["type"]}"),
      children: <Widget>[
        ListTile(
          title: Text("这里再放一点"),
        ),
        ListTile(
          title: Text("其他信息？"),
        ),
      ],
    );
  }
}

class Detail {
  const Detail({ this.name, this.value, this.icon });

  final String name;
  final String value;
  final IconData icon;
}

List<Detail> parseDetails(dynamic data) {
  final cardType = data["card_type"];

  if(cardType == CardType.Tsinghua) {
    return [
      Detail(
        name: "Card Number",
        value: data["detail"]["card_number"],
        icon: Icons.credit_card,
      ),
      Detail(
        name: "Holder",
        value: data["detail"]["name"],
        icon: Icons.person,
      ),
      Detail(
        name: "Expiry Date",
        value: formatDate(data["detail"]["expiry_date"]),
        icon: Icons.calendar_view_day,
      ),
      Detail(
        name: "Balance",
        value: formatMoney(data["detail"]["balance"]),
        icon: Icons.account_balance,
      ),
    ].toList();
  } else {
    return List();
  }
}

String formatDate(String raw) {
  return "${raw.substring(0, 4)}-${raw.substring(4,6)}-${raw.substring(6, 8)}";
}

String formatMoney(int raw) {
  if(raw == 0) return "0.00";
  else if(raw > 0)
    return "${(raw / 100).floor()}.${(raw % 100).toString().padLeft(2, "0")}";
  else
    return "-" + formatMoney(-raw);
}

String getSign(String type) {
  if(type == "充值") return "+";
  return "-";
}
