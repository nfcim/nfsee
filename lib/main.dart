import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:interactive_webview/interactive_webview.dart';

import 'models.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _state = '';
  final _webView = InteractiveWebView();

  @override
  void initState() {
    super.initState();
    this._addWebViewHandler();
  }

  _addWebViewHandler() async {
    final script = await rootBundle.loadString('assets/reader.js');
    _webView.evalJavascript(script);
    _webView.didReceiveMessage.listen(this._onReceivedMessage);
  }

  _onReceivedMessage(WebkitMessage message) async {
    var scriptModel = ScriptDataModel.fromJson(message.data);
    switch (scriptModel.action) {
      case 'poll':
        final tag = await FlutterNfcKit.poll();
        setState(() {
          _state = "detect: ${tag.type.toString()}";
        });
        _webView.evalJavascript("pollCallback(${jsonEncode(tag)})");
        break;

      case 'transceive':
        final rapdu = await FlutterNfcKit.transceive(scriptModel.data);
        _webView.evalJavascript("transceiveCallback('$rapdu')");
        break;

      case 'log':
        log(message.data.toString());
        break;
    }
  }

  void _readTag() async {
    setState(() {
      _state = 'polling';
    });
    final script = await rootBundle.loadString('assets/read.js');
    _webView.evalJavascript("""async function run() {
    $script
    }
    run();""");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Current state:',
            ),
            Text(
              '$_state',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _readTag,
        tooltip: 'Read a tag',
        child: Icon(Icons.add),
      ),
    );
  }
}
