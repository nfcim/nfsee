import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:interactive_webview/interactive_webview.dart';

import 'models.dart';
import 'widgets.dart';

class ScanTab extends StatefulWidget {
  static const title = 'Scan';
  static const androidIcon = Icon(Icons.nfc);
  static const iosIcon = Icon(Icons.nfc);

  const ScanTab({Key key, this.androidDrawer}) : super(key: key);

  final Widget androidDrawer;

  @override
  _ScanTabState createState() => _ScanTabState();
}

class _ScanTabState extends State<ScanTab> {
  final _webView = InteractiveWebView();

  @override
  void initState() {
    super.initState();
    this._addWebViewHandler();
  }

  _addWebViewHandler() async {
    _webView.evalJavascript(await rootBundle.loadString('assets/crypto-js.js'));
    _webView.evalJavascript(await rootBundle.loadString('assets/crypto.js'));
    _webView.evalJavascript(await rootBundle.loadString('assets/reader.js'));
    _webView.didReceiveMessage.listen(this._onReceivedMessage);
  }

  _onReceivedMessage(WebkitMessage message) async {
    var scriptModel = ScriptDataModel.fromJson(message.data);
    switch (scriptModel.action) {
      case 'poll':
        final tag = await FlutterNfcKit.poll();
        _webView.evalJavascript("pollCallback(${jsonEncode(tag)})");
        break;

      case 'transceive':
        final rapdu = await FlutterNfcKit.transceive(scriptModel.data);
        _webView.evalJavascript("transceiveCallback('$rapdu')");
        break;

      case 'log':
        log(message.data.toString());
        break;
    }
  }

  void _readTag() async {
    final script = await rootBundle.loadString('assets/read.js');
    _webView.evalJavascript("""async function run() {
    $script
    }
    run();""");
  }

  void _togglePlatform() {
    TargetPlatform _getOppositePlatform() {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return TargetPlatform.android;
      } else {
        return TargetPlatform.iOS;
      }
    }

    debugDefaultTargetPlatformOverride = _getOppositePlatform();
    // This rebuilds the application. This should obviously never be
    // done in a real app but it's done here since this app
    // unrealistically toggles the current platform for demonstration
    // purposes.
    WidgetsBinding.instance.reassembleApplication();
  }

  // ===========================================================================
  // Non-shared code below because:
  // - Android and iOS have different scaffolds
  // - There are differenc items in the app bar / nav bar
  // - Android has a hamburger drawer, iOS has bottom tabs
  // - The iOS nav bar is scrollable, Android is not
  // - Pull-to-refresh works differently, and Android has a button to trigger it too
  //
  // And these are all design time choices that doesn't have a single 'right'
  // answer.
  // ===========================================================================
  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ScanTab.title),
        actions: [
          IconButton(
            icon: Icon(Icons.shuffle),
            onPressed: _togglePlatform,
          ),
        ],
      ),
      drawer: widget.androidDrawer,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/tap.png', height: 240),
            Text(
              'Current state:',
            ),
            FlatButton(
              onPressed: _readTag,
              child:
                  Row(children: <Widget>[Icon(Icons.nfc), Text('Scan a card')]),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIos(BuildContext context) {
    return CustomScrollView(
      slivers: [
        CupertinoSliverNavigationBar(
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(CupertinoIcons.shuffle),
            onPressed: _togglePlatform,
          ),
        ),
      ],
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
