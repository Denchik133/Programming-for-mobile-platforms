import 'contact_sanitizer.dart';

class ContactValidator {
  const ContactValidator();

  Map<String, String> validate(ContactDraft draft) {
    final errors = <String, String>{};

    final name = draft.name;
    if (name.isEmpty) {
      errors['name'] = 'Вкажіть ім’я.';
    } else if (name.length < 2 || name.length > 60) {
      errors['name'] = 'Ім’я має містити від 2 до 60 символів.';
    } else if (name.contains('<') || name.contains('>')) {
      errors['name'] = 'Ім’я містить недопустимі символи.';
    } else if (!RegExp(r'[A-Za-z\u0400-\u04FF]').hasMatch(name)) {
      errors['name'] = 'Ім’я має містити літери.';
    }

    final email = draft.email;
    if (email.isEmpty) {
      errors['email'] = 'Вкажіть електронну пошту.';
    } else if (email.length > 254 ||
        !RegExp(
          r'^[A-Z0-9.!#$%&\x27*+/=?^_`{|}~-]+@[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?(?:\.[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?)+$',
          caseSensitive: false,
        ).hasMatch(email)) {
      errors['email'] = 'Введіть коректну електронну адресу.';
    }

    final phone = draft.phone;
    if (phone.isEmpty) {
      errors['phone'] = 'Вкажіть номер телефону.';
    } else if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(phone)) {
      errors['phone'] = 'Введіть 7–15 цифр, за потреби з + на початку.';
    }

    return errors;
  }
}
