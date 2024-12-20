# NFSee

![Build Android App](https://github.com/nfcim/nfsee/workflows/Build%20Android%20App/badge.svg)

NFSee is a flutter application that can dump data from various types of NFC tags & cards.

Currently NFSee can run on Android and iOS powered by Flutter.

[<img src="https://fdroid.gitlab.io/artwork/badge/get-it-on.png"
     alt="Get it on F-Droid"
     height="50">](https://f-droid.org/packages/im.nfc.nfsee/)
[<img src="https://play.google.com/intl/en_us/badges/images/generic/en-play-badge.png"
     alt="Get it on Google Play"
     height="50">](https://play.google.com/store/apps/details?id=im.nfc.nfsee)
[<img src="https://developer.apple.com/app-store/marketing/guidelines/images/badge-download-on-the-app-store.svg"
     alt="Download on the App Store"
     height="50">](https://apps.apple.com/us/app/nfsee/id1496080962)

## Build

Flutter SDK is required to build this project:

``` bash
flutter pub get
flutter run # for debug version
flutter build # for release version
```

## Support Matrix

| Type                            | Android | iOS  | Description                |
| ------------------------------- | ------- | ---- | -------------------------- |
| P. R. C. Resident ID            | ✅️       | ❌    | GUID only                  |
| Beijing Yikatong                | ✅️       | ❌    | Full[^1]                   |
| Tsinghua University Campus Card | ✅️       | ✅️    | Full                       |
| Bank Card (PPSE)                | ✅️       | ❌    | Full                       |
| T-Union Card                    | ✅️       | ✅️    | Full                       |
| CityUnion Card                  | ✅️       | ✅️    | Full                       |
| Shenzhen Tong                   | ✅️       | ✅️    | Full                       |
| Lingnan Pass                    | ✅️       | ✅️    | Full                       |
| Octopus                         | ✅️       | ✅️    | Limited metadata           |
| MIFARE Ultralight[^2]           | ✅️       | ✅️    | NDEF records & Memory Dump |
| MIFARE DESFire[^3]              | ✅️       | ✅️    | NDEF records               |
| MIFARE Classic[^4]              | ✅️       | ❌    | NDEF records               |

[^1]: "Full" in description field refers to metadata (such as card ID, balance, etc.) and recent transactions.

[^2]: Tested with NXP NTAG 213

[^3]: Tested with NXP DESFire EV2 MF3 D22

[^4]: Tested with NXP MIFARE Classic EV1 4K S70
