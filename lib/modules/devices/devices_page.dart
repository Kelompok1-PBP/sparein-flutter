import 'package:flutter/material.dart';
import 'package:sparein_mobile/core/network/api_client.dart';
import 'package:sparein_mobile/modules/devices/device.dart';

// Warna dari design token web (core/static/core/base.css).
const _blue200 = Color(0xFFB0D7FB);
const _muted = Color(0xFF5B6472);
const _surface = Color(0xFFF7F9FC);

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key, this.api});

  final ApiClient? api;

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  late final Future<List<Device>> _devices = _load();

  Future<List<Device>> _load() async {
    final data = await (widget.api ?? ApiClient()).getJson('/api/v1/devices/');
    return [
      for (final item in data['results'] as List)
        Device.fromJson(item as Map<String, dynamic>),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perangkat')),
      body: FutureBuilder<List<Device>>(
        future: _devices,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Gagal memuat perangkat.'));
          }
          final devices = snapshot.data!;
          if (devices.isEmpty) {
            return const Center(child: Text('Perangkat tidak ditemukan.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: devices.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (_, i) => DeviceCard(device: devices[i]),
          );
        },
      ),
    );
  }
}

/// Meniru `devices/_card.html`: gambar 4:3 di atas, nama, lalu merek.
class DeviceCard extends StatelessWidget {
  const DeviceCard({super.key, required this.device});

  final Device device;

  @override
  Widget build(BuildContext context) {
    const placeholder = Icon(
      Icons.inventory_2_outlined,
      size: 40,
      color: _muted,
    );
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _blue200),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ColoredBox(
              color: _surface,
              child: Center(
                child: device.imageUrl.isEmpty
                    ? placeholder
                    : FractionallySizedBox(
                        widthFactor: 0.8,
                        heightFactor: 0.8,
                        child: Image.network(
                          device.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => placeholder,
                        ),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 26 / 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (device.brand.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      device.brand,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        color: _muted,
                      ),
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
