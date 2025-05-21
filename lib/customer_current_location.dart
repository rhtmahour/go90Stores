import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomerCurrentLocation extends StatefulWidget {
  const CustomerCurrentLocation({super.key});

  @override
  State<CustomerCurrentLocation> createState() =>
      _CustomerCurrentLocationState();
}

class _CustomerCurrentLocationState extends State<CustomerCurrentLocation> {
  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(28.5310729, 77.0857176),
    zoom: 14.4746,
  );
  final List<Marker> _markers = const <Marker>[
    Marker(
        markerId: const MarkerId('1'),
        position: const LatLng(28.5310729, 77.0857176),
        infoWindow: InfoWindow(
          title: 'Go90 mart',
        ))
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          initialCameraPosition: _kGooglePlex,
          markers: _markers.toSet(),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.location_on_outlined),
      ),
    );
  }
}
