import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'widgets.dart';

class CardDetailTab extends StatelessWidget {
  const CardDetailTab({this.data});

  final dynamic data;

  String _getFilename() {
    switch (data['card_type']) {
      case 'UPCredit':
      case 'UPDebit':
      case 'UPSecuredCredit':
        return 'union_pay';
      case 'MC':
        return 'mc';
      case 'Visa':
        return 'visa';
      case 'AMEX':
        return 'amex';
      case 'JCB':
        return 'jcb';
      case 'Discover':
        return 'discover';
      case 'BMAC':
        return 'bmac';
      case 'ShenzhenTong':
        return 'shenzhentong';
      case 'LingnanPass':
        return 'lingnanpass';
      case 'WuhanTong':
        return 'wuhantong';
      case 'CityUnion':
        return 'city_union';
      case 'TUnion':
        return 't_union';
      case 'Octopus':
        return 'octopus';
      case 'TMoney':
        return 't_money';
      case 'Tsinghua':
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
        middle: Text(data['card_type']),
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
