import 'dart:convert';

import 'package:flutter/material.dart';
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
  String name;
  final CardType cardType;
  final String cardNo;
  final dynamic raw;

  CardData({ this.id, this.category, this.name, this.cardNo, this.cardType, this.raw });

  factory CardData.fromDumpedRecord(DumpedRecord rec) {
    final data = jsonDecode(rec.data);
    final config = jsonDecode(rec.config ?? DEFAULT_CONFIG);

    final cardType = getEnumFromString<CardType>(CardType.values, data['card_type']);

    final id = rec.id;
    final category = CardCategory.access;

    return CardData(
      id: id,
      name: config["name"] ?? null,
      category: category,
      cardType: cardType,
      raw: data,
    );
  }

  String generateConfig() {
    final m = Map();
    m.putIfAbsent("name", () => this.name);
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                        Text(this.name, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        Text(this.cardType.getName(context), style: TextStyle(color: Colors.white70, fontSize: 16)),
                      ]),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.white54),
                      ),
                    ]
                  ),
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
