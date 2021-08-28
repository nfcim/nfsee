import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:interactive_webview_null_safety/interactive_webview.dart';
import 'package:nfsee/ui/custom_expansion_panel.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nfsee/data/blocs/bloc.dart';
import 'package:nfsee/data/blocs/provider.dart';
import 'package:nfsee/data/database/database.dart';
import 'package:nfsee/generated/l10n.dart';
import 'package:nfsee/models.dart';
import 'package:nfsee/utilities.dart';

class ScriptsAct extends StatefulWidget {
  static const androidIcon = Icon(Icons.code);
  static const iosIcon = Icon(Icons.code);

  @override
  _ScriptsActState createState() => _ScriptsActState();
}

class _ScriptsActState extends State<ScriptsAct>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final _webView = InteractiveWebView();
  StreamSubscription _webViewListener;
  StreamSubscription _webViewReloadListener;

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

  ScrollController scroll;
  Animation<double> appbarFloat;
  double appbarFloatVal = 0;
  AnimationController appbarFloatTrans;

  Animation<double> runningOpacity;
  double runningOpacityVal = 0;
  AnimationController runningOpacityTrans;

  @override
  void initState() {
    super.initState();
    this._initSelf();
  }

  void _initSelf() {
    this._reloadWebviewListener();

    appbarFloatTrans = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);

    runningOpacityTrans = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this)
      ..repeat(reverse: true, period: Duration(seconds: 1));

    appbarFloat = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: appbarFloatTrans,
      curve: Curves.ease,
    ));

    appbarFloat.addListener(() {
      this.setState(() {
        this.appbarFloatVal = appbarFloat.value;
      });
    });

    runningOpacity = Tween<double>(
      begin: 0.3,
      end: 1,
    ).animate(CurvedAnimation(
      parent: runningOpacityTrans,
      curve: Curves.ease,
    ));

    runningOpacity.addListener(() {
      this.setState(() {
        this.runningOpacityVal = runningOpacity.value;
      });
    });

    scroll = ScrollController();
    scroll.addListener(() {
      if (scroll.position.pixels != 0)
        this.appbarFloatTrans.animateTo(1);
      else
        this.appbarFloatTrans.animateBack(0);
    });
  }

  @override
  void reassemble() {
    this._initSelf();
    super.reassemble();
  }

  void _reloadWebviewListener() {
    if (_webViewListener != null) _webViewListener.cancel();
    if (_webViewReloadListener != null) _webViewReloadListener.cancel();

    _webViewListener =
        _webView.didReceiveMessage.listen(this._onReceivedMessage);
    _webViewReloadListener = _webView.stateChanged.listen((e) async {
      log(e.type.toString());
      if (e.type == WebViewState.didFinish) {
        log("reload detected");
        // Reload
        setState(() {
          this.running = -1;
          this.lastRunning = -1;
        });

        log("Reset listener");
        this._reloadWebviewListener();
      }
    });
  }

  @override
  void dispose() {
    log("DISPOSE");
    _webViewListener.cancel();
    _webViewReloadListener.cancel();
    _webViewListener = null;
    _webViewReloadListener = null;
    this.appbarFloatTrans.dispose();
    this.runningOpacityTrans.dispose();
    super.dispose();
  }

  void _onReceivedMessage(WebkitMessage message) async {
    log(webviewOwner.toString());
    if (webviewOwner != WebViewOwner.Script) {
      return;
    }
    var scriptModel = ScriptDataModel.fromJson(message.data);
    log('[Script] Received action ${scriptModel.action} from script');
    switch (scriptModel.action) {
      case 'poll':
        try {
          final tag = await FlutterNfcKit.poll(
              iosAlertMessage: S.of(context).waitForCard);
          _webView.evalJavascript("pollCallback(${jsonEncode(tag)})");
          FlutterNfcKit.setIosAlertMessage(S.of(context).executingScript);
        } on PlatformException catch (e) {
          log('Poll exception: ${e.toDetailString()}');
          _webView.evalJavascript("pollErrorCallback(${e.toJsonString()})");
        }
        break;

      case 'transceive':
        try {
          final rapdu = await FlutterNfcKit.transceive(scriptModel.data);
          _webView.evalJavascript("transceiveCallback('$rapdu')");
        } on PlatformException catch (e) {
          log('Transceive exception: ${e.toDetailString()}');
          _webView
              .evalJavascript("transceiveErrorCallback(${e.toJsonString()})");
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
        if (this.errors[this.running] == true) {
          await FlutterNfcKit.finish(iosErrorMessage: S.of(context).readFailed);
        } else {
          await FlutterNfcKit.finish(
              iosAlertMessage: S.of(context).readSucceeded);
        }
        log("Reseting running state");
        setState(() {
          this.lastRunning = this.running;
          this.running = -1;
        });
        break;

      case 'log':
        log('Log from script: ${scriptModel.data.toString()}');
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
      _webView.evalJavascript('''
          (async function() {
            let source = $encoded;
            await eval(source);
          })().catch((e) => error(e.toString())).finally(finish);
      ''');
    } catch (e) {
      log(e);
    }
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
                  child: Text(MaterialLocalizations.of(context).okButtonLabel),
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
        '${S.of(context).script} ${script.name} ${S.of(context).deleted}';

    if (defaultTargetPlatform == TargetPlatform.android) {
      var scaffold = Scaffold.of(context);
      scaffold.hideCurrentSnackBar();
      scaffold
          .showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(message),
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: S.of(context).undo,
              onPressed: () {},
            ),
          ))
          .closed
          .then((reason) async {
        switch (reason) {
          case SnackBarClosedReason.action:
            // user cancelled deletion
            await this
                .bloc
                .addScript(script.name, script.source, script.creationTime);
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
                  child: Text(MaterialLocalizations.of(context).okButtonLabel),
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
    return Container(
        child: StreamBuilder<List<SavedScript>>(
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
        // filter only visible scripts
        final scripts = snapshot.data.toList()
          ..sort((a, b) => a.creationTime.compareTo(b.creationTime));

        return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 40, top: 120),
            controller: scroll,
            child: NFSeeExpansionPanelList.radio(
              elevation: 1,
              children: scripts
                  .map((script) => NFSeeExpansionPanelRadio(
                        running: this.running == script.id,
                        value: script.id,
                        canTapOnHeader: true,
                        headerBuilder: (context, open) => Opacity(
                          child: ListTile(
                            subtitle: Text(S.of(context).lastExecutionTime +
                                ': ' +
                                (script.lastUsed != null
                                    ? script.lastUsed
                                        .toString()
                                        .split('.')[0] // remove part before ms
                                    : S.of(context).never)),
                            title: Text(script.name),
                          ),
                          opacity:
                              this.running == script.id ? runningOpacityVal : 1,
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
                                                    Theme.of(context)
                                                        .disabledColor,
                                                  ),
                                                ),
                                              ))
                                          : Icon(Icons.play_arrow),
                                      label: Text(S.of(context).run)),
                                  Expanded(child: Container()),
                                  IconButton(
                                    onPressed: () {
                                      _showScriptDialog(script);
                                    },
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    icon: Icon(Icons.edit),
                                    tooltip: S.of(context).edit,
                                  ),
                                  IconButton(
                                    onPressed: () async =>
                                        _deleteScript(context, script),
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    icon: Icon(Icons.delete),
                                    tooltip: S.of(context).delete,
                                  ),
                                  IconButton(
                                      onPressed: () async {
                                        await Clipboard.setData(
                                            ClipboardData(text: script.source));
                                        _showMessage(context,
                                            '${S.of(context).script} ${script.name} ${S.of(context).copied}');
                                      },
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      icon: Icon(Icons.content_copy),
                                      tooltip: S.of(context).copy),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ));
      },
    ));
  }

  void _addOrModifyScript() async {
    if (this.currentSource == '') {
      return;
    }
    if (this.currentId == -1) {
      log("Adding script: ${this.currentName}");

      await this.bloc.addScript(
          this.currentName == '' ? 'Script' : this.currentName,
          this.currentSource);
    } else {
      log("Modifying script: ${this.currentName}");
      await this.bloc.updateScriptContent(
          this.currentId,
          this.currentName == '' ? 'Script' : this.currentName,
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
          hintText: S.of(context).name,
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
            border: OutlineInputBorder(), hintText: S.of(context).code),
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
      // _showScriptDialogIos(id, name, source);
      _showScriptDialogAndroid(id, name, source);
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
            title: Text(id == -1
                ? S.of(context).addScript
                : S.of(context).modifyScript),
            content: _buildAddScriptDialogContent(),
            actions: <Widget>[
              FlatButton(
                child:
                    Text(MaterialLocalizations.of(context).cancelButtonLabel),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
              FlatButton(
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
                onPressed: _addOrModifyScript,
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
            title: Text(S.of(context).addScript),
            content: _buildAddScriptDialogContent(),
            actions: <Widget>[
              CupertinoButton(
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
                onPressed: _addOrModifyScript,
              ),
              CupertinoButton(
                child:
                    Text(MaterialLocalizations.of(context).cancelButtonLabel),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final title = Transform.translate(
        offset: Offset(0, 20 * (1 - appbarFloatVal)),
        child: AppBar(
            elevation: math.max((appbarFloatVal - 0.8) / 0.2 * 4, 0),
            backgroundColor:
                Theme.of(context).primaryColor.withOpacity(appbarFloatVal),
            title: Text(
              S.of(context).scriptTabTitle,
              style: Theme.of(context).primaryTextTheme.headline6.copyWith(
                    fontSize: 20 + 12 * (1 - appbarFloatVal),
                  ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.add,
                    color: Theme.of(context).primaryTextTheme.headline5.color),
                onPressed: _showScriptDialog,
                tooltip: S.of(context).addScript,
              ),
              IconButton(
                icon: Icon(Icons.help,
                    color: Theme.of(context).primaryTextTheme.headline5.color),
                tooltip: S.of(context).help,
                onPressed: () {
                  launch('https://nfsee.nfc.im/js-extension/');
                },
              ),
            ]));

    return Stack(
      children: <Widget>[
        Builder(builder: _buildBody),
        Column(children: [
          PreferredSize(child: title, preferredSize: Size.fromHeight(56))
        ]),
      ],
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
              color:
                  error ? Colors.red : Theme.of(context).colorScheme.onSurface),
        ),
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

  @override
  bool get wantKeepAlive => true;
}
