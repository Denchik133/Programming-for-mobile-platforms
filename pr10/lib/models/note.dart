
class Note {
  final String fileName;
  final String title;
  final String content;
  final DateTime lastModified;
  final int size;

  Note({
    required this.fileName,
    required this.title,
    required this.content,
    required this.lastModified,
    required this.size,
  });
}
