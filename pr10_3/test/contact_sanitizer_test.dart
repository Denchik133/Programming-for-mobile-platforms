import 'package:flutter_test/flutter_test.dart';
import 'package:pr10_3/validation/contact_sanitizer.dart';
import 'package:pr10_3/validation/contact_validator.dart';

void main() {
  const sanitizer = ContactSanitizer();
  const validator = ContactValidator();

  group('ContactSanitizer', () {
    test('trims and normalizes harmless input noise', () {
      final result = sanitizer.sanitize(
        name: '  Олена   Коваль\n',
        email: '  OLENA@Example.COM ',
        phone: ' +380 (67) 123-45-67 ',
      );

      expect(result.name, 'Олена Коваль');
      expect(result.email, 'olena@example.com');
      expect(result.phone, '+380671234567');
    });

    test('preserves invalid phone characters for validator to reject', () {
      final result = sanitizer.sanitize(
        name: 'Olena',
        email: 'olena@example.com',
        phone: '1234567ext',
      );

      expect(result.phone, '1234567ext');
      expect(validator.validate(result).containsKey('phone'), isTrue);
    });
  });

  group('ContactValidator', () {
    test('accepts a valid Ukrainian contact', () {
      const draft = ContactDraft(
        name: 'Марія Шевченко',
        email: 'maria@example.com',
        phone: '+380671234567',
      );

      expect(validator.validate(draft), isEmpty);
    });

    test('returns an error for every invalid field', () {
      const draft = ContactDraft(name: ' ', email: 'bad@', phone: '123');

      expect(
        validator.validate(draft).keys,
        containsAll(['name', 'email', 'phone']),
      );
    });
  });
}
