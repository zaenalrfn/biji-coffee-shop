import 'package:flutter/material.dart';
import 'widgets/store_card.dart';
import 'widgets/store_map_view.dart';
import 'widgets/view_toggle.dart';

// Model Store
class StoreModel {
  final String id;
  final String name;
  final String image;
  final String openTime;
  final String closeTime;
  final double distance;
  final double latitude;
  final double longitude;
  final String address;

  StoreModel({
    required this.id,
    required this.name,
    required this.image,
    required this.openTime,
    required this.closeTime,
    required this.distance,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  String get operatingHours => '$openTime - $closeTime';
}

class StoreLocationPage extends StatefulWidget {
  const StoreLocationPage({super.key});

  @override
  State<StoreLocationPage> createState() => _StoreLocationPageState();
}

class _StoreLocationPageState extends State<StoreLocationPage> {
  bool isListView = true;

  final List<StoreModel> stores = [
    StoreModel(
      id: '1',
      name: 'Medan Plaza',
      image: 'assets/images/store.png',
      openTime: '09:00 AM',
      closeTime: '10:00 PM',
      distance: 3.5,
      latitude: -7.2575,
      longitude: 110.4108,
      address: 'Jl. Medan Plaza No. 123',
    ),
    StoreModel(
      id: '2',
      name: 'Center Point',
      image: 'assets/images/store.png',
      openTime: '09:00 AM',
      closeTime: '10:00 PM',
      distance: 7.5,
      latitude: -7.2585,
      longitude: 110.4128,
      address: 'Jl. Center Point No. 456',
    ),
    StoreModel(
      id: '3',
      name: 'Coffe Shope',
      image: 'assets/images/store.png',
      openTime: '09:00 AM',
      closeTime: '10:00 PM',
      distance: 3.5,
      latitude: -7.2595,
      longitude: 110.4088,
      address: 'Jl. Coffee Street No. 789',
    ),
    StoreModel(
      id: '4',
      name: 'Medan Plaza',
      image: 'assets/images/store.png',
      openTime: '09:00 AM',
      closeTime: '10:00 PM',
      distance: 3.5,
      latitude: -7.2565,
      longitude: 110.4148,
      address: 'Jl. Medan Plaza 2 No. 321',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Store Locations',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black, size: 24),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 16, bottom: 20),
            child: ViewToggle(
              isListView: isListView,
              onToggle: (value) {
                setState(() {
                  isListView = value;
                });
              },
            ),
          ),
          Expanded(
            child: isListView
                ? _buildListView()
                : StoreMapView(stores: stores),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: stores.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return StoreCard(store: stores[index]);
      },
    );
  }
}