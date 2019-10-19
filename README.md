# identicon

[![pub package](https://img.shields.io/pub/v/identicon.svg)](https://pub.dev/packages/identicon) [![GitHub license](https://img.shields.io/github/license/phinexdaz/identicon)](https://github.com/phinexdaz/identicon/blob/master/LICENSE)

A library which generate an identicon image based on a string.

<img src="https://raw.githubusercontent.com/phinexdaz/identicon/master/preview.png" width="500" />

## Usage
```dart
final bytes = Identicon().generate("HelloWorld");
File file = new File("example.png");
file.createSync(recursive: true);
file.writeAsBytesSync(bytes);
```

## Getting Started

This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
