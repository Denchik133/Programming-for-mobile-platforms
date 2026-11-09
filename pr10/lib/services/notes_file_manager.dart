
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/note.dart';
import 'package:flutter/foundation.dart';

class NotesFileManager {
  Future<Directory> _getNotesDirectory() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final notesDirectory = Directory('${appDirectory.path}/notes');

    if (!await notesDirectory.exists()) {
      await notesDirectory.create(recursive: true);
    }

    return notesDirectory;
  }

  String _createFileName(String title) {
    final safeName = title
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');

    return '${safeName.isEmpty ? 'note' : safeName}_${DateTime.now().millisecondsSinceEpoch}.json';
  }

  // Створення нотатки.
  Future<void> createNote(String title, String content) async {
    try {
      final directory = await _getNotesDirectory();
      final fileName = _createFileName(title);
      final file = File('${directory.path}/$fileName');
      debugPrint('Файл нотатки: ${file.path}');

      final data = {
        'title': title,
        'content': content,
        'lastModified': DateTime.now().toIso8601String(),
      };

      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      throw Exception('Помилка створення нотатки: $e');
    }
  }

  // Читання нотатки.
  Future<Note> readNote(String fileName) async {
    try {
      final directory = await _getNotesDirectory();
      final file = File('${directory.path}/$fileName');

      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      return Note(
        fileName: fileName,
        title: data['title'] as String,
        content: data['content'] as String,
        lastModified: DateTime.parse(data['lastModified'] as String),
        size: await file.length(),
      );
    } catch (e) {
      throw Exception('Помилка читання нотатки: $e');
    }
  }

  // Отримання списку всіх нотаток.
  Future<List<Note>> getNotes() async {
    try {
      final directory = await _getNotesDirectory();
      final files = directory.listSync().whereType<File>();

      final notes = <Note>[];

      for (final file in files) {
        if (file.path.endsWith('.json')) {
          final fileName = file.uri.pathSegments.last;
          notes.add(await readNote(fileName));
        }
      }

      notes.sort(
        (a, b) => b.lastModified.compareTo(a.lastModified),
      );

      return notes;
    } catch (e) {
      throw Exception('Помилка отримання списку нотаток: $e');
    }
  }

  // Редагування нотатки.
  Future<void> updateNote(
    String fileName,
    String title,
    String content,
  ) async {
    try {
      final directory = await _getNotesDirectory();
      final file = File('${directory.path}/$fileName');

      final data = {
        'title': title,
        'content': content,
        'lastModified': DateTime.now().toIso8601String(),
      };

      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      throw Exception('Помилка редагування нотатки: $e');
    }
  }

  // Видалення нотатки.
  Future<void> deleteNote(String fileName) async {
    try {
      final directory = await _getNotesDirectory();
      final file = File('${directory.path}/$fileName');

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Помилка видалення нотатки: $e');
    }
  }

  // Перейменування файлу нотатки.
  Future<void> renameNote(String fileName, String newTitle) async {
    try {
      final note = await readNote(fileName);
      final directory = await _getNotesDirectory();
      final newFileName = _createFileName(newTitle);

      final oldFile = File('${directory.path}/$fileName');
      final newFile = File('${directory.path}/$newFileName');

      final data = {
        'title': newTitle,
        'content': note.content,
        'lastModified': DateTime.now().toIso8601String(),
      };

      await newFile.writeAsString(jsonEncode(data));
      await oldFile.delete();
    } catch (e) {
      throw Exception('Помилка перейменування нотатки: $e');
    }
  }

  // Пошук нотаток за назвою або вмістом.
  Future<List<Note>> searchNotes(String query) async {
    final notes = await getNotes();
    final searchQuery = query.toLowerCase();

    return notes.where((note) {
      return note.title.toLowerCase().contains(searchQuery) ||
          note.content.toLowerCase().contains(searchQuery);
    }).toList();
  }

  // Фільтрація нотаток за датою.
  Future<List<Note>> filterNotesByDate(DateTime date) async {
    final notes = await getNotes();

    return notes.where((note) {
      return note.lastModified.year == date.year &&
          note.lastModified.month == date.month &&
          note.lastModified.day == date.day;
    }).toList();
  }

  // Експорт нотатки в окремий JSON-файл.
  Future<File> exportNoteToJson(String fileName) async {
    try {
      final note = await readNote(fileName);
      final directory = await _getNotesDirectory();

      final exportFile = File(
        '${directory.path}/export_${note.fileName}',
      );

      final data = {
        'title': note.title,
        'content': note.content,
        'lastModified': note.lastModified.toIso8601String(),
        'size': note.size,
      };

      await exportFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(data),
      );

      return exportFile;
    } catch (e) {
      throw Exception('Помилка експорту нотатки: $e');
    }
  }
}
