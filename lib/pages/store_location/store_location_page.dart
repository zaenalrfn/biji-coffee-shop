import 'package:flutter/material.dart';
import 'widgets/store_card.dart';
import 'widgets/store_map_view.dart';
import 'widgets/view_toggle.dart';

import 'package:provider/provider.dart';
import '../../data/models/store_model.dart';
import '../../providers/store_provider.dart';

class StoreLocationPage extends StatefulWidget {
  const StoreLocationPage({super.key});

  @override
  State<StoreLocationPage> createState() => _StoreLocationPageState();
}

class _StoreLocationPageState extends State<StoreLocationPage> {
  bool isListView = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => Provider.of<StoreProvider>(context, listen: false).fetchStores());
  }

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
      body: Consumer<StoreProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.stores.isEmpty) {
            return const Center(child: Text('No store locations found'));
          }

          return Column(
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
                    ? _buildListView(provider.stores)
                    : StoreMapView(stores: provider.stores),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListView(List<StoreModel> stores) {
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
