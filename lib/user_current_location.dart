import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserCurrentLocation extends StatefulWidget {
  const UserCurrentLocation({super.key});

  @override
  State<UserCurrentLocation> createState() => _UserCurrentLocationState();
}

class _UserCurrentLocationState extends State<UserCurrentLocation> {
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> _markers = [];
  final Set<Circle> _circles = {};

  // Store markers
  final Marker _store1 = const Marker(
    markerId: MarkerId('store1'),
    position: LatLng(28.528803, 77.082499),
    infoWindow: InfoWindow(title: 'Store 1'),
  );

  final Marker _store2 = const Marker(
    markerId: MarkerId('store2'),
    position: LatLng(28.534157, 77.081340),
    infoWindow: InfoWindow(title: 'Store 2'),
  );
  final Marker _store3 = const Marker(
    markerId: MarkerId('store3'),
    position: LatLng(28.529821, 77.079109),
    infoWindow: InfoWindow(title: 'Store 3'),
  );
  final Marker _store4 = const Marker(
    markerId: MarkerId('store4'),
    position: LatLng(28.533818, 77.086447),
    infoWindow: InfoWindow(title: 'Store 4'),
  );
  final Marker _go90mart = const Marker(
    markerId: MarkerId('go90mart'),
    position: LatLng(28.529831, 77.087220),
    infoWindow: InfoWindow(title: 'Go90Mart'),
  );

  @override
  void initState() {
    super.initState();
    _markers.addAll([_store1, _store2, _store3, _store4, _go90mart]);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(
        _store1.position,
        14,
      ));
    });
  }

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(20.5937, 78.9629),
    zoom: 1,
  );

  Future<Position> getCustomerCurrentLocation() async {
    LocationPermission permission;

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

    return await Geolocator.getCurrentPosition();
  }

  Future<void> updateMapWithNearbyStores() async {
    try {
      final Position position = await getCustomerCurrentLocation();
      final LatLng currentLatLng =
          LatLng(position.latitude, position.longitude);

      final List<Marker> updatedMarkers = [];

      // Add current location marker
      updatedMarkers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: currentLatLng,
          infoWindow: const InfoWindow(title: 'My current location'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );

      // Store markers list
      final List<Marker> allStoreMarkers = [
        _store1,
        _store2,
        _store3,
        _store4,
        _go90mart
      ];

      for (final storeMarker in allStoreMarkers) {
        final double distanceInMeters = Geolocator.distanceBetween(
          currentLatLng.latitude,
          currentLatLng.longitude,
          storeMarker.position.latitude,
          storeMarker.position.longitude,
        );

        // Highlight nearby stores, else add default
        updatedMarkers.add(
          Marker(
            markerId: storeMarker.markerId,
            position: storeMarker.position,
            infoWindow: storeMarker.infoWindow,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              distanceInMeters <= 500
                  ? BitmapDescriptor.hueGreen
                  : BitmapDescriptor.hueRed,
            ),
          ),
        );
      }

      // Draw 500-meter radius circle
      _circles.clear();
      _circles.add(
        Circle(
          circleId: const CircleId("radius_circle"),
          center: currentLatLng,
          radius: 500,
          strokeWidth: 2,
          strokeColor: Colors.blueAccent,
          fillColor: Colors.blueAccent.withOpacity(0.1),
        ),
      );

      setState(() {
        _markers
          ..clear()
          ..addAll(updatedMarkers);
      });

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: currentLatLng, zoom: 15),
      ));
    } catch (e) {
      print("Error fetching location or filtering stores: $e");
    }
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
        onPressed: updateMapWithNearbyStores,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
