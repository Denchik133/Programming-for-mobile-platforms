class ContactDraft {
  const ContactDraft({
    required this.name,
    required this.email,
    required this.phone,
  });

  final String name;
  final String email;
  final String phone;
}

/// Normalizes harmless input noise while preserving invalid characters so
/// validators can reject them instead of silently changing the user's data.
class ContactSanitizer {
  const ContactSanitizer();

  ContactDraft sanitize({
    required String name,
    required String email,
    required String phone,
  }) {
    return ContactDraft(
      name: sanitizeName(name),
      email: sanitizeEmail(email),
      phone: sanitizePhone(phone),
    );
  }

  String sanitizeName(String value) => value
      .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  String sanitizeEmail(String value) => value.trim().toLowerCase();

  String sanitizePhone(String value) =>
      value.trim().replaceAll(RegExp(r'[\s().-]'), '');
}
