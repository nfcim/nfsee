import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:interactive_webview/interactive_webview.dart';
import 'package:nfsee/data/blocs/bloc.dart';
import 'package:nfsee/data/blocs/provider.dart';
import 'package:nfsee/data/database/database.dart';
import 'package:nfsee/ui/script_tab.dart';

import '../generated/l10n.dart';
import '../models.dart';
import 'widgets.dart';

class ScanTab extends StatefulWidget {
  static const title = 'Scan';
  static const androidIcon = Icon(Icons.nfc);
  static const iosIcon = Icon(Icons.nfc);

  const ScanTab({this.androidDrawer});

  final Widget androidDrawer;

  @override
  _ScanTabState createState() => _ScanTabState();
}

class _ScanTabState extends State<ScanTab> {
  final _webView = InteractiveWebView();
  List<DumpedRecord> _records = new List<DumpedRecord>();
  StreamSubscription _webViewListener;

  NFSeeAppBloc get bloc => BlocProvider.provideBloc(context);

  @override
  void initState() {
    super.initState();
    this._addWebViewHandler();
    this._updateRecords();
  }

  void _addWebViewHandler() async {
    _webView.evalJavascript(await rootBundle.loadString('assets/ber-tlv.js'));
    _webView.evalJavascript(await rootBundle.loadString('assets/crypto-js.js'));
    _webView.evalJavascript(await rootBundle.loadString('assets/crypto.js'));
    _webView.evalJavascript(await rootBundle.loadString('assets/reader.js'));
    _webView.evalJavascript(await rootBundle.loadString('assets/codes.js'));
    _webViewListener =
        _webView.didReceiveMessage.listen(this._onReceivedMessage);
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
        final tag = await FlutterNfcKit.poll();
        _webView.evalJavascript("pollCallback(${jsonEncode(tag)})");
        break;

      case 'transceive':
        log('TX ${scriptModel.data}');
        final rapdu = await FlutterNfcKit.transceive(scriptModel.data);
        log('RX $rapdu');
        _webView.evalJavascript("transceiveCallback('$rapdu')");
        break;

      case 'report':
        print(scriptModel.data.toString());
        bloc.addDumpedRecord(scriptModel.data);
        await this._updateRecords();
        this._records.forEach((el) => print(el.toString()));
        await FlutterNfcKit.finish();
        break;

      case 'log':
        log(message.data.toString());
        break;
    }
  }

  void _readTag() async {
    final script = await rootBundle.loadString('assets/read.js');
    _webView.evalJavascript(script);
  }

  void _navigateToScriptMode() {
    _webViewListener.cancel();
    Navigator.of(context)
        .push<void>(
      MaterialPageRoute(builder: (context) => ScriptTab()),
    )
        .then((_) {
      _webViewListener =
          _webView.didReceiveMessage.listen(this._onReceivedMessage);
    });
  }

  // ===========================================================================
  // Non-shared code below because:
  // - Android and iOS have different scaffolds
  // - There are different items in the app bar / nav bar
  // - Android has a hamburger drawer, iOS has bottom tabs
  // - The iOS nav bar is scrollable, Android is not
  // - Pull-to-refresh works differently, and Android has a button to trigger it too
  //
  // And these are all design time choices that doesn't have a single 'right'
  // answer.
  // ===========================================================================
  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).scanTabTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.assignment),
            onPressed: _navigateToScriptMode,
          )
        ],
      ),
      drawer: widget.androidDrawer,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/tap.png', height: 240),
            Text(
              'Current state:',
            ),
            FlatButton(
              onPressed: _readTag,
              child:
                  Row(children: <Widget>[Icon(Icons.nfc), Text('Scan a card')]),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIos(BuildContext context) {
    return CustomScrollView(
      slivers: [
        CupertinoSliverNavigationBar(
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(CupertinoIcons.create),
                onPressed: _readTag,
              ),
            ],
          ),
        ),
        SliverPadding(
            // Top media padding consumed by CupertinoSliverNavigationBar.
            // Left/Right media padding consumed by Tab1RowItem.
            padding: MediaQuery.of(context)
                .removePadding(
                  removeTop: true,
                  removeLeft: true,
                  removeRight: true,
                )
                .padding,
            sliver: SliverList(
              delegate:
                  SliverChildBuilderDelegate((BuildContext context, int index) {
                int realIndex = index ~/ 2;
                if (index.isEven) {
                  return ReportRowItem(
                    record: this._records[realIndex],
                  );
                } else {
                  return Divider(height: 0, color: Colors.grey);
                }
              }, childCount: math.max(0, this._records.length * 2 - 1)),
            )),
      ],
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

class ReportRowItem extends StatelessWidget {
  const ReportRowItem({this.record});

  final DumpedRecord record;

  @override
  Widget build(context) {
    var data = json.decode(record.data);
    var title = data["title"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('${record.id}: $title', style: Theme.of(context).textTheme.subtitle),
        Text(data.toString(), style: Theme.of(context).textTheme.body1)
      ],
    );
  }
}
