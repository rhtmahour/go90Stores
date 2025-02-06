import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StoreDrawerHeader extends StatefulWidget {
  final String storeId;
  const StoreDrawerHeader({Key? key, required this.storeId}) : super(key: key);

  @override
  _StoreDrawerHeaderState createState() => _StoreDrawerHeaderState();
}

class _StoreDrawerHeaderState extends State<StoreDrawerHeader> {
  String storeName = "Loading...";
  String phone = "Loading...";
  String imageUrl = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStoreData();
  }

  Future<void> _fetchStoreData() async {
    try {
      DocumentSnapshot storeSnapshot = await FirebaseFirestore.instance
          .collection('stores')
          .doc(widget.storeId) // Fetching store by storeId
          .get();

      if (storeSnapshot.exists) {
        var data = storeSnapshot.data() as Map<String, dynamic>;

        if (mounted) {
          setState(() {
            storeName = data['storename'] ?? "Unknown Store";
            phone = data['phone'] ?? "N/A";
            imageUrl = data['imageUrl'] ?? "";
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            storeName = "Store Not Found";
            phone = "N/A";
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          storeName = "Error loading";
          phone = "Error";
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: DrawerHeader(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : const AssetImage("assets/default_store.png")
                      as ImageProvider,
            ),
            const SizedBox(height: 10),
            isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Column(
                    children: [
                      Text(
                        storeName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        phone,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
