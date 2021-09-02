import 'dart:convert';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nfsee/models.dart';

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

T? getEnumFromString<T>(Iterable<T> values, String value) {
  return values.firstWhereOrNull((type) => type.toString().split(".").last == value);
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
      [IconData? icon, transformer]) {
    _addDetail(data, details, fieldName, parsedName, icon, transformer);
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

List<Detail> parseCardDetails(
    Map<String, dynamic> _data, BuildContext context) {
  // make a copy and remove transactions & ndef, the remaining fields are all details
  var data = {}..addAll(_data);
  data.remove('transactions');
  data.remove('ndef');
  data.remove('data');

  var details = <Detail>[];

  void addDetail(String fieldName, String parsedName,
      [IconData? icon, transformer]) {
    _addDetail(data, details, fieldName, parsedName, icon, transformer);
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
  addDetail('province_code', S(context).provinceCode, Icons.home);
  // T Union
  addDetail('tu_type', S(context).tuType, Icons.person);
  // City Union / TUnion
  addDetail('city', S(context).city, Icons.home);
  // City Union
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
  addDetail('mifare_storage_size', S(context).mifareStorageSize,
      Icons.format_size);
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
