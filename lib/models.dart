import 'package:flutter/cupertino.dart';
import 'package:nfsee/utilities.dart';

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
        return S(context).upCredit;
      case CardType.UPDebit:
        return S(context).upDebit;
      case CardType.UPSecuredCredit:
        return S(context).upSecuredCredit;
      case CardType.Visa:
        return S(context).visa;
      case CardType.MC:
        return S(context).mc;
      case CardType.AMEX:
        return S(context).amex;
      case CardType.JCB:
        return S(context).jcb;
      case CardType.Discover:
        return S(context).discover;
      case CardType.CityUnion:
        return S(context).cityUnion;
      case CardType.TUnion:
        return S(context).tUnion;
      case CardType.BMAC:
        return S(context).bmac;
      case CardType.LingnanPass:
        return S(context).lingnanPass;
      case CardType.ShenzhenTong:
        return S(context).shenzhenTong;
      case CardType.WuhanTong:
        return S(context).wuhanTong;
      case CardType.TMoney:
        return S(context).tMoney;
      case CardType.Octopus:
        return S(context).octopus;
      case CardType.Tsinghua:
        return S(context).tsinghua;
      case CardType.ChinaResidentIDGen2:
        return S(context).chinaResidentIDGen2;
      case CardType.MifareUltralight:
        return S(context).mifareUltralight;
      case CardType.MifarePlus:
        return S(context).mifarePlus;
      case CardType.MifareDESFire:
        return S(context).mifareDESFire;
      case CardType.MifareClassic:
        return S(context).mifareClassic;
      case CardType.Unknown:
      default:
        return S(context).unknown;
    }
  }
}

enum ProcessingCode { Authorization, BalanceInquiry, Cash, Void, MobileTopup }

extension ProcessingCodeExtension on ProcessingCode? {
  String getName(BuildContext context) {
    switch (this) {
      case ProcessingCode.Authorization:
        return S(context).authorization;
      case ProcessingCode.BalanceInquiry:
        return S(context).balanceInquiry;
      case ProcessingCode.Cash:
        return S(context).cash;
      case ProcessingCode.MobileTopup:
        return S(context).mobileTopup;
      case ProcessingCode.Void:
        return S(context).strVoid;
      default:
        return S(context).unknown;
    }
  }
}

enum PBOCTransactionType { Load, Purchase, CompoundPurchase }

extension PBOCTransactionTypeExtension on PBOCTransactionType {
  String getName(BuildContext context) {
    switch (this) {
      case PBOCTransactionType.Load:
        return S(context).strLoad;
      case PBOCTransactionType.Purchase:
        return S(context).purchase;
      case PBOCTransactionType.CompoundPurchase:
        return S(context).compoundPurchase;
      default:
        return S(context).unknown;
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
        return S(context).line1;
      case BeijingSubway.Line2:
        return S(context).line2;
      case BeijingSubway.Line4:
        return S(context).line4;
      case BeijingSubway.Line5:
        return S(context).line5;
      case BeijingSubway.Line6:
        return S(context).line6;
      case BeijingSubway.Line7:
        return S(context).line7;
      case BeijingSubway.Line8:
        return S(context).line8;
      case BeijingSubway.Line9:
        return S(context).line9;
      case BeijingSubway.Line10:
        return S(context).line10;
      case BeijingSubway.Line13:
        return S(context).line13;
      case BeijingSubway.Line14:
        return S(context).line14;
      case BeijingSubway.Line15:
        return S(context).line15;
      case BeijingSubway.Line16:
        return S(context).line16;
      case BeijingSubway.Xijiao:
        return S(context).xijiao;
      case BeijingSubway.DaxingAirport:
        return S(context).daxingAirport;
      case BeijingSubway.Daxing:
        return S(context).daxing;
      case BeijingSubway.Changping:
        return S(context).changping;
      case BeijingSubway.Fangshan:
        return S(context).fangshan;
      case BeijingSubway.Yizhuang:
        return S(context).yizhuang;
      case BeijingSubway.Batong:
        return S(context).batong;
      case BeijingSubway.CapitalAirport:
        return S(context).capitalAirport;
      default:
        return "Unknown";
    }
  }
}

const String DEFAULT_CONFIG = '{}';
