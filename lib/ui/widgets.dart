import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart' as ndef;
import 'package:nfsee/data/database/database.dart';
import 'package:nfsee/generated/l10n.dart';
import 'package:nfsee/models.dart';
import 'package:nfsee/utilities.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// A simple widget that builds different things on different platforms.
class PlatformWidget extends StatelessWidget {
  const PlatformWidget({
    Key? key,
    required this.androidBuilder,
    required this.iosBuilder,
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
        return null as Widget;
    }
  }
}

class WebViewTab extends StatelessWidget {
  final String? title;
  final String? assetUrl;

  const WebViewTab({this.title, this.assetUrl});

  Widget _buildWebView() {
    return WebView(
      initialUrl: 'about:blank',
      onWebViewCreated: (WebViewController webViewController) async {
        String fileText = await rootBundle.loadString(assetUrl!);
        webViewController.loadUrl(Uri.dataFromString(fileText,
                mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
            .toString());
      },
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title!),
      ),
      body: _buildWebView(),
    );
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(title!),
          previousPageTitle: S.of(context)!.about,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: _buildWebView(),
        ));
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

  final DumpedRecord? record;
  final void Function()? onTap;

  @override
  Widget build(context) {
    var data = json.decode(record!.data);
    var config = json.decode(record!.config ?? DEFAULT_CONFIG);

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
  final int? index;

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
            Text("#${this.index! + 1} - TX",
                style: Theme.of(context).textTheme.caption),
            this.hexView(data["tx"], context, Colors.green),
            SizedBox(height: 16),
            Text("#${this.index! + 1} - RX",
                style: Theme.of(context).textTheme.caption),
            this.hexView(data["rx"], context, Colors.orange),
          ]),
    );
  }

  Widget hexView(String str, BuildContext context, Color color) {
    var segs = List<Widget>.empty(growable: true);

    for (int i = 0; i < str.length; i += 2) {
      final slice = str.substring(i, i + 2).toUpperCase();
      final seg = Container(
          width: 22,
          margin: EdgeInsets.only(right: 5),
          child: Text(
            slice,
            style: Theme.of(context).textTheme.bodyText2!.apply(color: color),
          ));
      segs.add(seg);
    }

    return Wrap(children: segs);
  }
}

class TransferTile extends StatelessWidget {
  const TransferTile({this.data});

  final Map<String, dynamic>? data;

  @override
  Widget build(context) {
    final typePBOC = getEnumFromString<PBOCTransactionType>(
        PBOCTransactionType.values, data!["type"]);
    final typePPSE =
        getEnumFromString<ProcessingCode>(ProcessingCode.values, data!["type"]);

    var subtitle;
    if (data!["date"] != null && data!["time"] != null) {
      subtitle =
          "${formatTransactionDate(data!["date"])} ${formatTransactionTime(data!["time"])}";
    } else {
      subtitle = "";
    }

    return ExpansionTile(
      leading: Icon(typePBOC == PBOCTransactionType.Load
          ? Icons.attach_money
          : Icons.money_off),
      title: Text(
          "${formatTransactionBalance(data!["amount"])} - ${typePBOC == null ? typePPSE.getName(context) : typePBOC.getName(context)}"),
      subtitle: Text(subtitle),
      children: parseTransactionDetails(data!, context)
          .map((d) => ListTile(
                dense: true,
                title: Text(d.name!),
                subtitle: Text(d.value!),
                leading: Icon(d.icon ?? Icons.info),
              ))
          .toList(),
    );
  }
}

class NDEFTile extends StatelessWidget {
  NDEFTile({this.raw}) : data = NDEFRecordConvert.fromRaw(raw!);

  final NDEFRawRecord? raw;
  final ndef.NDEFRecord data;

  @override
  Widget build(context) {
    var title = S.of(context)!.Unknown;
    var subtitle = "";
    var icon = Icons.info;
    var details = <Detail>[];

    // general info
    // add identifier when available
    if (raw!.identifier != null && raw!.identifier != '') {
      details.add(Detail(
          name: S.of(context)!.identifier,
          value: raw!.identifier,
          icon: Icons.title));
    }

    // type & TNF
    details.add(Detail(
        name: "Type Name Format",
        value: enumToString(raw!.typeNameFormat),
        icon: Icons.sort_by_alpha));
    details.add(Detail(
        name: S.of(context)!.type,
        value: data.decodedType,
        icon: Icons.sort_by_alpha));

    // payload (raw + decoded)
    details.add(Detail(
        name: S.of(context)!.payload, value: raw!.payload, icon: Icons.sd_card));
    try {
      final payloadUtf8 = utf8.decode(decodeHexString(raw!.payload));
      details.add(Detail(
          name: S.of(context)!.payload + " (UTF-8)",
          value: payloadUtf8,
          icon: Icons.text_fields));
    } on FormatException catch (_) {
      // silently ignore
    }

    if (data is ndef.UriRecord) {
      var r = data as ndef.UriRecord;
      icon = Icons.web;
      title = "URI";
      subtitle = r.uriString!;
      details.add(Detail(
          name: S.of(context)!.wellKnownPrefix,
          value: r.prefix,
          icon: Icons.tab));
    } else if (data is ndef.TextRecord) {
      var r = data as ndef.TextRecord;
      icon = Icons.text_fields;
      title = S.of(context)!.text;
      subtitle = r.text!;
      details.add(Detail(
          name: S.of(context)!.encoding,
          value: enumToString(r.encoding),
          icon: Icons.code));
      details.add(Detail(
          name: S.of(context)!.languageCode,
          value: r.language,
          icon: Icons.language));
    } else if (data is ndef.MimeRecord) {
      title = S.of(context)!.mimeMediaRecord;
      subtitle = data.decodedType!;
    }

    return ExpansionTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      children: details
          .map((d) => ListTile(
                dense: true,
                title: Text(d.name!),
                subtitle: Text(d.value!),
                leading: Icon(d.icon ?? Icons.info),
              ))
          .toList(),
    );
  }
}

class TechnologicalDetailTile extends StatelessWidget {
  const TechnologicalDetailTile({this.name, this.value});

  final String? name;
  final String? value;

  @override
  Widget build(context) {
    return ListTile(
      dense: true,
      title: Text(parseTechnologicalDetailKey(name)!),
      subtitle: Text(value ?? "null"),
      leading: Icon(Icons.info),
    );
  }
}

class DataTile extends StatelessWidget {
  const DataTile({this.data});

  final String? data;

  @override
  Widget build(context) {
    var group = 16;
    var view = List<Widget>.empty(growable: true);
    for (int i = 0; i < data!.length; i += group) {
      var segs = List<Widget>.empty(growable: true);

      // addr
      final seg = Container(
          width: 50,
          margin: EdgeInsets.only(right: 5),
          child: Text(
            "${(i >> 1).toRadixString(16).padLeft(4, '0')}:",
            style: Theme.of(context)
                .textTheme
                .bodyText2!
                .apply(color: Colors.green)
                .apply(fontFamily: "Courier"), // monospaced
          ));
      segs.add(seg);

      // data
      var dump = "";
      for (int j = i; j < i + group; j += 2) {
        var slice = "";
        if (j < data!.length) {
          slice = data!.substring(j, j + 2).toUpperCase();
        }

        final seg = Container(
            width: 20,
            margin: EdgeInsets.only(right: 5),
            child: Text(
              slice,
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .apply(color: Colors.green)
                  .apply(fontFamily: "Courier"), // monospaced
            ));
        segs.add(seg);

        if (slice != "") {
          final ascii = int.parse(slice, radix: 16);
          if (0x20 <= ascii && ascii <= 0x7e) {
            // printable
            dump += String.fromCharCode(ascii);
          } else {
            dump += ".";
          }
        }
      }

      final segDump = Container(
          width: 70,
          margin: EdgeInsets.only(right: 5),
          child: Text(
            dump,
            style: Theme.of(context)
                .textTheme
                .bodyText2!
                .apply(color: Colors.green)
                .apply(fontFamily: "Courier"), // monospaced
          ));
      segs.add(segDump);

      view.add(Wrap(children: segs));
    }

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
          children: view),
    );
  }
}
