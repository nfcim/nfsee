import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nfsee/data/blocs/bloc.dart';
import 'package:nfsee/data/blocs/provider.dart';
import 'package:nfsee/ui/about.dart';

import 'widgets.dart';

class SettingsAct extends StatefulWidget {
  static const title = 'Settings';
  static const androidIcon = Icon(Icons.info);
  static const iosIcon = Icon(Icons.info);

  const SettingsAct();

  @override
  _SettingsActState createState() => _SettingsActState();
}

class _SettingsActState extends State<SettingsAct> {
  NFSeeAppBloc get bloc => BlocProvider.provideBloc(context);

  @override
  void initState() {
    super.initState();
  }

  void _togglePlatform() {
    TargetPlatform _getOppositePlatform() {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return TargetPlatform.android;
      } else {
        return TargetPlatform.iOS;
      }
    }

    debugDefaultTargetPlatformOverride = _getOppositePlatform();
    // This rebuilds the application. This should obviously never be
    // done in a real app but it's done here since this app
    // unrealistically toggles the current platform for demonstration
    // purposes.
    WidgetsBinding.instance.reassembleApplication();
  }

  // ===========================================================================
  // Non-shared code below because:
  // - Android and iOS have different scaffolds
  // - There are differenc items in the app bar / nav bar
  // - Android has a hamburger drawer, iOS has bottom tabs
  // - The iOS nav bar is scrollable, Android is not
  // - Pull-to-refresh works differently, and Android has a button to trigger it too
  //
  // And these are all design time choices that doesn't have a single 'right'
  // answer.
  // ===========================================================================
  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(title: const Text(SettingsAct.title)),
        body: Builder(
            builder: (outerCtx) => SafeArea(
                    child: ListView(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.delete_sweep),
                      title: Text("Delete all records/scripts"),
                      onTap: () async {
                        bool delRecords = false;
                        bool delScripts = false;

                        final recordCount = await bloc.countRecords();
                        final scriptCount = await bloc.countScripts();

                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text("Delete"),
                                  content: StatefulBuilder(
                                    builder: (context, setState) => Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        CheckboxListTile(
                                          onChanged: (v) {
                                            setState(() {
                                              delRecords = v;
                                            });
                                          },
                                          value: delRecords,
                                          title: Text("Records"),
                                          subtitle: Text("Count: $recordCount"),
                                        ),
                                        CheckboxListTile(
                                          onChanged: (v) {
                                            setState(() {
                                              delScripts = v;
                                            });
                                          },
                                          value: delScripts,
                                          title: Text("Scripts"),
                                          subtitle: Text("Count: $scriptCount"),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("CANCEL"),
                                    ),
                                    FlatButton(
                                      onPressed: () {
                                        if (delRecords)
                                          bloc.delAllDumpedRecord();
                                        if (delScripts) bloc.delAllScripts();
                                        Navigator.of(context).pop();
                                        Scaffold.of(outerCtx)
                                            .showSnackBar(SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          content: Text("Data deleted"),
                                          duration: Duration(seconds: 1),
                                        ));
                                      },
                                      child: Text("DELETE"),
                                    ),
                                  ],
                                ));
                      },
                    ),
                    Divider(height: 0),
                    ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text("About"),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AboutAct()));
                      },
                    ),
                  ],
                ))));
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(SettingsAct.title),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.eye),
          onPressed: _togglePlatform,
        ),
      ),
      child: Text(""),
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
