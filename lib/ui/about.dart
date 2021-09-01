import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nfsee/generated/l10n.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets.dart';

class AboutAct extends StatefulWidget {
  @override
  _AboutActState createState() => _AboutActState();
}

class _AboutActState extends State<AboutAct> {
  var _projectVersion = "";
  var _projectCode = "";
  var _appId = "";
  var _appName = "";

  @override
  void initState() {
    super.initState();
  }

  void initVersions() async {
    var packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _projectVersion = packageInfo.version;
      _projectCode = packageInfo.buildNumber;
      _appId = packageInfo.packageName;
      _appName = packageInfo.appName;
    });
  }

  void launchAssetPage(String title, String url) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewTab(
                    title: title,
                    assetUrl: url,
                  )));
    } else {
      Navigator.of(context).push<void>(CupertinoPageRoute(
          builder: (context) => SafeArea(
                  child: WebViewTab(
                title: title,
                assetUrl: url,
              ))));
    }
  }

  Widget _buildAboutBody() {
    initVersions();
    return Builder(
      builder: (outerContext) => SafeArea(
          child: Padding(
        padding: EdgeInsets.only(top: 24, bottom: 24),
        child: Center(
            child: Column(
          children: <Widget>[
            Image.asset('assets/icons/icon_square.png', width: 100),
            Text(
              _appName,
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
              _appId,
              style: Theme.of(context).textTheme.bodyText2,
            ),
            Text(
              '$_projectVersion ($_projectCode)',
              style: Theme.of(context).textTheme.bodyText2,
            ),
            ListTile(
              title: Text(S.of(context).homepage),
              onTap: () => launch('https://nfsee.nfc.im'),
            ),
            Divider(
              height: 0,
            ),
            ListTile(
              title: Text(S.of(context).sourceCode),
              onTap: () => launch('https://github.com/nfcim/nfsee'),
            ),
            Divider(
              height: 0,
            ),
            ListTile(
              title: Text(S.of(context).privacyPolicy),
              onTap: () => launchAssetPage(S.of(context).privacyPolicy,
                  S.of(context).privacyPolicyContent),
            ),
            Divider(
              height: 0,
            ),
            ListTile(
              title: Text(S.of(context).openSourceLicenses),
              onTap: () => launchAssetPage(S.of(context).openSourceLicenses,
                  S.of(context).thirdPartyLicenseContent),
            ),
            Divider(
              height: 0,
            ),
            ListTile(
              title: Text(S.of(context).contactUs),
              onTap: () => launch('mailto:nfsee@nfc.im'),
            )
          ],
        )),
      )),
    );
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
      appBar: AppBar(
        title: Text(S.of(context).about),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _buildAboutBody(),
    );
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(S.of(context).about),
        previousPageTitle: S.of(context).settingsTabTitle,
      ),
      child: _buildAboutBody(),
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
