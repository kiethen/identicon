import 'package:identicon/identicon.dart';
import 'package:test/test.dart';

void main() {
  test('adds one to input values', () {
    final bytes = Identicon().generate("HelloWorld");
    expect(bytes.isEmpty, false);
  });
}
