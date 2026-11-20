import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sparein_mobile/modules/parts/models/part.dart';
import 'package:sparein_mobile/modules/parts/parts_service.dart';
import 'package:sparein_mobile/modules/parts/widgets/parts_widgets.dart';

/// Data toko yang lebih lama dari ini ditandai mungkin sudah berubah.
const _staleDays = 30;

/// Detail satu suku cadang dari `/api/v1/parts/<slug>/`.
class PartDetailPage extends StatefulWidget {
  const PartDetailPage({
    super.key,
    required this.slug,
    required this.title,
    this.service,
  });

  final String slug;

  /// Nama dari halaman daftar, dipakai di AppBar selama detail dimuat.
  final String title;
  final PartsService? service;

  @override
  State<PartDetailPage> createState() => _PartDetailPageState();
}

class _PartDetailPageState extends State<PartDetailPage> {
  late final PartsService _service = widget.service ?? PartsService();
  late Future<Part> _future = _service.fetchPart(widget.slug);

  void _reload() {
    setState(() {
      _future = _service.fetchPart(widget.slug);
    });
  }

  Future<void> _copy(String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, overflow: TextOverflow.ellipsis),
      ),
      body: FutureBuilder<Part>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: PartsMessage(
                icon: Icons.cloud_off_outlined,
                message: 'Gagal memuat detail suku cadang.',
                actionLabel: 'Coba lagi',
                onAction: _reload,
              ),
            );
          }
          return _PartDetail(part: snapshot.requireData, onCopy: _copy);
        },
      ),
    );
  }
}

class _PartDetail extends StatelessWidget {
  const _PartDetail({required this.part, required this.onCopy});

  final Part part;
  final void Function(String text, String message) onCopy;

  String get _priceSummary {
    final sources = part.sources;
    if (sources.isEmpty) return 'Harga belum tersedia.';
    final prices = [
      for (final s in sources)
        if (s.price != null) s.price!,
    ];
    if (prices.isEmpty) return 'Harga dan kontak penjual cuma buat member.';
    final low = prices.reduce((a, b) => a < b ? a : b);
    final high = prices.reduce((a, b) => a > b ? a : b);
    if (low == high) {
      return 'Harga ${formatRupiah(low)} dari ${sources.length} toko';
    }
    return 'Kisaran ${formatRupiah(low)} sampai ${formatRupiah(high)} '
        'dari ${sources.length} toko';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PartThumbnail(imageUrl: part.imageUrl, size: 72),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryBadge(part.categoryLabel),
                  const SizedBox(height: 4),
                  Text(part.name, style: theme.textTheme.titleLarge),
                  if (part.partNumber.isNotEmpty)
                    Row(
                      children: [
                        Text(
                          part.partNumber,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                        IconButton(
                          tooltip: 'Salin nomor part',
                          visualDensity: VisualDensity.compact,
                          iconSize: 18,
                          icon: const Icon(Icons.copy_outlined),
                          onPressed: () =>
                              onCopy(part.partNumber, 'Nomor part disalin'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
        if (part.description.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(part.description),
        ],
        const SizedBox(height: 8),
        Text(
          _priceSummary,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text('Cocok untuk perangkat', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (part.compatibilities.isEmpty)
          const Text('Belum ada perangkat yang dicatat.')
        else
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                for (final c in part.compatibilities)
                  ListTile(
                    leading: const Icon(Icons.smartphone_outlined),
                    title: Text(c.deviceName),
                    subtitle: c.note.isEmpty ? null : Text(c.note),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        Text('Tempat beli', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        if (part.sources.isEmpty)
          const Text('Belum ada toko yang terdaftar buat suku cadang ini.')
        else ...[
          Text(
            'Sparein tidak menjual barang. Harga bisa berubah, '
            'selalu cek lagi di toko sebelum beli.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          for (final s in part.sources) _SourceCard(source: s, onCopy: onCopy),
        ],
      ],
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.source, required this.onCopy});

  final PartSource source;
  final void Function(String text, String message) onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final checked = source.lastChecked;
    final stale =
        checked != null &&
        DateTime.now().difference(checked).inDays > _staleDays;
    final contact = source.contact ?? '';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    source.vendorName,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                if (source.price != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      formatRupiah(source.price!),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Flexible(
                  child: Text(
                    [
                      source.city,
                      if (checked != null) 'Dicek ${daysAgo(checked)}',
                    ].where((s) => s.isNotEmpty).join(' · '),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                if (stale)
                  Tooltip(
                    message:
                        'Data lebih dari $_staleDays hari, '
                        'mungkin sudah berubah',
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
            if (contact.isNotEmpty)
              Text('Kontak: $contact', style: theme.textTheme.bodySmall),
            if (source.url.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => onCopy(source.url, 'Tautan toko disalin'),
                  icon: const Icon(Icons.link, size: 18),
                  label: const Text('Salin tautan toko'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
