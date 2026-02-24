import 'package:flutter_test/flutter_test.dart';
import 'package:beakon/shared/extensions/datetime_extensions.dart';

void main() {
  group('timeAgo', () {
    test('returns just now for recent times', () {
      final now = DateTime.now().subtract(const Duration(seconds: 30));
      expect(now.timeAgo(), equals('just now'));
    });

    test('returns minutes ago', () {
      final time = DateTime.now().subtract(const Duration(minutes: 5));
      expect(time.timeAgo(), equals('5 minutes ago'));
    });

    test('returns singular minute', () {
      final time = DateTime.now().subtract(const Duration(minutes: 1));
      expect(time.timeAgo(), equals('1 minute ago'));
    });

    test('returns hours ago', () {
      final time = DateTime.now().subtract(const Duration(hours: 3));
      expect(time.timeAgo(), equals('3 hours ago'));
    });

    test('returns days ago', () {
      final time = DateTime.now().subtract(const Duration(days: 2));
      expect(time.timeAgo(), equals('2 days ago'));
    });
  });

  group('toDisplayDate', () {
    test('formats date correctly', () {
      final date = DateTime(2025, 3, 15);
      expect(date.toDisplayDate(), equals('Mar 15, 2025'));
    });

    test('formats January correctly', () {
      final date = DateTime(2024, 1, 1);
      expect(date.toDisplayDate(), equals('Jan 1, 2024'));
    });
  });

  group('isExpired', () {
    test('returns true for past dates', () {
      final past = DateTime.now().subtract(const Duration(days: 1));
      expect(past.isExpired(), isTrue);
    });

    test('returns false for future dates', () {
      final future = DateTime.now().add(const Duration(days: 1));
      expect(future.isExpired(), isFalse);
    });
  });
}
