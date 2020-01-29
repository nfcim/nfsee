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

import 'ui/scripts.dart';
import 'ui/settings.dart';
import 'ui/widgets.dart';

import 'generated/l10n.dart';

const SAMPLE =
    '{"action":"report","data":{"card_number":12345678,"balance":123,"issue_date":20200101,"expiry_date":20300101,"purchase_atc":158,"title":"北京一卡通（非互联互通版）","transactions":[]}}';

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
  void dispose() {
    super.dispose();
    bloc.dispose();
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
        title: 'NFSee',
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
  List<DumpedRecord> _records = new List<DumpedRecord>();
  StreamSubscription _webViewListener;
  var _reading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  NFSeeAppBloc get bloc => BlocProvider.provideBloc(context);

  @override
  void initState() {
    super.initState();
    this._addWebViewHandler();
  }

  void _addWebViewHandler() async {
    _webView.evalJavascript(await rootBundle.loadString('assets/ber-tlv.js'));
    _webView.evalJavascript(await rootBundle.loadString('assets/crypto-js.js'));
    _webView.evalJavascript(await rootBundle.loadString('assets/crypto.js'));
    _webView.evalJavascript(await rootBundle.loadString('assets/reader.js'));
    _webView.evalJavascript(await rootBundle.loadString('assets/codes.js'));
    _webViewListener = _webView.didReceiveMessage.listen(_onReceivedMessage);
  }

  _updateRecords() async {
    var records = await bloc.listDumpedRecords();
    setState(() {
      this._records = records;
    });
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
          _closeReadModal(this.context);
          _scaffoldKey.currentState
              .showSnackBar(SnackBar(content: Text(errorMessage)));
        }
        break;

      case 'transceive':
        try {
          final rapdu = await FlutterNfcKit.transceive(scriptModel.data);
          log('RX $rapdu');
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

      case 'report':
        // save result to database
        bloc.addDumpedRecord(scriptModel.data);
        await this._updateRecords();
        // dump results to console
        print(scriptModel.data.toString());
        this._records.forEach((el) => print(el.toString()));
        // finish NFC communication
        await FlutterNfcKit.finish();

        _closeReadModal(this.context);

        this._navigateToTag(scriptModel.data);
        break;

      case 'log':
        log(message.data.toString());
        break;
    }
  }

  void _navigateToScriptMode() {
    _webViewListener.cancel();
    Navigator.push(
            context, MaterialPageRoute(builder: (context) => ScriptsAct()))
        .then((_) {
      _webViewListener = _webView.didReceiveMessage.listen(_onReceivedMessage);
    });
  }

  void _navigateToTag(dynamic data) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (context) => CardDetailTab(
              cardType: CardType.values.firstWhere((it) =>
                  it.toString() == "CardType.${data['card_type']}"),
              cardNumber: '123',
              data: data,
            ),
          ),
        );
        break;
      case TargetPlatform.iOS:
        Navigator.of(context).push<void>(
          CupertinoPageRoute(
            title: 'Card Detail',
            builder: (context) => CardDetailTab(
              cardType: CardType.values.firstWhere((it) =>
              it.toString() == "CardType.${data['card_type']}"),
              cardNumber: '123',
              data: null,
            ),
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
          title: Text("History"),
        ),
        bottomNavigationBar: this._buildBottomAppbar(context),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            this._readTag(context);
          },
          child: Icon(Icons.nfc),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        body: Scrollbar(
            child: StreamBuilder<List<DumpedRecord>>(
          stream: bloc.dumpedRecords,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data.length == 0) {
              return const Align(
                alignment: Alignment.center,
                child: Text('No history found'),
              );
            }
            final records = snapshot.data;
            return ListView.builder(
              padding: EdgeInsets.only(bottom: 48),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final r = records[index];
                return ReportRowItem(
                    record: r,
                    onTap: () {
                      _navigateToTag(r);
                    });
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
            onPressed: _navigateToScriptMode,
            color: Colors.black54,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
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

  Widget _buildIosHistoryPage(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(CupertinoIcons.create),
            onPressed: () {
              _readTag(context);
            },
          ),
        ),
        SliverPadding(
            padding: MediaQuery.of(context)
                .removePadding(
                    removeTop: true, removeLeft: true, removeRight: true)
                .padding,
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (this._records.length == 0) {
                    return Text(
                      "Press button on the top right to scan a NFC tag",
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    );
                  } else {
                    int realIndex = index ~/ 2;
                    if (index.isEven) {
                      return ReportRowItem(
                          record: this._records[realIndex],
                          onTap: () {
                            this._navigateToTag(this._records[realIndex]);
                          });
                    } else {
                      return Divider(height: 0, color: Colors.grey);
                    }
                  }
                },
                childCount: math.max(1, 2 * this._records.length - 1),
              ),
            ))
      ],
    );
  }

  Widget _buildIosHomePage(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            title: Text("History"),
            icon: Icon(Icons.nfc),
          ),
          BottomNavigationBarItem(
            title: Text("Script"),
            icon: Icon(Icons.play_arrow),
          ),
          BottomNavigationBarItem(
            title: Text("Settings"),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (context) => _buildIosHistoryPage(context),
              defaultTitle: "History",
            );
          case 1:
            return CupertinoTabView(
              builder: (context) => ScriptsAct(),
              defaultTitle: "Script",
            );
          case 2:
            return CupertinoTabView(
              builder: (context) => SettingsAct(),
              defaultTitle: "Settings",
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
      iosBuilder: _buildIosHomePage,
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
    // this.mockRead();

    if ((await modal) != true) {
      // closed by user, cancel polling
      await FlutterNfcKit.finish();
    }

    _reading = false;
  }

  void _mockRead() async {
    log("Mock read start");
    await Future.delayed(Duration(seconds: 1));
    this._onReceivedMessage(WebkitMessage("", json.decode(SAMPLE)));
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
                  "Waiting for cards...",
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
    var title = data["title"];
    return ListTile(
      leading: Container(
        height: double.infinity,
        child: Icon(Icons.credit_card),
      ),
      title: Text('${record.id}: $title'),
      subtitle: data["card_number"] != null
          ? Text(data["card_number"].toString())
          : null,
      onTap: this.onTap,
    );
  }
}
