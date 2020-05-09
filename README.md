# NFSee

NFSee is a flutter application that can dump data from various types of NFC tags & cards.

Currently NFSee can run on Android and iOS powered by Flutter.

You can get NFSee on [Google Play](https://play.google.com/store/apps/details?id=im.nfc.nfsee).

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
| Beijing Yikatong                | ✅️       | ❌    | Full                       |
| Tsinghua University Campus Card | ✅️       | ✅️    | Full                       |
| Bank Card (PPSE)                | ✅️       | ❌    | Full                       |
| T-Union Card                    | ✅️       | ✅️    | Full                       |
| CityUnion Card                  | ✅️       | ✅️    | Full                       |
| Shenzhen Tong                   | ✅️       | ✅️    | Full                       |
| Lingnan Pass                    | ✅️       | ✅️    | Full                       |
| Octopus                         | ✅️       | ✅️    | Limited metadata           |
| NXP NTAG 213                    | ❌       | ✅️    | NDEF records & Memory Dump |
| NXP DESFire EV2 MF3 D22         | ❌       | ✅️    | NDEF records               |

"Full" in description field refers to metadata (such as card ID, balance, etc.) and recent transactions.

