import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class StoreAddress extends StatefulWidget {
  final String storeId;
  final Function(String address) onLocationSelected;

  const StoreAddress({
    super.key,
    required this.storeId,
    required this.onLocationSelected,
  });

  @override
  State<StoreAddress> createState() => _StoreAddressState();
}

class _StoreAddressState extends State<StoreAddress> {
  String? storeAddress;
  double? latitude;
  double? longitude;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStoreAddress();
  }

  Future<void> fetchStoreAddress() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('stores')
          .doc(widget.storeId)
          .get();

      if (doc.exists) {
        final address = doc['storeAddress'];
        setState(() {
          storeAddress = address;
        });

        widget.onLocationSelected(address);
        await getCoordinatesFromAddress(address);
      } else {
        setState(() {
          storeAddress = 'Store not found';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        storeAddress = 'Error fetching address';
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  Future<void> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        double lat = locations.first.latitude;
        double lng = locations.first.longitude;

        setState(() {
          latitude = lat;
          longitude = lng;
          isLoading = false;
        });

        // Save coordinates back to Firestore
        await FirebaseFirestore.instance
            .collection('stores')
            .doc(widget.storeId)
            .update({
          'latitude': lat,
          'longitude': lng,
        });

        print('Latitude: $lat, Longitude: $lng (saved to Firestore)');
      }
    } catch (e) {
      setState(() {
        latitude = null;
        longitude = null;
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Store Address",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 10,
                  shadowColor: Colors.purpleAccent.withOpacity(0.4),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.white, Color(0xFFE0F7FA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.store_mall_directory,
                            color: Colors.deepPurple, size: 40),
                        const SizedBox(height: 12),
                        const Text(
                          "Store Address",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          storeAddress ?? "No Address Available",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 10),
                        const Text(
                          "Geolocation",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          latitude != null && longitude != null
                              ? "Latitude: $latitude\nLongitude: $longitude"
                              : "Coordinates not available",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
