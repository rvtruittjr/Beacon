import 'package:flutter_test/flutter_test.dart';
import 'package:beakon/shared/extensions/string_extensions.dart';

void main() {
  group('isValidEmail', () {
    test('accepts valid emails', () {
      expect('user@example.com'.isValidEmail(), isTrue);
      expect('user+tag@example.co.uk'.isValidEmail(), isTrue);
      expect('first.last@domain.org'.isValidEmail(), isTrue);
    });

    test('rejects invalid emails', () {
      expect(''.isValidEmail(), isFalse);
      expect('not-an-email'.isValidEmail(), isFalse);
      expect('@missing.com'.isValidEmail(), isFalse);
      expect('missing@'.isValidEmail(), isFalse);
    });
  });

  group('isValidHex', () {
    test('accepts valid hex colors', () {
      expect('#FF5733'.isValidHex(), isTrue);
      expect('FF5733'.isValidHex(), isTrue);
      expect('#ff5733'.isValidHex(), isTrue);
      expect('#FF5733AA'.isValidHex(), isTrue);
    });

    test('rejects invalid hex colors', () {
      expect(''.isValidHex(), isFalse);
      expect('#FFF'.isValidHex(), isFalse);
      expect('#GGGGGG'.isValidHex(), isFalse);
      expect('hello'.isValidHex(), isFalse);
    });
  });

  group('toSlug', () {
    test('converts strings to slugs', () {
      expect('Hello World'.toSlug(), equals('hello-world'));
      expect('My Brand Kit!'.toSlug(), equals('my-brand-kit'));
      expect('  spaces  everywhere  '.toSlug(), equals('spaces-everywhere'));
      expect('Already-a-slug'.toSlug(), equals('already-a-slug'));
    });
  });

  group('truncate', () {
    test('truncates long strings', () {
      expect('Hello World'.truncate(5), equals('Hello...'));
    });

    test('leaves short strings unchanged', () {
      expect('Hi'.truncate(10), equals('Hi'));
    });

    test('handles exact length', () {
      expect('Hello'.truncate(5), equals('Hello'));
    });
  });
}
