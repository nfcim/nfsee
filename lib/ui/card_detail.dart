import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nfsee/data/blocs/bloc.dart';
import 'package:nfsee/data/blocs/provider.dart';
import 'package:nfsee/generated/l10n.dart';

import '../models.dart';
import 'widgets.dart';
import "../utilities.dart";

class CardDetailTab extends StatefulWidget {
  const CardDetailTab({this.data, this.config, this.id, this.time});

  final dynamic data;
  final dynamic config;
  final int id;
  final DateTime time;

  @override
  CardDetailTabState createState() => CardDetailTabState(
    data: this.data,
    config: this.config,
    id: this.id,
    time: this.time,
  );
}

class CardDetailTabState extends State<CardDetailTab> {
  CardDetailTabState({ this.data, this.config, this.id, this.time });

  final dynamic data;
  final dynamic config;
  final int id;
  final DateTime time;

  String pendingName = "";

  List<bool> expanded = [false, false, false, false];

  NFSeeAppBloc get bloc => BlocProvider.provideBloc(context);

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

  void _editCardName() {
    this.pendingName = config["name"] ?? "";

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
              initialValue: config["name"] ?? "",

              onChanged: (cont) {
                this.pendingName = cont;
              },
            ),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
            onPressed: () {
              setState(() {
                if(this.pendingName == "") {
                  this.config["name"] = null;
                } else {
                  this.config["name"] = this.pendingName;
                }
                bloc.updateDumpedRecordConfig(this.id, config);
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

  Widget _buildCard() {
    return Card(
        margin: EdgeInsets.only(bottom: 20),
        elevation: 2,
        child: Column(children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [
                    Color(0xFF000000 + int.parse(config["from"], radix: 16)),
                    Color(0xFF000000 + int.parse(config["to"], radix: 16)),
                  ])),
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
                    data["detail"]["card_number"] ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.black38),
                  )
                ],
              ),
            ),
          ),
          ListTile(
            title: Text(config["name"] ?? S.of(context).unnamedCard),
            subtitle: Text(time.toString().split('.')[0]),
            trailing: IconButton(
              onPressed: _editCardName,
              icon: Icon(Icons.edit),
              tooltip: S.of(context).edit,
            ),
          ),
        ]));
  }

  Widget _buildDetail() {
    return Card(
        margin: EdgeInsets.only(bottom: 20),
        elevation: 2,
        child: Column(
            children: parseCardDetails(data["detail"], context)
                .map((d) => ListTile(
                      dense: true,
                      title: Text(d.name),
                      subtitle: Text(d.value),
                      leading: Icon(d.icon ?? Icons.info),
                    ))
                .toList()));
  }

  Widget _buildMisc() {
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
    final technologyDetailTiles = (data["tag"] as Map<String, dynamic>)
        .entries
        .where((t) => t.value != '') // filter empty values
        .map((t) => TechnologicalDetailTile(name: t.key, value: t.value))
        .toList();

    return ExpansionPanelList(
      expansionCallback: (int idx, bool original) {
        if (transferTiles == null && idx == 0) return;
        setState(() {
          this.expanded[idx] = !original;
        });
      },
      children: <ExpansionPanel>[
        ExpansionPanel(
          canTapOnHeader: true,
          headerBuilder: (ctx, isExp) {
            return ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.payment),
              ),
              title: Text(S.of(context).transactionHistory),
              subtitle: transferTiles == null
                  ? Text(S.of(context).notSupported)
                  : Text("${transferTiles.length} ${S.of(context).recordCount}"),
            );
          },
          body: Column(
            children: transferTiles ?? [],
          ),
          isExpanded: this.expanded[0],
        ),
        ExpansionPanel(
          canTapOnHeader: true,
          headerBuilder: (ctx, isExp) {
            return ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.nfc),
              ),
              title: Text(S.of(context).technologicalDetails),
              subtitle: Text(data['tag']['standard']),
            );
          },
          body: Column(
            children: technologyDetailTiles,
          ),
          isExpanded: this.expanded[1],
        ),
        ExpansionPanel(
          canTapOnHeader: true,
          headerBuilder: (ctx, isExp) {
            return ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.history),
              ),
              title: Text(S.of(context).apduLogs),
              subtitle: Text(
                  "${data["apdu_history"].length} ${S.of(context).recordCount}"),
            );
          },
          body: Container(
              child: Column(
            children: apduTiles,
          )),
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
    ));
  }

  // ===========================================================================
  // Non-shared code below because we're using different scaffolds.
  // ===========================================================================

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((data['card_type'] as CardType).getName(context)),
      ),
      extendBodyBehindAppBar: true,
      body: _buildBody(),
    );
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text((data['card_type'] as CardType).getName(context)),
        previousPageTitle: S.of(context).scanTabTitle,
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

