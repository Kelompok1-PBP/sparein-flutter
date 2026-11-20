import 'package:flutter/material.dart';
import 'package:sparein_mobile/core/network/api_client.dart';
import 'package:sparein_mobile/modules/journal/journal_format.dart';
import 'package:sparein_mobile/modules/journal/journal_service.dart';
import 'package:sparein_mobile/modules/journal/models/impact_summary.dart';

// Warna dari design token web (core/static/core/base.css).
const _blue200 = Color(0xFFB0D7FB);
const _blue500 = Color(0xFF1581EE);
const _success = Color(0xFF16A34A);
const _muted = Color(0xFF5B6472);

class JournalPage extends StatefulWidget {
  const JournalPage({super.key, this.api});

  final ApiClient? api;

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  late final Future<JournalSummary> _summary = JournalService(api: widget.api)
      .fetchSummary();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jurnal Perbaikan')),
      body: FutureBuilder<JournalSummary>(
        future: _summary,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Gagal memuat jurnal.'));
          }
          final summary = snapshot.data!;
          final impact = summary.personal ?? summary.site;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                summary.isMember
                    ? 'Catatan semua perbaikan yang kamu kerjakan.'
                    : 'Dampak nyata dari perbaikan yang dicatat komunitas Sparein.',
                style: const TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  color: _muted,
                ),
              ),
              const SizedBox(height: 16),
              _StatTile(
                icon: Icons.check_circle_outline,
                color: _success,
                value: '${impact.repairs}',
                label: 'perbaikan berhasil',
              ),
              const SizedBox(height: 12),
              _StatTile(
                icon: Icons.eco_outlined,
                color: _success,
                value: JournalFormat.kg(impact.wasteAvoidedKg),
                label: 'limbah elektronik terhindar',
              ),
              const SizedBox(height: 12),
              _StatTile(
                icon: Icons.account_balance_wallet_outlined,
                color: _blue500,
                value: JournalFormat.rupiahShort(impact.costAvoided),
                label: 'biaya ganti baru yang dihemat',
              ),
              if (!summary.isMember) ...[
                const SizedBox(height: 16),
                const _LoginHint(),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Meniru `journal/_stat_tiles.html`: ikon, angka, lalu keterangan.
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _blue200),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 28 / 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Ajakan untuk visitor, teks sama dengan kartu `j-cta` di web.
class _LoginHint extends StatelessWidget {
  const _LoginHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _blue200),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Catat perbaikanmu sendiri',
            style: TextStyle(
              fontSize: 18,
              height: 28 / 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Masuk untuk menyimpan riwayat perbaikan dan melihat berapa limbah elektronik yang kamu hindari.',
            style: TextStyle(fontSize: 14, height: 20 / 14),
          ),
        ],
      ),
    );
  }
}
