// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

class S {
  S(this.localeName);
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final String name = locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return S(localeName);
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  final String localeName;

  String get scriptTabTitle {
    return Intl.message(
      'Script Mode',
      name: 'scriptTabTitle',
      desc: '',
      args: [],
    );
  }

  String get scanTabTitle {
    return Intl.message(
      'Scan',
      name: 'scanTabTitle',
      desc: '',
      args: [],
    );
  }

  String get aboutTabTitle {
    return Intl.message(
      'About',
      name: 'aboutTabTitle',
      desc: '',
      args: [],
    );
  }

  String get UPCredit {
    return Intl.message(
      'UnionPay Credit',
      name: 'UPCredit',
      desc: '',
      args: [],
    );
  }

  String get UPDebit {
    return Intl.message(
      'UnionPay Debit',
      name: 'UPDebit',
      desc: '',
      args: [],
    );
  }

  String get UPSecuredCredit {
    return Intl.message(
      'UnionPay Secured Credit',
      name: 'UPSecuredCredit',
      desc: '',
      args: [],
    );
  }

  String get Visa {
    return Intl.message(
      'Visa',
      name: 'Visa',
      desc: '',
      args: [],
    );
  }

  String get MC {
    return Intl.message(
      'MasterCard',
      name: 'MC',
      desc: '',
      args: [],
    );
  }

  String get AMEX {
    return Intl.message(
      'American Express',
      name: 'AMEX',
      desc: '',
      args: [],
    );
  }

  String get JCB {
    return Intl.message(
      'JCB',
      name: 'JCB',
      desc: '',
      args: [],
    );
  }

  String get Discover {
    return Intl.message(
      'Discover',
      name: 'Discover',
      desc: '',
      args: [],
    );
  }

  String get CityUnion {
    return Intl.message(
      'City Union',
      name: 'CityUnion',
      desc: '',
      args: [],
    );
  }

  String get TUnion {
    return Intl.message(
      'T Union',
      name: 'TUnion',
      desc: '',
      args: [],
    );
  }

  String get BMAC {
    return Intl.message(
      'Beijing Yikatong',
      name: 'BMAC',
      desc: '',
      args: [],
    );
  }

  String get LingnanPass {
    return Intl.message(
      'Lingnan Pass',
      name: 'LingnanPass',
      desc: '',
      args: [],
    );
  }

  String get ShenzhenTong {
    return Intl.message(
      'Shenzhen Tong',
      name: 'ShenzhenTong',
      desc: '',
      args: [],
    );
  }

  String get WuhanTong {
    return Intl.message(
      'Wuhan Tong',
      name: 'WuhanTong',
      desc: '',
      args: [],
    );
  }

  String get TMoney {
    return Intl.message(
      'T-Money',
      name: 'TMoney',
      desc: '',
      args: [],
    );
  }

  String get Octopus {
    return Intl.message(
      'Octopus',
      name: 'Octopus',
      desc: '',
      args: [],
    );
  }

  String get Tsinghua {
    return Intl.message(
      'Tsinghua University',
      name: 'Tsinghua',
      desc: '',
      args: [],
    );
  }

  String get Unknown {
    return Intl.message(
      'Unknown',
      name: 'Unknown',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale('en', ''), Locale('zh', ''),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (Locale supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}