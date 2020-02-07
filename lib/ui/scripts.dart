import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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

  /// Whether last run has error
  Map<int, bool> errors = Map();

  /// Running script
  int running = -1;

  /// Last running script
  /// Used to resolve a race between report and scriptEnd
  int lastRunning = -1;

  /// Id of current script
  var currentId = -1;

  /// Name of current script
  var currentName = '';

  /// Content of current script
  var currentSource = '';

  @override
  void initState() {
    super.initState();
    _webViewListener =
        _webView.didReceiveMessage.listen(this._onReceivedMessage);
  }

  void _onReceivedMessage(WebkitMessage message) async {
    if (webviewOwner != WebViewOwner.Script) {
      return;
    }
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
          _webView.evalJavascript("pollErrorCallback()");
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

      case 'error':
        setState(() {
          if (this.running != -1) {
            this.errors[this.running] = true;
          } else if (this.lastRunning != -1) {
            this.errors[this.lastRunning] = true;
          }
        });
        continue report;
      report:
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
      this.errors[script.id] = false;
      this.results[script.id] = "";
      this.running = script.id;
    });

    log('Run script: ${script.source}');

    try {
      final wrapped = "(async function() {${script.source}})()";
      final encoded = json.encode(wrapped);
      await _webView.evalJavascript('''
          (async function() {
            let source = $encoded;
            await eval(source);
          })().catch((e) => error(e.toString())).finally(finish);
      ''');
    } catch(e) {
      log(e);
    }
  }

  @override
  void dispose() {
    _webViewListener.cancel();
    super.dispose();
  }

  void _showMessage(BuildContext context, String message) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      var scaffold = Scaffold.of(context);
      scaffold.hideCurrentSnackBar();
      scaffold.showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        duration: Duration(seconds: 1),
      ));
    } else {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text(message),
              actions: <Widget>[
                CupertinoButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }

  void _deleteScript(BuildContext context, SavedScript script) async {
    // first hide the script
    await this.bloc.delScript(script.id);
    log('Script ${script.name} deleted');
    final message =
        '${S
        .of(context)
        .script} ${script.name} ${S
        .of(context)
        .deleted}';

    if (defaultTargetPlatform == TargetPlatform.android) {
      var scaffold = Scaffold.of(context);
      scaffold.hideCurrentSnackBar();
      scaffold
          .showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: S
              .of(context)
              .undo,
          onPressed: () {},
        ),
      ))
          .closed
          .then((reason) async {
        switch (reason) {
          case SnackBarClosedReason.action:
            // user cancelled deletion
            await this.bloc.addScript(script.name, script.source, script.creationTime);
            log('Script ${script.name} restored');
            break;
          default:
            break;
        }
      });
    } else {
      await this.bloc.delScript(script.id);
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text(message),
              actions: <Widget>[
                CupertinoButton(
                  child: Text(S.of(context).ok),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
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
                  Text(S
                      .of(context)
                      .noHistoryFound),
                ],
              ));
        }
        // filter only visible scripts
        final scripts = snapshot.data.toList()
          ..sort((a, b) => a.creationTime.compareTo(b.creationTime));

        return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 40),
            child: ExpansionPanelList.radio(
              children: scripts
                  .map((script) =>
                  ExpansionPanelRadio(
                    value: script.id,
                    canTapOnHeader: true,
                    headerBuilder: (context, open) =>
                        ListTile(
                          subtitle: Text(S
                              .of(context)
                              .lastExecutionTime +
                              ': ' +
                              (script.lastUsed != null
                                  ? script.lastUsed
                                  .toString()
                                  .split('.')[0] // remove part before ms
                                  : S
                                  .of(context)
                                  .never)),
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
                                    await this
                                        .bloc
                                        .updateScriptUseTime(
                                        script.id);
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
                                            Theme
                                                .of(context)
                                                .disabledColor,
                                          ),
                                        ),
                                      ))
                                      : Icon(Icons.play_arrow),
                                  label: Text(S
                                      .of(context)
                                      .run)),
                              Expanded(child: Container()),
                              IconButton(
                                onPressed: () {
                                  _showScriptDialog(script);
                                },
                                color: Colors.black54,
                                icon: Icon(Icons.edit),
                                tooltip: S.of(context).edit,
                              ),
                              IconButton(
                                onPressed: () async =>
                                    _deleteScript(context, script),
                                color: Colors.black54,
                                icon: Icon(Icons.delete),
                                tooltip: S.of(context).delete,
                              ),
                              IconButton(
                                onPressed: () async {
                                  await Clipboard.setData(
                                      ClipboardData(text: script.source));
                                  _showMessage(context,
                                      '${S
                                          .of(context)
                                          .script} ${script.name} ${S
                                          .of(context)
                                          .copied}');
                                },
                                color: Colors.black54,
                                icon: Icon(Icons.content_copy),
                                tooltip: S.of(context).copy
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

  void _addOrModifyScript() async {
    if (this.currentId == -1) {
      log("Adding script: ${this.currentName}");

      await this.bloc.addScript(
          this.currentName == '' ? 'Script' : this.currentName,
          this.currentSource);
    } else {
      log("Modifying script: ${this.currentName}");
      await this.bloc.updateScriptContent(
          this.currentId, this.currentName == '' ? 'Script' : this.currentName,
          this.currentSource);
    }

    this.currentId = -1;
    this.currentName = '';
    this.currentSource = '';

    // Close alert dialog
    Navigator.of(context, rootNavigator: true).pop();
  }

  Widget _buildAddScriptDialogContent() {
    return SingleChildScrollView(
        child: ListBody(children: <Widget>[
          TextFormField(
            initialValue: this.currentName,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: S
                  .of(context)
                  .name,
            ),
            maxLines: 1,
            onChanged: (cont) {
              this.currentName = cont;
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            initialValue: this.currentSource,
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: S
                .of(context)
                .code),
            minLines: 3,
            maxLines: null,
            onChanged: (cont) {
              this.currentSource = cont;
            },
          )
        ]));
  }

  void _showScriptDialog([SavedScript script]) {
    var id = script?.id ?? -1;
    var name = script?.name ?? '';
    var source = script?.source ?? '';
    if (defaultTargetPlatform == TargetPlatform.android) {
      _showScriptDialogAndroid(id, name, source);
    } else {
      _showScriptDialogIos(id, name, source);
    }
  }

  // ===========================================================================
  // Non-shared code below because we're using different scaffolds.
  // ===========================================================================

  void _showScriptDialogAndroid(int id, String name, String source) {
    this.currentId = id;
    this.currentSource = source;
    this.currentName = name;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(id == -1 ? S
                .of(context)
                .addScript : S
                .of(context)
                .modifyScript),
            content: _buildAddScriptDialogContent(),
            actions: <Widget>[
              FlatButton(
                child: Text(S
                    .of(context)
                    .ok),
                onPressed: _addOrModifyScript,
              ),
              FlatButton(
                child: Text(S
                    .of(context)
                    .cancel),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ],
          );
        });
  }

  void _showScriptDialogIos(int id, String name, String source) {
    this.currentId = id;
    this.currentSource = source;
    this.currentName = name;

    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(S
                .of(context)
                .addScript),
            content: _buildAddScriptDialogContent(),
            actions: <Widget>[
              CupertinoButton(
                child: Text(S
                    .of(context)
                    .ok),
                onPressed: _addOrModifyScript,
              ),
              CupertinoButton(
                child: Text(S
                    .of(context)
                    .cancel),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ],
          );
        });
  }

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S
          .of(context)
          .scriptTabTitle)),
//      bottomNavigationBar: BottomAppBar(
//        color: Colors.orange[500],
//        shape: CircularNotchedRectangle(),
//        child: Padding(
//          padding: const EdgeInsets.all(8),
//          child: Row(children: <Widget>[
//            IconButton(
//              icon: const Icon(Icons.file_download),
//              onPressed: () {
//                // TODO(script): download from gist
//              },
//              color: Colors.black54,
//            ),
//          ]),
//        ),
//      ),
      body: Builder(builder: _buildBody),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _showScriptDialog,
        tooltip: S.of(context).addScript,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(S
            .of(context)
            .scriptTabTitle),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.create),
          onPressed: _showScriptDialog,
        ),
      ),
      child: SafeArea(child: _buildBody(context)),
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
    final error = this.errors[script.id];

    if (result != null && result != "") {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.only(bottom: 10),
        color: Color.fromARGB(10, 0, 0, 0),
        child: SelectableText(
          result,
          style: TextStyle(
            color: error
            ? Colors.red
            : Theme.of(context).colorScheme.onSurface),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 10),
      child: Center(
          child: Text(
            S
                .of(context)
                .pressRun,
            style: TextStyle(color: Theme
                .of(context)
                .disabledColor),
          )),
    );
  }
}
