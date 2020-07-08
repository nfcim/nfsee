// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Run Script`
  String get scriptTabTitle {
    return Intl.message(
      'Run Script',
      name: 'scriptTabTitle',
      desc: '',
      args: [],
    );
  }

  /// `Scan`
  String get scanTabTitle {
    return Intl.message(
      'Scan',
      name: 'scanTabTitle',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settingsTabTitle {
    return Intl.message(
      'Settings',
      name: 'settingsTabTitle',
      desc: '',
      args: [],
    );
  }

  /// `NFSee`
  String get homeScreenTitle {
    return Intl.message(
      'NFSee',
      name: 'homeScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `Hold your phone near the NFC card / tag...`
  String get waitForCard {
    return Intl.message(
      'Hold your phone near the NFC card / tag...',
      name: 'waitForCard',
      desc: '',
      args: [],
    );
  }

  /// `Reading you NFC card / tag...`
  String get cardPolled {
    return Intl.message(
      'Reading you NFC card / tag...',
      name: 'cardPolled',
      desc: '',
      args: [],
    );
  }

  /// `Executing your script...`
  String get executingScript {
    return Intl.message(
      'Executing your script...',
      name: 'executingScript',
      desc: '',
      args: [],
    );
  }

  /// `Read succeeded`
  String get readSucceeded {
    return Intl.message(
      'Read succeeded',
      name: 'readSucceeded',
      desc: '',
      args: [],
    );
  }

  /// `Read failed`
  String get readFailed {
    return Intl.message(
      'Read failed',
      name: 'readFailed',
      desc: '',
      args: [],
    );
  }

  /// `No history found`
  String get noHistoryFound {
    return Intl.message(
      'No history found',
      name: 'noHistoryFound',
      desc: '',
      args: [],
    );
  }

  /// `Card name`
  String get cardName {
    return Intl.message(
      'Card name',
      name: 'cardName',
      desc: '',
      args: [],
    );
  }

  /// `Last execution time`
  String get lastExecutionTime {
    return Intl.message(
      'Last execution time',
      name: 'lastExecutionTime',
      desc: '',
      args: [],
    );
  }

  /// `Never`
  String get never {
    return Intl.message(
      'Never',
      name: 'never',
      desc: '',
      args: [],
    );
  }

  /// `RUN`
  String get run {
    return Intl.message(
      'RUN',
      name: 'run',
      desc: '',
      args: [],
    );
  }

  /// `Add script`
  String get addScript {
    return Intl.message(
      'Add script',
      name: 'addScript',
      desc: '',
      args: [],
    );
  }

  /// `Modify script`
  String get modifyScript {
    return Intl.message(
      'Modify script',
      name: 'modifyScript',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Code`
  String get code {
    return Intl.message(
      'Code',
      name: 'code',
      desc: '',
      args: [],
    );
  }

  /// `UNDO`
  String get undo {
    return Intl.message(
      'UNDO',
      name: 'undo',
      desc: '',
      args: [],
    );
  }

  /// `Record`
  String get record {
    return Intl.message(
      'Record',
      name: 'record',
      desc: '',
      args: [],
    );
  }

  /// `Script`
  String get script {
    return Intl.message(
      'Script',
      name: 'script',
      desc: '',
      args: [],
    );
  }

  /// `deleted`
  String get deleted {
    return Intl.message(
      'deleted',
      name: 'deleted',
      desc: '',
      args: [],
    );
  }

  /// `copied`
  String get copied {
    return Intl.message(
      'copied',
      name: 'copied',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get copy {
    return Intl.message(
      'Copy',
      name: 'copy',
      desc: '',
      args: [],
    );
  }

  /// `Press RUN to get result`
  String get pressRun {
    return Intl.message(
      'Press RUN to get result',
      name: 'pressRun',
      desc: '',
      args: [],
    );
  }

  /// `Toggle UI Platform (debug only)`
  String get togglePlatform {
    return Intl.message(
      'Toggle UI Platform (debug only)',
      name: 'togglePlatform',
      desc: '',
      args: [],
    );
  }

  /// `UnionPay Credit`
  String get UPCredit {
    return Intl.message(
      'UnionPay Credit',
      name: 'UPCredit',
      desc: '',
      args: [],
    );
  }

  /// `UnionPay Debit`
  String get UPDebit {
    return Intl.message(
      'UnionPay Debit',
      name: 'UPDebit',
      desc: '',
      args: [],
    );
  }

  /// `UnionPay Secured Credit`
  String get UPSecuredCredit {
    return Intl.message(
      'UnionPay Secured Credit',
      name: 'UPSecuredCredit',
      desc: '',
      args: [],
    );
  }

  /// `Visa`
  String get Visa {
    return Intl.message(
      'Visa',
      name: 'Visa',
      desc: '',
      args: [],
    );
  }

  /// `MasterCard`
  String get MC {
    return Intl.message(
      'MasterCard',
      name: 'MC',
      desc: '',
      args: [],
    );
  }

  /// `American Express`
  String get AMEX {
    return Intl.message(
      'American Express',
      name: 'AMEX',
      desc: '',
      args: [],
    );
  }

  /// `JCB`
  String get JCB {
    return Intl.message(
      'JCB',
      name: 'JCB',
      desc: '',
      args: [],
    );
  }

  /// `Discover`
  String get Discover {
    return Intl.message(
      'Discover',
      name: 'Discover',
      desc: '',
      args: [],
    );
  }

  /// `City Union`
  String get CityUnion {
    return Intl.message(
      'City Union',
      name: 'CityUnion',
      desc: '',
      args: [],
    );
  }

  /// `T Union`
  String get TUnion {
    return Intl.message(
      'T Union',
      name: 'TUnion',
      desc: '',
      args: [],
    );
  }

  /// `Beijing Yikatong`
  String get BMAC {
    return Intl.message(
      'Beijing Yikatong',
      name: 'BMAC',
      desc: '',
      args: [],
    );
  }

  /// `Lingnan Pass`
  String get LingnanPass {
    return Intl.message(
      'Lingnan Pass',
      name: 'LingnanPass',
      desc: '',
      args: [],
    );
  }

  /// `Shenzhen Tong`
  String get ShenzhenTong {
    return Intl.message(
      'Shenzhen Tong',
      name: 'ShenzhenTong',
      desc: '',
      args: [],
    );
  }

  /// `Wuhan Tong`
  String get WuhanTong {
    return Intl.message(
      'Wuhan Tong',
      name: 'WuhanTong',
      desc: '',
      args: [],
    );
  }

  /// `T-Money`
  String get TMoney {
    return Intl.message(
      'T-Money',
      name: 'TMoney',
      desc: '',
      args: [],
    );
  }

  /// `Octopus`
  String get Octopus {
    return Intl.message(
      'Octopus',
      name: 'Octopus',
      desc: '',
      args: [],
    );
  }

  /// `Tsinghua University Campus Card`
  String get Tsinghua {
    return Intl.message(
      'Tsinghua University Campus Card',
      name: 'Tsinghua',
      desc: '',
      args: [],
    );
  }

  /// `China Resident ID Card`
  String get ChinaResidentIDGen2 {
    return Intl.message(
      'China Resident ID Card',
      name: 'ChinaResidentIDGen2',
      desc: '',
      args: [],
    );
  }

  /// `MIFARE Ultralight`
  String get MifareUltralight {
    return Intl.message(
      'MIFARE Ultralight',
      name: 'MifareUltralight',
      desc: '',
      args: [],
    );
  }

  /// `MIFARE Plus`
  String get MifarePlus {
    return Intl.message(
      'MIFARE Plus',
      name: 'MifarePlus',
      desc: '',
      args: [],
    );
  }

  /// `MIFARE DESFire`
  String get MifareDESFire {
    return Intl.message(
      'MIFARE DESFire',
      name: 'MifareDESFire',
      desc: '',
      args: [],
    );
  }

  /// `MIFARE Classic`
  String get MifareClassic {
    return Intl.message(
      'MIFARE Classic',
      name: 'MifareClassic',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get Unknown {
    return Intl.message(
      'Unknown',
      name: 'Unknown',
      desc: '',
      args: [],
    );
  }

  /// `Authorization`
  String get Authorization {
    return Intl.message(
      'Authorization',
      name: 'Authorization',
      desc: '',
      args: [],
    );
  }

  /// `Balance Inquiry`
  String get BalanceInquiry {
    return Intl.message(
      'Balance Inquiry',
      name: 'BalanceInquiry',
      desc: '',
      args: [],
    );
  }

  /// `Cash`
  String get Cash {
    return Intl.message(
      'Cash',
      name: 'Cash',
      desc: '',
      args: [],
    );
  }

  /// `Void`
  String get Void {
    return Intl.message(
      'Void',
      name: 'Void',
      desc: '',
      args: [],
    );
  }

  /// `Mobile Topup`
  String get MobileTopup {
    return Intl.message(
      'Mobile Topup',
      name: 'MobileTopup',
      desc: '',
      args: [],
    );
  }

  /// `Load`
  String get Load {
    return Intl.message(
      'Load',
      name: 'Load',
      desc: '',
      args: [],
    );
  }

  /// `Purchase`
  String get Purchase {
    return Intl.message(
      'Purchase',
      name: 'Purchase',
      desc: '',
      args: [],
    );
  }

  /// `Compound Purchase`
  String get CompoundPurchase {
    return Intl.message(
      'Compound Purchase',
      name: 'CompoundPurchase',
      desc: '',
      args: [],
    );
  }

  /// `Unnamed Card`
  String get unnamedCard {
    return Intl.message(
      'Unnamed Card',
      name: 'unnamedCard',
      desc: '',
      args: [],
    );
  }

  /// `Transaction History`
  String get transactionHistory {
    return Intl.message(
      'Transaction History',
      name: 'transactionHistory',
      desc: '',
      args: [],
    );
  }

  /// `record(s)`
  String get recordCount {
    return Intl.message(
      'record(s)',
      name: 'recordCount',
      desc: '',
      args: [],
    );
  }

  /// `Technological Details`
  String get technologicalDetails {
    return Intl.message(
      'Technological Details',
      name: 'technologicalDetails',
      desc: '',
      args: [],
    );
  }

  /// `Communication Logs`
  String get apduLogs {
    return Intl.message(
      'Communication Logs',
      name: 'apduLogs',
      desc: '',
      args: [],
    );
  }

  /// `Not supported`
  String get notSupported {
    return Intl.message(
      'Not supported',
      name: 'notSupported',
      desc: '',
      args: [],
    );
  }

  /// `Card Number`
  String get cardNumber {
    return Intl.message(
      'Card Number',
      name: 'cardNumber',
      desc: '',
      args: [],
    );
  }

  /// `Internal Number`
  String get internalNumber {
    return Intl.message(
      'Internal Number',
      name: 'internalNumber',
      desc: '',
      args: [],
    );
  }

  /// `Holder Name`
  String get holderName {
    return Intl.message(
      'Holder Name',
      name: 'holderName',
      desc: '',
      args: [],
    );
  }

  /// `Balance`
  String get balance {
    return Intl.message(
      'Balance',
      name: 'balance',
      desc: '',
      args: [],
    );
  }

  /// `Province Code`
  String get provinceCode {
    return Intl.message(
      'Province Code',
      name: 'provinceCode',
      desc: '',
      args: [],
    );
  }

  /// `TUnion Card Type`
  String get tuType {
    return Intl.message(
      'TUnion Card Type',
      name: 'tuType',
      desc: '',
      args: [],
    );
  }

  /// `City`
  String get city {
    return Intl.message(
      'City',
      name: 'city',
      desc: '',
      args: [],
    );
  }

  /// `Issue Date`
  String get issueDate {
    return Intl.message(
      'Issue Date',
      name: 'issueDate',
      desc: '',
      args: [],
    );
  }

  /// `Expiry Date`
  String get expiryDate {
    return Intl.message(
      'Expiry Date',
      name: 'expiryDate',
      desc: '',
      args: [],
    );
  }

  /// `Expiry Date on Card`
  String get displayExpiryDate {
    return Intl.message(
      'Expiry Date on Card',
      name: 'displayExpiryDate',
      desc: '',
      args: [],
    );
  }

  /// `Valid Until`
  String get validUntil {
    return Intl.message(
      'Valid Until',
      name: 'validUntil',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Counter`
  String get ATC {
    return Intl.message(
      'Transaction Counter',
      name: 'ATC',
      desc: '',
      args: [],
    );
  }

  /// `Remaining PIN Retry Counter`
  String get pinRetry {
    return Intl.message(
      'Remaining PIN Retry Counter',
      name: 'pinRetry',
      desc: '',
      args: [],
    );
  }

  /// ` Raw data`
  String get rawData {
    return Intl.message(
      ' Raw data',
      name: 'rawData',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Number`
  String get transactionNumber {
    return Intl.message(
      'Transaction Number',
      name: 'transactionNumber',
      desc: '',
      args: [],
    );
  }

  /// `Terminal`
  String get terminal {
    return Intl.message(
      'Terminal',
      name: 'terminal',
      desc: '',
      args: [],
    );
  }

  /// `Type`
  String get type {
    return Intl.message(
      'Type',
      name: 'type',
      desc: '',
      args: [],
    );
  }

  /// `Country Code`
  String get countryCode {
    return Intl.message(
      'Country Code',
      name: 'countryCode',
      desc: '',
      args: [],
    );
  }

  /// `Currency`
  String get currency {
    return Intl.message(
      'Currency',
      name: 'currency',
      desc: '',
      args: [],
    );
  }

  /// `Amount, Other`
  String get amountOther {
    return Intl.message(
      'Amount, Other',
      name: 'amountOther',
      desc: '',
      args: [],
    );
  }

  /// `Subway Exit`
  String get subwayExit {
    return Intl.message(
      'Subway Exit',
      name: 'subwayExit',
      desc: '',
      args: [],
    );
  }

  /// `IC Serial No.`
  String get icSerial {
    return Intl.message(
      'IC Serial No.',
      name: 'icSerial',
      desc: '',
      args: [],
    );
  }

  /// `Card Management No.`
  String get mgmtNumber {
    return Intl.message(
      'Card Management No.',
      name: 'mgmtNumber',
      desc: '',
      args: [],
    );
  }

  /// `Line 1`
  String get Line1 {
    return Intl.message(
      'Line 1',
      name: 'Line1',
      desc: '',
      args: [],
    );
  }

  /// `Line 2`
  String get Line2 {
    return Intl.message(
      'Line 2',
      name: 'Line2',
      desc: '',
      args: [],
    );
  }

  /// `Line 4`
  String get Line4 {
    return Intl.message(
      'Line 4',
      name: 'Line4',
      desc: '',
      args: [],
    );
  }

  /// `Line 5`
  String get Line5 {
    return Intl.message(
      'Line 5',
      name: 'Line5',
      desc: '',
      args: [],
    );
  }

  /// `Line 6`
  String get Line6 {
    return Intl.message(
      'Line 6',
      name: 'Line6',
      desc: '',
      args: [],
    );
  }

  /// `Line 7`
  String get Line7 {
    return Intl.message(
      'Line 7',
      name: 'Line7',
      desc: '',
      args: [],
    );
  }

  /// `Line 8`
  String get Line8 {
    return Intl.message(
      'Line 8',
      name: 'Line8',
      desc: '',
      args: [],
    );
  }

  /// `Line 9`
  String get Line9 {
    return Intl.message(
      'Line 9',
      name: 'Line9',
      desc: '',
      args: [],
    );
  }

  /// `Line 10`
  String get Line10 {
    return Intl.message(
      'Line 10',
      name: 'Line10',
      desc: '',
      args: [],
    );
  }

  /// `Line 13`
  String get Line13 {
    return Intl.message(
      'Line 13',
      name: 'Line13',
      desc: '',
      args: [],
    );
  }

  /// `Line 14`
  String get Line14 {
    return Intl.message(
      'Line 14',
      name: 'Line14',
      desc: '',
      args: [],
    );
  }

  /// `Line 15`
  String get Line15 {
    return Intl.message(
      'Line 15',
      name: 'Line15',
      desc: '',
      args: [],
    );
  }

  /// `Line 16`
  String get Line16 {
    return Intl.message(
      'Line 16',
      name: 'Line16',
      desc: '',
      args: [],
    );
  }

  /// `Xijiao Line`
  String get Xijiao {
    return Intl.message(
      'Xijiao Line',
      name: 'Xijiao',
      desc: '',
      args: [],
    );
  }

  /// `Daxing Airport Line`
  String get DaxingAirport {
    return Intl.message(
      'Daxing Airport Line',
      name: 'DaxingAirport',
      desc: '',
      args: [],
    );
  }

  /// `Daxing Line`
  String get Daxing {
    return Intl.message(
      'Daxing Line',
      name: 'Daxing',
      desc: '',
      args: [],
    );
  }

  /// `Changping Line`
  String get Changping {
    return Intl.message(
      'Changping Line',
      name: 'Changping',
      desc: '',
      args: [],
    );
  }

  /// `Fangshan Line`
  String get Fangshan {
    return Intl.message(
      'Fangshan Line',
      name: 'Fangshan',
      desc: '',
      args: [],
    );
  }

  /// `Yizhuang Line`
  String get Yizhuang {
    return Intl.message(
      'Yizhuang Line',
      name: 'Yizhuang',
      desc: '',
      args: [],
    );
  }

  /// `Batong Line`
  String get Batong {
    return Intl.message(
      'Batong Line',
      name: 'Batong',
      desc: '',
      args: [],
    );
  }

  /// `Capital Airport Line`
  String get CapitalAirport {
    return Intl.message(
      'Capital Airport Line',
      name: 'CapitalAirport',
      desc: '',
      args: [],
    );
  }

  /// `Data deleted`
  String get deletedHint {
    return Intl.message(
      'Data deleted',
      name: 'deletedHint',
      desc: '',
      args: [],
    );
  }

  /// `Delete Data`
  String get deleteDataDialog {
    return Intl.message(
      'Delete Data',
      name: 'deleteDataDialog',
      desc: '',
      args: [],
    );
  }

  /// `Count`
  String get dataCount {
    return Intl.message(
      'Count',
      name: 'dataCount',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `Delete records & scripts`
  String get deleteData {
    return Intl.message(
      'Delete records & scripts',
      name: 'deleteData',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Home Page`
  String get homepage {
    return Intl.message(
      'Home Page',
      name: 'homepage',
      desc: '',
      args: [],
    );
  }

  /// `Source Code`
  String get sourceCode {
    return Intl.message(
      'Source Code',
      name: 'sourceCode',
      desc: '',
      args: [],
    );
  }

  /// `Open Source Licenses`
  String get openSourceLicenses {
    return Intl.message(
      'Open Source Licenses',
      name: 'openSourceLicenses',
      desc: '',
      args: [],
    );
  }

  /// `Contact Us`
  String get contactUs {
    return Intl.message(
      'Contact Us',
      name: 'contactUs',
      desc: '',
      args: [],
    );
  }

  /// `assets/html/privacy_policy.en.html`
  String get privacyPolicyContent {
    return Intl.message(
      'assets/html/privacy_policy.en.html',
      name: 'privacyPolicyContent',
      desc: '',
      args: [],
    );
  }

  /// `assets/html/third_party_license.html`
  String get thirdPartyLicenseContent {
    return Intl.message(
      'assets/html/third_party_license.html',
      name: 'thirdPartyLicenseContent',
      desc: '',
      args: [],
    );
  }

  /// `Help`
  String get help {
    return Intl.message(
      'Help',
      name: 'help',
      desc: '',
      args: [],
    );
  }

  /// `Scan History`
  String get scanHistory {
    return Intl.message(
      'Scan History',
      name: 'scanHistory',
      desc: '',
      args: [],
    );
  }

  /// `$ found`
  String get historyCount {
    return Intl.message(
      '\$ found',
      name: 'historyCount',
      desc: '',
      args: [],
    );
  }

  /// `Added at`
  String get addedAt {
    return Intl.message(
      'Added at',
      name: 'addedAt',
      desc: '',
      args: [],
    );
  }

  /// `Swipe up or tap on the card to show more`
  String get detailHint {
    return Intl.message(
      'Swipe up or tap on the card to show more',
      name: 'detailHint',
      desc: '',
      args: [],
    );
  }

  /// `NDEF Records`
  String get ndefRecords {
    return Intl.message(
      'NDEF Records',
      name: 'ndefRecords',
      desc: '',
      args: [],
    );
  }

  /// `MIFARE Vendor`
  String get mifareVendor {
    return Intl.message(
      'MIFARE Vendor',
      name: 'mifareVendor',
      desc: '',
      args: [],
    );
  }

  /// `MIFARE Product Type`
  String get mifareProductType {
    return Intl.message(
      'MIFARE Product Type',
      name: 'mifareProductType',
      desc: '',
      args: [],
    );
  }

  /// `MIFARE Product Subtype`
  String get mifareProductSubtype {
    return Intl.message(
      'MIFARE Product Subtype',
      name: 'mifareProductSubtype',
      desc: '',
      args: [],
    );
  }

  /// `MIFARE Product Version`
  String get mifareProductVersion {
    return Intl.message(
      'MIFARE Product Version',
      name: 'mifareProductVersion',
      desc: '',
      args: [],
    );
  }

  /// `MIFARE Product Name`
  String get mifareProductName {
    return Intl.message(
      'MIFARE Product Name',
      name: 'mifareProductName',
      desc: '',
      args: [],
    );
  }

  /// `MIFARE Storage Size`
  String get mifareStorageSize {
    return Intl.message(
      'MIFARE Storage Size',
      name: 'mifareStorageSize',
      desc: '',
      args: [],
    );
  }

  /// `MIFARE Protocol Type`
  String get mifareProtocolType {
    return Intl.message(
      'MIFARE Protocol Type',
      name: 'mifareProtocolType',
      desc: '',
      args: [],
    );
  }

  /// `MIFARE Production Date`
  String get mifareProductionDate {
    return Intl.message(
      'MIFARE Production Date',
      name: 'mifareProductionDate',
      desc: '',
      args: [],
    );
  }

  /// `Memory Data`
  String get memoryData {
    return Intl.message(
      'Memory Data',
      name: 'memoryData',
      desc: '',
      args: [],
    );
  }

  /// `byte(s)`
  String get byteCount {
    return Intl.message(
      'byte(s)',
      name: 'byteCount',
      desc: '',
      args: [],
    );
  }

  /// `Well-known Prefix`
  String get wellKnownPrefix {
    return Intl.message(
      'Well-known Prefix',
      name: 'wellKnownPrefix',
      desc: '',
      args: [],
    );
  }

  /// `Text`
  String get text {
    return Intl.message(
      'Text',
      name: 'text',
      desc: '',
      args: [],
    );
  }

  /// `Language Code`
  String get languageCode {
    return Intl.message(
      'Language Code',
      name: 'languageCode',
      desc: '',
      args: [],
    );
  }

  /// `MIME Media Record`
  String get mimeMediaRecord {
    return Intl.message(
      'MIME Media Record',
      name: 'mimeMediaRecord',
      desc: '',
      args: [],
    );
  }

  /// `Payload`
  String get payload {
    return Intl.message(
      'Payload',
      name: 'payload',
      desc: '',
      args: [],
    );
  }

  /// `Identifier`
  String get identifier {
    return Intl.message(
      'Identifier',
      name: 'identifier',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
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
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}