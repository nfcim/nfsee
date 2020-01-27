import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nfsee/data/blocs/bloc.dart';
import 'package:nfsee/data/blocs/provider.dart';

import 'ui/about_tab.dart';
import 'ui/scan_tab.dart';
import 'ui/script_tab.dart';
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
          primarySwatch: Colors.deepOrange,
        ),
        darkTheme: ThemeData(
            brightness: Brightness.dark, primarySwatch: Colors.deepOrange),
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
  int _currentIndex = 0;
  final List<Widget> _children = [ScanTab(), ScriptTab(), AboutTab()];
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<BottomNavigationBarItem> _buildNavigationItem(BuildContext context) {
    return [
      BottomNavigationBarItem(
          title: Text(S.of(context).scanTabTitle), icon: ScanTab.iosIcon),
      BottomNavigationBarItem(
          title: Text(S.of(context).scriptTabTitle), icon: ScriptTab.iosIcon),
      BottomNavigationBarItem(
          title: Text(S.of(context).aboutTabTitle), icon: AboutTab.iosIcon),
    ];
  }

  Widget _buildAndroidHomePage(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: Colors.orange[500],
        child: Row(children: <Widget>[
          IconButton(
            icon: const Icon(Icons.description),
            onPressed: () {
            },
            color: Colors.black54,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
            },
            color: Colors.black54,
          )
        ]),
        shape: CircularNotchedRectangle()
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
                      Image.asset('assets/read.gif', height: 200),
                    ],
                  )
                )
              );
            },
          );
        },
        child: Icon(Icons.nfc),
        backgroundColor: Colors.orange[900],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Widget _buildIosHomePage(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: _buildNavigationItem(context),
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              defaultTitle: S.of(context).scanTabTitle,
              builder: (context) => _children[0],
            );
          case 1:
            return CupertinoTabView(
              defaultTitle: S.of(context).scriptTabTitle,
              builder: (context) => _children[1],
            );
          case 2:
            return CupertinoTabView(
              defaultTitle: S.of(context).aboutTabTitle,
              builder: (context) => _children[2],
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
}
