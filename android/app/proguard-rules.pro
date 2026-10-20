# ProGuard/R8 rules untuk build rilis.
# Aturan keep Flutter sudah ditambahkan otomatis oleh Flutter Gradle plugin,
# dan plugin (google_sign_in, audioplayers, record, dll.) membawa consumer
# rules sendiri. Hindari -keep yang luas agar persentase obfuscation tinggi.

# Flutter merujuk Play Core (deferred components) yang tidak dipakai app ini.
-dontwarn com.google.android.play.core.**

# Pertahankan info baris agar stack trace bisa di-deobfuscate via mapping.txt
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
