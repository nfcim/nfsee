import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nfsee/data/database/database.dart';
import 'package:nfsee/models.dart';
import 'package:nfsee/utilities.dart';

enum CardCategory {
  traffic,
  payment,
  access,
  unspecified,
}

class CardData {
  int id;
  final CardCategory category;
  String? name;
  CardType? cardType;
  String? cardNo;
  final dynamic raw;
  final DateTime time;

  bool sameAs(CardData? ano) {
    if (ano == null) return false;
    if (id != ano.id) return false;
    if (config != ano.config) return false;
    return true;
  }

  String get formattedTime => DateFormat("MM/dd HH:mm:ss").format(time);

  CardData(
      {required this.id,
      required this.category,
      this.name,
      this.cardNo,
      this.cardType,
      this.raw,
      required this.time});

  factory CardData.fromDumpedRecord(DumpedRecord rec) {
    final data = jsonDecode(rec.data);
    final config = jsonDecode(rec.config);

    final cardType =
        getEnumFromString<CardType>(CardType.values, data['card_type']);

    final id = rec.id;
    final category = CardCategory.access;

    return CardData(
      id: id,
      name: config["name"],
      category: category,
      cardType: cardType,
      raw: data,
      time: rec.time,
    );
  }

  String get config {
    final m = {};
    m.putIfAbsent("name", () => name);
    return jsonEncode(m);
  }

  Widget homepageCard(BuildContext context) {
    final card = Card(
      elevation: 4,
      margin: EdgeInsets.only(),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: <Widget>[
          Image.asset('assets/card-bg.png'),
          AspectRatio(
            aspectRatio: 86 / 54,
            child: Padding(
              padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
              child: Column(
                children: <Widget>[
                  Spacer(),
                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name ?? S(context).unnamedCard,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                          Text(cardType.getName(context),
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16)),
                        ]),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Padding(padding: EdgeInsets.all(10), child: card);
  }
}

const String DEFAULT_CONFIG = '{}';
