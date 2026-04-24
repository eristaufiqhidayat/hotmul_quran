plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.hotmul_quran"
    compileSdk = flutter.compileSdkVersion
    //ndkVersion = flutter.ndkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        // Target Java 17 (latest LTS). Use toVersion(17) for compatibility across Gradle versions.
        sourceCompatibility = JavaVersion.toVersion(17)
        targetCompatibility = JavaVersion.toVersion(17)
    }

    kotlinOptions {
        // Kotlin jvmTarget should match the Java target. Set to "17" for Java 17.
        jvmTarget = JavaVersion.toVersion(17).toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.hotmul_quran"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
