import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:nfsee/data/blocs/bloc.dart';
import 'package:nfsee/data/blocs/provider.dart';
import 'package:nfsee/generated/l10n.dart';

import 'about.dart';
import 'widgets.dart';

class SettingsAct extends StatefulWidget {
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

  Widget _buildSettingsBody() {
    return Builder(
        builder: (outerCtx) => SafeArea(
                child: ListView(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.delete_sweep),
                  title: Text(S.of(context).deleteData),
                  onTap: () async {
                    bool delRecords = false;
                    bool delScripts = false;

                    final recordCount = await bloc.countRecords();
                    final scriptCount = await bloc.countScripts();

                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text(S.of(context).deleteDataDialog),
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
                                      title: Text(S.of(context).record),
                                      subtitle: Text(
                                          "${S.of(context).dataCount}: $recordCount"),
                                    ),
                                    CheckboxListTile(
                                      onChanged: (v) {
                                        setState(() {
                                          delScripts = v;
                                        });
                                      },
                                      value: delScripts,
                                      title: Text(S.of(context).script),
                                      subtitle: Text(
                                          "${S.of(context).dataCount}: $scriptCount"),
                                    ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(MaterialLocalizations.of(context)
                                      .cancelButtonLabel
                                      .toUpperCase()),
                                ),
                                FlatButton(
                                  onPressed: () {
                                    if (delRecords) bloc.delAllDumpedRecord();
                                    if (delScripts) bloc.delAllScripts();
                                    Navigator.of(context).pop();
                                    Scaffold.of(outerCtx).showSnackBar(SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      content: Text(S.of(context).deletedHint),
                                      duration: Duration(seconds: 1),
                                    ));
                                  },
                                  child:
                                      Text(S.of(context).delete.toUpperCase()),
                                ),
                              ],
                            ));
                  },
                ),
                Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.shuffle),
                  title: Text(S.of(context).togglePlatform),
                  onTap: _togglePlatform,
                ),
                Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text(S.of(context).about),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AboutAct()));
                  },
                ),
              ],
            )));
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
        appBar: new AppBar(title: Text(S.of(context).settingsTabTitle)),
        body: _buildSettingsBody());
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(S.of(context).settingsTabTitle),
      ),
      child: _buildSettingsBody(),
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
