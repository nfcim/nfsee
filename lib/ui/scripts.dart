import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:nfsee/ui/custom_expansion_panel.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nfsee/data/blocs/bloc.dart';
import 'package:nfsee/data/blocs/provider.dart';
import 'package:nfsee/data/database/database.dart';
import 'package:nfsee/models.dart';
import 'package:nfsee/utilities.dart';

class ScriptsAct extends StatefulWidget {
  static const androidIcon = Icon(Icons.code);
  static const iosIcon = Icon(Icons.code);

  final WebViewManager webview;

  ScriptsAct({required this.webview});

  @override
  _ScriptsActState createState() => _ScriptsActState(webview: this.webview);
}

class _ScriptsActState extends State<ScriptsAct>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final WebViewManager webview;
  StreamSubscription? _webViewListener;

  NFSeeAppBloc? get bloc => BlocProvider.provideBloc(context);

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

  ScrollController? scroll;
  late Animation<double> appbarFloat;
  double appbarFloatVal = 0;
  late AnimationController appbarFloatTrans;

  late Animation<double> runningOpacity;
  double runningOpacityVal = 0;
  late AnimationController runningOpacityTrans;

  _ScriptsActState({required this.webview});

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
    scroll!.addListener(() {
      if (scroll!.position.pixels != 0)
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
    _webViewListener?.cancel();

    _webViewListener =
        webview.stream(WebViewOwner.Script).listen(this._onReceivedMessage);
  }

  @override
  void dispose() {
    log("DISPOSE");
    this.appbarFloatTrans.dispose();
    this.runningOpacityTrans.dispose();
    super.dispose();
  }

  void _onReceivedMessage(WebViewEvent ev) async {
    if (ev.reload) {
      log("[Script] Reload detected");
      // Reload
      setState(() {
        this.running = -1;
        this.lastRunning = -1;
      });

      // With the new stream, we never need to reset listeners.
      // log("Reset listener");
      // this._reloadWebviewListener();
      return;
    }

    assert(ev.message != null);
    var scriptModel = ScriptDataModel.fromJson(json.decode(ev.message!));
    log('[Script] Received action ${scriptModel.action} from script');
    switch (scriptModel.action) {
      case 'poll':
        try {
          final tag =
              await FlutterNfcKit.poll(iosAlertMessage: S(context).waitForCard);
          await webview.run("pollCallback(${jsonEncode(tag)})");
          FlutterNfcKit.setIosAlertMessage(S(context).executingScript);
        } on PlatformException catch (e) {
          log('Poll exception: ${e.toDetailString()}');
          await webview.run("pollErrorCallback(${e.toJsonString()})");
        }
        break;

      case 'transceive':
        try {
          final rapdu = await FlutterNfcKit.transceive(scriptModel.data);
          await webview.run("transceiveCallback('$rapdu')");
        } on PlatformException catch (e) {
          log('Transceive exception: ${e.toDetailString()}');
          await webview.run("transceiveErrorCallback(${e.toJsonString()})");
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
            this.results[this.running] = (scriptModel.data.toString() + '\n') +
                this.results[this.running]!;
          } else if (this.lastRunning != -1) {
            this.results[this.lastRunning] =
                (scriptModel.data.toString() + '\n') +
                    this.results[this.lastRunning]!;
          }
        });
        break;

      case 'finish':
        if (this.errors[this.running] == true) {
          await FlutterNfcKit.finish(iosErrorMessage: S(context).readFailed);
        } else {
          await FlutterNfcKit.finish(iosAlertMessage: S(context).readSucceeded);
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

    log('[Script] Run script: ${script.source}');

    try {
      final wrapped = "(async function() {${script.source}})()";
      final encoded = json.encode(wrapped);
      await webview.run('''
          (async function() {
            let source = $encoded;
            await eval(source);
          })().catch((e) => error(e.toString())).finally(finish);
      ''');
    } catch (e) {
      log('[Script] Error: ${e as String}');
    }
  }

  void _showMessage(BuildContext context, String message) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      var scaffoldMsg = ScaffoldMessenger.of(context);
      scaffoldMsg.hideCurrentSnackBar();
      scaffoldMsg.showSnackBar(SnackBar(
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
    await this.bloc!.delScript(script.id);
    log('Script ${script.name} deleted');
    final message = '${S(context).script} ${script.name} ${S(context).deleted}';

    if (defaultTargetPlatform == TargetPlatform.android) {
      var scaffoldMsg = ScaffoldMessenger.of(context);
      scaffoldMsg.hideCurrentSnackBar();
      scaffoldMsg
          .showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(message),
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: S(context).undo,
              onPressed: () {},
            ),
          ))
          .closed
          .then((reason) async {
        switch (reason) {
          case SnackBarClosedReason.action:
            // user cancelled deletion
            await this
                .bloc!
                .addScript(script.name, script.source, script.creationTime);
            log('Script ${script.name} restored');
            break;
          default:
            break;
        }
      });
    } else {
      await this.bloc!.delScript(script.id);
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
      stream: bloc!.savedScripts,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.length == 0) {
          return Container(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/empty.png', height: 200),
                  Text(S(context).noScriptFound),
                ],
              ));
        }
        // filter only visible scripts
        final scripts = snapshot.data!.toList()
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
                            subtitle: Text(S(context).lastExecutionTime +
                                ': ' +
                                (script.lastUsed != null
                                    ? script.lastUsed
                                        .toString()
                                        .split('.')[0] // remove part before ms
                                    : S(context).never)),
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
                                  TextButton.icon(
                                      // Disable run button if there is a script running in background
                                      onPressed: this.running == -1
                                          ? () async {
                                              this._runScript(script);
                                              await this
                                                  .bloc!
                                                  .updateScriptUseTime(
                                                      script.id);
                                            }
                                          : null,
                                      style: TextButton.styleFrom(
                                          foregroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary),
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
                                      label: Text(S(context).run)),
                                  Expanded(child: Container()),
                                  IconButton(
                                    onPressed: () {
                                      _showScriptDialog(script);
                                    },
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    icon: Icon(Icons.edit),
                                    tooltip: S(context).edit,
                                  ),
                                  IconButton(
                                    onPressed: () async =>
                                        _deleteScript(context, script),
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    icon: Icon(Icons.delete),
                                    tooltip: S(context).delete,
                                  ),
                                  IconButton(
                                      onPressed: () async {
                                        await Clipboard.setData(
                                            ClipboardData(text: script.source));
                                        _showMessage(context,
                                            '${S(context).script} ${script.name} ${S(context).copied}');
                                      },
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      icon: Icon(Icons.content_copy),
                                      tooltip: S(context).copy),
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

      await this.bloc!.addScript(
          this.currentName == '' ? 'Script' : this.currentName,
          this.currentSource);
    } else {
      log("Modifying script: ${this.currentName}");
      await this.bloc!.updateScriptContent(
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
          hintText: S(context).name,
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
            border: OutlineInputBorder(), hintText: S(context).code),
        minLines: 3,
        maxLines: null,
        onChanged: (cont) {
          this.currentSource = cont;
        },
      )
    ]));
  }

  void _showScriptDialog([SavedScript? script]) {
    var id = script?.id ?? -1;
    var name = script?.name ?? '';
    var source = script?.source ?? '';

    // These variables are not used in rendering, so we don't need to setState here
    this.currentId = id;
    this.currentSource = source;
    this.currentName = name;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title:
                Text(id == -1 ? S(context).addScript : S(context).modifyScript),
            content: _buildAddScriptDialogContent(),
            actions: <Widget>[
              TextButton(
                child:
                    Text(MaterialLocalizations.of(context).cancelButtonLabel),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
              TextButton(
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
                onPressed: _addOrModifyScript,
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
              S(context).scriptTabTitle,
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    fontSize: 20 + 12 * (1 - appbarFloatVal),
                  ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.add,
                    color: Theme.of(context).primaryTextTheme.headlineSmall!.color),
                onPressed: _showScriptDialog,
                tooltip: S(context).addScript,
              ),
              IconButton(
                icon: Icon(Icons.help,
                    color: Theme.of(context).primaryTextTheme.headlineSmall!.color),
                tooltip: S(context).help,
                onPressed: () {
                  launchUrl(Uri.parse('https://nfsee.nfc.im/js-extension/'));
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
              color: error!
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
        S(context).pressRun,
        style: TextStyle(color: Theme.of(context).disabledColor),
      )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
