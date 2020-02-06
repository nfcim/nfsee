import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
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
  Map<int, String> results = Map();

  /// Running script
  int running = -1;

  /// Last running script
  /// Used to resolve a race between report and scriptEnd
  int lastRunning = -1;

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
    log('Received action ${scriptModel.action} from script');
    switch (scriptModel.action) {
      case 'poll':
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
        setState(() {
          if (this.running != -1) {
            this.results[this.running] += scriptModel.data.toString() + '\n';
          } else if (this.lastRunning != -1) {
            this.results[this.lastRunning] +=
                scriptModel.data.toString() + '\n';
          }
        });
        break;

      case 'finish':
        await FlutterNfcKit.finish();
        setState(() {
          this.lastRunning = this.running;
          this.running = -1;
        });
        break;

      case 'log':
        log('Log from script: ${message.data.toString()}');
        break;

      default:
        assert(false, 'Unknown action ${scriptModel.action}');
        break;
    }
  }

  void _runScript(SavedScript script) async {
    this.setState(() {
      this.results[script.id] = "";
      this.running = script.id;
    });

    log(script.source);

    _webView.evalJavascript(
        "(async function () {${script.source}})().then(finish).catch((e) => {report(e);finish();});");
  }

  @override
  void dispose() {
    _webViewListener.cancel();
    super.dispose();
  }

  Widget _buildBody(BuildContext context) {
    var outer = context;
    return StreamBuilder<List<SavedScript>>(
      stream: bloc.savedScripts,
      builder: (context, snapshot) {
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
        return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 40),
            child: ExpansionPanelList.radio(
              children: scripts
                  .map((script) => ExpansionPanelRadio(
                        value: script.id,
                        canTapOnHeader: true,
                        headerBuilder: (context, open) => ListTile(
                          subtitle: Text(S.of(context).lastExecutionTime +
                              ': ' +
                              (script.lastUsed != null
                                  ? script.lastUsed
                                      .toString()
                                      .split('.')[0] // remove part before ms
                                  : S.of(context).never)),
                          title: Text(script.name),
                          trailing: this.running == script.id
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 3),
                                )
                              : null,
                        ),
                        body: Container(
                          padding: EdgeInsets.only(
                            bottom: 10,
                            left: 20,
                            right: 20,
                          ),
                          child: Column(
                            children: <Widget>[
                              this._getScriptResult(context, script),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  FlatButton.icon(
                                      // Disable run button if there is a script running in background
                                      onPressed: this.running == -1
                                          ? () async {
                                              this._runScript(script);
                                              await this.bloc.useScript(script);
                                            }
                                          : null,
                                      textTheme: ButtonTextTheme.primary,
                                      // icon:
                                      icon: this.running == script.id
                                          ? Padding(
                                              padding: EdgeInsets.all(4),
                                              child: SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      new AlwaysStoppedAnimation(
                                                    Theme.of(context)
                                                        .disabledColor,
                                                  ),
                                                ),
                                              ))
                                          : Icon(Icons.play_arrow),
                                      label: Text(S.of(context).run)),
                                  Expanded(child: Container()),
                                  IconButton(
                                    onPressed: () async {
                                      await this.bloc.delScript(script);
                                      // TODO: undo
                                    },
                                    color: Colors.black54,
                                    icon: Icon(Icons.delete),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      await Clipboard.setData(
                                          ClipboardData(text: script.source));
                                      var scaff = Scaffold.of(outer);
                                      scaff.hideCurrentSnackBar();
                                      scaff.showSnackBar(SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        content:
                                            Text(S.of(context).scriptCopied),
                                        duration: Duration(seconds: 1),
                                      ));
                                    },
                                    color: Colors.black54,
                                    icon: Icon(Icons.content_copy),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ));
      },
    );
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
                  title: Text(S.of(context).addScript),
                  content: SingleChildScrollView(
                      child: ListBody(children: <Widget>[
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: S.of(context).name,
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
                          hintText: S.of(context).code),
                      minLines: 3,
                      maxLines: null,
                      onChanged: (cont) {
                        this.pendingSrc = cont;
                      },
                    )
                  ])),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(S.of(context).add),
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

  Widget _getScriptResult(BuildContext context, SavedScript script) {
    final result = this.results[script.id];

    if (result != null && result != "") {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.only(bottom: 10),
        color: Color.fromARGB(10, 0, 0, 0),
        child: SelectableText(result),
      );
    }

    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 10),
      child: Center(
          child: Text(
        S.of(context).pressRun,
        style: TextStyle(color: Theme.of(context).disabledColor),
      )),
    );
  }
}
