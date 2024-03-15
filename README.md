# Autogram Mobile App (AVM)

## Entry points

- [main](lib/main.dart) - main app
- [preview](lib/preview.dart) - [Widgetbook](https://www.widgetbook.io/blog/getting-started) app

## Scripts

FVM init and Pub get:

```shell
fvm install
```

```shell
fvm flutter pub get
```

To generate code:

```shell
fvm dart run build_runner build --delete-conflicting-outputs
```

Build Android APK:

```shell
fvm flutter build apk
```

Build WEB:

```shell
fvm flutter build web --target=lib/preview.dart
```
