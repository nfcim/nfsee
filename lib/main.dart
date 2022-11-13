import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:nfsee/data/blocs/bloc.dart';
import 'package:nfsee/data/blocs/provider.dart';
import 'package:nfsee/models.dart';
import 'package:nfsee/ui/home.dart';
import 'package:nfsee/ui/scripts.dart';
import 'package:nfsee/ui/settings.dart';
import 'package:nfsee/utilities.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() => runApp(NFSeeApp());

class NFSeeApp extends StatefulWidget {
  @override
  _NFSeeAppState createState() => _NFSeeAppState();
}

class _NFSeeAppState extends State<NFSeeApp> {
  late NFSeeAppBloc bloc;

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
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateTitle: (context) {
          return S(context).homeScreenTitle;
        },
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.orange,
          platform: TargetPlatform.android,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.orange,
          platform: TargetPlatform.android,
        ),
        builder: (context, child) {
          var themeData = CupertinoThemeData();
          if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
            themeData =
                CupertinoThemeData(scaffoldBackgroundColor: Colors.grey[850]);
          }
          return CupertinoTheme(
            data: themeData,
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
  late HomeAct home;
  var _reading = false;
  Exception? error;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  PageController? topController;
  WebViewManager webview = WebViewManager();
  StreamSubscription? _webViewListener;
  int currentTop = 1;

  NFSeeAppBloc get bloc => BlocProvider.provideBloc(context);

  @override
  void initState() {
    super.initState();
    this._initSelf();
  }

  @override
  void reassemble() {
    super.reassemble();
    this._initSelf();
  }

  void _initSelf() {
    _webViewListener =
        webview.stream(WebViewOwner.Main).listen(_onReceivedMessage);
    topController = PageController(
      initialPage: this.currentTop,
    );
    // Webview should reload when it's initialized. So we don't need to call reload here
    // webview.reload();
  }

  @override
  void dispose() {
    topController!.dispose();
    super.dispose();
    _webViewListener?.cancel();
    _webViewListener = null;
  }

  void showSnackbar(SnackBar snackBar) {
    if (_scaffoldMessengerKey.currentState != null) {
      _scaffoldMessengerKey.currentState!.showSnackBar(snackBar);
    }
  }

  void _onReceivedMessage(WebViewEvent ev) async {
    if (ev.reload) return; // Main doesn't care about reload events
    assert(ev.message != null);

    var scriptModel = ScriptDataModel.fromJson(json.decode(ev.message!));
    log('[Main] Received action ${scriptModel.action} from script');
    switch (scriptModel.action) {
      case 'poll':
        error = null;
        try {
          final tag =
              await FlutterNfcKit.poll(iosAlertMessage: S(context).waitForCard);
          final json = tag.toJson();

          // try to read ndef and insert into json
          try {
            final ndef = await FlutterNfcKit.readNDEFRawRecords();
            json["ndef"] = ndef;
          } on PlatformException catch (e) {
            // allow readNDEF to fail
            json["ndef"] = null;
            log('Silent readNDEF error: ${e.toDetailString()}');
          }

          await webview.run("pollCallback(${jsonEncode(json)})");
          FlutterNfcKit.setIosAlertMessage(S(context).cardPolled);
        } on PlatformException catch (e) {
          error = e;
          // no need to do anything with FlutterNfcKit, which will reset itself
          log('Poll error: ${e.toDetailString()}');
          _closeReadModal(this.context);
          showSnackbar(SnackBar(
              content:
                  Text('${S(context).readFailed}: ${e.toDetailString()}')));
          // reject the promise
          await webview.run("pollErrorCallback(${e.toJsonString()})");
        }
        break;

      case 'transceive':
        try {
          log('TX: ${scriptModel.data}');
          final rapdu =
              await FlutterNfcKit.transceive(scriptModel.data as String);
          log('RX: $rapdu');
          await webview.run("transceiveCallback('$rapdu')");
        } on PlatformException catch (e) {
          error = e;
          // we need to explicitly finish the reader session now **in the script** to stop any following operations,
          // otherwise a following poll might crash the entire application,
          // because ReaderMode is still enabled, and the obselete MethodChannel.Result will be re-used.
          log('Transceive error: ${e.toDetailString()}');
          _closeReadModal(this.context);
          showSnackbar(SnackBar(
              content:
                  Text('${S(context).readFailed}: ${e.toDetailString()}')));
          await webview.run("transceiveErrorCallback(${e.toJsonString()})");
        }
        break;

      case 'report':
        _closeReadModal(this.context);
        /* final id = */ await bloc
            .addDumpedRecord(jsonEncode(scriptModel.data));
        home.scrollToNewCard();
        break;

      case 'finish':
        if (error != null) {
          await FlutterNfcKit.finish(iosErrorMessage: S(context).readFailed);
          error = null;
        } else {
          await FlutterNfcKit.finish(iosAlertMessage: S(context).readSucceeded);
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
        if (e == 0)
          webviewOwner = WebViewOwner.Script;
        else
          webviewOwner = WebViewOwner.Main;
        await webview.reload();
        this.topController!.animateToPage(e,
            duration: Duration(milliseconds: 500), curve: Curves.ease);
      },
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.code),
          label: S(context).scriptTabTitle,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.nfc),
          label: S(context).scanTabTitle,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: S(context).settingsTabTitle,
        ),
      ],
    );

    final top = this._buildTop(context);
    final stack = Stack(children: <Widget>[
      Offstage(
        offstage: true,
        child: WebView(
          onWebViewCreated: webview.onWebviewInit,
          onPageFinished: webview.onWebviewPageLoad,
          javascriptMode: JavascriptMode.unrestricted,
          javascriptChannels: {webview.channel},
        ),
      ),
      top
    ]);

    return Scaffold(
      body: stack,
      bottomNavigationBar: bottom,
    );
  }

  Widget _buildTop(context) {
    final scripts = ScriptsAct(webview: this.webview);
    final home = HomeAct(readCard: () {
      return this._readTag(this.context);
    });
    this.home = home;
    final settings = SettingsAct();
    return PageView(
      controller: topController,
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[scripts, home, settings],
      onPageChanged: (page) {
        this.setState(() {
          this.currentTop = page;
        });
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
    // Reload before read to ensure an clear state
    await webview.reload();
    await webview.run(script);
    // this._mockRead();

    bool cardRead = true;
    if ((await modal) != true) {
      // closed by user, reject the promise
      await webview.run("pollErrorCallback('User cancelled operation')");
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
                  S(context).waitForCard,
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
