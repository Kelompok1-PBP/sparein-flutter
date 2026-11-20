import 'package:flutter/material.dart';
import 'package:sparein_mobile/core/network/api_client.dart';
import 'package:sparein_mobile/modules/diagnostics/diagnostics_service.dart';
import 'package:sparein_mobile/modules/diagnostics/models/symptom.dart';

// Warna dari design token web (core/static/core/base.css).
const _blue200 = Color(0xFFB0D7FB);
const _muted = Color(0xFF5B6472);

class DiagnosticsPage extends StatefulWidget {
  const DiagnosticsPage({super.key, this.api});

  final ApiClient? api;

  @override
  State<DiagnosticsPage> createState() => _DiagnosticsPageState();
}

class _DiagnosticsPageState extends State<DiagnosticsPage> {
  late final Future<List<Symptom>> _symptoms = DiagnosticsService(
    api: widget.api,
  ).fetchSymptoms();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnosa masalah')),
      body: FutureBuilder<List<Symptom>>(
        future: _symptoms,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Gagal memuat gejala.'));
          }
          final symptoms = snapshot.data!;
          if (symptoms.isEmpty) {
            return const Center(child: Text('Belum ada gejala yang dicatat.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: symptoms.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => SymptomCard(symptom: symptoms[i]),
          );
        },
      ),
    );
  }
}

/// Meniru baris gejala di `diagnostics/diagnose.html`: judul, deskripsi, lalu keparahan.
class SymptomCard extends StatelessWidget {
  const SymptomCard({super.key, required this.symptom});

  final Symptom symptom;

  static Color _severityColor(String severity) => switch (severity) {
    'low' => const Color(0xFF16A34A),
    'high' => const Color(0xFFDC2626),
    _ => const Color(0xFFD97706),
  };

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(symptom.severity);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _blue200),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symptom.title,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 26 / 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (symptom.description.isNotEmpty)
                  Text(
                    symptom.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      color: _muted,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              symptom.severityLabel,
              style: TextStyle(fontSize: 14, height: 20 / 14, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
