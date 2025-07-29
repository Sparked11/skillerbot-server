plugins {
    id("com.android.application")
    kotlin("android")
    id("com.google.gms.google-services") // Firebase plugin
}

android {
    namespace = "com.yourcompany.yourapp" // 🔁 Replace this with your actual package name
    compileSdk = 34

    defaultConfig {
        applicationId = "com.yourcompany.yourapp" // 🔁 Same here
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"

        // For Firebase to work
        multiDexEnabled = true
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("com.google.firebase:firebase-storage-ktx:20.3.0")
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.11.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    implementation("androidx.multidex:multidex:2.0.1") // Required for multidex
}
