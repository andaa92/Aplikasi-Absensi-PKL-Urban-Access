plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // gunakan versi lengkap plugin Kotlin
    id("dev.flutter.flutter-gradle-plugin") // Flutter Gradle Plugin harus terakhir
}

android {
    namespace = "com.urbanaccess.absensipkl"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.urbanaccess.absensipkl"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        getByName("release") {
            // TODO: tambahkan signingConfig release jika sudah ada key
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
