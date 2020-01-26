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
      body: _children[_currentIndex], // new
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped, // new
        currentIndex: _currentIndex, // new
        items: _buildNavigationItem(context),
      ),
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

class _AndroidDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Icon(
                Icons.account_circle,
                color: Colors.green.shade800,
                size: 96,
              ),
            ),
          ),
          ListTile(
            leading: ScanTab.androidIcon,
            title: Text(ScanTab.title),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          // Long drawer contents are often segmented.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
        ],
      ),
    );
  }
}
