import 'package:nfsee/data/database/database.dart';

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
  VisaCredit,
  VisaDebit,
  VisaPrepaid,
  MCCredit,
  MCDebit,
  MCPrepaid,
  AMEXCredit,
  AMEXDebit,
  AMEXPrepaid,
  CityUnion,
  TUnion,
  BMAC,
  LingnanPass,
  ShenzhenTong,
  WuhanTong,
  TMoney,
  Octopus,
  Tsinghua,
}
