
import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/notes_file_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotesFileManager _fileManager = NotesFileManager();
  final TextEditingController _searchController = TextEditingController();

  List<Note> _notes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);

    try {
      List<Note> notes;

      if (_selectedDate != null) {
        notes = await _fileManager.filterNotesByDate(_selectedDate!);
      } else if (_searchQuery.isNotEmpty) {
        notes = await _fileManager.searchNotes(_searchQuery);
      } else {
        notes = await _fileManager.getNotes();
      }

      if (!mounted) return;

      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      _showMessage(e.toString());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showNoteDialog({Note? note}) async {
    final titleController = TextEditingController(
      text: note?.title ?? '',
    );
    final contentController = TextEditingController(
      text: note?.content ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(note == null ? 'Нова нотатка' : 'Редагування нотатки'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Назва нотатки',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Текст нотатки',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Скасувати'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Зберегти'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        if (note == null) {
          await _fileManager.createNote(
            titleController.text.trim(),
            contentController.text,
          );
        } else {
          await _fileManager.updateNote(
            note.fileName,
            titleController.text.trim(),
            contentController.text,
          );
        }

        await _loadNotes();
        if (mounted) _showMessage('Нотатку збережено');
      } catch (e) {
        if (mounted) _showMessage(e.toString());
      }
    }

    titleController.dispose();
    contentController.dispose();
  }

  Future<void> _renameNote(Note note) async {
    final controller = TextEditingController(text: note.title);

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Перейменувати нотатку'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Нова назва',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Перейменувати'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _fileManager.renameNote(
          note.fileName,
          controller.text.trim(),
        );
        await _loadNotes();
        if (mounted) _showMessage('Нотатку перейменовано');
      } catch (e) {
        if (mounted) _showMessage(e.toString());
      }
    }

    controller.dispose();
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Видалити нотатку?'),
        content: Text('Ви дійсно хочете видалити "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Видалити'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _fileManager.deleteNote(note.fileName);
        await _loadNotes();
        if (mounted) _showMessage('Нотатку видалено');
      } catch (e) {
        if (mounted) _showMessage(e.toString());
      }
    }
  }

  Future<void> _exportNote(Note note) async {
    try {
      final file = await _fileManager.exportNoteToJson(note.fileName);

      if (mounted) {
        _showMessage('JSON-файл збережено: ${file.path}');
      }
    } catch (e) {
      if (mounted) _showMessage(e.toString());
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _searchQuery = '';
        _searchController.clear();
      });
      await _loadNotes();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes Б';
    return '${(bytes / 1024).toStringAsFixed(2)} КБ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Менеджер нотаток'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Фільтр за датою',
            icon: const Icon(Icons.calendar_month),
            onPressed: _selectDate,
          ),
          if (_selectedDate != null)
            IconButton(
              tooltip: 'Скинути фільтр',
              icon: const Icon(Icons.filter_alt_off),
              onPressed: () {
                setState(() => _selectedDate = null);
                _loadNotes();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Пошук нотаток...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _selectedDate = null;
                    });
                    _loadNotes();
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _selectedDate = null;
                });
                _loadNotes();
              },
            ),
          ),
          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Фільтр за датою: ${_formatDate(_selectedDate!)}',
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notes.isEmpty
                    ? const Center(
                        child: Text(
                          'Нотаток поки немає',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadNotes,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _notes.length,
                          itemBuilder: (context, index) {
                            final note = _notes[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(
                                  note.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        note.content.isEmpty
                                            ? 'Порожня нотатка'
                                            : note.content,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Змінено: ${_formatDate(note.lastModified)}',
                                      ),
                                      Text(
                                        'Розмір: ${_formatSize(note.size)}',
                                      ),
                                    ],
                                  ),
                                ),
                                isThreeLine: true,
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'edit':
                                        _showNoteDialog(note: note);
                                        break;
                                      case 'rename':
                                        _renameNote(note);
                                        break;
                                      case 'export':
                                        _exportNote(note);
                                        break;
                                      case 'delete':
                                        _deleteNote(note);
                                        break;
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Редагувати'),
                                    ),
                                    PopupMenuItem(
                                      value: 'rename',
                                      child: Text('Перейменувати'),
                                    ),
                                    PopupMenuItem(
                                      value: 'export',
                                      child: Text('Експорт JSON'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Видалити'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        tooltip: 'Створити нотатку',
        child: const Icon(Icons.add),
      ),
    );
  }
}
