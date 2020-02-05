import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:interactive_webview/interactive_webview.dart';

import '../data/blocs/bloc.dart';
import '../data/blocs/provider.dart';
import '../data/database/database.dart';
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

  NFSeeAppBloc get bloc => BlocProvider.provideBloc(context);

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
        log('Poll');
        try {
          final tag = await FlutterNfcKit.poll();
          _webView.evalJavascript("pollCallback(${jsonEncode(tag)})");
        } catch (e) {
          final errorMessage = 'Poll exception: ${e.toString()}';
          log(errorMessage);
        }
        break;

      case 'transceive':
        try {
          final rapdu = await FlutterNfcKit.transceive(scriptModel.data);
          _webView.evalJavascript("transceiveCallback('$rapdu')");
        } catch (e) {
          final errorMessage = 'Transceive exception: ${e.toString()}';
          log(errorMessage);
          _webView.evalJavascript("transceiveErrorCallback()");
        }
        break;

      case 'report':
        await FlutterNfcKit.finish();
        setState(() {
          result += scriptModel.data.toString() + '\n';
        });
        break;

      case 'log':
        log(message.data.toString());
        break;
    }
  }

  void _runScript(String src) async {
    _webView.evalJavascript("(async function () {$src})();");
  }

  @override
  void dispose() {
    _webViewListener.cancel();
    super.dispose();
  }

  Widget _buildBody(BuildContext context) {
    var outer = context;
    return Scrollbar(
        child: StreamBuilder<List<SavedScript>>(
            stream: bloc.savedScripts,
            builder: (context, snapshot) {
              log(snapshot.data.toString());
              if (!snapshot.hasData || snapshot.data.length == 0) {
                return Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image.asset('assets/empty.png', height: 200),
                        Text(S.of(context).noHistoryFound),
                      ],
                    ));
              }
              final scripts = snapshot.data.reversed.toList();
              return ListView.builder(
                padding: EdgeInsets.only(bottom: 48),
                itemCount: scripts.length,
                itemBuilder: (context, index) {
                  final s = scripts[index];
                  return ScriptEntry(
                      script: s,
                      execute: () {
                        showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Script: ${s.name}"),
                                content: Text('Result:\n' + this.result),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () async {
                                      await Clipboard.setData(
                                          ClipboardData(text: s.source));
                                      Navigator.of(context).pop();
                                      var scaff = Scaffold.of(outer);
                                      scaff.hideCurrentSnackBar();
                                      scaff.showSnackBar(SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        content: Text("Copied!"),
                                        duration: Duration(seconds: 1),
                                      ));
                                    },
                                    child: Text("Copy"),
                                  ),
                                  FlatButton(
                                    onPressed: () async {
                                      this._runScript(s.source);
                                      await this.bloc.useScript(s);
                                    },
                                    child: Text("Run"),
                                  ),
                                ],
                              );
                            });
                      },
                      contextPop: () {
                        showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (context) {
                              return SimpleDialog(
                                children: <Widget>[
                                  SimpleDialogOption(
                                    onPressed: () async {
                                      await this.bloc.delScript(s);
                                      Navigator.of(context).pop();
                                    },
                                    child: ListTile(
                                      leading: Icon(Icons.delete,
                                          color:
                                              Theme.of(context).disabledColor),
                                      title: const Text("Delete"),
                                    ),
                                  ),
                                ],
                              );
                            });
                      });
                },
              );
            }));
  }

  // ===========================================================================
  // Non-shared code below because we're using different scaffolds.
  // ===========================================================================

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).scriptTabTitle)),
      bottomNavigationBar: BottomAppBar(
        color: Colors.orange[500],
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children: <Widget>[
            IconButton(
              icon: const Icon(Icons.file_download),
              onPressed: () {
                // TODO(script): download from gist
              },
              color: Colors.black54,
            ),
          ]),
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
                      child: ListBody(children: <Widget>[
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
                          border: OutlineInputBorder(), hintText: "Code"),
                      minLines: 3,
                      maxLines: null,
                      onChanged: (cont) {
                        this.pendingSrc = cont;
                      },
                    )
                  ])),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Add"),
                      onPressed: () async {
                        log("Adding script: ${this.pendingName}");

                        await this.bloc.addScript(
                            this.pendingName == ''
                                ? 'Script'
                                : this.pendingName,
                            this.pendingSrc);

                        this.pendingName = '';
                        this.pendingSrc = '';

                        // Close alert dialog
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              });
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
          onPressed: () {},
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
  final SavedScript script;
  final void Function() execute;
  final void Function() contextPop;

  const ScriptEntry({this.script, this.execute, this.contextPop});

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
                      "Last executed: " +
                          (script.lastUsed != null
                              ? script.lastUsed.toString()
                              : "Never"),
                      style: Theme.of(context)
                          .textTheme
                          .subhead
                          .apply(color: Colors.black38),
                      textAlign: TextAlign.left,
                    )),
                SizedBox(
                    width: double.infinity,
                    child: Text(
                      this.script.name,
                      style: Theme.of(context).textTheme.headline,
                      textAlign: TextAlign.left,
                    ))
              ],
            ),
          ),
        ));
  }
}
