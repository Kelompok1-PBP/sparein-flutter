import 'package:flutter/material.dart';
import 'package:sparein_mobile/modules/parts/models/part.dart';
import 'package:sparein_mobile/modules/parts/part_detail_page.dart';
import 'package:sparein_mobile/modules/parts/parts_service.dart';
import 'package:sparein_mobile/modules/parts/widgets/parts_widgets.dart';

/// M4 Parts: direktori suku cadang dari `/api/v1/parts/`.
class PartsPage extends StatefulWidget {
  const PartsPage({super.key, this.service});

  /// Bisa diganti di test, default-nya memanggil web service Django.
  final PartsService? service;

  @override
  State<PartsPage> createState() => _PartsPageState();
}

class _PartsPageState extends State<PartsPage> {
  late final PartsService _service = widget.service ?? PartsService();
  final _search = TextEditingController();
  String _query = '';
  String? _category;
  late Future<List<Part>> _future;

  bool get _filtered => _query.isNotEmpty || _category != null;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<List<Part>> _load() =>
      _service.fetchParts(q: _query, category: _category);

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() {
      _future = future;
    });
    try {
      await future;
    } catch (_) {
      // Error-nya ditampilkan FutureBuilder.
    }
  }

  void _submitSearch(String value) {
    _query = value.trim();
    _reload();
  }

  void _clearSearch() {
    _search.clear();
    if (_query.isEmpty) return;
    _query = '';
    _reload();
  }

  void _toggleCategory(String value) {
    _category = _category == value ? null : value;
    _reload();
  }

  void _resetFilters() {
    _search.clear();
    _query = '';
    _category = null;
    _reload();
  }

  void _openDetail(Part part) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PartDetailPage(
          slug: part.slug,
          title: part.name,
          service: _service,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parts')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _search,
              builder: (context, value, child) => TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
                onSubmitted: _submitSearch,
                decoration: InputDecoration(
                  hintText: 'Cari nama atau nomor part',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: value.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Hapus pencarian',
                          icon: const Icon(Icons.close),
                          onPressed: _clearSearch,
                        ),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final entry in partCategories.entries)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(entry.value),
                      selected: _category == entry.key,
                      onSelected: (_) => _toggleCategory(entry.key),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<Part>>(
                future: _future,
                builder: _buildResults,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(
    BuildContext context,
    AsyncSnapshot<List<Part>> snapshot,
  ) {
    final loading = snapshot.connectionState != ConnectionState.done;
    if (loading && !snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return ScrollableMessage(
        child: PartsMessage(
          icon: Icons.cloud_off_outlined,
          message: 'Gagal memuat suku cadang.\nPeriksa koneksi lalu coba lagi.',
          actionLabel: 'Coba lagi',
          onAction: _reload,
        ),
      );
    }
    final parts = snapshot.data ?? const <Part>[];
    if (parts.isEmpty) {
      return ScrollableMessage(
        child: PartsMessage(
          icon: Icons.inbox_outlined,
          message: _filtered
              ? 'Belum ada suku cadang yang cocok.'
              : 'Belum ada suku cadang terdaftar.',
          actionLabel: _filtered ? 'Reset filter' : null,
          onAction: _filtered ? _resetFilters : null,
        ),
      );
    }
    return Stack(
      children: [
        ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          itemCount: parts.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${parts.length} suku cadang',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }
            final part = parts[i - 1];
            return _PartCard(part: part, onTap: () => _openDetail(part));
          },
        ),
        if (loading) const LinearProgressIndicator(minHeight: 2),
      ],
    );
  }
}

String _priceSummary(Part part) {
  if (part.sourceCount == 0) return 'Harga belum tersedia';
  final price = part.lowestPrice;
  if (price == null) return 'Harga untuk member · ${part.sourceCount} toko';
  return 'Mulai ${formatRupiah(price)} · ${part.sourceCount} toko';
}

class _PartCard extends StatelessWidget {
  const _PartCard({required this.part, required this.onTap});

  final Part part;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              PartThumbnail(imageUrl: part.imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CategoryBadge(part.categoryLabel),
                    const SizedBox(height: 4),
                    Text(part.name, style: theme.textTheme.titleMedium),
                    if (part.partNumber.isNotEmpty)
                      Text(part.partNumber, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text(
                      _priceSummary(part),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
