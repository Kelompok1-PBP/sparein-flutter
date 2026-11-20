/// Gejala kerusakan milik satu perangkat (`/api/v1/symptoms/`).
class Symptom {
  const Symptom({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.severity,
    required this.severityLabel,
  });

  factory Symptom.fromJson(Map<String, dynamic> json) => Symptom(
    id: json['id'] as int,
    title: json['title'] as String,
    slug: json['slug'] as String,
    description: json['description'] as String? ?? '',
    severity: json['severity'] as String? ?? 'medium',
    severityLabel: json['severity_label'] as String? ?? '',
  );

  final int id;
  final String title;
  final String slug;
  final String description;

  /// `low`, `medium`, atau `high`.
  final String severity;
  final String severityLabel;
}
