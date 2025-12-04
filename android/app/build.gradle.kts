plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// 1. IMPORT LIBRARY (WAJIB)
import java.util.Properties
import java.io.FileInputStream

// 2. LOAD FILE KEY.PROPERTIES
val keystoreProperties = Properties()
val keystorePropertiesFile = project.file("key.properties") // Pake project.file biar nyari di folder app
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.ecommerce"
    compileSdk = 35 // Oke, pake angka langsung aman
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true 
    }

    kotlinOptions {
        jvmTarget = "1.8" // Gw samain jadi 1.8 biar sinkron sama Java version di atas
    }

    defaultConfig {
        applicationId = "com.example.ecommerce"
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 3. SETTING SIGNING CONFIG (PENTING!)
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            // Logic buat baca lokasi keystore
            storeFile = if (keystoreProperties["storeFile"] != null) project.file(keystoreProperties["storeFile"] as String) else null
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            // 4. GUNAKAN CONFIG RELEASE YANG BARU DIBUAT (BUKAN DEBUG)
            signingConfig = signingConfigs.getByName("release") 
            
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}