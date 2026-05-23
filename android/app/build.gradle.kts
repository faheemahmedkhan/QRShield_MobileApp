import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// ─── Load signing credentials from key.properties (if it exists) ───────────
val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
val hasKeystore = keyPropertiesFile.exists().also { exists ->
    if (exists) keyProperties.load(FileInputStream(keyPropertiesFile))
}

android {
    namespace = "com.qrshieldpro"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "qrshieldpro.com"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ─── Signing ────────────────────────────────────────────────────────────
    signingConfigs {
        if (hasKeystore) {
            create("release") {
                keyAlias     = keyProperties.getProperty("keyAlias")
                keyPassword  = keyProperties.getProperty("keyPassword")
                storePassword = keyProperties.getProperty("storePassword")
                storeFile    = keyProperties.getProperty("storeFile")
                                   ?.let { rootProject.file(it) }
            }
        }
    }

    buildTypes {
        release {
            // Use release keystore when available, otherwise fall back to debug
            signingConfig = if (hasKeystore)
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
