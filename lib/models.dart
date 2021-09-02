import 'package:flutter/cupertino.dart';
import 'package:nfsee/generated/l10n.dart';

class Detail {
  const Detail({this.name, this.value, this.icon});

  final String? name;
  final String? value;
  final IconData? icon;
}

class ScriptDataModel {
  final String? action;
  final dynamic data;

  ScriptDataModel({this.action, this.data});

  ScriptDataModel.fromJson(Map map)
      : action = map['action'],
        data = map['data'];
}

enum CardType {
  UPCredit,
  UPDebit,
  UPSecuredCredit,
  Visa,
  MC,
  AMEX,
  JCB,
  Discover,
  CityUnion,
  TUnion,
  BMAC,
  LingnanPass,
  ShenzhenTong,
  WuhanTong,
  TMoney,
  Octopus,
  Tsinghua,
  ChinaResidentIDGen2,
  MifareUltralight,
  MifarePlus,
  MifareDESFire,
  MifareClassic,
  Unknown,
}

extension CardTypeExtension on CardType? {
  String getName(BuildContext context) {
    switch (this) {
      case CardType.UPCredit:
        return AppLocalizations.of(context)!.upCredit;
      case CardType.UPDebit:
        return AppLocalizations.of(context)!.upDebit;
      case CardType.UPSecuredCredit:
        return AppLocalizations.of(context)!.upSecuredCredit;
      case CardType.Visa:
        return AppLocalizations.of(context)!.visa;
      case CardType.MC:
        return AppLocalizations.of(context)!.mc;
      case CardType.AMEX:
        return AppLocalizations.of(context)!.amex;
      case CardType.JCB:
        return AppLocalizations.of(context)!.jcb;
      case CardType.Discover:
        return AppLocalizations.of(context)!.discover;
      case CardType.CityUnion:
        return AppLocalizations.of(context)!.cityUnion;
      case CardType.TUnion:
        return AppLocalizations.of(context)!.tUnion;
      case CardType.BMAC:
        return AppLocalizations.of(context)!.bmac;
      case CardType.LingnanPass:
        return AppLocalizations.of(context)!.lingnanPass;
      case CardType.ShenzhenTong:
        return AppLocalizations.of(context)!.shenzhenTong;
      case CardType.WuhanTong:
        return AppLocalizations.of(context)!.wuhanTong;
      case CardType.TMoney:
        return AppLocalizations.of(context)!.tMoney;
      case CardType.Octopus:
        return AppLocalizations.of(context)!.octopus;
      case CardType.Tsinghua:
        return AppLocalizations.of(context)!.tsinghua;
      case CardType.ChinaResidentIDGen2:
        return AppLocalizations.of(context)!.chinaResidentIDGen2;
      case CardType.MifareUltralight:
        return AppLocalizations.of(context)!.mifareUltralight;
      case CardType.MifarePlus:
        return AppLocalizations.of(context)!.mifarePlus;
      case CardType.MifareDESFire:
        return AppLocalizations.of(context)!.mifareDESFire;
      case CardType.MifareClassic:
        return AppLocalizations.of(context)!.mifareClassic;
      case CardType.Unknown:
      default:
        return AppLocalizations.of(context)!.unknown;
    }
  }
}

enum ProcessingCode { Authorization, BalanceInquiry, Cash, Void, MobileTopup }

extension ProcessingCodeExtension on ProcessingCode? {
  String getName(BuildContext context) {
    switch (this) {
      case ProcessingCode.Authorization:
        return AppLocalizations.of(context)!.authorization;
      case ProcessingCode.BalanceInquiry:
        return AppLocalizations.of(context)!.balanceInquiry;
      case ProcessingCode.Cash:
        return AppLocalizations.of(context)!.cash;
      case ProcessingCode.MobileTopup:
        return AppLocalizations.of(context)!.mobileTopup;
      case ProcessingCode.Void:
        return AppLocalizations.of(context)!.strVoid;
      default:
        return AppLocalizations.of(context)!.unknown;
    }
  }
}

enum PBOCTransactionType { Load, Purchase, CompoundPurchase }

extension PBOCTransactionTypeExtension on PBOCTransactionType {
  String getName(BuildContext context) {
    switch (this) {
      case PBOCTransactionType.Load:
        return AppLocalizations.of(context)!.strLoad;
      case PBOCTransactionType.Purchase:
        return AppLocalizations.of(context)!.purchase;
      case PBOCTransactionType.CompoundPurchase:
        return AppLocalizations.of(context)!.compoundPurchase;
      default:
        return AppLocalizations.of(context)!.unknown;
    }
  }
}

enum BeijingSubway {
  Line1,
  Line2,
  Line4,
  Line5,
  Line6,
  Line7,
  Line8,
  Line9,
  Line10,
  Line13,
  Line14,
  Line15,
  Line16,
  Xijiao,
  DaxingAirport,
  Daxing,
  Changping,
  Fangshan,
  Yizhuang,
  Batong,
  CapitalAirport
}

extension BeijingSubwayExtension on BeijingSubway {
  String getName(BuildContext context) {
    switch (this) {
      case BeijingSubway.Line1:
        return AppLocalizations.of(context)!.line1;
      case BeijingSubway.Line2:
        return AppLocalizations.of(context)!.line2;
      case BeijingSubway.Line4:
        return AppLocalizations.of(context)!.line4;
      case BeijingSubway.Line5:
        return AppLocalizations.of(context)!.line5;
      case BeijingSubway.Line6:
        return AppLocalizations.of(context)!.line6;
      case BeijingSubway.Line7:
        return AppLocalizations.of(context)!.line7;
      case BeijingSubway.Line8:
        return AppLocalizations.of(context)!.line8;
      case BeijingSubway.Line9:
        return AppLocalizations.of(context)!.line9;
      case BeijingSubway.Line10:
        return AppLocalizations.of(context)!.line10;
      case BeijingSubway.Line13:
        return AppLocalizations.of(context)!.line13;
      case BeijingSubway.Line14:
        return AppLocalizations.of(context)!.line14;
      case BeijingSubway.Line15:
        return AppLocalizations.of(context)!.line15;
      case BeijingSubway.Line16:
        return AppLocalizations.of(context)!.line16;
      case BeijingSubway.Xijiao:
        return AppLocalizations.of(context)!.xijiao;
      case BeijingSubway.DaxingAirport:
        return AppLocalizations.of(context)!.daxingAirport;
      case BeijingSubway.Daxing:
        return AppLocalizations.of(context)!.daxing;
      case BeijingSubway.Changping:
        return AppLocalizations.of(context)!.changping;
      case BeijingSubway.Fangshan:
        return AppLocalizations.of(context)!.fangshan;
      case BeijingSubway.Yizhuang:
        return AppLocalizations.of(context)!.yizhuang;
      case BeijingSubway.Batong:
        return AppLocalizations.of(context)!.batong;
      case BeijingSubway.CapitalAirport:
        return AppLocalizations.of(context)!.capitalAirport;
      default:
        return "Unknown";
    }
  }
}

const String DEFAULT_CONFIG = '{}';
