import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:interactive_webview/interactive_webview.dart';
import 'package:nfsee/data/blocs/bloc.dart';
import 'package:nfsee/data/blocs/provider.dart';
import 'package:nfsee/data/database/database.dart';
import 'package:nfsee/models.dart';
import 'package:nfsee/ui/card_detail.dart';

import 'ui/about_tab.dart';
import 'ui/scan_tab.dart';
import 'ui/scripts.dart';
import 'ui/settings.dart';
import 'ui/widgets.dart';

import 'generated/l10n.dart';

void main() => runApp(NFSeeApp());

class NFSeeApp extends StatefulWidget {
  @override
  _NFSeeAppState createState() => _NFSeeAppState();
}

class _NFSeeAppState extends State<NFSeeApp> {
  NFSeeAppBloc bloc;

  @override
  void initState() {
    bloc = NFSeeAppBloc();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }

  @override
  Widget build(context) {
    return BlocProvider(
      bloc: bloc,
      // Either Material or Cupertino widgets work in either Material or Cupertino
      // Apps.
      child: MaterialApp(
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        title: 'NFSee',
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.orange,
          accentColor: Colors.deepOrange,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.orange,
          accentColor: Colors.deepOrange,
        ),
        builder: (context, child) {
          return CupertinoTheme(
            data: CupertinoThemeData(),
            child: Material(child: child),
          );
        },
        home: PlatformAdaptingHomePage(),
      ),
    );
  }
}

// Shows a different type of scaffold depending on the platform.
//
// This file has the most amount of non-sharable code since it behaves the most
// differently between the platforms.
//
// These differences are also subjective and have more than one 'right' answer
// depending on the app and content.
class PlatformAdaptingHomePage extends StatefulWidget {
  @override
  _PlatformAdaptingHomePageState createState() =>
      _PlatformAdaptingHomePageState();
}

class _PlatformAdaptingHomePageState extends State<PlatformAdaptingHomePage> {
  final _webView = InteractiveWebView();
  List<DumpedRecord> _records = new List<DumpedRecord>();
  StreamSubscription _webViewListener;
  var _reading = false;

  NFSeeAppBloc get bloc => BlocProvider.provideBloc(context);

  @override
  void initState() {
    super.initState();
    this._addWebViewHandler();
    this._updateRecords();
  }

  void _addWebViewHandler() async {
    _webView.evalJavascript(await rootBundle.loadString('assets/ber-tlv.js'));
    _webView.evalJavascript(await rootBundle.loadString('assets/crypto-js.js'));
    _webView.evalJavascript(await rootBundle.loadString('assets/crypto.js'));
    _webView.evalJavascript(await rootBundle.loadString('assets/reader.js'));
    _webView.evalJavascript(await rootBundle.loadString('assets/codes.js'));
    _webViewListener =
        _webView.didReceiveMessage.listen(this._onReceivedMessage);
  }

  _updateRecords() async {
    var records = await bloc.listDumpedRecords();
    setState(() {
      this._records = records;
    });
  }

  void _onReceivedMessage(WebkitMessage message) async {
    var scriptModel = ScriptDataModel.fromJson(message.data);
    switch (scriptModel.action) {
      case 'poll':
        final tag = await FlutterNfcKit.poll();
        _webView.evalJavascript("pollCallback(${jsonEncode(tag)})");
        break;

      case 'transceive':
        log('TX ${scriptModel.data}');
        final rapdu = await FlutterNfcKit.transceive(scriptModel.data);
        log('RX $rapdu');
        _webView.evalJavascript("transceiveCallback('$rapdu')");
        break;

      case 'report':
        // save result to database
        bloc.addDumpedRecord(scriptModel.data);
        await this._updateRecords();
        // dump results to console
        print(scriptModel.data.toString());
        this._records.forEach((el) => print(el.toString()));
        // finish NFC communication
        await FlutterNfcKit.finish();

        if(_reading)
          Navigator.of(this.context).pop();

        this._navigateToTag(scriptModel.data);
        break;

      case 'log':
        log(message.data.toString());
        break;
    }
  }

  void _navigateToTag(dynamic data) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (context) => CardDetailTab(
                cardType: CardType.CityUnion, cardNumber: '123', data: data),
          ),
        );
        break;
      case TargetPlatform.iOS:
        Navigator.of(context).push<void>(
          CupertinoPageRoute(
            title: 'Card Detail',
            builder: (context) => CardDetailTab(
                cardType: CardType.CityUnion, cardNumber: '123', data: null),
          ),
        );
        break;
      default:
        assert(false, 'Unexpected platform $defaultTargetPlatform');
    }
  }

  Widget _buildAndroidHomePage(BuildContext context) {
    return Scaffold(
      primary: true,
      bottomNavigationBar: BottomAppBar(
        color: Colors.orange[500],
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.description),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ScriptsAct()));
                },
                color: Colors.black54,
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsAct()));
                },
                color: Colors.black54,
              )
            ]
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          this._readTag(context);
        },
        child: Icon(Icons.nfc),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Widget _buildIosHomePage(BuildContext context) {
    return CupertinoApp();
  }

  @override
  Widget build(context) {
    return PlatformWidget(
      androidBuilder: _buildAndroidHomePage,
      iosBuilder: _buildIosHomePage,
    );
  }

  Future<void> _readTag(BuildContext context) async {
    assert(!_reading);

    _reading = true;
    var modal = showModalBottomSheet(
      context: context,
      builder: this._buildReadModal,
    );

    final script = await rootBundle.loadString('assets/read.js');
    _webView.evalJavascript(script);

    await modal;
    _reading = false;
  }

  Widget _buildReadModal(BuildContext context) {
    return Container(
      child:Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "Waiting for cards...",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Image.asset('assets/read.webp', height: 200),
          ],
        )
      )
    );
  }
}
