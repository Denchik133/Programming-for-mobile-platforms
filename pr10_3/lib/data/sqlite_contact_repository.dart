import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/contact.dart';
import 'contact_repository.dart';

class SqliteContactRepository implements ContactRepository {
  SqliteContactRepository(this._database);

  final Database _database;

  static Future<SqliteContactRepository> open() async {
    final databasePath = await getDatabasesPath();
    final database = await openDatabase(
      path.join(databasePath, 'pr10_3_contacts.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE contacts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL CHECK(length(name) BETWEEN 2 AND 60),
            email TEXT NOT NULL COLLATE NOCASE UNIQUE,
            phone TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
    return SqliteContactRepository(database);
  }

  @override
  Future<List<Contact>> getAll() async {
    final rows = await _database.query('contacts', orderBy: 'id DESC');
    return rows.map(Contact.fromMap).toList(growable: false);
  }

  @override
  Future<Contact> insert(Contact contact) async {
    final id = await _database.insert(
      'contacts',
      contact.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    return contact.withId(id);
  }

  @override
  Future<void> delete(int id) async {
    await _database.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }
}
