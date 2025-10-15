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
    applicationId = "com.urbanaccess.absensipkl"
    minSdk = flutter.minSdkVersion
    targetSdk = 34
    versionCode = 1
    versionName = "1.0"
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
