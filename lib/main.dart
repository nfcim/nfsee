import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:interactive_webview/interactive_webview.dart';

import 'package:nfsee/data/blocs/bloc.dart';
import 'package:nfsee/data/blocs/provider.dart';
import 'package:nfsee/data/card.dart';
import 'package:nfsee/data/database/database.dart';
import 'package:nfsee/generated/l10n.dart';
import 'package:nfsee/models.dart';
import 'package:nfsee/ui/card_physics.dart';
import 'package:nfsee/ui/home.dart';
import 'package:nfsee/utilities.dart';
import 'package:nfsee/ui/scripts.dart';
import 'package:nfsee/ui/settings.dart';
import 'package:nfsee/ui/widgets.dart';

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
        onGenerateTitle: (context) {
          return S.of(context).homeScreenTitle;
        },
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
  StreamSubscription _webViewListener;
  var _reading = false;
  Exception error;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  PageController topController;
  int currentTop = 1;

  NFSeeAppBloc get bloc => BlocProvider.provideBloc(context);

  @override
  void initState() {
    super.initState();
    this._initSelf();
  }

  @override
  void reassemble() {
    this._initSelf();
    super.reassemble();
  }

  void _initSelf() async {
    topController = PageController(
      initialPage: this.currentTop,
    );
    await this._reloadWebview();
  }

  @override
  void dispose() {
    _webViewListener.cancel();
    _webViewListener = null;
    topController.dispose();
    super.dispose();
  }

  Future<void> _reloadWebview() async {
    // _webView.loadHTML("<!DOCTYPE html>");
    _webView.evalJavascript(await rootBundle.loadString('assets/ber-tlv.js'));
    _webView.evalJavascript(await rootBundle.loadString('assets/crypto-js.js'));
    _webView.evalJavascript(await rootBundle.loadString('assets/crypto.js'));
    _webView.evalJavascript(await rootBundle.loadString('assets/reader.js'));
    _webView.evalJavascript(await rootBundle.loadString('assets/felica.js'));
    _webView.evalJavascript(await rootBundle.loadString('assets/codes.js'));
    await this._addWebViewHandler();
  }

  Future<void> _addWebViewHandler() async {
    if(_webViewListener != null)
      _webViewListener.cancel();
    _webViewListener = _webView.didReceiveMessage.listen(_onReceivedMessage);
  }

  void showSnackbar(SnackBar snackBar) {
    if (_scaffoldKey.currentState != null) {
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  void _onReceivedMessage(WebkitMessage message) async {
    if (webviewOwner != WebViewOwner.Main) {
      return;
    }
    var scriptModel = ScriptDataModel.fromJson(message.data);
    log('[Main] Received action ${scriptModel.action} from script');
    switch (scriptModel.action) {
      case 'poll':
        error = null;
        try {
          final tag = await FlutterNfcKit.poll(iosAlertMessage: S.of(context).waitForCard);
          _webView.evalJavascript("pollCallback(${jsonEncode(tag)})");
          FlutterNfcKit.setIosAlertMessage(S.of(context).cardPolled);
        } on PlatformException catch (e) {
          error = e;
          // no need to do anything with FlutterNfcKit, which will reset itself
          log('Poll error: ${e.toDetailString()}');
          _closeReadModal(this.context);
          showSnackbar(SnackBar(
              content:
                  Text('${S.of(context).readFailed}: ${e.toDetailString()}')));
          // reject the promise
          _webView.evalJavascript("pollErrorCallback(${e.toJsonString()})");
        }
        break;

      case 'transceive':
        try {
          log('TX: ${scriptModel.data}');
          final rapdu = await FlutterNfcKit.transceive(scriptModel.data as String);
          log('RX: $rapdu');
          _webView.evalJavascript("transceiveCallback('$rapdu')");
        } on PlatformException catch (e) {
          error = e;
          // we need to explicitly finish the reader session now **in the script** to stop any following operations,
          // otherwise a following poll might crash the entire application,
          // because ReaderMode is still enabled, and the obselete MethodChannel.Result will be re-used.
          log('Transceive error: ${e.toDetailString()}');
          _closeReadModal(this.context);
          showSnackbar(SnackBar(
              content:
                  Text('${S.of(context).readFailed}: ${e.toDetailString()}')));
          _webView
              .evalJavascript("transceiveErrorCallback(${e.toJsonString()})");
        }
        break;

      case 'report':
        _closeReadModal(this.context);
        final id = await bloc.addDumpedRecord(jsonEncode(scriptModel.data));
        // TODO: pass to home page
        break;

      case 'finish':
        if (error != null) {
          await FlutterNfcKit.finish(iosErrorMessage: S.of(context).readFailed);
          error = null;
        } else {
          await FlutterNfcKit.finish(iosAlertMessage: S.of(context).readSucceeded);
        }
        break;

      case 'log':
        log('Log from script: ${scriptModel.data.toString()}');
        break;

      default:
        assert(false, 'Unknown action ${scriptModel.action}');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = BottomNavigationBar(
      currentIndex: this.currentTop,
      onTap: (e) async {
        setState(() {
          this.currentTop = e;
        });
        if(e == 0)
          webviewOwner = WebViewOwner.Script;
        else
          webviewOwner = WebViewOwner.Main;
        await this._reloadWebview();
        this.topController.animateToPage(e, duration: Duration(milliseconds: 500), curve: Curves.ease);
      },
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.code),
          title: Text(S.of(context).scriptTabTitle),
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.nfc),
          title: Text(S.of(context).scanTabTitle),
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          title: Text(S.of(context).settingsTabTitle),
        ),
      ],
    );

    final top = this._buildTop(context);

    return Scaffold(
      body: top,
      bottomNavigationBar: bottom,
    );
  }

  Widget _buildTop(context) {
    final scripts = ScriptsAct();
    final home = HomeAct(readCard: () { return this._readTag(this.context); });
    final settings = SettingsAct();
    return PageView(
      controller: topController,
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[scripts, home, settings],
      onPageChanged: (page) {
        this.setState(() { this.currentTop = page; });
      },
    );
  }

  Future<bool> _readTag(BuildContext context) async {
    // Because we are launching an modal bottom sheet, user should not be able to intereact with the app anymore
    assert(!_reading);

    _reading = true;
    var modal;
    if (defaultTargetPlatform == TargetPlatform.android) {
      modal = showModalBottomSheet(
        context: context,
        builder: this._buildReadModal,
      );
    } else {
      modal = Future.value(true);
    }

    final script = await rootBundle.loadString('assets/read.js');
    _webView.evalJavascript(script);
    // this._mockRead();

    bool cardRead = true;
    if ((await modal) != true) {
      // closed by user, reject the promise
      _webView.evalJavascript("pollErrorCallback('User cancelled operation')");
      cardRead = false;
    }

    _reading = false;
    return cardRead;
  }

  void _closeReadModal(BuildContext context) {
    if (_reading && defaultTargetPlatform != TargetPlatform.iOS) {
      Navigator.of(context).pop(true);
    }
  }

  Widget _buildReadModal(BuildContext context) {
    return Container(
        child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  S.of(context).waitForCard,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Image.asset('assets/read.webp', height: 200),
              ],
            )));
  }
}

const String DEFAULT_CONFIG = '{}';
