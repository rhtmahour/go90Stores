import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go90stores/adminlogin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go90stores/brandpage.dart';
import 'package:go90stores/category.dart';
import 'package:go90stores/customeraddress.dart';
import 'package:go90stores/customernotification.dart';
import 'package:go90stores/customersettings.dart';
import 'package:go90stores/homebottombar.dart';
import 'package:go90stores/orderpage.dart';
import 'package:go90stores/productsearch.dart';
import 'package:go90stores/rateandreview.dart';
import 'package:go90stores/slider1.dart';
import 'package:go90stores/slider2.dart';
import 'package:go90stores/support.dart';
import 'package:image_picker/image_picker.dart';

class Customerdashboard extends StatefulWidget {
  const Customerdashboard({super.key});

  @override
  State<Customerdashboard> createState() => _CustomerdashboardState();
}

class _CustomerdashboardState extends State<Customerdashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  File? pickedImageFile;
  User? user;
  String? name;
  String? phoneNumber;
  bool _isLoggedIn = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Future<void> pickImage() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage == null) return;

      setState(() {
        pickedImageFile = File(pickedImage.path);
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final currentUser = _auth.currentUser;

      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('customers')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null) {
            setState(() {
              user = currentUser;
              name = data['name']?.toString() ?? 'No name available';
              phoneNumber = data['phoneNumber']?.toString() ??
                  'No phone number available';
              _isLoggedIn = true;
            });
          }
        } else {
          print('User document does not exist in Firestore.');
        }
      } else {
        print('User not logged in.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Home",
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
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('userId', isEqualTo: user?.uid)
                .where('isRead', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              int unreadCount = 0;
              if (snapshot.hasData) {
                unreadCount = snapshot.data!.docs.length;
              }
              return IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Customernotification()),
                  );
                },
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications,
                        color: Colors.white, size: 28),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 350,
              width: double.maxFinite,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          // Add edit profile logic here
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 35,
                        backgroundImage: pickedImageFile != null
                            ? FileImage(pickedImageFile!)
                            : null,
                        backgroundColor: Colors.grey[200],
                        child: pickedImageFile == null
                            ? Icon(Icons.camera_alt,
                                size: 40, color: Colors.grey[600])
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isLoggedIn && name != null && name!.isNotEmpty
                          ? name!
                          : 'Name not available',
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    Text(
                      _isLoggedIn &&
                              phoneNumber != null &&
                              phoneNumber!.isNotEmpty
                          ? phoneNumber!
                          : 'Phone not available',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.receipt),
              title: const Text(
                'Orders',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                // Add your onTap logic here
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderPage(),
                    ));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.location_on),
              title: const Text(
                'Address',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerAddressPage(),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.star_border),
              title: const Text(
                'Ratings and Reviews',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Rateandreview(),
                    ));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.support_agent),
              title: const Text(
                'Support',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Support(),
                    ));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: const Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Customersettings(),
                    ));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.notification_add),
              title: const Text(
                'Notifications',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Customernotification(),
                    ));
              },
            ),
            Divider(),
            ListTile(
                title: Text(
              "FAQ's",
              style: TextStyle(fontWeight: FontWeight.w500),
            )),
            ListTile(
              title: const Text(
                'Privacy Policy',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {},
            ),
            ListTile(
              title: const Text(
                'Send feedback',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {},
            ),
            SizedBox(
              height: 50,
            ),
            if (_isLoggedIn)
              PrettyFuzzyButton(
                text: 'Logout',
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  setState(() {
                    _isLoggedIn = false;
                    name = null;
                    phoneNumber = null;
                  });
                },
              )
            else
              PrettyFuzzyButton(
                text: 'Login',
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminLogin()),
                  ).then((_) {
                    _fetchUserData(); // Refresh user data after login
                  });
                },
              )
          ],
        ),
      ),
      body: Center(
        child: Builder(
          builder: (context) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Center(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            filled:
                                true, // Adds background color to the search bar
                            fillColor: Colors
                                .grey[200], // Set a light background color
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 20), // Add some padding
                            labelText: 'Search products by name ...',
                            labelStyle: TextStyle(
                                color: Colors
                                    .grey[700]), // Customize label text color
                            hintText: 'Find the best deals...',
                            hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14), // Set hint text style
                            prefixIcon: Icon(Icons.search,
                                color: Colors
                                    .purple), // Customize the search icon color
                            suffixIcon: IconButton(
                              icon: Icon(Icons.close,
                                  color: Colors
                                      .red), // Add a clear (close) button to reset search
                              onPressed: () {
                                _searchController
                                    .clear(); // Clear the search text
                                FocusScope.of(context)
                                    .unfocus(); // Dismiss the keyboard
                              },
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  20), // Add rounded corners
                              borderSide: BorderSide(
                                  color: Colors.purple,
                                  width: 2), // Border color when not focused
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(25), // Rounded corners
                              borderSide: BorderSide(
                                  color: Colors.blue,
                                  width: 2), // Border color when focused
                            ),
                          ),
                          onSubmitted: (searchQuery) {
                            searchQuery = _searchController.text.trim();
                            if (searchQuery.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductSearchPage(
                                    searchQuery: searchQuery,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const Slider1(),
                  SizedBox(height: 10),
                  const Category(),
                  SizedBox(height: 10),
                  const Slider2(),
                  SizedBox(height: 10),
                  const Brandpage(),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: HomeBottomBar(onAccountTap: _openDrawer),
    );
  }
}

class PrettyFuzzyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PrettyFuzzyButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    MediaQuery.of(context);
    return Container(
      width: 100,
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 28.0),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
