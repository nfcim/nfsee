import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:interactive_webview/interactive_webview.dart';
import 'package:nfsee/data/blocs/bloc.dart';
import 'package:nfsee/data/blocs/provider.dart';
import 'package:nfsee/data/database/database.dart';
import 'package:nfsee/models.dart';
import 'package:nfsee/ui/card_detail.dart';
import 'package:nfsee/utilities.dart';

import 'ui/scripts.dart';
import 'ui/settings.dart';
import 'ui/widgets.dart';

import 'generated/l10n.dart';

void main() => runApp(NFSeeApp());

class NFSeeApp extends StatefulWidget {
  @override
  _NFSeeAppState createState() => _NFSeeAppState();
}

class _NFSeeAppState extends State<NFSeeApp> {
  NFSeeAppBloc bloc;

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
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        onGenerateTitle: (context) {
          return S.of(context).homeScreenTitle;
        },
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.orange,
          accentColor: Colors.deepOrange,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.orange,
          accentColor: Colors.deepOrange,
        ),
        builder: (context, child) {
          return CupertinoTheme(
            data: CupertinoThemeData(),
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
  final _webView = InteractiveWebView();
  StreamSubscription _webViewListener;
  var _reading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  NFSeeAppBloc get bloc => BlocProvider.provideBloc(context);

  @override
  void initState() {
    super.initState();
    this._addWebViewHandler();
  }

  @override
  void dispose() {
    _webViewListener.cancel();
    super.dispose();
  }

  void _addWebViewHandler() async {
    _webView.evalJavascript(await rootBundle.loadString('assets/ber-tlv.js'));
    _webView.evalJavascript(await rootBundle.loadString('assets/crypto-js.js'));
    _webView.evalJavascript(await rootBundle.loadString('assets/crypto.js'));
    _webView.evalJavascript(await rootBundle.loadString('assets/reader.js'));
    _webView.evalJavascript(await rootBundle.loadString('assets/codes.js'));
    _webViewListener = _webView.didReceiveMessage.listen(_onReceivedMessage);
  }

  void _onReceivedMessage(WebkitMessage message) async {
    if (webviewOwner != WebViewOwner.Main) {
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
          _closeReadModal(this.context);
          _scaffoldKey.currentState
              .showSnackBar(SnackBar(content: Text(errorMessage)));
        }
        break;

      case 'transceive':
        try {
          final rapdu = await FlutterNfcKit.transceive(scriptModel.data);
          _webView.evalJavascript("transceiveCallback('$rapdu')");
        } catch (e) {
          final errorMessage = 'Transceive exception: ${e.toString()}';
          log(errorMessage);
          _closeReadModal(this.context);
          _scaffoldKey.currentState
              .showSnackBar(SnackBar(content: Text(errorMessage)));
          _webView.evalJavascript("transceiveErrorCallback()");
        }
        break;

      case 'finish':
        await FlutterNfcKit.finish();
        _closeReadModal(this.context);
        final id = await bloc.addDumpedRecord(jsonEncode(scriptModel.data));
        this._navigateToTag(DumpedRecord(
          id: id,
          time: DateTime.now(),
          data: jsonEncode(scriptModel.data),
          config: DEFAULT_CONFIG,
        ));
        break;

      case 'log':
        log('Log from script: ${message.data.toString()}');
        break;

      default:
        assert(false, 'Unknown action ${scriptModel.action}');
        break;
    }
  }

  void _navigateToScriptMode() {
    webviewOwner = WebViewOwner.Script;
    Navigator.push(
            context, MaterialPageRoute(builder: (context) => ScriptsAct()))
        .then((_) {
      webviewOwner = WebViewOwner.Main;
    });
  }

  void _navigateToTag(DumpedRecord record) {
    var data = jsonDecode(record.data);
    var config = jsonDecode(record.config ?? DEFAULT_CONFIG);

    // convert card_type to Type CardType
    data['card_type'] =
        getEnumFromString<CardType>(CardType.values, data['card_type']);

    log(data.toString());
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (context) => CardDetailTab(
                data: data, config: config, id: record.id, time: record.time),
          ),
        );
        break;
      case TargetPlatform.iOS:
        Navigator.of(context).push<void>(
          CupertinoPageRoute(
            title: 'Card Detail',
            builder: (context) => CardDetailTab(
                data: data, config: config, id: record.id, time: record.time),
          ),
        );
        break;
      default:
        assert(false, 'Unexpected platform $defaultTargetPlatform');
    }
  }

  Widget _buildAndroidHomePage(BuildContext context) {
    return Scaffold(
        primary: true,
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(S.of(context).homeScreenTitle),
        ),
        bottomNavigationBar: this._buildBottomAppbar(context),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            this._readTag(context);
          },
          child: Icon(Icons.nfc),
          tooltip: S.of(context).scanTabTitle,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        body: Scrollbar(
            child: StreamBuilder<List<DumpedRecord>>(
          stream: bloc.dumpedRecords,
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
            final records = snapshot.data.toList()
              ..sort((a, b) => a.time.compareTo(b.time));
            return ListView.builder(
              padding: EdgeInsets.only(bottom: 48),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final r = records[index];
                return Dismissible(
                  direction: DismissDirection.startToEnd,
                  onDismissed: (direction) async {
                    final message =
                        '${S.of(context).record} ${r.id} ${S.of(context).deleted}';
                    log('Record ${r.id} deleted');
                    await this.bloc.delDumpedRecord(r.id);
                    Scaffold.of(context).hideCurrentSnackBar();
                    Scaffold.of(context)
                        .showSnackBar(SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text(message),
                            duration: Duration(seconds: 5),
                            action: SnackBarAction(
                              label: S.of(context).undo,
                              onPressed: () {},
                            )))
                        .closed
                        .then((reason) async {
                      switch (reason) {
                        case SnackBarClosedReason.action:
                          // user cancelled deletion, restore it
                          await this
                              .bloc
                              .addDumpedRecord(r.data, r.time, r.config);
                          log('Record ${r.id} restored');
                          break;
                        default:
                          break;
                      }
                    });
                  },
                  key: Key(r.id.toString()),
                  background: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.red,
                      padding: EdgeInsets.all(18),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(Icons.delete, color: Colors.white30),
                      )),
                  child: ReportRowItem(
                      record: r,
                      onTap: () {
                        _navigateToTag(r);
                      }),
                );
              },
            );
          },
        )));
  }

  Widget _buildBottomAppbar(BuildContext context) {
    return BottomAppBar(
      color: Colors.orange[500],
      shape: CircularNotchedRectangle(),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(children: <Widget>[
          IconButton(
            icon: const Icon(Icons.description),
            tooltip: S.of(context).scriptTabTitle,
            onPressed: _navigateToScriptMode,
            color: Colors.black54,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: S.of(context).settingsTabTitle,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsAct()));
            },
            color: Colors.black54,
          )
        ]),
      ),
    );
  }

  Widget _buildHistoryPageIos(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(CupertinoIcons.delete),
                onPressed: () {
                  _deleteAll(context);
                },
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(CupertinoIcons.create),
                onPressed: () {
                  _readTag(context);
                },
              )
            ],
          ),
        ),
        SliverPadding(
          padding: MediaQuery.of(context)
              .removePadding(
                  removeTop: true, removeLeft: true, removeRight: true)
              .padding,
          sliver: StreamBuilder<List<DumpedRecord>>(
            stream: bloc.dumpedRecords,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data.length == 0) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Text(
                      "Press button on the top right to scan a NFC tag",
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    );
                  }, childCount: 1),
                );
              }
              final records = snapshot.data.reversed.toList();
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    int realIndex = index ~/ 2;
                    if (index.isEven) {
                      return ReportRowItem(
                          record: records[realIndex],
                          onTap: () {
                            this._navigateToTag(records[realIndex]);
                          });
                    } else {
                      return Divider(height: 0, color: Colors.grey);
                    }
                  },
                  childCount: math.max(1, 2 * records.length - 1),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildHomePageIos(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            title: Text(S.of(context).homeScreenTitle),
            icon: Icon(Icons.nfc),
          ),
          BottomNavigationBarItem(
            title: Text(S.of(context).scriptTabTitle),
            icon: Icon(Icons.play_arrow),
          ),
          BottomNavigationBarItem(
            title: Text(S.of(context).settingsTabTitle),
            icon: Icon(Icons.settings),
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              webviewOwner = WebViewOwner.Main;
              break;
            case 1:
              webviewOwner = WebViewOwner.Script;
              break;
            case 2:
              break;
            default:
              assert(false, 'Unexpected tab');
          }
        },
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (context) => _buildHistoryPageIos(context),
              defaultTitle: S.of(context).homeScreenTitle,
            );
          case 1:
            return CupertinoTabView(
              builder: (context) => ScriptsAct(),
              defaultTitle: S.of(context).scriptTabTitle,
            );
          case 2:
            return CupertinoTabView(
              builder: (context) => SettingsAct(),
              defaultTitle: S.of(context).settingsTabTitle,
            );
          default:
            assert(false, 'Unexpected tab');
            return null;
        }
      },
    );
  }

  @override
  Widget build(context) {
    return PlatformWidget(
      androidBuilder: _buildAndroidHomePage,
      iosBuilder: _buildHomePageIos,
    );
  }

  Future<void> _readTag(BuildContext context) async {
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
      modal = Future.value();
    }

    final script = await rootBundle.loadString('assets/read.js');
    _webView.evalJavascript(script);
    // this._mockRead();

    if ((await modal) != true) {
      // closed by user, cancel polling
      await FlutterNfcKit.finish();
    }

    _reading = false;
  }

  void _deleteAll(BuildContext context) {
    bloc.delAllDumpedRecord();
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
                  S.of(context).waitForCard,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Image.asset('assets/read.webp', height: 200),
              ],
            )));
  }
}

class ReportRowItem extends StatelessWidget {
  const ReportRowItem({this.record, this.onTap});

  final DumpedRecord record;
  final void Function() onTap;

  @override
  Widget build(context) {
    var data = json.decode(record.data);
    var config = json.decode(record.config ?? DEFAULT_CONFIG);

    final type =
        getEnumFromString<CardType>(CardType.values, data["card_type"]);

    var typestr = '${type.getName(context)}';
    if (type == CardType.Unknown) {
      typestr += ' (${data["tag"]["standard"]})';
    }

    var title = typestr;
    var subtitle = "Unknown";
    if (data["detail"] != null && data["detail"]["card_number"] != null) {
      subtitle = data["detail"]["card_number"];
    }
    if (config["name"] != null && config["name"] != "") {
      if (subtitle == null)
        subtitle = typestr;
      else
        subtitle = typestr + " - " + subtitle;
      title = config["name"];
    }

    return ListTile(
      leading: Container(
        height: double.infinity,
        child: Icon(Icons.credit_card),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      onTap: this.onTap,
    );
  }
}
