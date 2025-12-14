// File: lib/pages/tracker/delivery_tracker_page.dart
// (Versi LENGKAP dengan Tile Provider yang WORK di APK)

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/routes/app_routes.dart';

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

  Timer? _timer;
  bool _isSheetFullScreen = false;

  final LatLng _startPoint = const LatLng(-6.175, 106.828);
  final LatLng _endPoint = const LatLng(-6.200, 106.845);

  late LatLng _driverLocation;

  final int _totalRouteSteps = 30;
  int _currentRouteStep = 0;
  final Duration _timerTick = const Duration(milliseconds: 1500);

  int _currentDeliveryStep = 0;
  String _estimatedTime = "15-18 men";

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

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _sheetController = DraggableScrollableController();

    _driverLocation = _startPoint;
    _estimatedTime = "15-18 men";

    _sheetController.addListener(() {
      final isFull = _sheetController.size > (_maxSheetSize - 0.1);
      if (isFull != _isSheetFullScreen) {
        setState(() {
          _isSheetFullScreen = isFull;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startDeliverySimulation();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _startDeliverySimulation() {
    _timer = Timer.periodic(_timerTick, (timer) {
      if (_currentRouteStep >= _totalRouteSteps) {
        timer.cancel();
        setState(() {
          _driverLocation = _endPoint;
          _currentDeliveryStep = 4;
          _estimatedTime = "Telah Tiba";
        });
        return;
      }

      _currentRouteStep++;
      double progress = _currentRouteStep / _totalRouteSteps;

      double newLat = _startPoint.latitude +
          (_endPoint.latitude - _startPoint.latitude) * progress;
      double newLng = _startPoint.longitude +
          (_endPoint.longitude - _startPoint.longitude) * progress;

      String newEstimatedTime = _estimatedTime;
      int newDeliveryStep = _currentDeliveryStep;

      if (_currentRouteStep == _totalRouteSteps - 1) {
        newEstimatedTime = "< 1 menit";
        newDeliveryStep = 3;
      } else if (_currentRouteStep > 25) {
        newEstimatedTime = "2-3 menit";
        newDeliveryStep = 3;
      } else if (_currentRouteStep > 15) {
        newEstimatedTime = "5-7 menit";
        newDeliveryStep = 3;
      } else if (_currentRouteStep > 8) {
        newEstimatedTime = "10-12 menit";
        newDeliveryStep = 2;
      } else if (_currentRouteStep > 2) {
        newEstimatedTime = "12-15 menit";
        newDeliveryStep = 1;
      }

      if (mounted) {
        setState(() {
          _driverLocation = LatLng(newLat, newLng);
          _estimatedTime = newEstimatedTime;
          _currentDeliveryStep = newDeliveryStep;
        });

        _mapController.move(_driverLocation, _mapController.camera.zoom);
      }
    });
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
          onPressed: () {},
        ),
      ],
    );
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
              width: 250.0,
              height: 70.0,
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
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage("assets/images/profile1.jpg"),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Roy Leebauf",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text("ID 2445556", style: TextStyle(color: Colors.grey)),
              ],
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
                _buildEstimatedTimeChip(_estimatedTime),
                const SizedBox(height: 20),
                ...List.generate(_deliverySteps.length, (index) {
                  return _buildStatusStep(
                    step: _deliverySteps[index],
                    index: index,
                    isLastStep: index == _deliverySteps.length - 1,
                    currentStep: _currentDeliveryStep,
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
