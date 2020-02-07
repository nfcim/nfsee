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
      case CardType.ChinaResidentIDGen2:
        return 'china_id';
      default:
        return '';
    }
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
              onPressed: () {
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
                        child: Text(S.of(context).ok),
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
                        child: Text(S.of(context).cancel),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  ),
                );
              },
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
            children: _parseCardDetails(data["detail"], context)
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

class APDUTile extends StatelessWidget {
  const APDUTile({this.data, this.index});

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
            Text("#${this.index} - TX",
                style: Theme.of(context).textTheme.caption),
            this.hexView(data["tx"], context, Colors.green),
            SizedBox(height: 16),
            Text("#${this.index} - RX",
                style: Theme.of(context).textTheme.caption),
            this.hexView(data["rx"], context, Colors.orange),
          ]),
    );
  }

  Widget hexView(String str, BuildContext context, Color color) {
    var segs = List<Widget>();

    for (int i = 0; i < str.length; i += 2) {
      final slice = str.substring(i, i + 2).toUpperCase();
      final seg = Container(
          width: 20,
          margin: EdgeInsets.only(right: 5),
          child: Text(
            slice,
            style: Theme.of(context).textTheme.body1.apply(color: color),
          ));
      segs.add(seg);
    }

    return Wrap(children: segs);
  }
}

class TransferTile extends StatelessWidget {
  const TransferTile({this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(context) {
    final typePBOC = getEnumFromString<PBOCTransactionType>(
        PBOCTransactionType.values, data["type"]);
    final typePPSE =
        getEnumFromString<ProcessingCode>(ProcessingCode.values, data["type"]);

    return ExpansionTile(
      leading: Icon(typePBOC == PBOCTransactionType.Load
          ? Icons.attach_money
          : Icons.money_off),
      title: Text(
          "${formatTransactionBalance(data["amount"])} - ${typePBOC == null ? typePPSE.getName(context) : typePBOC.getName(context)}"),
      subtitle: Text(
          "${formatTransactionDate(data["date"])} ${formatTransactionTime(data["time"])}"),
      children: _parseTransactionDetails(data, context)
          .map((d) => ListTile(
                dense: true,
                title: Text(d.name),
                subtitle: Text(d.value),
                leading: Icon(d.icon ?? Icons.info),
              ))
          .toList(),
    );
  }
}

class TechnologicalDetailTile extends StatelessWidget {
  const TechnologicalDetailTile({this.name, this.value});

  final String name;
  final String value;

  @override
  Widget build(context) {
    return ListTile(
      dense: true,
      title: Text(_parseTechnologicalDetailKey(name)),
      subtitle: Text(value ?? "null"),
      leading: Icon(Icons.info),
    );
  }
}

class Detail {
  const Detail({this.name, this.value, this.icon});

  final String name;
  final String value;
  final IconData icon;
}

void _addDetail(Map<dynamic, dynamic> data, List<Detail> details,
    String fieldName, String parsedName,
    [IconData icon, transformer]) {
  // optional parameters
  if (icon == null) icon = Icons.list;
  if (transformer == null) {
    transformer = (s) => "$s";
  }
  // check existence and add to list
  if (data[fieldName] != null) {
    details.add(Detail(
        name: parsedName, value: transformer(data[fieldName]), icon: icon));
    data.remove(fieldName);
  }
}

// TODO: i18n
List<Detail> _parseCardDetails(
    Map<String, dynamic> _data, BuildContext context) {
  // make a copy and remove transactions, the remaining fields are all details
  var data = {}..addAll(_data);
  data.remove('transactions');

  var details = <Detail>[];

  void addDetail(String fieldName, String parsedName,
      [IconData icon, transformer]) {
    _addDetail(data, details, fieldName, parsedName, icon, transformer);
  }

  // all cards
  addDetail('card_number', S.of(context).cardNumber, Icons.credit_card);
  // THU
  addDetail('internal_number', S.of(context).internalNumber, Icons.credit_card);
  // China ID
  addDetail('ic_serial', S.of(context).icSerial, Icons.sim_card);
  // China ID
  addDetail('mgmt_number', S.of(context).mgmtNumber, Icons.credit_card);
  // PBOC
  addDetail('name', S.of(context).holderName, Icons.person);
  // PBOC
  addDetail(
      'balance', S.of(context).balance, Icons.account_balance, formatTransactionBalance);
  // T Union
  addDetail('province_code', S.of(context).provinceCode, Icons.home);
  // T Union
  addDetail('tu_type', S.of(context).tuType, Icons.person);
  // City Union / TUnion
  addDetail('city', S.of(context).city, Icons.home);
  // City Union
  addDetail(
      'issue_date', S.of(context).issueDate, Icons.calendar_today, formatTransactionDate);
  // PBOC
  addDetail('expiry_date', S.of(context).expiryDate, Icons.calendar_today,
      formatTransactionDate);
  // THU
  addDetail('display_expiry_date', S.of(context).displayExpiryDate, Icons.calendar_today,
      formatTransactionDate);
  // PPSE
  addDetail('expiration', S.of(context).validUntil, Icons.calendar_today);
  // PBOC
  addDetail('purchase_atc', '${S.of(context).ATC} (${S.of(context).Purchase})',
      Icons.exposure_neg_1);
  // PBOC
  addDetail('load_atc', '${S.of(context).ATC} (${S.of(context).Load})',
      Icons.exposure_plus_1);
  // PPSE
  addDetail('atc', S.of(context).ATC, Icons.exposure_plus_1);
  // PPSE
  addDetail('pin_retry', S.of(context).pinRetry, Icons.lock);
  // all remaining data, clone to avoid concurrent modification
  final remain = {}..addAll(data);
  remain.forEach((k, _) => addDetail(k, '${S.of(context).rawData}: $k', Icons.error));

  return details;
}

List<Detail> _parseTransactionDetails(
    Map<String, dynamic> _data, BuildContext context) {
  // make a copy
  var data = {}..addAll(_data);
  data.remove('amount');
  data.remove('date');
  data.remove('time');

  var details = <Detail>[];

  void addDetail(String fieldName, String parsedName,
      [IconData icon, transformer]) {
    _addDetail(data, details, fieldName, parsedName, icon, transformer);
  }

  addDetail('number', S.of(context).transactionNumber, Icons.bookmark);
  addDetail('terminal', S.of(context).terminal, Icons.place);
  addDetail(
      'subway_exit',
      S.of(context).subwayExit,
      Icons.subway,
      (s) => (getEnumFromString<BeijingSubway>(BeijingSubway.values, s))
          .getName(context));
  addDetail('type', S.of(context).type);
  addDetail('country_code', S.of(context).countryCode, Icons.map);
  addDetail('currency', S.of(context).currency, Icons.local_atm);
  addDetail('amount_other', S.of(context).amountOther, Icons.attach_money);

  // all remaining data, clone to avoid concurrent modificationL
  final remain = {}..addAll(data);
  remain.forEach((k, _) => addDetail(k, '${S.of(context).rawData}: $k', Icons.error));

  return details;
}

String _parseTechnologicalDetailKey(String key) {
  switch (key) {
    case 'standard':
      return 'Standard';
    case 'protocolInfo':
      return 'Protocol Infomation';
    case 'id':
      return 'Unique ID';
    case 'dsfId':
      return 'DSF ID';
    case 'systemCode':
      return 'System Code';
    case 'applicationData':
      return 'Application Data';
    case 'type':
      return 'Type';
    case 'sak':
      return 'SAK';
    case 'hiLayerResponse':
      return 'Higher Layer Response';
    case 'historicalBytes':
      return 'Historical Bytes';
    case 'atqa':
      return 'ATQA';
    case 'manufacturer':
      return 'Manufacturer';
    default:
      return key;
  }
}
