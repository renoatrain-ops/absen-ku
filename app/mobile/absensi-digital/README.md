# absensi-digital (Flutter)

Aplikasi Android (Flutter) sederhana untuk absensi digital menggunakan kamera depan untuk memindai QR Code.

Fitur awal:
- Scan QR code menggunakan kamera depan
- Tampilan sederhana: Home dan Scan

Catatan:
- Paket utama untuk pemindaian: mobile_scanner
- Perlu menambahkan permission CAMERA pada AndroidManifest dan NSCameraUsageDescription di Info.plist untuk iOS

Cara menjalankan (setelah memasang Flutter SDK):

```bash
cd app/mobile/absensi-digital
flutter pub get
flutter run
```

Permission Android (tambahkan di android/app/src/main/AndroidManifest.xml):

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

Permission iOS (Info.plist):

```xml
<key>NSCameraUsageDescription</key>
<string>Digunakan untuk memindai QR Code untuk absensi</string>
```

Jika ingin saya tambahkan Dockerfile, CI, atau integrasi backend (API untuk menyimpan kehadiran), beri tahu stack backend yang diinginkan.
