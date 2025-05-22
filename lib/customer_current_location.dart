import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomerCurrentLocation extends StatefulWidget {
  const CustomerCurrentLocation({super.key});

  @override
  State<CustomerCurrentLocation> createState() =>
      _CustomerCurrentLocationState();
}

class _CustomerCurrentLocationState extends State<CustomerCurrentLocation> {
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> _markers = [];

  // Set a neutral starting point (20.5937, 78.9629) just to render the map
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          initialCameraPosition: _initialCameraPosition,
          markers: Set<Marker>.of(_markers),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final Position position = await getCustomerCurrentLocation();
            final LatLng currentLatLng =
                LatLng(position.latitude, position.longitude);

            setState(() {
              _markers.removeWhere(
                  (marker) => marker.markerId.value == 'current_location');

              _markers.add(Marker(
                markerId: const MarkerId('current_location'),
                position: currentLatLng,
                infoWindow: const InfoWindow(title: 'My current location'),
              ));
            });

            final GoogleMapController controller = await _controller.future;
            controller.animateCamera(
              CameraUpdate.newCameraPosition(CameraPosition(
                target: currentLatLng,
                zoom: 14,
              )),
            );
          } catch (e) {
            print("Error fetching location: $e");
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
