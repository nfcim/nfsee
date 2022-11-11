import 'package:flutter/material.dart';

import 'package:nfsee/data/blocs/bloc.dart';
import 'package:nfsee/data/blocs/provider.dart';
import 'package:nfsee/utilities.dart';

import 'about.dart';

class SettingsAct extends StatefulWidget {
  const SettingsAct();

  @override
  _SettingsActState createState() => _SettingsActState();
}

class _SettingsActState extends State<SettingsAct> {
  NFSeeAppBloc? get bloc => BlocProvider.provideBloc(context);

  @override
  void initState() {
    super.initState();
  }

  void _onTapDelete(BuildContext context, BuildContext outerCtx) async {
    bool delRecords = false;
    bool delScripts = false;

    final recordCount = await bloc!.countRecords();
    final scriptCount = await bloc!.countScripts();

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(S(context).deleteDataDialog),
              content: StatefulBuilder(
                builder: (context, setState) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CheckboxListTile(
                      onChanged: (v) {
                        setState(() {
                          delRecords = v!;
                        });
                      },
                      value: delRecords,
                      title: Text(S(context).record),
                      subtitle: Text("${S(context).dataCount}: $recordCount"),
                    ),
                    CheckboxListTile(
                      onChanged: (v) {
                        setState(() {
                          delScripts = v!;
                        });
                      },
                      value: delScripts,
                      title: Text(S(context).script),
                      subtitle: Text("${S(context).dataCount}: $scriptCount"),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(MaterialLocalizations.of(context)
                      .cancelButtonLabel
                      .toUpperCase()),
                ),
                TextButton(
                  onPressed: () {
                    if (delRecords) bloc!.delAllDumpedRecord();
                    if (delScripts) bloc!.delAllScripts();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(outerCtx).showSnackBar(SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(S(context).deletedHint),
                      duration: Duration(seconds: 1),
                    ));
                  },
                  child: Text(S(context).delete.toUpperCase()),
                ),
              ],
            ));
  }

  List<Widget> _buildListItems(BuildContext outerCtx) {
    var items = <Widget>[
      Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          S(context).settingsTabTitle,
          style: Theme.of(context)
              .primaryTextTheme
              .headline6!
              .copyWith(fontSize: 32),
        ),
      ),
      ListTile(
        leading: Icon(Icons.delete_sweep),
        title: Text(S(context).deleteData),
        onTap: () async {
          _onTapDelete(context, outerCtx);
        },
      ),
      Divider(height: 0),
      ListTile(
        leading: Icon(Icons.info_outline),
        title: Text(S(context).about),
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AboutAct()));
        },
      ),
    ];

    return items;
  }

  Widget _buildSettingsBody() {
    return Builder(
        builder: (context) => SafeArea(
                child: ListView(
              children: _buildListItems(context),
            )));
  }

  Widget build(BuildContext context) {
    return Scaffold(body: _buildSettingsBody());
  }
}
