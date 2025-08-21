Oke, saya buatkan **panduan lengkap release APK Flutter** supaya semua berjalan lancar—API, gambar, ikon, nama aplikasi, dan permission—dengan langkah step by step:

---

# **Panduan Release APK Flutter Lengkap**

## 1️⃣ Persiapan Project

* Pastikan semua dependency Flutter sudah update:

```bash
flutter clean
flutter pub get
```

* Cek versi Flutter:

```bash
flutter --version
```

* Pastikan semua **asset (gambar, JSON, dll)** sudah dicantumkan di `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/json/
```

---

## 2️⃣ Atur Nama Aplikasi & Ikon

### Nama Aplikasi

* AndroidManifest.xml:

```xml
<application
    android:label="@string/app_name"
    ...>
```

* Strings.xml (`android/app/src/main/res/values/strings.xml`):

```xml
<string name="app_name">Masjid Nurul Islam</string>
```

### Icon Launcher

* Gunakan package **flutter\_launcher\_icons**:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.10.0

flutter_icons:
  android: true
  ios: true
  image_path: "assets/images/app_icon.png"
```

* Jalankan:

```bash
flutter pub get
flutter pub run flutter_launcher_icons:main
```

* Otomatis mengganti semua mipmap density dan iOS icon.

---

## 3️⃣ Permission & Network Security

### AndroidManifest.xml

* Tambahkan permission internet:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

* Pastikan network security config dipakai:

```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    ...>
```

### network\_security\_config.xml

* Lokasi: `android/app/src/main/res/xml/network_security_config.xml`
* Contoh untuk domain + subdomain:

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">lembaharafah.com</domain>
    </domain-config>
</network-security-config>
```

* Semua API / gambar **harus pakai HTTPS**.

---

## 4️⃣ Base URL Flutter

* Pastikan URL API dan gambar menggunakan HTTPS, bukan localhost:

```dart
const baseUrl = 'https://khandaq.lembaharafah.com/api';
const imageUrl = 'https://khandaq.lembaharafah.com/public/uploads/images/kursus.png';
```

---

## 5️⃣ Build Release APK

* Bersihkan build:

```bash
flutter clean
flutter pub get
```

* Build release:

```bash
flutter build apk --release
```

* Install di device:

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 6️⃣ Testing Release

* Pastikan:

  1. API bisa diakses
  2. Gambar tampil
  3. Tidak ada error di logcat:

```bash
adb logcat | grep flutter
```

* Jika pakai obfuscation, pastikan **Proguard rules** untuk model/serializer API.

---

## 7️⃣ Tips Tambahan

* Multi-domain network\_security\_config:

```xml
<domain-config cleartextTrafficPermitted="false">
    <domain includeSubdomains="true">lembaharafah.com</domain>
    <domain includeSubdomains="true">khandaq.lembaharafah.com</domain>
    <domain includeSubdomains="true">cdn.lembaharafah.com</domain>
</domain-config>
```

* Selalu pakai **HTTPS** untuk semua subdomain.
* Gunakan **flutter\_launcher\_icons** agar ikon dan nama aplikasi konsisten.

---
