import 'package:flutter/cupertino.dart';
import 'package:nfsee/generated/l10n.dart';

class Detail {
  const Detail({this.name, this.value, this.icon});

  final String name;
  final String value;
  final IconData icon;
}

class ScriptDataModel {
  final String action;
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

extension CardTypeExtension on CardType {
  String getName(BuildContext context) {
    switch (this) {
      case CardType.UPCredit:
        return S.of(context).UPCredit;
      case CardType.UPDebit:
        return S.of(context).UPDebit;
      case CardType.UPSecuredCredit:
        return S.of(context).UPSecuredCredit;
      case CardType.Visa:
        return S.of(context).Visa;
      case CardType.MC:
        return S.of(context).MC;
      case CardType.AMEX:
        return S.of(context).AMEX;
      case CardType.JCB:
        return S.of(context).JCB;
      case CardType.Discover:
        return S.of(context).Discover;
      case CardType.CityUnion:
        return S.of(context).CityUnion;
      case CardType.TUnion:
        return S.of(context).TUnion;
      case CardType.BMAC:
        return S.of(context).BMAC;
      case CardType.LingnanPass:
        return S.of(context).LingnanPass;
      case CardType.ShenzhenTong:
        return S.of(context).ShenzhenTong;
      case CardType.WuhanTong:
        return S.of(context).WuhanTong;
      case CardType.TMoney:
        return S.of(context).TMoney;
      case CardType.Octopus:
        return S.of(context).Octopus;
      case CardType.Tsinghua:
        return S.of(context).Tsinghua;
      case CardType.ChinaResidentIDGen2:
        return S.of(context).ChinaResidentIDGen2;
      case CardType.MifareUltralight:
        return S.of(context).MifareUltralight;
      case CardType.MifarePlus:
        return S.of(context).MifarePlus;
      case CardType.MifareDESFire:
        return S.of(context).MifareDESFire;
      case CardType.MifareClassic:
        return S.of(context).MifareClassic;
      case CardType.Unknown:
      default:
        return S.of(context).Unknown;
    }
  }
}

enum ProcessingCode { Authorization, BalanceInquiry, Cash, Void, MobileTopup }

extension ProcessingCodeExtension on ProcessingCode {
  String getName(BuildContext context) {
    switch (this) {
      case ProcessingCode.Authorization:
        return S.of(context).Authorization;
      case ProcessingCode.BalanceInquiry:
        return S.of(context).BalanceInquiry;
      case ProcessingCode.Cash:
        return S.of(context).Cash;
      case ProcessingCode.MobileTopup:
        return S.of(context).MobileTopup;
      case ProcessingCode.Void:
        return S.of(context).Void;
      default:
        return S.of(context).Unknown;
    }
  }
}

enum PBOCTransactionType { Load, Purchase, CompoundPurchase }

extension PBOCTransactionTypeExtension on PBOCTransactionType {
  String getName(BuildContext context) {
    switch (this) {
      case PBOCTransactionType.Load:
        return S.of(context).Load;
      case PBOCTransactionType.Purchase:
        return S.of(context).Purchase;
      case PBOCTransactionType.CompoundPurchase:
        return S.of(context).CompoundPurchase;
      default:
        return S.of(context).Unknown;
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
        return S.of(context).Line1;
      case BeijingSubway.Line2:
        return S.of(context).Line2;
      case BeijingSubway.Line4:
        return S.of(context).Line4;
      case BeijingSubway.Line5:
        return S.of(context).Line5;
      case BeijingSubway.Line6:
        return S.of(context).Line6;
      case BeijingSubway.Line7:
        return S.of(context).Line7;
      case BeijingSubway.Line8:
        return S.of(context).Line8;
      case BeijingSubway.Line9:
        return S.of(context).Line9;
      case BeijingSubway.Line10:
        return S.of(context).Line10;
      case BeijingSubway.Line13:
        return S.of(context).Line13;
      case BeijingSubway.Line14:
        return S.of(context).Line14;
      case BeijingSubway.Line15:
        return S.of(context).Line15;
      case BeijingSubway.Line16:
        return S.of(context).Line16;
      case BeijingSubway.Xijiao:
        return S.of(context).Xijiao;
      case BeijingSubway.DaxingAirport:
        return S.of(context).DaxingAirport;
      case BeijingSubway.Daxing:
        return S.of(context).Daxing;
      case BeijingSubway.Changping:
        return S.of(context).Changping;
      case BeijingSubway.Fangshan:
        return S.of(context).Fangshan;
      case BeijingSubway.Yizhuang:
        return S.of(context).Yizhuang;
      case BeijingSubway.Batong:
        return S.of(context).Batong;
      case BeijingSubway.CapitalAirport:
        return S.of(context).CapitalAirport;
      default:
        return "Unknown";
    }
  }
}

const String DEFAULT_CONFIG = '{}';
