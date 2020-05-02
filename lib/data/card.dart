import 'package:flutter/material.dart';
import 'package:nfsee/data/database/database.dart';

enum CardCategory {
  traffic,
  payment,
  access,
  unspecified,
}

class CardData {
  final CardCategory category;
  final String name;
  final String model;
  final String cardNo;
  final dynamic raw;

  CardData({ this.category, this.name, this.cardNo, this.model, this.raw });

  Widget homepageCard() {
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
                        Text(this.model, style: TextStyle(color: Colors.white70, fontSize: 16)),
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
