import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:interactive_webview/interactive_webview.dart';

import '../generated/l10n.dart';
import '../models.dart';
import 'widgets.dart';

class ScriptTab extends StatefulWidget {
  static const title = 'Script';
  static const androidIcon = Icon(Icons.code);
  static const iosIcon = Icon(Icons.code);

  const ScriptTab({Key key}) : super(key: key);

  @override
  _ScriptTabState createState() => _ScriptTabState();
}

class _ScriptTabState extends State<ScriptTab> {
  final _webView = InteractiveWebView();
  final _scriptTextController = TextEditingController();
  StreamSubscription _webViewListener;
  var result = '';

  @override
  void initState() {
    super.initState();
    _webViewListener =
        _webView.didReceiveMessage.listen(this._onReceivedMessage);
  }

  void _onReceivedMessage(WebkitMessage message) async {
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

      case 'report':
        setState(() {
          result += scriptModel.data.toString() + '\n';
        });
        await FlutterNfcKit.finish();
        break;

      case 'log':
        log(message.data.toString());
        break;
    }
  }

  void _runScript() async {
    _webView.evalJavascript(
        "(async function () {${_scriptTextController.text}})();");
  }

  @override
  void dispose() {
    _webViewListener.cancel();
    _scriptTextController.dispose();
    super.dispose();
  }

  Widget _buildBody() {
    return SafeArea(
      bottom: false,
      left: false,
      right: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _scriptTextController,
            keyboardType: TextInputType.multiline,
            maxLines: 10,
          ),
          Text('Result:\n$result')
        ],
      ),
    );
  }

  // ===========================================================================
  // Non-shared code below because we're using different scaffolds.
  // ===========================================================================

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).scriptTabTitle)),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.done),
        onPressed: _runScript,
      ),
    );
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(S.of(context).scriptTabTitle),
        previousPageTitle: 'Songs',
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
