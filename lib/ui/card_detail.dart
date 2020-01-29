import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models.dart';
import 'widgets.dart';

class CardDetailTab extends StatelessWidget {
  const CardDetailTab({this.cardType, this.cardNumber, this.data});

  final CardType cardType;
  final String cardNumber;
  final dynamic data;

  String _getFilename() {
    switch (cardType) {
      case CardType.UPCredit:
      case CardType.UPDebit:
      case CardType.UPSecuredCredit:
        return 'union_pay';
      case CardType.MC:
        return 'mc';
      case CardType.Visa:
        return 'visa';
      case CardType.AMEX:
        return 'amex';
      case CardType.JCB:
        return 'jcb';
      case CardType.Discover:
        return 'discover';
      case CardType.BMAC:
        return 'bmac';
      case CardType.ShenzhenTong:
        return 'shenzhentong';
      case CardType.LingnanPass:
        return 'lingnanpass';
      case CardType.WuhanTong:
        return 'wuhantong';
      case CardType.CityUnion:
        return 'city_union';
      case CardType.TUnion:
        return 't_union';
      case CardType.Octopus:
        return 'octopus';
      case CardType.TMoney:
        return 't_money';
      case CardType.Tsinghua:
        return 'tsinghua';
      default:
        return '';
    }
  }

  Widget _buildBody() {
    return SafeArea(
      bottom: false,
      left: false,
      right: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            'assets/cards/${_getFilename()}.png',
            height: 150,
          ),
          Text(data.toString()),
        ],
      ),
    );
  }

  // ===========================================================================
  // Non-shared code below because we're using different scaffolds.
  // ===========================================================================

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('name')),
      body: _buildBody(),
    );
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('name'),
        previousPageTitle: 'Scan',
      ),
      child: _buildBody(),
    );
  }

  @override
  Widget build(context) {
    return PlatformWidget(
      androidBuilder: _buildAndroid,
      iosBuilder: _buildIos,
    );
  }
}
