import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets.dart';
import 'package:nfsee/utilities.dart';

class AboutAct extends StatefulWidget {
  @override
  State<AboutAct> createState() => _AboutActState();
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
            Image.asset('assets/icons/icon_android_square.png', width: 100),
            Text(
              _appName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              _appId,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '$_projectVersion ($_projectCode)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            ListTile(
              title: Text(S(context).homepage),
              onTap: () => launchUrl(Uri.parse('https://nfsee.nfc.im')),
            ),
            Divider(
              height: 0,
            ),
            ListTile(
              title: Text(S(context).sourceCode),
              onTap: () =>
                  launchUrl(Uri.parse('https://github.com/nfcim/nfsee')),
            ),
            Divider(
              height: 0,
            ),
            ListTile(
              title: Text(S(context).privacyPolicy),
              onTap: () => launchAssetPage(
                  S(context).privacyPolicy, S(context).privacyPolicyContent),
            ),
            Divider(
              height: 0,
            ),
            ListTile(
              title: Text(S(context).openSourceLicenses),
              onTap: () => showAboutDialog(
                  context: context,
                  applicationName: _appName,
                  applicationVersion: '$_projectVersion ($_projectCode)',
                  applicationLegalese: '© 2021-2025 nfc.im',
                  applicationIcon: Image.asset(
                    'assets/icons/icon_android_square.png', width: 60, height: 60
                    ),
                  ),
            ),
            Divider(
              height: 0,
            ),
            ListTile(
              title: Text(S(context).contactUs),
              onTap: () => launchUrl(Uri.parse('mailto:nfsee@nfc.im')),
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
        title: Text(S(context).about),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _buildAboutBody(),
    );
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(S(context).about),
        previousPageTitle: S(context).settingsTabTitle,
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
