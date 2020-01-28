import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nfsee/data/blocs/bloc.dart';
import 'package:nfsee/data/blocs/provider.dart';

import 'ui/about_tab.dart';
import 'ui/scan_tab.dart';
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
  Widget _buildAndroidHomePage(BuildContext context) {
    return Scaffold(
      primary: true,
      bottomNavigationBar: BottomAppBar(
        color: Colors.orange[500],
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.description),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ScriptsAct()));
                },
                color: Colors.black54,
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsAct()));
                },
                color: Colors.black54,
              )
            ]
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                child:Padding(
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
                  )
                )
              );
            },
          );
        },
        child: Icon(Icons.nfc),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Widget _buildIosHomePage(BuildContext context) {
    return CupertinoApp();
  }

  @override
  Widget build(context) {
    return PlatformWidget(
      androidBuilder: _buildAndroidHomePage,
      iosBuilder: _buildIosHomePage,
    );
  }
}
