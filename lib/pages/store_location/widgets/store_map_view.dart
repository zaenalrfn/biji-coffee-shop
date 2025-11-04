import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../store_location_page.dart';

class StoreMapView extends StatefulWidget {
  final List<StoreModel> stores;

  const StoreMapView({
    super.key,
    required this.stores,
  });

  @override
  State<StoreMapView> createState() => _StoreMapViewState();
}

class _StoreMapViewState extends State<StoreMapView> {
  final MapController _mapController = MapController();
  int _selectedStoreIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.52,
      initialPage: 0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(
              widget.stores[0].latitude,
              widget.stores[0].longitude,
            ),
            initialZoom: 13.0,
            minZoom: 3.0,
            maxZoom: 18.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: _buildMarkers(),
            ),
          ],
        ),
        // Store Cards at Bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SizedBox(
            height: 260,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedStoreIndex = index;
                });
                _mapController.move(
                  LatLng(
                    widget.stores[index].latitude,
                    widget.stores[index].longitude,
                  ),
                  14.0,
                );
              },
              itemCount: widget.stores.length,
              itemBuilder: (context, index) {
                final store = widget.stores[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: _MapStoreCard(
                    store: store,
                    outletNumber: index + 1,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    return widget.stores.asMap().entries.map((entry) {
      final index = entry.key;
      final store = entry.value;
      final isSelected = _selectedStoreIndex == index;

      return Marker(
        width: 44,
        height: 44,
        point: LatLng(store.latitude, store.longitude),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedStoreIndex = index;
            });
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            _mapController.move(
              LatLng(store.latitude, store.longitude),
              14.0,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected 
                  ? const Color(0xFF6F4E37)
                  : const Color(0xFF9B7E6B),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.store_rounded,
              color: Colors.white,
              size: isSelected ? 24 : 20,
            ),
          ),
        ),
      );
    }).toList();
  }
}

class _MapStoreCard extends StatelessWidget {
  final StoreModel store;
  final int outletNumber;

  const _MapStoreCard({
    required this.store,
    required this.outletNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Badge
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.asset(
                    store.image,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFF5F5F5),
                        child: const Icon(
                          Icons.store,
                          size: 40,
                          color: Color(0xFFD9D9D9),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD2691E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Outlet ${outletNumber.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Store Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store Name
                  Text(
                    store.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Operating Hours
                  Text(
                    store.operatingHours,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B6B6B),
                    ),
                  ),
                  const Spacer(),
                  // Distance and Avatars
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Color(0xFF6B6B6B),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${store.distance} Km',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B6B6B),
                        ),
                      ),
                      const Spacer(),
                      _buildStaffAvatars(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffAvatars() {
    return SizedBox(
      width: 52,
      height: 24,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: _buildAvatar(const Color(0xFFB39DDB)),
          ),
          Positioned(
            left: 14,
            child: _buildAvatar(const Color(0xFFBCAAA4)),
          ),
          Positioned(
            left: 28,
            child: _buildAvatar(const Color(0xFFFFAB91)),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
    );
  }
}