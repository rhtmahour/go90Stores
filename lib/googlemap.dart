import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapScreen extends StatefulWidget {
  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(28.5310729, 77.0857176),
    zoom: 14,
  );
  List<Marker> _markers = [];
  final List<Marker> _list = const [
    Marker(
        markerId: MarkerId('1'),
        position: LatLng(28.5310729, 77.0857176),
        infoWindow: InfoWindow(
          title: 'Go90 mart',
        )),
  ];
  @override
  void initState() {
    super.initState();
    _markers.addAll(_list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          markers: Set<Marker>.of(_markers),
          initialCameraPosition: _kGooglePlex,
          mapType: MapType.normal,
          compassEnabled: true,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.location_disabled_outlined),
        onPressed: () async {
          GoogleMapController controller = await _controller.future;
          controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(39.000000, -80.500000),
              zoom: 14,
            ),
          ));
          setState(() {
            _markers.add(Marker(
                markerId: MarkerId('2'),
                position: LatLng(39.000000, -80.500000),
                infoWindow: InfoWindow(
                  title: 'New Location',
                )));
          });
        },
      ),
    );
  }
}
