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
  StreamSubscription _webViewListener;

  /// All scripts
  /// TODO(script): sync to database, hence make this one a non-state
  var scripts = List<Script>();

  /// Result from webkit
  var result = '';

  /// Name of new scripts
  var pendingName = '';

  /// Content of new scripts
  var pendingSrc = '';

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

  void _runScript(String src) async {
    _webView.evalJavascript(
        "(async function () {$src})();");
  }

  @override
  void dispose() {
    _webViewListener.cancel();
    super.dispose();
  }

  Widget _buildBody(BuildContext context) {
    var outer = context;
    return SafeArea(
      child: Scrollbar(
        child: ListView(
          children: <Widget>[
            AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: Text(S.of(context).scriptTabTitle),
            ),
          ]..addAll(this.scripts.map((s) {
            return ScriptEntry(
              script: s,
              execute: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Script: ${s.name}"),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: s.source));
                            Navigator.of(context).pop();
                            var scaff = Scaffold.of(outer);
                            scaff.hideCurrentSnackBar();
                            scaff.showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text("Copied!"),
                                duration: Duration(seconds: 1),
                              )
                            );
                          },
                          child: Text("Copy"),
                        ),
                        FlatButton(
                          onPressed: () {
                            this._runScript(s.source);
                          },
                          child: Text("Run"),
                        ),
                      ],
                    );
                  }
                );
              },
              contextPop: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) {
                    return SimpleDialog(
                      children: <Widget>[
                        SimpleDialogOption(
                          onPressed: () {
                            setState(() {
                              this.scripts.remove(s);
                            });
                            Navigator.of(context).pop();
                          },
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Theme.of(context).disabledColor),
                            title: const Text("Delete"),
                          ),
                        ),
                      ],
                    );
                  }
                );
              }
            );
          })),
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
      body: Builder(builder: _buildBody),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          this.pendingSrc = '';
          this.pendingName = '';
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return AlertDialog(
                title: const Text("Add script"),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Name",
                        ),
                        maxLines: 1,

                        onChanged: (cont) {
                          this.pendingName = cont;
                        },
                      ),
                      SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Code"
                        ),
                        minLines: 3,
                        maxLines: null,

                        onChanged: (cont) {
                          this.pendingSrc = cont;
                        },
                      )
                    ]
                  )
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Add"),
                    onPressed: () {
                      log("Adding script: ${this.pendingName}");

                      setState(() {
                        this.scripts.add(Script.create(
                          name: this.pendingName == '' ? "Script" : this.pendingName,
                          source: this.pendingSrc,
                        ));
                      });

                      this.pendingName = '';
                      this.pendingSrc = '';

                      // Close alert dialog
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            }
          );
        },
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
        ),
      ),
      child: _buildBody(context),
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
  final void Function() contextPop;

  const ScriptEntry({ this.script, this.execute, this.contextPop });

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
        onLongPress: this.contextPop,
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
