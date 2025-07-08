import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserCurrentLocation extends StatefulWidget {
  const UserCurrentLocation({Key? key}) : super(key: key);

  @override
  State<UserCurrentLocation> createState() => _UserCurrentLocationState();
}

class _UserCurrentLocationState extends State<UserCurrentLocation> {
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> _markers = [];
  LatLng? _userLatLng;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = "Location permissions are denied";
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = "Location permissions are permanently denied";
          _isLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _userLatLng = LatLng(position.latitude, position.longitude);
      });

      await getAllStoreMarkers();

      if (_controller.isCompleted) {
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newLatLngZoom(_userLatLng!, 15));
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error getting location: ${e.toString()}";
        _isLoading = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> getAllStoreMarkers() async {
    if (_userLatLng == null) return;

    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('stores').get();
      final List<Marker> storeMarkers = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final dynamic latitude = data['latitude'];
        final dynamic longitude = data['longitude'];
        final dynamic storename = data['storename'];

        // Skip if any required field is null or not the correct type
        if (latitude == null ||
            longitude == null ||
            storename == null ||
            latitude is! num ||
            longitude is! num) {
          continue;
        }

        final double lat = latitude.toDouble();
        final double lng = longitude.toDouble();

        final double distanceInMeters = Geolocator.distanceBetween(
          _userLatLng!.latitude,
          _userLatLng!.longitude,
          lat,
          lng,
        );

        final hue = distanceInMeters <= 500
            ? BitmapDescriptor.hueAzure
            : BitmapDescriptor.hueOrange;

        storeMarkers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
                title: "$storename (${distanceInMeters.toStringAsFixed(0)}m)"),
            icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          ),
        );
      }

      setState(() {
        _markers.clear();
        _markers.addAll(storeMarkers);
        if (_userLatLng != null) {
          _markers.add(
            Marker(
              markerId: const MarkerId("user_location"),
              position: _userLatLng!,
              infoWindow: const InfoWindow(title: "My Location"),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
            ),
          );
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error loading stores: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Nearby Stores on Map",
          style: TextStyle(color: Colors.white),
        ),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _userLatLng == null
                  ? const Center(child: Text("Unable to determine location"))
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _userLatLng!,
                        zoom: 15,
                      ),
                      markers: Set<Marker>.of(_markers),
                      circles: {
                        Circle(
                          circleId: const CircleId("user_radius"),
                          center: _userLatLng!,
                          radius: 500,
                          fillColor: Colors.blue.withOpacity(0.1),
                          strokeColor: Colors.blue,
                          strokeWidth: 2,
                        ),
                      },
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                    ),
    );
  }
}
