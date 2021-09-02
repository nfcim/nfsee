
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_zh.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations returned
/// by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// localizationDelegates list, and the locales they support in the app's
/// supportedLocales list. For example:
///
/// ```
/// import 'generated/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @scriptTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Run Script'**
  String get scriptTabTitle;

  /// No description provided for @scanTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scanTabTitle;

  /// No description provided for @settingsTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTabTitle;

  /// No description provided for @homeScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'NFSee'**
  String get homeScreenTitle;

  /// No description provided for @waitForCard.
  ///
  /// In en, this message translates to:
  /// **'Hold your phone near the NFC card / tag...'**
  String get waitForCard;

  /// No description provided for @cardPolled.
  ///
  /// In en, this message translates to:
  /// **'Reading you NFC card / tag...'**
  String get cardPolled;

  /// No description provided for @executingScript.
  ///
  /// In en, this message translates to:
  /// **'Executing your script...'**
  String get executingScript;

  /// No description provided for @readSucceeded.
  ///
  /// In en, this message translates to:
  /// **'Read succeeded'**
  String get readSucceeded;

  /// No description provided for @readFailed.
  ///
  /// In en, this message translates to:
  /// **'Read failed'**
  String get readFailed;

  /// No description provided for @noHistoryFound.
  ///
  /// In en, this message translates to:
  /// **'No history found'**
  String get noHistoryFound;

  /// No description provided for @cardName.
  ///
  /// In en, this message translates to:
  /// **'Card name'**
  String get cardName;

  /// No description provided for @lastExecutionTime.
  ///
  /// In en, this message translates to:
  /// **'Last execution time'**
  String get lastExecutionTime;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @run.
  ///
  /// In en, this message translates to:
  /// **'RUN'**
  String get run;

  /// No description provided for @addScript.
  ///
  /// In en, this message translates to:
  /// **'Add script'**
  String get addScript;

  /// No description provided for @modifyScript.
  ///
  /// In en, this message translates to:
  /// **'Modify script'**
  String get modifyScript;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get undo;

  /// No description provided for @record.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get record;

  /// No description provided for @script.
  ///
  /// In en, this message translates to:
  /// **'Script'**
  String get script;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'deleted'**
  String get deleted;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'copied'**
  String get copied;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @pressRun.
  ///
  /// In en, this message translates to:
  /// **'Press RUN to get result'**
  String get pressRun;

  /// No description provided for @togglePlatform.
  ///
  /// In en, this message translates to:
  /// **'Toggle UI Platform (debug only)'**
  String get togglePlatform;

  /// No description provided for @upCredit.
  ///
  /// In en, this message translates to:
  /// **'UnionPay Credit'**
  String get upCredit;

  /// No description provided for @upDebit.
  ///
  /// In en, this message translates to:
  /// **'UnionPay Debit'**
  String get upDebit;

  /// No description provided for @upSecuredCredit.
  ///
  /// In en, this message translates to:
  /// **'UnionPay Secured Credit'**
  String get upSecuredCredit;

  /// No description provided for @visa.
  ///
  /// In en, this message translates to:
  /// **'Visa'**
  String get visa;

  /// No description provided for @mc.
  ///
  /// In en, this message translates to:
  /// **'MasterCard'**
  String get mc;

  /// No description provided for @amex.
  ///
  /// In en, this message translates to:
  /// **'American Express'**
  String get amex;

  /// No description provided for @jcb.
  ///
  /// In en, this message translates to:
  /// **'JCB'**
  String get jcb;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @cityUnion.
  ///
  /// In en, this message translates to:
  /// **'City Union'**
  String get cityUnion;

  /// No description provided for @tUnion.
  ///
  /// In en, this message translates to:
  /// **'T Union'**
  String get tUnion;

  /// No description provided for @bmac.
  ///
  /// In en, this message translates to:
  /// **'Beijing Yikatong'**
  String get bmac;

  /// No description provided for @lingnanPass.
  ///
  /// In en, this message translates to:
  /// **'Lingnan Pass'**
  String get lingnanPass;

  /// No description provided for @shenzhenTong.
  ///
  /// In en, this message translates to:
  /// **'Shenzhen Tong'**
  String get shenzhenTong;

  /// No description provided for @wuhanTong.
  ///
  /// In en, this message translates to:
  /// **'Wuhan Tong'**
  String get wuhanTong;

  /// No description provided for @tMoney.
  ///
  /// In en, this message translates to:
  /// **'T-Money'**
  String get tMoney;

  /// No description provided for @octopus.
  ///
  /// In en, this message translates to:
  /// **'Octopus'**
  String get octopus;

  /// No description provided for @tsinghua.
  ///
  /// In en, this message translates to:
  /// **'Tsinghua University Campus Card'**
  String get tsinghua;

  /// No description provided for @chinaResidentIDGen2.
  ///
  /// In en, this message translates to:
  /// **'China Resident ID Card'**
  String get chinaResidentIDGen2;

  /// No description provided for @mifareUltralight.
  ///
  /// In en, this message translates to:
  /// **'MIFARE Ultralight'**
  String get mifareUltralight;

  /// No description provided for @mifarePlus.
  ///
  /// In en, this message translates to:
  /// **'MIFARE Plus'**
  String get mifarePlus;

  /// No description provided for @mifareDESFire.
  ///
  /// In en, this message translates to:
  /// **'MIFARE DESFire'**
  String get mifareDESFire;

  /// No description provided for @mifareClassic.
  ///
  /// In en, this message translates to:
  /// **'MIFARE Classic'**
  String get mifareClassic;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @authorization.
  ///
  /// In en, this message translates to:
  /// **'Authorization'**
  String get authorization;

  /// No description provided for @balanceInquiry.
  ///
  /// In en, this message translates to:
  /// **'Balance Inquiry'**
  String get balanceInquiry;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @strVoid.
  ///
  /// In en, this message translates to:
  /// **'Void'**
  String get strVoid;

  /// No description provided for @mobileTopup.
  ///
  /// In en, this message translates to:
  /// **'Mobile Topup'**
  String get mobileTopup;

  /// No description provided for @strLoad.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get strLoad;

  /// No description provided for @purchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchase;

  /// No description provided for @compoundPurchase.
  ///
  /// In en, this message translates to:
  /// **'Compound Purchase'**
  String get compoundPurchase;

  /// No description provided for @unnamedCard.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Card'**
  String get unnamedCard;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @recordCount.
  ///
  /// In en, this message translates to:
  /// **'record(s)'**
  String get recordCount;

  /// No description provided for @technologicalDetails.
  ///
  /// In en, this message translates to:
  /// **'Technological Details'**
  String get technologicalDetails;

  /// No description provided for @apduLogs.
  ///
  /// In en, this message translates to:
  /// **'Communication Logs'**
  String get apduLogs;

  /// No description provided for @notSupported.
  ///
  /// In en, this message translates to:
  /// **'Not supported'**
  String get notSupported;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @internalNumber.
  ///
  /// In en, this message translates to:
  /// **'Internal Number'**
  String get internalNumber;

  /// No description provided for @holderName.
  ///
  /// In en, this message translates to:
  /// **'Holder Name'**
  String get holderName;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @provinceCode.
  ///
  /// In en, this message translates to:
  /// **'Province Code'**
  String get provinceCode;

  /// No description provided for @tuType.
  ///
  /// In en, this message translates to:
  /// **'TUnion Card Type'**
  String get tuType;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @issueDate.
  ///
  /// In en, this message translates to:
  /// **'Issue Date'**
  String get issueDate;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @displayExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date on Card'**
  String get displayExpiryDate;

  /// No description provided for @validUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid Until'**
  String get validUntil;

  /// No description provided for @atc.
  ///
  /// In en, this message translates to:
  /// **'Transaction Counter'**
  String get atc;

  /// No description provided for @pinRetry.
  ///
  /// In en, this message translates to:
  /// **'Remaining PIN Retry Counter'**
  String get pinRetry;

  /// No description provided for @rawData.
  ///
  /// In en, this message translates to:
  /// **' Raw data'**
  String get rawData;

  /// No description provided for @transactionNumber.
  ///
  /// In en, this message translates to:
  /// **'Transaction Number'**
  String get transactionNumber;

  /// No description provided for @terminal.
  ///
  /// In en, this message translates to:
  /// **'Terminal'**
  String get terminal;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @countryCode.
  ///
  /// In en, this message translates to:
  /// **'Country Code'**
  String get countryCode;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @amountOther.
  ///
  /// In en, this message translates to:
  /// **'Amount, Other'**
  String get amountOther;

  /// No description provided for @subwayExit.
  ///
  /// In en, this message translates to:
  /// **'Subway Exit'**
  String get subwayExit;

  /// No description provided for @icSerial.
  ///
  /// In en, this message translates to:
  /// **'IC Serial No.'**
  String get icSerial;

  /// No description provided for @mgmtNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Management No.'**
  String get mgmtNumber;

  /// No description provided for @line1.
  ///
  /// In en, this message translates to:
  /// **'Line 1'**
  String get line1;

  /// No description provided for @line2.
  ///
  /// In en, this message translates to:
  /// **'Line 2'**
  String get line2;

  /// No description provided for @line4.
  ///
  /// In en, this message translates to:
  /// **'Line 4'**
  String get line4;

  /// No description provided for @line5.
  ///
  /// In en, this message translates to:
  /// **'Line 5'**
  String get line5;

  /// No description provided for @line6.
  ///
  /// In en, this message translates to:
  /// **'Line 6'**
  String get line6;

  /// No description provided for @line7.
  ///
  /// In en, this message translates to:
  /// **'Line 7'**
  String get line7;

  /// No description provided for @line8.
  ///
  /// In en, this message translates to:
  /// **'Line 8'**
  String get line8;

  /// No description provided for @line9.
  ///
  /// In en, this message translates to:
  /// **'Line 9'**
  String get line9;

  /// No description provided for @line10.
  ///
  /// In en, this message translates to:
  /// **'Line 10'**
  String get line10;

  /// No description provided for @line13.
  ///
  /// In en, this message translates to:
  /// **'Line 13'**
  String get line13;

  /// No description provided for @line14.
  ///
  /// In en, this message translates to:
  /// **'Line 14'**
  String get line14;

  /// No description provided for @line15.
  ///
  /// In en, this message translates to:
  /// **'Line 15'**
  String get line15;

  /// No description provided for @line16.
  ///
  /// In en, this message translates to:
  /// **'Line 16'**
  String get line16;

  /// No description provided for @xijiao.
  ///
  /// In en, this message translates to:
  /// **'Xijiao Line'**
  String get xijiao;

  /// No description provided for @daxingAirport.
  ///
  /// In en, this message translates to:
  /// **'Daxing Airport Line'**
  String get daxingAirport;

  /// No description provided for @daxing.
  ///
  /// In en, this message translates to:
  /// **'Daxing Line'**
  String get daxing;

  /// No description provided for @changping.
  ///
  /// In en, this message translates to:
  /// **'Changping Line'**
  String get changping;

  /// No description provided for @fangshan.
  ///
  /// In en, this message translates to:
  /// **'Fangshan Line'**
  String get fangshan;

  /// No description provided for @yizhuang.
  ///
  /// In en, this message translates to:
  /// **'Yizhuang Line'**
  String get yizhuang;

  /// No description provided for @batong.
  ///
  /// In en, this message translates to:
  /// **'Batong Line'**
  String get batong;

  /// No description provided for @capitalAirport.
  ///
  /// In en, this message translates to:
  /// **'Capital Airport Line'**
  String get capitalAirport;

  /// No description provided for @deletedHint.
  ///
  /// In en, this message translates to:
  /// **'Data deleted'**
  String get deletedHint;

  /// No description provided for @deleteDataDialog.
  ///
  /// In en, this message translates to:
  /// **'Delete Data'**
  String get deleteDataDialog;

  /// No description provided for @dataCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get dataCount;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @deleteData.
  ///
  /// In en, this message translates to:
  /// **'Delete records & scripts'**
  String get deleteData;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @homepage.
  ///
  /// In en, this message translates to:
  /// **'Home Page'**
  String get homepage;

  /// No description provided for @sourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source Code'**
  String get sourceCode;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get openSourceLicenses;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'assets/html/privacy_policy.en.html'**
  String get privacyPolicyContent;

  /// No description provided for @thirdPartyLicenseContent.
  ///
  /// In en, this message translates to:
  /// **'assets/html/third_party_license.html'**
  String get thirdPartyLicenseContent;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @scanHistory.
  ///
  /// In en, this message translates to:
  /// **'Scan History'**
  String get scanHistory;

  /// No description provided for @historyCount.
  ///
  /// In en, this message translates to:
  /// **'\$ found'**
  String get historyCount;

  /// No description provided for @addedAt.
  ///
  /// In en, this message translates to:
  /// **'Added at'**
  String get addedAt;

  /// No description provided for @detailHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe up or tap on the card to show more'**
  String get detailHint;

  /// No description provided for @ndefRecords.
  ///
  /// In en, this message translates to:
  /// **'NDEF Records'**
  String get ndefRecords;

  /// No description provided for @mifareVendor.
  ///
  /// In en, this message translates to:
  /// **'MIFARE Vendor'**
  String get mifareVendor;

  /// No description provided for @mifareProductType.
  ///
  /// In en, this message translates to:
  /// **'MIFARE Product Type'**
  String get mifareProductType;

  /// No description provided for @mifareProductSubtype.
  ///
  /// In en, this message translates to:
  /// **'MIFARE Product Subtype'**
  String get mifareProductSubtype;

  /// No description provided for @mifareProductVersion.
  ///
  /// In en, this message translates to:
  /// **'MIFARE Product Version'**
  String get mifareProductVersion;

  /// No description provided for @mifareProductName.
  ///
  /// In en, this message translates to:
  /// **'MIFARE Product Name'**
  String get mifareProductName;

  /// No description provided for @mifareStorageSize.
  ///
  /// In en, this message translates to:
  /// **'MIFARE Storage Size'**
  String get mifareStorageSize;

  /// No description provided for @mifareProtocolType.
  ///
  /// In en, this message translates to:
  /// **'MIFARE Protocol Type'**
  String get mifareProtocolType;

  /// No description provided for @mifareProductionDate.
  ///
  /// In en, this message translates to:
  /// **'MIFARE Production Date'**
  String get mifareProductionDate;

  /// No description provided for @memoryData.
  ///
  /// In en, this message translates to:
  /// **'Memory Data'**
  String get memoryData;

  /// No description provided for @byteCount.
  ///
  /// In en, this message translates to:
  /// **'byte(s)'**
  String get byteCount;

  /// No description provided for @wellKnownPrefix.
  ///
  /// In en, this message translates to:
  /// **'Well-known Prefix'**
  String get wellKnownPrefix;

  /// No description provided for @text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get text;

  /// No description provided for @languageCode.
  ///
  /// In en, this message translates to:
  /// **'Language Code'**
  String get languageCode;

  /// No description provided for @mimeMediaRecord.
  ///
  /// In en, this message translates to:
  /// **'MIME Media Record'**
  String get mimeMediaRecord;

  /// No description provided for @payload.
  ///
  /// In en, this message translates to:
  /// **'Payload'**
  String get payload;

  /// No description provided for @identifier.
  ///
  /// In en, this message translates to:
  /// **'Identifier'**
  String get identifier;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @encoding.
  ///
  /// In en, this message translates to:
  /// **'Encoding'**
  String get encoding;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(_lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations _lookupAppLocalizations(Locale locale) {
  


// Lookup logic when only language code is specified.
switch (locale.languageCode) {
  case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
}


  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
