import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class ConvertLatLonToAddress extends StatefulWidget {
  const ConvertLatLonToAddress({Key? key}) : super(key: key);
  @override
  _ConvertLatLonToAddressState createState() => _ConvertLatLonToAddressState();
}

class _ConvertLatLonToAddressState extends State<ConvertLatLonToAddress> {
  String stAddress = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Convert'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Latitude and Longitude: $stAddress',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () async {
              List<Location> locations =
                  await locationFromAddress("Gronausestraat 710, Enschede");

              setState(() {
                stAddress = locations.last.latitude.toString() +
                    "  " +
                    locations.last.longitude.toString();
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text('Convert '),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
