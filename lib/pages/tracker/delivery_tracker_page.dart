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
import '../../providers/point_provider.dart'; // Import PointProvider
import '../../providers/coupon_provider.dart'; // Import CouponProvider
import 'package:provider/provider.dart'; // Import Provider

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
  bool _isLoading = false;
  String? _errorMessage;

  final double _initialSheetSize = 0.25;
  final double _minSheetSize = 0.25;
  final double _maxSheetSize = 0.9;

  final List<DeliveryStep> _deliverySteps = [
    DeliveryStep(
      title: "Pesanan Diterima",
      subtitle: "Kami telah menerima pesanan Anda.",
      icon: Icons.receipt_long,
      activeIcon: Icons.check_circle,
    ),
    DeliveryStep(
      title: "Mencari Driver & Menyiapkan",
      subtitle: "Sedang menyiapkan dan mencari pengemudi.",
      icon: Icons.soup_kitchen,
      activeIcon: Icons.storefront,
    ),
    DeliveryStep(
      title: "Driver Menuju Restoran",
      subtitle: "Driver sedang dalam perjalanan mengambil pesanan.",
      icon: Icons.directions_bike,
      activeIcon: Icons.directions_bike,
    ),
    DeliveryStep(
      title: "Dalam Pengantaran",
      subtitle: "Pesanan Anda sedang dalam perjalanan.",
      icon: Icons.local_shipping,
      activeIcon: Icons.local_shipping,
    ),
    DeliveryStep(
      title: "Pesanan Selesai",
      subtitle: "Selamat menikmati!",
      icon: Icons.flag,
      activeIcon: Icons.flag_circle,
    ),
  ];

  @override
  void initState() {
    super.initState();
    debugPrint("🚀 DeliveryTrackerPage INIT");
    _mapController = MapController();
    _sheetController = DraggableScrollableController();
    _driverLocation = _startPoint;

    _sheetController.addListener(() {
      final isFull = _sheetController.size > (_maxSheetSize - 0.1);
      if (isFull != _isSheetFullScreen) {
        setState(() => _isSheetFullScreen = isFull);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PointProvider>(context, listen: false).fetchPoints();
      Provider.of<CouponProvider>(context, listen: false).fetchCoupons();
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
        try {
          _order = Order.fromJson(args);
          _startTracking();
        } catch (e) {
          debugPrint("Error parsing order from args: $e");
        }
      } else {
        // No args: Trigger Fast Track (Auto Find Active Order)
        _fetchActiveOrder();
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

  Future<void> _fetchActiveOrder() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orders = await _apiService.getOrders();
      // Find the first order that is NOT completed and NOT cancelled
      final activeOrder = orders.firstWhere(
        (o) =>
            o.status.toLowerCase() != 'completed' &&
            o.status.toLowerCase() != 'cancelled',
        orElse: () => Order(
          id: -1, // Dummy ID indicating no active order
          orderNumber: '',
          totalPrice: 0,
          status: 'none',
          createdAt: '',
        ),
      );

      if (activeOrder.id != -1) {
        if (mounted) {
          setState(() {
            _order = activeOrder;
            _isLoading = false;
          });
          _startTracking();
        }
      } else {
        if (mounted) {
          setState(() {
            _order = null; // No active order found
            _isLoading = false;
            _errorMessage = "Tidak ada pesanan aktif saat ini.";
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching active order: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Gagal memuat pesanan aktif.";
        });
      }
    }
  }

  void _startTracking() {
    _fetchOrderDetails();

    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _fetchOrderDetails();

      if (_order?.driverId != null) {
        try {
          final data = await _apiService.getDriverLocation(_order!.driverId!);
          if (mounted) {
            setState(() {
              _driverLocation = LatLng(
                (data['current_lat'] as num).toDouble(),
                (data['current_lng'] as num).toDouble(),
              );
            });
          }
        } catch (e) {
          debugPrint("Error getting driver location: $e");
        }
      }
    });
  }

  Future<void> _fetchOrderDetails() async {
    if (_order == null) return;

    try {
      final updatedOrder = await _apiService.getOrderById(_order!.id);
      if (mounted) {
        setState(() {
          _order = updatedOrder;
          if (_order?.driver != null && _driverLocation == _startPoint) {
            _driverLocation =
                LatLng(_order!.driver!.currentLat, _order!.driver!.currentLng);
          }
        });
      }
    } catch (e) {
      debugPrint("Error refreshing order: $e");
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _mapController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  int _getCurrentStepIndex() {
    if (_order == null) return 0;
    switch (_order!.status.toLowerCase()) {
      case 'pending':
        return 0; // Pesanan Dikonfirmasi
      case 'confirmed':
      case 'processing': // Sedang disiapkan/mencari driver
        return 1; // Driver Menuju Kedai (Waiting for Driver/Driver Assigned)
      case 'on_delivery': // Driver bawa pesanan
        return 3; // Pesanan Sedang Diantar
      case 'completed': // Selesai
        return 4; // Tiba di Lokasi / Selesai
      case 'cancelled':
        return -1;
      default:
        return 0;
    }
  }

  String _getEstimatedTime(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return "Disiapkan";
      case 'confirmed':
      case 'processing':
        return "15-20 men";
      case 'on_delivery':
        return "5-10 men";
      case 'completed':
        return "Telah Tiba";
      default:
        return "--";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_order == null) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.filter_none, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? "Belum ada pesanan aktif.",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.home, (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B3B47),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text("Pesan Sekarang"),
              ),
            ],
          ),
        ),
      );
    }

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
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.black),
          onPressed: _fetchOrderDetails,
        ),
      ],
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
              child:
                  const Icon(Icons.location_pin, color: Colors.red, size: 50),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDriverMarker() {
    final name = _order?.driver?.name ?? "Mencari Driver...";
    final id = _order?.driver != null ? "ID ${_order!.driver!.id}" : "";

    ImageProvider avatarProvider;
    if (_order?.driver?.photoUrl != null) {
      avatarProvider = NetworkImage(_order!.driver!.photoUrl!);
    } else {
      avatarProvider = const AssetImage("assets/images/profile1.jpg");
    }

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: avatarProvider,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(id,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () {
                if (_order != null) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.chatDetail,
                    arguments: {
                      'orderId': _order!.id,
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
          _mapController.move(_driverLocation, _mapController.camera.zoom);
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
        final currentStep = _getCurrentStepIndex();

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Center(
                child: Text(
                  "Status Pengiriman",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              // Estimated Time Chip
              _buildEstimatedTimeChip(_order != null
                  ? _getEstimatedTime(_order!.status)
                  : "Loading..."),
              const SizedBox(height: 10),

              // Refresh Button
              Center(
                child: TextButton.icon(
                  onPressed: _fetchOrderDetails,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text("Refresh Status"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              if (currentStep == -1)
                const Center(
                  child: Text(
                    "Pesanan Dibatalkan",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                )
              else
                ...List.generate(_deliverySteps.length, (index) {
                  return _buildStatusStep(
                    step: _deliverySteps[index],
                    index: index,
                    isLastStep: index == _deliverySteps.length - 1,
                    currentStep: currentStep,
                  );
                }),

              const Divider(height: 24, thickness: 1),

              // Address Widgets
              _buildAddressRow(
                icon: Icons.location_on,
                title:
                    _order?.shippingAddress?['address'] ?? "Alamat Pengiriman",
                subtitle: "Lokasi Anda",
                trailing: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Change",
                    style: TextStyle(
                        color: Color(0xFFE74C3C), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildAddressRow(
                icon: Icons.storefront,
                title: "Biji Coffee Shop",
                subtitle: _order != null
                    ? "Order #${_order!.orderNumber}"
                    : "Processing...",
                trailing: null,
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // Custom Widgets from User's Code
  Widget _buildEstimatedTimeChip(String time) {
    bool hasArrived = time == "Telah Tiba";

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: hasArrived ? Colors.green.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasArrived ? Icons.check_circle_outline : Icons.timer_outlined,
              color:
                  hasArrived ? Colors.green.shade700 : const Color(0xFF4B3B47),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              "Estimasi Tiba: ",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              time,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: hasArrived ? Colors.green.shade800 : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStep({
    required DeliveryStep step,
    required int index,
    required bool isLastStep,
    required int currentStep,
  }) {
    final bool isCompleted = index < currentStep;
    final bool isActive = index == currentStep;

    const Color activeColor = Color(0xFF4B3B47);
    final Color inactiveColor = Colors.grey.shade300;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              isCompleted
                  ? Icons.check_circle
                  : (isActive ? step.activeIcon : step.icon),
              color: isCompleted || isActive ? activeColor : inactiveColor,
              size: isActive ? 24.0 : 22.0,
            ),
            if (!isLastStep)
              Container(
                width: 2,
                height: 40,
                color: inactiveColor,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 2,
                    height: isCompleted ? 40 : 0,
                    color: activeColor,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                  color: isActive ? Colors.black : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                step.subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressRow({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4B3B47), size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }
}
