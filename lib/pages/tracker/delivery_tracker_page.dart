// File: lib/pages/tracker/delivery_tracker_page.dart
// (Versi LENGKAP + Chat kirim orderId asli)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/routes/app_routes.dart';
import '../../data/models/order_model.dart';
import '../../data/services/api_service.dart';

class DeliveryStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final IconData activeIcon;

  DeliveryStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.activeIcon,
  });
}

class DeliveryTrackerPage extends StatefulWidget {
  const DeliveryTrackerPage({super.key});

  @override
  State<DeliveryTrackerPage> createState() => _DeliveryTrackerPageState();
}

class _DeliveryTrackerPageState extends State<DeliveryTrackerPage> {
  late final MapController _mapController;
  late final DraggableScrollableController _sheetController;

  final ApiService _apiService = ApiService();
  Timer? _locationTimer;

  Order? _order;

  final LatLng _startPoint = const LatLng(-6.175, 106.828);
  final LatLng _endPoint = const LatLng(-6.200, 106.845);
  late LatLng _driverLocation;

  bool _isInit = true;
  bool _isSheetFullScreen = false;

  final double _initialSheetSize = 0.25;
  final double _minSheetSize = 0.25;
  final double _maxSheetSize = 0.9;

  final List<DeliveryStep> _deliverySteps = [
    DeliveryStep(
      title: "Pesanan Dikonfirmasi",
      subtitle: "Kedai sedang menyiapkan pesanan Anda.",
      icon: Icons.radio_button_unchecked,
      activeIcon: Icons.check_circle_outline,
    ),
    DeliveryStep(
      title: "Driver Menuju Kedai Kopi",
      subtitle: "Driver sedang dalam perjalanan.",
      icon: Icons.radio_button_unchecked,
      activeIcon: Icons.storefront,
    ),
    DeliveryStep(
      title: "Pesanan Siap Diambil",
      subtitle: "Driver telah mengambil pesanan.",
      icon: Icons.radio_button_unchecked,
      activeIcon: Icons.shopping_bag_outlined,
    ),
    DeliveryStep(
      title: "Pesanan Sedang Diantar",
      subtitle: "Driver sedang menuju ke lokasi Anda.",
      icon: Icons.radio_button_unchecked,
      activeIcon: Icons.local_shipping,
    ),
    DeliveryStep(
      title: "Tiba di Lokasi",
      subtitle: "Silakan ambil pesanan Anda.",
      icon: Icons.radio_button_unchecked,
      activeIcon: Icons.flag_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _sheetController = DraggableScrollableController();
    _driverLocation = _startPoint;

    _sheetController.addListener(() {
      final isFull = _sheetController.size > (_maxSheetSize - 0.1);
      if (isFull != _isSheetFullScreen) {
        setState(() => _isSheetFullScreen = isFull);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args is Order) {
        _order = args;
        _startTracking();
      } else if (args is Map<String, dynamic>) {
        _order = Order.fromJson(args);
        _startTracking();
      }

      if (_order?.driver != null) {
        _driverLocation = LatLng(
          _order!.driver!.currentLat,
          _order!.driver!.currentLng,
        );
      }

      _isInit = false;
    }
  }

  void _startTracking() {
    _fetchOrderDetails();

    _locationTimer?.cancel();
    _locationTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _fetchOrderDetails();

      if (_order?.driverId != null) {
        final data =
            await _apiService.getDriverLocation(_order!.driverId!);
        if (mounted) {
          setState(() {
            _driverLocation = LatLng(
              (data['current_lat'] as num).toDouble(),
              (data['current_lng'] as num).toDouble(),
            );
          });
        }
      }
    });
  }

  Future<void> _fetchOrderDetails() async {
    if (_order == null) return;

    final updated = await _apiService.getOrderById(_order!.id);
    if (mounted) {
      setState(() => _order = updated);
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _mapController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding =
        MediaQuery.of(context).size.height * _initialSheetSize;

    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildMap(),
          _buildMapControls(bottomPadding: bottomPadding + 16),
          _buildDraggableSheet(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.home, (_) => false),
      ),
      title: const Text(
        "Tracking",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _startPoint,
        initialZoom: 14,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: _driverLocation,
              width: 260,
              height: 80,
              child: _buildDriverMarker(),
            ),
            Marker(
              point: _endPoint,
              width: 50,
              height: 50,
              child: const Icon(Icons.location_pin,
                  color: Colors.red, size: 50),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDriverMarker() {
    final name = _order?.driver?.name ?? "Mencari Driver...";
    final id = _order?.driver != null
        ? "ID ${_order!.driver!.id}"
        : "";
    final avatar = _order?.driver?.photoUrl != null
        ? NetworkImage(_order!.driver!.photoUrl!)
        : const AssetImage("assets/images/profile1.jpg");

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            CircleAvatar(
            radius: 25, 
            backgroundImage: avatar is ImageProvider ? avatar as ImageProvider : AssetImage(avatar.toString()),
),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold)),
                  Text(id,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),

            /// ✅ CHAT BUTTON (FIXED)
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () {
                if (_order != null) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.chatDetail,
                    arguments: {
                      'orderId': _order!.id, // ✅ ID ORDER ASLI
                      'name': _order!.driver?.name ?? 'Driver',
                      'avatar': _order!.driver?.photoUrl ??
                          'assets/images/profile1.jpg',
                      'id': 'ID ${_order!.driver?.id ?? ""}',
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControls({required double bottomPadding}) {
    return Positioned(
      bottom: bottomPadding,
      right: 16,
      child: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          _mapController.move(
              _driverLocation, _mapController.camera.zoom);
        },
        child: const Icon(Icons.my_location, color: Colors.black),
      ),
    );
  }

  Widget _buildDraggableSheet() {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: _initialSheetSize,
      minChildSize: _minSheetSize,
      maxChildSize: _maxSheetSize,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: const [
              Center(
                child: Text(
                  "Status Pengiriman",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
