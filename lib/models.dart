import 'package:flutter/cupertino.dart';
import 'package:nfsee/data/database/database.dart';

import 'generated/l10n.dart';

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
      case CardType.Unknown:
      default:
        return S.of(context).Unknown;
    }
  }
}

enum ProcessingCode {
  Authorization,
  BalanceInquiry,
  Cash,
  Void,
  MobileTopup
}

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

enum PBOCTransactionType {
  Load,
  Purchase,
  CompoundPurchase
}

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

