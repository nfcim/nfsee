import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'generated/l10n.dart';
import 'models.dart';

String formatTransactionDate(String raw) {
  return "${raw.substring(0, 4)}-${raw.substring(4, 6)}-${raw.substring(6, 8)}";
}

String formatTransactionTime(String raw) {
  return "${raw.substring(0, 2)}:${raw.substring(2, 4)}:${raw.substring(4, 6)}";
}

String formatTransactionBalance(int raw) {
  if (raw == 0)
    return "0.00";
  else if (raw > 0)
    return "${(raw / 100).floor()}.${(raw % 100).toString().padLeft(2, "0")}";
  else
    return "-" + formatTransactionBalance(-raw);
}

T getEnumFromString<T>(Iterable<T> values, String value) {
  return values.firstWhere((type) => type.toString().split(".").last == value,
      orElse: () => null);
}

extension PlatformExceptionExtension on PlatformException {
  Map<String, dynamic> asMap() {
    return {
      "code": this.code,
      "message": this.message,
      "details": this.details.toString()
    };
  }

  String toJsonString() => jsonEncode(this.asMap());

  String toDetailString() {
    var result = '${this.code} ${this.message}';
    if (this.details != null) {
       result += ' (${this.details.toString()})';
    }
    return result;
  }
}


enum WebViewOwner { Main, Script }

WebViewOwner webviewOwner = WebViewOwner.Main;

List<Detail> parseTransactionDetails(
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
  remain.forEach(
      (k, _) => addDetail(k, '${S.of(context).rawData}: $k', Icons.error));

  return details;
}

List<Detail> parseCardDetails(
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
  addDetail('balance', S.of(context).balance, Icons.account_balance,
      formatTransactionBalance);
  // T Union
  addDetail('province_code', S.of(context).provinceCode, Icons.home);
  // T Union
  addDetail('tu_type', S.of(context).tuType, Icons.person);
  // City Union / TUnion
  addDetail('city', S.of(context).city, Icons.home);
  // City Union
  addDetail('issue_date', S.of(context).issueDate, Icons.calendar_today,
      formatTransactionDate);
  // PBOC
  addDetail('expiry_date', S.of(context).expiryDate, Icons.calendar_today,
      formatTransactionDate);
  // THU
  addDetail('display_expiry_date', S.of(context).displayExpiryDate,
      Icons.calendar_today, formatTransactionDate);
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
  remain.forEach(
      (k, _) => addDetail(k, '${S.of(context).rawData}: $k', Icons.error));

  return details;
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

String parseTechnologicalDetailKey(String key) {
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
