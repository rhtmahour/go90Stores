import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class StoreCurrentLocation extends StatefulWidget {
  final String storeId;
  final Function(String address) onLocationSelected;

  const StoreCurrentLocation({
    super.key,
    required this.storeId,
    required this.onLocationSelected,
  });

  @override
  State<StoreCurrentLocation> createState() => _StoreCurrentLocationState();
}

class _StoreCurrentLocationState extends State<StoreCurrentLocation> {
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> _markers = [];
  final Set<Circle> _circles = {};

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(20.5937, 78.9629), // India center
    zoom: 4,
  );

  Future<void> updateMapWithCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    // Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied");
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition();

    // Move camera to current location
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 16,
        ),
      ),
    );

    // Add a marker at current location
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId("storeLocation"),
          position: LatLng(28.528803, 77.082499),
          infoWindow: const InfoWindow(title: "Store Location"),
        ),
      );
    });

    // Optional: callback with lat/long string
    widget.onLocationSelected("${28.528803}, ${77.082499}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          initialCameraPosition: _initialCameraPosition,
          markers: Set<Marker>.of(_markers),
          circles: _circles,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          myLocationEnabled: true,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: updateMapWithCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
