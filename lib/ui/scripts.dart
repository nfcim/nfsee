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

class ScriptsAct extends StatefulWidget {
  static const title = 'Script';
  static const androidIcon = Icon(Icons.code);
  static const iosIcon = Icon(Icons.code);

  @override
  _ScriptsActState createState() => _ScriptsActState();
}

class _ScriptsActState extends State<ScriptsAct> {
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
      child: Scrollbar(
        child: ListView(
          children: <Widget>[
            AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: Text(S.of(context).scriptTabTitle),
            ),
            ScriptEntry(
              execute: () {
              },
              script: Script.create(
                name: "Test",
                source: "WTF"
              ),
            ),
            ScriptEntry(
              execute: () {
              },
              script: Script.create(
                name: "Test",
                source: "WTF"
              )
            )
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Non-shared code below because we're using different scaffolds.
  // ===========================================================================

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: Colors.orange[500],
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.file_download),
                onPressed: () {
                  // TODO(script): download from gist
                },
                color: Colors.black54,
              ),
            ]
          ),
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _runScript,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(S.of(context).scriptTabTitle),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.play_arrow),
          onPressed: _runScript,
        ),
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

class ScriptEntry extends StatelessWidget {
  final Script script;
  final void Function() execute;

  const ScriptEntry({ this.script, this.execute });

  // TODO: iOS
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(
        left: 10,
        top: 10,
        right: 10,
      ),
      elevation: 2,
      child: InkWell(
        onTap: this.execute,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            top: 16,
            right: 20,
            bottom: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                child: Text(
                  "Last executed: " + (script.lastExecuted != null ? script.lastExecuted.toString() : "Never"),
                  style: Theme.of(context).textTheme.subhead.apply(
                    color: Colors.black38
                  ),
                  textAlign: TextAlign.left,
                )
              ),
              SizedBox(
                width: double.infinity,
                child: Text(
                  this.script.name,
                  style: Theme.of(context).textTheme.headline,
                  textAlign: TextAlign.left,
                )
              )
            ],
          ),
        ),
      )
    );
  }
}
