import '../data/contact_repository.dart';
import '../models/contact.dart';
import '../validation/contact_sanitizer.dart';
import '../validation/contact_validator.dart';

class ContactValidationException implements Exception {
  const ContactValidationException(this.errors);

  final Map<String, String> errors;
}

class ContactStorageException implements Exception {
  const ContactStorageException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

/// Coordinates sanitization, validation, and persistence in that order.
class ContactService {
  const ContactService(
    this._repository, {
    this._sanitizer = const ContactSanitizer(),
    this._validator = const ContactValidator(),
  });

  final ContactRepository _repository;
  final ContactSanitizer _sanitizer;
  final ContactValidator _validator;

  Future<List<Contact>> getContacts() async {
    try {
      return await _repository.getAll();
    } catch (error) {
      throw ContactStorageException(
        'Не вдалося завантажити контакти.',
        cause: error,
      );
    }
  }

  Future<Contact> createContact({
    required String name,
    required String email,
    required String phone,
  }) async {
    final cleaned = _sanitizer.sanitize(name: name, email: email, phone: phone);
    final errors = _validator.validate(cleaned);
    if (errors.isNotEmpty) {
      throw ContactValidationException(errors);
    }

    final contact = Contact(
      name: cleaned.name,
      email: cleaned.email,
      phone: cleaned.phone,
      createdAt: DateTime.now(),
    );

    try {
      return await _repository.insert(contact);
    } catch (error) {
      throw ContactStorageException(
        'Не вдалося зберегти контакт. Перевірте, чи така пошта вже не використовується.',
        cause: error,
      );
    }
  }

  Future<void> deleteContact(int id) async {
    try {
      await _repository.delete(id);
    } catch (error) {
      throw ContactStorageException(
        'Не вдалося видалити контакт.',
        cause: error,
      );
    }
  }
}
