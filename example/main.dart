import 'dart:io';

import 'package:identicon/identicon.dart';

void main() {
  final bytes = Identicon().generate("HelloWorld");
  File file = new File("example.png");
  file.createSync(recursive: true);
  file.writeAsBytesSync(bytes);
}
