plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // gunakan versi lengkap plugin Kotlin
    // Flutter Gradle Plugin harus di-load terakhir
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.urbanaccess.absensipkl" // Ganti namespace unik kamu
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Ganti applicationId agar tidak bentrok dengan versi lama
        applicationId = "com.urbanaccess.absensipkl"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Tetap pakai debug signing sementara agar bisa run tanpa keystore khusus
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
