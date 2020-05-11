import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    test('First Test', () {
      var cu = '0'.codeUnits;
      expect(cu.length, 1);
      expect(cu[0], 48);

      cu = '\x00'.codeUnits;
      expect(cu.length, 1);
      expect(cu[0], 0);
    });
  });
}
