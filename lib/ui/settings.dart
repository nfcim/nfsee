import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:nfsee/data/blocs/bloc.dart';
import 'package:nfsee/data/blocs/provider.dart';
import 'package:nfsee/generated/l10n.dart';

import 'about.dart';

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

  void _onTapDelete(BuildContext context, BuildContext outerCtx) async {
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
                      subtitle:
                          Text("${S.of(context).dataCount}: $recordCount"),
                    ),
                    CheckboxListTile(
                      onChanged: (v) {
                        setState(() {
                          delScripts = v;
                        });
                      },
                      value: delScripts,
                      title: Text(S.of(context).script),
                      subtitle:
                          Text("${S.of(context).dataCount}: $scriptCount"),
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
                  child: Text(S.of(context).delete.toUpperCase()),
                ),
              ],
            ));
  }

  List<Widget> _buildListItems(BuildContext outerCtx) {
    var items = <Widget>[
      Padding(
        padding: EdgeInsets.all(20),
        child: Text(S.of(context).settingsTabTitle,
          style: Theme.of(context).primaryTextTheme.headline6.copyWith(fontSize: 32),
        ),
      ),
      ListTile(
        leading: Icon(Icons.delete_sweep),
        title: Text(S.of(context).deleteData),
        onTap: () async {
          _onTapDelete(context, outerCtx);
        },
      ),
      Divider(height: 0),
      ListTile(
        leading: Icon(Icons.info_outline),
        title: Text(S.of(context).about),
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
    return Scaffold(
      body: _buildSettingsBody()
    );
  }
}
