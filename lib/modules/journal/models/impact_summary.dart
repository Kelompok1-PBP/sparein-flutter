/// Total dampak: jumlah perbaikan berhasil, limbah yang dihindari, dan biaya yang dihemat.
class ImpactSummary {
  const ImpactSummary({
    required this.repairs,
    required this.wasteAvoidedKg,
    required this.costAvoided,
  });

  factory ImpactSummary.fromJson(Map<String, dynamic> json) => ImpactSummary(
    repairs: (json['repairs'] as num).toInt(),
    wasteAvoidedKg: (json['waste_avoided_kg'] as num).toDouble(),
    costAvoided: (json['cost_avoided'] as num).toInt(),
  );

  final int repairs;
  final double wasteAvoidedKg;
  final int costAvoided;
}

/// Respons `/api/v1/journal/summary/`.
///
/// Visitor hanya mendapat [site]. Member juga mendapat [personal].
class JournalSummary {
  const JournalSummary({required this.site, this.personal});

  factory JournalSummary.fromJson(Map<String, dynamic> json) {
    final personal = json['summary'];
    return JournalSummary(
      site: ImpactSummary.fromJson(json['site'] as Map<String, dynamic>),
      personal: personal == null
          ? null
          : ImpactSummary.fromJson(personal as Map<String, dynamic>),
    );
  }

  final ImpactSummary site;
  final ImpactSummary? personal;

  bool get isMember => personal != null;
}
