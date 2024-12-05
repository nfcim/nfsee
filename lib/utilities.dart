import 'dart:convert';
import 'dart:async';
import 'dart:developer';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nfsee/models.dart';
import 'package:webview_flutter/webview_flutter.dart';

String formatTransactionDate(String raw) {
  return "${raw.substring(0, 4)}-${raw.substring(4, 6)}-${raw.substring(6, 8)}";
}

String formatTransactionTime(String raw) {
  return "${raw.substring(0, 2)}:${raw.substring(2, 4)}:${raw.substring(4, 6)}";
}

String formatTransactionBalance(int raw) {
  if (raw == 0) {
    return "0.00";
  } else if (raw > 0) {
    return "${(raw / 100).floor()}.${(raw % 100).toString().padLeft(2, "0")}";
  } else {
    return "-${formatTransactionBalance(-raw)}";
  }
}

T? getEnumFromString<T>(Iterable<T> values, String value) {
  return values
      .firstWhereOrNull((type) => type.toString().split(".").last == value);
}

String enumToString<T>(T value) {
  return value.toString().split('.').last;
}

List<int> decodeHexString(String hex) {
  var result = <int>[];
  for (int i = 0; i < hex.length; i += 2) {
    result.add(int.parse(hex.substring(i, i + 2), radix: 16));
  }
  return result;
}

extension PlatformExceptionExtension on PlatformException {
  Map<String, dynamic> asMap() {
    return {"code": code, "message": message, "details": details.toString()};
  }

  String toJsonString() => jsonEncode(asMap());

  String toDetailString() {
    var result = '$code $message';
    if (details != null) {
      result += ' (${details.toString()})';
    }
    return result;
  }
}

enum WebViewOwner { Main, Script }

WebViewOwner webviewOwner = WebViewOwner.Main;

// Actually this should be an ADT, but Dart doesn't have that (yet)
class WebViewEvent {
  final String? message;
  final bool reload;

  WebViewEvent({this.reload = false, this.message});
}

class WebViewManager {
  final Map<WebViewOwner, StreamController<WebViewEvent>> _streams = {
    for (final owner in WebViewOwner.values) owner: StreamController.broadcast()
  };
  WebViewController? _cont;

  late JavascriptChannel channel =
      JavascriptChannel(name: "nfsee", onMessageReceived: _dispatch);

  _dispatch(JavascriptMessage msg) {
    log("[Webview] Incoming msg ${msg.message}");
    final ev = WebViewEvent(message: msg.message);
    _streams[webviewOwner]?.add(ev);
  }

  onWebviewInit(WebViewController cont) {
    log("[Webview] Init");
    _cont = cont;
    // Fire and forget
    reload();
  }

  onWebviewPageLoad(String url) {
    for (final stream in _streams.values) {
      stream.add(WebViewEvent(reload: true));
    }
  }

  Future<void> reload() async {
    if (_cont == null) return;
    WebViewController cont = _cont!;
    await cont.loadHtmlString("<!DOCTYPE html>");
    await run(await rootBundle.loadString('assets/ber-tlv.js'));
    await run(await rootBundle.loadString('assets/crypto-js.js'));
    await run(await rootBundle.loadString('assets/crypto.js'));
    await run(await rootBundle.loadString('assets/reader.js'));
    await run(await rootBundle.loadString('assets/felica.js'));
    await run(await rootBundle.loadString('assets/codes.js'));
  }

  Future<void> run(String js) async {
    if (_cont == null) throw "Not initialized";
    log("[Webview] Run script $js");
    // https://stackoverflow.com/questions/42887438/wkwebview-evaluatejavascript-returns-unsupported-type-error
    await _cont!.runJavascript("$js;\n(function() {})();");
  }

  Stream<WebViewEvent> stream(WebViewOwner owner) {
    return _streams[owner]!.stream;
  }
}

List<Detail> parseTransactionDetails(
    Map<String, dynamic> data, BuildContext context) {
  // make a copy
  var d = {}..addAll(data);
  d.remove('amount');
  d.remove('date');
  d.remove('time');

  var details = <Detail>[];

  void addDetail(String fieldName, String parsedName,
      [IconData? icon, transformer]) {
    _addDetail(d, details, fieldName, parsedName, icon, transformer);
  }

  addDetail('number', S(context).transactionNumber, Icons.bookmark);
  addDetail('terminal', S(context).terminal, Icons.place);
  addDetail(
      'subway_exit',
      S(context).subwayExit,
      Icons.subway,
      (s) => (getEnumFromString<BeijingSubway>(BeijingSubway.values, s))!
          .getName(context));
  addDetail('type', S(context).type);
  addDetail('country_code', S(context).countryCode, Icons.map);
  addDetail('currency', S(context).currency, Icons.local_atm);
  addDetail('amount_other', S(context).amountOther, Icons.attach_money);

  // all remaining data, clone to avoid concurrent modificationL
  final remain = {}..addAll(data);
  remain.forEach(
      (k, _) => addDetail(k, '${S(context).rawData}: $k', Icons.error));

  return details;
}

List<Detail> parseCardDetails(Map<String, dynamic> data, BuildContext context) {
  // make a copy and remove transactions & ndef, the remaining fields are all details
  var d = {}..addAll(data);
  d.remove('transactions');
  d.remove('ndef');
  d.remove('data');

  var details = <Detail>[];

  void addDetail(String fieldName, String parsedName,
      [IconData? icon, transformer]) {
    _addDetail(d, details, fieldName, parsedName, icon, transformer);
  }

  // all cards
  addDetail('card_number', S(context).cardNumber, Icons.credit_card);
  // THU
  addDetail('internal_number', S(context).internalNumber, Icons.credit_card);
  // China ID
  addDetail('ic_serial', S(context).icSerial, Icons.sim_card);
  // China ID
  addDetail('mgmt_number', S(context).mgmtNumber, Icons.credit_card);
  // PBOC
  addDetail('name', S(context).holderName, Icons.person);
  // PBOC
  addDetail('balance', S(context).balance, Icons.account_balance,
      formatTransactionBalance);
  // T Union
  addDetail('tu_type', S(context).tuType, Icons.person);
  // T Union
  addDetail('province', S(context).province, Icons.home);
  // City Union / T Union
  addDetail('city', S(context).city, Icons.home);
  // City Union / T Union
  addDetail('issue_date', S(context).issueDate, Icons.calendar_today,
      formatTransactionDate);
  // PBOC
  addDetail('expiry_date', S(context).expiryDate, Icons.calendar_today,
      formatTransactionDate);
  // THU
  addDetail('display_expiry_date', S(context).displayExpiryDate,
      Icons.calendar_today, formatTransactionDate);
  // PPSE
  addDetail('expiration', S(context).validUntil, Icons.calendar_today);
  // PBOC
  addDetail('purchase_atc', '${S(context).atc} (${S(context).purchase})',
      Icons.exposure_neg_1);
  // PBOC
  addDetail('load_atc', '${S(context).atc} (${S(context).strLoad})',
      Icons.exposure_plus_1);
  // PPSE
  addDetail('atc', S(context).atc, Icons.exposure_plus_1);
  // PPSE
  addDetail('pin_retry', S(context).pinRetry, Icons.lock);
  // Mifare
  addDetail('mifare_vendor', S(context).mifareVendor, Icons.copyright);
  addDetail(
      'mifare_product_type', S(context).mifareProductType, Icons.looks_one);
  addDetail('mifare_product_subtype', S(context).mifareProductSubtype,
      Icons.looks_two);
  addDetail('mifare_product_version', S(context).mifareProductVersion,
      Icons.text_fields);
  addDetail('mifare_product_name', S(context).mifareProductName,
      Icons.branding_watermark);
  addDetail(
      'mifare_storage_size', S(context).mifareStorageSize, Icons.format_size);
  addDetail('mifare_production_date', S(context).mifareProductionDate,
      Icons.date_range);
  // all remaining data, clone to avoid concurrent modification
  final remain = {}..addAll(data);
  remain.forEach(
      (k, _) => addDetail(k, '${S(context).rawData}: $k', Icons.error));

  return details;
}

void _addDetail(Map<dynamic, dynamic> data, List<Detail> details,
    String fieldName, String parsedName,
    [IconData? icon, transformer]) {
  // optional parameters
  icon ??= Icons.list;
  transformer ??= (s) => "$s";
  // check existence and add to list
  if (data[fieldName] != null) {
    details.add(Detail(
        name: parsedName, value: transformer(data[fieldName]), icon: icon));
    data.remove(fieldName);
  }
}

String? parseTechnologicalDetailKey(String? key) {
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
    case 'ndefAvailable':
      return 'NDEF Available';
    case 'ndefCanMakeReadOnly':
      return 'NDEF Can Make Read Only';
    case 'ndefWritable':
      return 'NDEF Writable';
    case 'ndefCapacity':
      return 'NDEF Capacity';
    case 'ndefType':
      return 'NDEF Tag Type';
    default:
      return key;
  }
}

AppLocalizations S(BuildContext context) {
  return AppLocalizations.of(context)!;
}
