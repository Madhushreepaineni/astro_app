# astro_app (Android first, iOS phase 2)
Setup on Windows (Flutter SDK + Android Studio installed):
1. flutter create astro_app
2. Copy this folder's `lib/main.dart`, `pubspec.yaml` and `assets/` over the created project.
3. cd astro_app && flutter pub get && flutter run   (phone or emulator)
4. APK: flutter build apk --release
Data lives in assets/data/*.json (bundled, works offline). Edit a JSON file to change a table.
iOS (phase 2): same code; build on a Mac with `flutter build ios`.
