import 'package:flutter_test/flutter_test.dart';
import 'package:pr10_3/data/contact_repository.dart';
import 'package:pr10_3/models/contact.dart';
import 'package:pr10_3/services/contact_service.dart';

void main() {
  group('ContactService', () {
    test('validates and saves only sanitized values', () async {
      final repository = _FakeContactRepository();
      final service = ContactService(repository);

      final saved = await service.createContact(
        name: '  Олена   Коваль ',
        email: ' OLENA@Example.com ',
        phone: '+380 (67) 123-45-67',
      );

      expect(saved.name, 'Олена Коваль');
      expect(saved.email, 'olena@example.com');
      expect(saved.phone, '+380671234567');
      expect(repository.insertCalls, 1);
    });

    test('does not call repository when validation fails', () async {
      final repository = _FakeContactRepository();
      final service = ContactService(repository);

      await expectLater(
        service.createContact(name: '<>', email: 'bad', phone: '123'),
        throwsA(isA<ContactValidationException>()),
      );

      expect(repository.insertCalls, 0);
    });

    test(
      'converts persistence failures into a user-facing storage error',
      () async {
        final repository = _FakeContactRepository()..failInsert = true;
        final service = ContactService(repository);

        await expectLater(
          service.createContact(
            name: 'Olena Koval',
            email: 'olena@example.com',
            phone: '+380671234567',
          ),
          throwsA(isA<ContactStorageException>()),
        );
      },
    );
  });
}

class _FakeContactRepository implements ContactRepository {
  int insertCalls = 0;
  bool failInsert = false;
  final List<Contact> contacts = [];

  @override
  Future<void> delete(int id) async {
    contacts.removeWhere((contact) => contact.id == id);
  }

  @override
  Future<List<Contact>> getAll() async => List.unmodifiable(contacts);

  @override
  Future<Contact> insert(Contact contact) async {
    insertCalls++;
    if (failInsert) throw StateError('simulated database failure');
    final saved = contact.withId(insertCalls);
    contacts.add(saved);
    return saved;
  }
}
