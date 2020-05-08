import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:webview_flutter/webview_flutter.dart';

import 'package:nfsee/data/database/database.dart';
import 'package:nfsee/generated/l10n.dart';
import 'package:nfsee/models.dart';
import 'package:nfsee/utilities.dart';

/// A simple widget that builds different things on different platforms.
class PlatformWidget extends StatelessWidget {
  const PlatformWidget({
    Key key,
    @required this.androidBuilder,
    @required this.iosBuilder,
  })  : assert(androidBuilder != null),
        assert(iosBuilder != null),
        super(key: key);

  final WidgetBuilder androidBuilder;
  final WidgetBuilder iosBuilder;

  @override
  Widget build(context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidBuilder(context);
      case TargetPlatform.iOS:
        return iosBuilder(context);
      default:
        assert(false, 'Unexpected platform $defaultTargetPlatform');
        return null;
    }
  }
}

class WebViewTab extends StatelessWidget {
  final String title;
  final String assetUrl;
  const WebViewTab({this.title, this.assetUrl});

  Widget _buildWebView() {
    return WebView(
      initialUrl: 'about:blank',
      onWebViewCreated: (WebViewController webViewController) async {
        String fileText = await rootBundle.loadString(assetUrl);
        webViewController.loadUrl(Uri.dataFromString(fileText,
                mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
            .toString());
      },
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: _buildWebView(),
    );
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        previousPageTitle: S.of(context).about,
      ),
      child: _buildWebView(),
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

class ReportRowItem extends StatelessWidget {
  const ReportRowItem({this.record, this.onTap});

  final DumpedRecord record;
  final void Function() onTap;

  @override
  Widget build(context) {
    var data = json.decode(record.data);
    var config = json.decode(record.config ?? DEFAULT_CONFIG);

    final type =
        getEnumFromString<CardType>(CardType.values, data["card_type"]);

    var typestr = '${type.getName(context)}';
    if (type == CardType.Unknown) {
      typestr += ' (${data["tag"]["standard"]})';
    }

    var title = typestr;
    var subtitle = "Unknown";
    if (data["detail"] != null && data["detail"]["card_number"] != null) {
      subtitle = data["detail"]["card_number"];
    }
    if (config["name"] != null && config["name"] != "") {
      if (subtitle == null)
        subtitle = typestr;
      else
        subtitle = typestr + " - " + subtitle;
      title = config["name"];
    }

    return ListTile(
      leading: Container(
        height: double.infinity,
        child: Icon(Icons.credit_card),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      onTap: this.onTap,
      trailing: Icon(CupertinoIcons.right_chevron),
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
      children: parseTransactionDetails(data, context)
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

class NDEFTile extends StatelessWidget {
  const NDEFTile({this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(context) {
    var title = "unknown";
    var subtitle = "";
    var icon = Icons.info;
    var details = <Detail>[];
    final payload = decodeHexString(data["payload"].toString());
    if (data["typeNameFormat"] == "nfcWellKnown") {
      // record text definition
      // https://nfc-forum.org/our-work/specification-releases/specifications/nfc-forum-assigned-numbers-register/
      if (data["type"] == "55") {
        // URI, ascii "U"
        title = "URI";
        icon = Icons.web;
        // first byte is URI identifer code
        var prefix = "";
        if (payload.length >= 1) {
          final identifier = payload[0];
          // TODO whole mapping
          if (identifier == 0x02) {
            prefix = "https://www.";
          } else if (identifier == 0x04) {
            prefix = "https://";
          } else if (identifier == 0x05) {
            prefix = "tel:";
          }
        }
        // the rest is uri
        var rest = utf8.decode(payload.sublist(1));
        details.add(Detail(name: "URI", value: "$prefix$rest", icon: Icons.web));
      } else if (data["type"] == "54") {
        // Text, ascii "T"
        title = "Text";
        icon = Icons.text_fields;
      }
    }
    details.add(
        Detail(name: "Raw payload", value: data["payload"], icon: Icons.web));
    if (data["identifier"] != null && data["identifier"] != '') {
      details.add(Detail(
          name: "Identifier", value: data["identifier"], icon: Icons.web));
    }

    return ExpansionTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      children: details
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
      title: Text(parseTechnologicalDetailKey(name)),
      subtitle: Text(value ?? "null"),
      leading: Icon(Icons.info),
    );
  }
}
