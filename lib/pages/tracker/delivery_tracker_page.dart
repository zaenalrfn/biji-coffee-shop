// File: lib/pages/tracker/delivery_tracker_page.dart
// (Versi LENGKAP dengan Tile Provider yang WORK di APK)

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/order_model.dart';
import '../../data/services/api_service.dart';
import 'dart:async';

// Model Data untuk Status
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

  bool _isSheetFullScreen = false;

  final LatLng _startPoint = const LatLng(-6.175, 106.828); // Monas
  final LatLng _endPoint = const LatLng(-6.200, 106.845); // Menteng
  late LatLng _driverLocation;

  Order? _order;
  Timer? _locationTimer;
  final ApiService _apiService = ApiService();

  // Steps matching backend status
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

  final double _initialSheetSize = 0.25;
  final double _minSheetSize = 0.25;
  final double _maxSheetSize = 0.9;

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;
      debugPrint("📦 Received Arguments: $args (Type: ${args.runtimeType})");

      if (args is Order) {
        _order = args;
        _startTracking();
      } else if (args is Map<String, dynamic>) {
        // Fallback for Map arguments
        try {
          _order = Order.fromJson(args);
          _startTracking();
        } catch (e) {
          debugPrint("❌ Failed to parse Map arguments: $e");
        }
      } else {
        debugPrint("⚠️ Arguments are NOT valid Order object!");
      }

      // Initialize driver location if available
      if (_order?.driver != null) {
        _driverLocation = LatLng(
            _order!.driver!.currentLat != 0
                ? _order!.driver!.currentLat
                : _startPoint.latitude,
            _order!.driver!.currentLng != 0
                ? _order!.driver!.currentLng
                : _startPoint.longitude);
      }
      _isInit = false;
    }
  }

  void _startTracking() {
    debugPrint("🏁 Starting Tracking Logic...");
    // Fetch immediately first!
    _fetchOrderDetails();

    // Then Poll every 5 seconds for Status & Location
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _fetchOrderDetails();

      if (_order?.driverId != null) {
        try {
          final data = await _apiService.getDriverLocation(_order!.driverId!);
          if (mounted) {
            setState(() {
              _driverLocation = LatLng((data['current_lat'] as num).toDouble(),
                  (data['current_lng'] as num).toDouble());
            });
            // Optional: Auto-center on driver
            // _mapController.move(_driverLocation, _mapController.camera.zoom);
          }
        } catch (e) {
          debugPrint("Error fetching driver location: $e");
        }
      }
    });
  }

  Future<void> _fetchOrderDetails() async {
    if (_order == null) return;
    try {
      debugPrint("Fetching order details for ID: ${_order!.id}...");
      final updatedOrder = await _apiService.getOrderById(_order!.id);
      debugPrint("Fetched Order Status: ${updatedOrder.status}");
      debugPrint("Fetched Driver: ${updatedOrder.driver?.name}");

      if (mounted) {
        setState(() {
          _order = updatedOrder;
          // Also update driver start location if just assigned
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
  void initState() {
    super.initState();
    debugPrint("🚀 DeliveryTrackerPage INIT");
    _mapController = MapController();
    _sheetController = DraggableScrollableController();
    // Default location (Monas), will be updated
    _driverLocation = _startPoint;

    _sheetController.addListener(() {
      final isFull = _sheetController.size > (_maxSheetSize - 0.1);
      if (isFull != _isSheetFullScreen) {
        setState(() {
          _isSheetFullScreen = isFull;
        });
      }
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _mapController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  // Map Backend Status to Step Index
  int _getCurrentStepIndex(String status) {
    // Normalize status: lowercase and replace spaces with underscores
    final normalized = status.toLowerCase().replaceAll(' ', '_');

    switch (normalized) {
      case 'pending':
        return 0; // Just created
      case 'confirmed':
        return 1; // Preparing
      case 'processing': // Optional extra status
        return 2; // Driver pickup
      case 'on_delivery':
        return 3; // On the way
      case 'completed':
        return 4; // Arrived
      case 'cancelled':
        return -1;
      default:
        // Handle variations
        if (normalized.contains('delivery')) return 3;
        if (normalized.contains('complete')) return 4;
        return 0;
    }
  }

  String _getEstimatedTime(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return "Disiapkan";
      case 'confirmed':
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
    final double initialSheetHeightInPixels =
        MediaQuery.of(context).size.height * _initialSheetSize;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          _buildMap(),
          _buildMapControls(bottomPadding: initialSheetHeightInPixels + 16),
          _buildDraggableSheet(),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      scrolledUnderElevation: 1,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.home, (route) => false),
      ),
      title: const Text(
        "Tracking",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onPressed: () => _showDebugMenu(context),
        ),
      ],
    );
  }

  void _showDebugMenu(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("🛠️ Simulation Menu",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                if (_order != null) ...[
                  ListTile(
                    leading: const Icon(Icons.person_add),
                    title: const Text("Assign Fake Driver"),
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        // Mock Driver ID 1
                        await _apiService.assignDriver(_order!.id, 1);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Driver Assigned! Refreshing...")));
                        setState(
                            () {}); // Trigger rebuild/fetch if logic implemented
                      } catch (e) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.update),
                    title: const Text("Set Status: On Delivery"),
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        await _apiService.updateOrderStatus(
                            _order!.id, 'on_delivery');
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Status Updated!")));
                      } catch (e) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.check_circle),
                    title: const Text("Set Status: Completed"),
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        await _apiService.updateOrderStatus(
                            _order!.id, 'completed');
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Status Completed!")));
                      } catch (e) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.directions_bike),
                    title: const Text("Teleport Driver (Move)"),
                    subtitle: const Text("Moves driver 500m"),
                    onTap: () async {
                      Navigator.pop(context);
                      if (_order?.driverId != null) {
                        try {
                          // Simple movement simulation
                          final newLat = _driverLocation.latitude + 0.001;
                          final newLng = _driverLocation.longitude + 0.0005;
                          await _apiService.updateDriverLocation(
                              _order!.driverId!, newLat, newLng);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Driver Moved! Wait 10s...")));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")));
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("No Driver Assigned yet!")));
                      }
                    },
                  ),
                ]
              ],
            ),
          );
        });
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _startPoint,
        initialZoom: 14.0,
      ),
      children: [
        // ✅ PERBAIKAN: Gunakan CartoDB yang WORK di APK!
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.example.app',
          maxNativeZoom: 19,
        ),

        // ALTERNATIF lain yang juga WORK:
        // 1. CartoDB Dark Mode
        // TileLayer(
        //   urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
        //   subdomains: const ['a', 'b', 'c', 'd'],
        // ),

        // 2. CartoDB Light (Minimalis)
        // TileLayer(
        //   urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
        //   subdomains: const ['a', 'b', 'c', 'd'],
        // ),

        MarkerLayer(
          markers: [
            Marker(
              width: 260.0, // Slightly wider
              height: 80.0, // Increased height
              point: _driverLocation,
              child: _buildDriverMarker(context),
            ),
            Marker(
              width: 50.0,
              height: 50.0,
              point: _endPoint,
              child:
                  const Icon(Icons.location_pin, color: Colors.red, size: 50),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDriverMarker(BuildContext context) {
    // Default data
    String name = "Mencari Driver...";
    String id = "";
    ImageProvider avatar = const AssetImage("assets/images/profile1.jpg");

    if (_order?.driver != null) {
      name = _order!.driver!.name;
      id = "ID ${_order!.driver!.id}";
      if (_order!.driver!.photoUrl != null) {
        avatar = NetworkImage(_order!.driver!.photoUrl!);
      }
    } else if (_order?.driverId != null) {
      // Fallback if ID exists but full object missing
      name = "Driver #${_order!.driverId}";
      id = "Info sedang dimuat...";
    }

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: avatar,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // Fix vertical overflow
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1, // Fix horizontal overflow
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    id,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.chatDetail,
                  arguments: {
                    'name': 'Roy Leebauf',
                    'avatar': 'assets/images/profile1.jpg',
                    'id': 'ID 2445556',
                  },
                );
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
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
                ]),
            child: Column(
              children: [
                IconButton(
                  onPressed: () {
                    double currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                        _mapController.camera.center, currentZoom + 1);
                  },
                  icon: const Icon(Icons.add, color: Colors.black54),
                ),
                Container(
                  width: 30,
                  height: 1,
                  color: Colors.grey.shade300,
                ),
                IconButton(
                  onPressed: () {
                    double currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                        _mapController.camera.center, currentZoom - 1);
                  },
                  icon: const Icon(Icons.remove, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              _mapController.move(_driverLocation, _mapController.camera.zoom);
            },
            backgroundColor: Colors.white,
            elevation: 4,
            child: const Icon(Icons.my_location, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableSheet() {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: _initialSheetSize,
      minChildSize: _minSheetSize,
      maxChildSize: _maxSheetSize,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            ),
            child: ListView(
              controller: scrollController,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: _isSheetFullScreen ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context, AppRoutes.home, (route) => false);
                          },
                          child: const Text("Back directly to Home"),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    "Status Pengiriman",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Use dynamic data
                _buildEstimatedTimeChip(_order != null
                    ? _getEstimatedTime(_order!.status)
                    : "Loading..."),
                const SizedBox(height: 10),
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
                ...List.generate(_deliverySteps.length, (index) {
                  return _buildStatusStep(
                    step: _deliverySteps[index],
                    index: index,
                    isLastStep: index == _deliverySteps.length - 1,
                    currentStep: _order != null
                        ? _getCurrentStepIndex(_order!.status)
                        : 0,
                  );
                }),
                const Divider(height: 24, thickness: 1),
                _buildAddressRow(
                  icon: Icons.location_on,
                  title: "Sweet Corner St.",
                  subtitle: "Franklin Avenue 2253",
                  trailing: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Change",
                      style: TextStyle(
                          color: Color(0xFFE74C3C),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildAddressRow(
                  icon: Icons.storefront,
                  title: "Biji Coffee Shop",
                  subtitle: "Sent at 08:23 AM",
                  trailing: null,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: Text(
                time,
                key: ValueKey<String>(time),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: hasArrived ? Colors.green.shade800 : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildStatusStep({
    required DeliveryStep step,
    required int index,
    required bool isLastStep,
    required int currentStep,
  }) {
    final bool isCompleted = index < currentStep;
    final bool isActive = index == currentStep;

    final Color activeColor = const Color(0xFF4B3B47);
    final Color inactiveColor = Colors.grey.shade300;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Icon(
                key: ValueKey<int>(isCompleted ? 0 : (isActive ? 1 : 2)),
                isCompleted
                    ? Icons.check_circle
                    : (isActive ? step.activeIcon : step.icon),
                color: isCompleted || isActive ? activeColor : inactiveColor,
                size: isActive ? 24.0 : 22.0,
              ),
            ),
            if (!isLastStep)
              Container(
                width: 2,
                height: 30,
                color: inactiveColor,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 2,
                    height: isCompleted ? 30 : 0,
                    color: activeColor,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 0.0, bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? Colors.black : Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  step.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
