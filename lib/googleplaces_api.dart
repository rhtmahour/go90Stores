import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:uuid/uuid.dart';

class GooglePlacesApiScreen extends StatefulWidget {
  const GooglePlacesApiScreen({super.key});

  @override
  State<GooglePlacesApiScreen> createState() => _GooglePlacesApiScreenState();
}

class _GooglePlacesApiScreenState extends State<GooglePlacesApiScreen> {
  TextEditingController searchController = TextEditingController();
  var uuid = Uuid();
  String _sessionToken = '122344';

  // Dummy list for demonstration
  List<dynamic> _placesList = [
    {"description": "New York"},
    {"description": "Los Angeles"},
    {"description": "Chicago"},
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchController.addListener(() {
      onChanged();
    });
  }

  void onChanged() {
    if (_sessionToken.isEmpty) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(searchController.text);
  }

  void getSuggestion(String input) async {
    String KPLACES_API = "AIzaSyAKnUPS_kKqrK3w5nENjY40tVtsFu5YMsE";
    // Your logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google search places API"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Column(
          children: [
            TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                labelText: "Search Places with name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _placesList.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    onTap: () async {
                      List<Location> locations = await locationFromAddress(
                          _placesList[index]["description"]);
                      print(locations.last.longitude);
                      print(locations.last.latitude);
                    },
                    title: Text(_placesList[index]["description"]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
