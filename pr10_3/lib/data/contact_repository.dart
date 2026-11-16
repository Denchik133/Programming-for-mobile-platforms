import '../models/contact.dart';

abstract interface class ContactRepository {
  Future<List<Contact>> getAll();

  Future<Contact> insert(Contact contact);

  Future<void> delete(int id);
}
