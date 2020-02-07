// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

class S {
  S(this.localeName);
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final String name = locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return S(localeName);
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  final String localeName;

  String get scriptTabTitle {
    return Intl.message(
      'Run Script',
      name: 'scriptTabTitle',
      desc: '',
      args: [],
    );
  }

  String get scanTabTitle {
    return Intl.message(
      'Scan',
      name: 'scanTabTitle',
      desc: '',
      args: [],
    );
  }

  String get settingsTabTitle {
    return Intl.message(
      'Settings',
      name: 'settingsTabTitle',
      desc: '',
      args: [],
    );
  }

  String get homeScreenTitle {
    return Intl.message(
      'NFSee',
      name: 'homeScreenTitle',
      desc: '',
      args: [],
    );
  }

  String get waitForCard {
    return Intl.message(
      'Waiting for card...',
      name: 'waitForCard',
      desc: '',
      args: [],
    );
  }

  String get noHistoryFound {
    return Intl.message(
      'No history found',
      name: 'noHistoryFound',
      desc: '',
      args: [],
    );
  }

  String get cardName {
    return Intl.message(
      'Card name',
      name: 'cardName',
      desc: '',
      args: [],
    );
  }

  String get lastExecutionTime {
    return Intl.message(
      'Last execution time',
      name: 'lastExecutionTime',
      desc: '',
      args: [],
    );
  }

  String get never {
    return Intl.message(
      'Never',
      name: 'never',
      desc: '',
      args: [],
    );
  }

  String get run {
    return Intl.message(
      'RUN',
      name: 'run',
      desc: '',
      args: [],
    );
  }

  String get addScript {
    return Intl.message(
      'Add script',
      name: 'addScript',
      desc: '',
      args: [],
    );
  }

  String get modifyScript {
    return Intl.message(
      'Modify script',
      name: 'modifyScript',
      desc: '',
      args: [],
    );
  }

  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  String get code {
    return Intl.message(
      'Code',
      name: 'code',
      desc: '',
      args: [],
    );
  }

  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  String get undo {
    return Intl.message(
      'UNDO',
      name: 'undo',
      desc: '',
      args: [],
    );
  }

  String get record {
    return Intl.message(
      'Record',
      name: 'record',
      desc: '',
      args: [],
    );
  }

  String get script {
    return Intl.message(
      'Script',
      name: 'script',
      desc: '',
      args: [],
    );
  }

  String get deleted {
    return Intl.message(
      'deleted',
      name: 'deleted',
      desc: '',
      args: [],
    );
  }

  String get copied {
    return Intl.message(
      'copied',
      name: 'copied',
      desc: '',
      args: [],
    );
  }

  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  String get copy {
    return Intl.message(
      'Copy',
      name: 'copy',
      desc: '',
      args: [],
    );
  }

  String get pressRun {
    return Intl.message(
      'Press RUN to get result',
      name: 'pressRun',
      desc: '',
      args: [],
    );
  }

  String get UPCredit {
    return Intl.message(
      'UnionPay Credit',
      name: 'UPCredit',
      desc: '',
      args: [],
    );
  }

  String get UPDebit {
    return Intl.message(
      'UnionPay Debit',
      name: 'UPDebit',
      desc: '',
      args: [],
    );
  }

  String get UPSecuredCredit {
    return Intl.message(
      'UnionPay Secured Credit',
      name: 'UPSecuredCredit',
      desc: '',
      args: [],
    );
  }

  String get Visa {
    return Intl.message(
      'Visa',
      name: 'Visa',
      desc: '',
      args: [],
    );
  }

  String get MC {
    return Intl.message(
      'MasterCard',
      name: 'MC',
      desc: '',
      args: [],
    );
  }

  String get AMEX {
    return Intl.message(
      'American Express',
      name: 'AMEX',
      desc: '',
      args: [],
    );
  }

  String get JCB {
    return Intl.message(
      'JCB',
      name: 'JCB',
      desc: '',
      args: [],
    );
  }

  String get Discover {
    return Intl.message(
      'Discover',
      name: 'Discover',
      desc: '',
      args: [],
    );
  }

  String get CityUnion {
    return Intl.message(
      'City Union',
      name: 'CityUnion',
      desc: '',
      args: [],
    );
  }

  String get TUnion {
    return Intl.message(
      'T Union',
      name: 'TUnion',
      desc: '',
      args: [],
    );
  }

  String get BMAC {
    return Intl.message(
      'Beijing Yikatong',
      name: 'BMAC',
      desc: '',
      args: [],
    );
  }

  String get LingnanPass {
    return Intl.message(
      'Lingnan Pass',
      name: 'LingnanPass',
      desc: '',
      args: [],
    );
  }

  String get ShenzhenTong {
    return Intl.message(
      'Shenzhen Tong',
      name: 'ShenzhenTong',
      desc: '',
      args: [],
    );
  }

  String get WuhanTong {
    return Intl.message(
      'Wuhan Tong',
      name: 'WuhanTong',
      desc: '',
      args: [],
    );
  }

  String get TMoney {
    return Intl.message(
      'T-Money',
      name: 'TMoney',
      desc: '',
      args: [],
    );
  }

  String get Octopus {
    return Intl.message(
      'Octopus',
      name: 'Octopus',
      desc: '',
      args: [],
    );
  }

  String get Tsinghua {
    return Intl.message(
      'Tsinghua University Campus Card',
      name: 'Tsinghua',
      desc: '',
      args: [],
    );
  }

  String get Unknown {
    return Intl.message(
      'Unknown',
      name: 'Unknown',
      desc: '',
      args: [],
    );
  }

  String get Authorization {
    return Intl.message(
      'Authorization',
      name: 'Authorization',
      desc: '',
      args: [],
    );
  }

  String get BalanceInquiry {
    return Intl.message(
      'Balance Inquiry',
      name: 'BalanceInquiry',
      desc: '',
      args: [],
    );
  }

  String get Cash {
    return Intl.message(
      'Cash',
      name: 'Cash',
      desc: '',
      args: [],
    );
  }

  String get Void {
    return Intl.message(
      'Void',
      name: 'Void',
      desc: '',
      args: [],
    );
  }

  String get MobileTopup {
    return Intl.message(
      'Mobile Topup',
      name: 'MobileTopup',
      desc: '',
      args: [],
    );
  }

  String get Load {
    return Intl.message(
      'Load',
      name: 'Load',
      desc: '',
      args: [],
    );
  }

  String get Purchase {
    return Intl.message(
      'Purchase',
      name: 'Purchase',
      desc: '',
      args: [],
    );
  }

  String get CompoundPurchase {
    return Intl.message(
      'Compound Purchase',
      name: 'CompoundPurchase',
      desc: '',
      args: [],
    );
  }

  String get unnamedCard {
    return Intl.message(
      'Unnamed Card',
      name: 'unnamedCard',
      desc: '',
      args: [],
    );
  }

  String get transactionHistory {
    return Intl.message(
      'Transaction History',
      name: 'transactionHistory',
      desc: '',
      args: [],
    );
  }

  String get recordCount {
    return Intl.message(
      'record(s)',
      name: 'recordCount',
      desc: '',
      args: [],
    );
  }

  String get technologicalDetails {
    return Intl.message(
      'Technological Details',
      name: 'technologicalDetails',
      desc: '',
      args: [],
    );
  }

  String get apduLogs {
    return Intl.message(
      'APDU Logs',
      name: 'apduLogs',
      desc: '',
      args: [],
    );
  }

  String get notSupported {
    return Intl.message(
      'Not supported',
      name: 'notSupported',
      desc: '',
      args: [],
    );
  }

  String get cardNumber {
    return Intl.message(
      'Card Number',
      name: 'cardNumber',
      desc: '',
      args: [],
    );
  }

  String get internalNumber {
    return Intl.message(
      'Internal Number',
      name: 'internalNumber',
      desc: '',
      args: [],
    );
  }

  String get holderName {
    return Intl.message(
      'Holder Name',
      name: 'holderName',
      desc: '',
      args: [],
    );
  }

  String get balance {
    return Intl.message(
      'Balance',
      name: 'balance',
      desc: '',
      args: [],
    );
  }

  String get provinceCode {
    return Intl.message(
      'Province Code',
      name: 'provinceCode',
      desc: '',
      args: [],
    );
  }

  String get tuType {
    return Intl.message(
      'TUnion Card Type',
      name: 'tuType',
      desc: '',
      args: [],
    );
  }

  String get city {
    return Intl.message(
      'City',
      name: 'city',
      desc: '',
      args: [],
    );
  }

  String get issueDate {
    return Intl.message(
      'Issue Date',
      name: 'issueDate',
      desc: '',
      args: [],
    );
  }

  String get expiryDate {
    return Intl.message(
      'Expiry Date',
      name: 'expiryDate',
      desc: '',
      args: [],
    );
  }

  String get displayExpiryDate {
    return Intl.message(
      'Expiry Date on Card',
      name: 'displayExpiryDate',
      desc: '',
      args: [],
    );
  }

  String get validUntil {
    return Intl.message(
      'Valid Until',
      name: 'validUntil',
      desc: '',
      args: [],
    );
  }

  String get ATC {
    return Intl.message(
      'Application Transaction Counter',
      name: 'ATC',
      desc: '',
      args: [],
    );
  }

  String get pinRetry {
    return Intl.message(
      'Remaining PIN Retry Counter',
      name: 'pinRetry',
      desc: '',
      args: [],
    );
  }

  String get rawData {
    return Intl.message(
      ' Raw data',
      name: 'rawData',
      desc: '',
      args: [],
    );
  }

  String get transactionNumber {
    return Intl.message(
      'Transaction Number',
      name: 'transactionNumber',
      desc: '',
      args: [],
    );
  }

  String get terminal {
    return Intl.message(
      'Terminal',
      name: 'terminal',
      desc: '',
      args: [],
    );
  }

  String get type {
    return Intl.message(
      'Type',
      name: 'type',
      desc: '',
      args: [],
    );
  }

  String get countryCode {
    return Intl.message(
      'Country Code',
      name: 'countryCode',
      desc: '',
      args: [],
    );
  }

  String get currency {
    return Intl.message(
      'Currency',
      name: 'currency',
      desc: '',
      args: [],
    );
  }

  String get amountOther {
    return Intl.message(
      'Amount, Other',
      name: 'amountOther',
      desc: '',
      args: [],
    );
  }

  String get subwayExit {
    return Intl.message(
      'Subway Exit',
      name: 'subwayExit',
      desc: '',
      args: [],
    );
  }

  String get Line1 {
    return Intl.message(
      'Line 1',
      name: 'Line1',
      desc: '',
      args: [],
    );
  }

  String get Line2 {
    return Intl.message(
      'Line 2',
      name: 'Line2',
      desc: '',
      args: [],
    );
  }

  String get Line4 {
    return Intl.message(
      'Line 4',
      name: 'Line4',
      desc: '',
      args: [],
    );
  }

  String get Line5 {
    return Intl.message(
      'Line 5',
      name: 'Line5',
      desc: '',
      args: [],
    );
  }

  String get Line6 {
    return Intl.message(
      'Line 6',
      name: 'Line6',
      desc: '',
      args: [],
    );
  }

  String get Line7 {
    return Intl.message(
      'Line 7',
      name: 'Line7',
      desc: '',
      args: [],
    );
  }

  String get Line8 {
    return Intl.message(
      'Line 8',
      name: 'Line8',
      desc: '',
      args: [],
    );
  }

  String get Line9 {
    return Intl.message(
      'Line 9',
      name: 'Line9',
      desc: '',
      args: [],
    );
  }

  String get Line10 {
    return Intl.message(
      'Line 10',
      name: 'Line10',
      desc: '',
      args: [],
    );
  }

  String get Line13 {
    return Intl.message(
      'Line 13',
      name: 'Line13',
      desc: '',
      args: [],
    );
  }

  String get Line14 {
    return Intl.message(
      'Line 14',
      name: 'Line14',
      desc: '',
      args: [],
    );
  }

  String get Line15 {
    return Intl.message(
      'Line 15',
      name: 'Line15',
      desc: '',
      args: [],
    );
  }

  String get Line16 {
    return Intl.message(
      'Line 16',
      name: 'Line16',
      desc: '',
      args: [],
    );
  }

  String get Xijiao {
    return Intl.message(
      'Xijiao Line',
      name: 'Xijiao',
      desc: '',
      args: [],
    );
  }

  String get DaxingAirport {
    return Intl.message(
      'Daxing Airport Line',
      name: 'DaxingAirport',
      desc: '',
      args: [],
    );
  }

  String get Daxing {
    return Intl.message(
      'Daxing Line',
      name: 'Daxing',
      desc: '',
      args: [],
    );
  }

  String get Changping {
    return Intl.message(
      'Changping Line',
      name: 'Changping',
      desc: '',
      args: [],
    );
  }

  String get Fangshan {
    return Intl.message(
      'Fangshan Line',
      name: 'Fangshan',
      desc: '',
      args: [],
    );
  }

  String get Yizhuang {
    return Intl.message(
      'Yizhuang Line',
      name: 'Yizhuang',
      desc: '',
      args: [],
    );
  }

  String get Batong {
    return Intl.message(
      'Batong Line',
      name: 'Batong',
      desc: '',
      args: [],
    );
  }

  String get CapitalAirport {
    return Intl.message(
      'Capital Airport Line',
      name: 'CapitalAirport',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale('en', ''), Locale('zh', ''),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (Locale supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}