# Project Structure

biji_coffee
├── .dart_tool
│   ├── dartpad
│   │   └── web_plugin_registrant.dart
│   ├── package_config_subset
│   ├── package_config.json
│   └── version
├── .idea
│   ├── libraries
│   │   ├── Dart_SDK.xml
│   │   └── KotlinJavaRuntime.xml
│   ├── runConfigurations
│   │   └── main_dart.xml
│   ├── modules.xml
│   └── workspace.xml
├── android
│   ├── app
│   │   ├── src
│   │   │   ├── debug
│   │   │   │   └── AndroidManifest.xml
│   │   │   ├── main
│   │   │   │   ├── java
│   │   │   │   │   └── io
│   │   │   │   │       └── flutter
│   │   │   │   │           └── plugins
│   │   │   │   │               └── GeneratedPluginRegistrant.java
│   │   │   │   ├── kotlin
│   │   │   │   │   └── com
│   │   │   │   │       └── example
│   │   │   │   │           └── biji_coffee
│   │   │   │   │               └── MainActivity.kt
│   │   │   │   ├── res
│   │   │   │   │   ├── drawable
│   │   │   │   │   │   └── launch_background.xml
│   │   │   │   │   ├── drawable-v21
│   │   │   │   │   │   └── launch_background.xml
│   │   │   │   │   ├── mipmap-hdpi
│   │   │   │   │   │   └── ic_launcher.png
│   │   │   │   │   ├── mipmap-mdpi
│   │   │   │   │   │   └── ic_launcher.png
│   │   │   │   │   ├── mipmap-xhdpi
│   │   │   │   │   │   └── ic_launcher.png
│   │   │   │   │   ├── mipmap-xxhdpi
│   │   │   │   │   │   └── ic_launcher.png
│   │   │   │   │   ├── mipmap-xxxhdpi
│   │   │   │   │   │   └── ic_launcher.png
│   │   │   │   │   ├── values
│   │   │   │   │   │   └── styles.xml
│   │   │   │   │   └── values-night
│   │   │   │   │       └── styles.xml
│   │   │   │   └── AndroidManifest.xml
│   │   │   └── profile
│   │   │       └── AndroidManifest.xml
│   │   └── build.gradle
│   ├── gradle
│   │   └── wrapper
│   │       ├── gradle-wrapper.jar
│   │       └── gradle-wrapper.properties
│   ├── .gitignore
│   ├── biji_coffee_android.iml
│   ├── build.gradle
│   ├── gradle.properties
│   ├── gradlew
│   ├── gradlew.bat
│   ├── local.properties
│   └── settings.gradle
├── assets
│   └── images
│       ├── bean.svg
│       ├── bg1.jpg
│       ├── line.png
│       ├── rank.png
│       └── welcome.png
├── ios
│   ├── Flutter
│   │   ├── AppFrameworkInfo.plist
│   │   ├── Debug.xcconfig
│   │   ├── flutter_export_environment.sh
│   │   ├── Generated.xcconfig
│   │   └── Release.xcconfig
│   ├── Runner
│   │   ├── Assets.xcassets
│   │   │   ├── AppIcon.appiconset
│   │   │   │   ├── Contents.json
│   │   │   │   ├── Icon-App-1024x1024@1x.png
│   │   │   │   ├── Icon-App-20x20@1x.png
│   │   │   │   ├── Icon-App-20x20@2x.png
│   │   │   │   ├── Icon-App-20x20@3x.png
│   │   │   │   ├── Icon-App-29x29@1x.png
│   │   │   │   ├── Icon-App-29x29@2x.png
│   │   │   │   ├── Icon-App-29x29@3x.png
│   │   │   │   ├── Icon-App-40x40@1x.png
│   │   │   │   ├── Icon-App-40x40@2x.png
│   │   │   │   ├── Icon-App-40x40@3x.png
│   │   │   │   ├── Icon-App-60x60@2x.png
│   │   │   │   ├── Icon-App-60x60@3x.png
│   │   │   │   ├── Icon-App-76x76@1x.png
│   │   │   │   ├── Icon-App-76x76@2x.png
│   │   │   │   └── Icon-App-83.5x83.5@2x.png
│   │   │   └── LaunchImage.imageset
│   │   │       ├── Contents.json
│   │   │       ├── LaunchImage.png
│   │   │       ├── LaunchImage@2x.png
│   │   │       ├── LaunchImage@3x.png
│   │   │       └── README.md
│   │   ├── Base.lproj
│   │   │   ├── LaunchScreen.storyboard
│   │   │   └── Main.storyboard
│   │   ├── AppDelegate.swift
│   │   ├── GeneratedPluginRegistrant.h
│   │   ├── GeneratedPluginRegistrant.m
│   │   ├── Info.plist
│   │   └── Runner-Bridging-Header.h
│   ├── Runner.xcodeproj
│   │   ├── project.xcworkspace
│   │   │   ├── xcshareddata
│   │   │   │   ├── IDEWorkspaceChecks.plist
│   │   │   │   └── WorkspaceSettings.xcsettings
│   │   │   └── contents.xcworkspacedata
│   │   ├── xcshareddata
│   │   │   └── xcschemes
│   │   │       └── Runner.xcscheme
│   │   └── project.pbxproj
│   ├── Runner.xcworkspace
│   │   ├── xcshareddata
│   │   │   ├── IDEWorkspaceChecks.plist
│   │   │   └── WorkspaceSettings.xcsettings
│   │   └── contents.xcworkspacedata
│   ├── RunnerTests
│   │   └── RunnerTests.swift
│   └── .gitignore
├── lib
│   ├── core
│   │   ├── routes
│   │   │   └── app_routes.dart
│   │   └── theme
│   │       ├── app_colors.dart
│   │       ├── app_text_styles.dart
│   │       └── app_theme.dart
│   ├── pages
│   │   ├── auth
│   │   │   └── login_page.dart
│   │   ├── onboarding
│   │   │   └── onboarding_page.dart
│   │   └── welcome
│   │       └── welcome_page.dart
│   ├── widgets
│   └── main.dart
├── linux
│   ├── flutter
│   │   ├── CMakeLists.txt
│   │   ├── generated_plugin_registrant.cc
│   │   ├── generated_plugin_registrant.h
│   │   └── generated_plugins.cmake
│   ├── .gitignore
│   ├── CMakeLists.txt
│   ├── main.cc
│   ├── my_application.cc
│   └── my_application.h
├── macos
│   ├── Flutter
│   │   ├── ephemeral
│   │   │   ├── flutter_export_environment.sh
│   │   │   └── Flutter-Generated.xcconfig
│   │   ├── Flutter-Debug.xcconfig
│   │   ├── Flutter-Release.xcconfig
│   │   └── GeneratedPluginRegistrant.swift
│   ├── Runner
│   │   ├── Assets.xcassets
│   │   │   └── AppIcon.appiconset
│   │   │       ├── app_icon_1024.png
│   │   │       ├── app_icon_128.png
│   │   │       ├── app_icon_16.png
│   │   │       ├── app_icon_256.png
│   │   │       ├── app_icon_32.png
│   │   │       ├── app_icon_512.png
│   │   │       ├── app_icon_64.png
│   │   │       └── Contents.json
│   │   ├── Base.lproj
│   │   │   └── MainMenu.xib
│   │   ├── Configs
│   │   │   ├── AppInfo.xcconfig
│   │   │   ├── Debug.xcconfig
│   │   │   ├── Release.xcconfig
│   │   │   └── Warnings.xcconfig
│   │   ├── AppDelegate.swift
│   │   ├── DebugProfile.entitlements
│   │   ├── Info.plist
│   │   ├── MainFlutterWindow.swift
│   │   └── Release.entitlements
│   ├── Runner.xcodeproj
│   │   ├── project.xcworkspace
│   │   │   └── xcshareddata
│   │   │       └── IDEWorkspaceChecks.plist
│   │   ├── xcshareddata
│   │   │   └── xcschemes
│   │   │       └── Runner.xcscheme
│   │   └── project.pbxproj
│   ├── Runner.xcworkspace
│   │   ├── xcshareddata
│   │   │   └── IDEWorkspaceChecks.plist
│   │   └── contents.xcworkspacedata
│   ├── RunnerTests
│   │   └── RunnerTests.swift
│   └── .gitignore
├── test
│   └── widget_test.dart
├── web
│   ├── icons
│   │   ├── Icon-192.png
│   │   ├── Icon-512.png
│   │   ├── Icon-maskable-192.png
│   │   └── Icon-maskable-512.png
│   ├── favicon.png
│   ├── index.html
│   └── manifest.json
├── windows
│   ├── flutter
│   │   ├── CMakeLists.txt
│   │   ├── generated_plugin_registrant.cc
│   │   ├── generated_plugin_registrant.h
│   │   └── generated_plugins.cmake
│   ├── runner
│   │   ├── resources
│   │   │   └── app_icon.ico
│   │   ├── CMakeLists.txt
│   │   ├── flutter_window.cpp
│   │   ├── flutter_window.h
│   │   ├── main.cpp
│   │   ├── resource.h
│   │   ├── runner.exe.manifest
│   │   ├── Runner.rc
│   │   ├── utils.cpp
│   │   ├── utils.h
│   │   ├── win32_window.cpp
│   │   └── win32_window.h
│   ├── .gitignore
│   └── CMakeLists.txt
├── .gitignore
├── .metadata
├── analysis_options.yaml
├── biji_coffee.iml
├── info.txt
├── pubspec.lock
├── pubspec.yaml
└── README.md
