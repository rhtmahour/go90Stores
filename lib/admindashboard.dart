import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go90stores/adminlogin.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void _showLogoutConfirmation(BuildContext context) {
    showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Logout",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Do you want to logout?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                        builder: (context) => const AdminLogin()),
                    (Route<dynamic> route) => false,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error logging out: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => _showLogoutConfirmation(context),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('stores').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading store data.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No stores available.'));
          }

          final storeDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: storeDocs.length,
            itemBuilder: (context, index) {
              final store = storeDocs[index];
              final data = store.data() as Map<String, dynamic>;

              final imageUrl = data['storeImage'];
              final email = data['email'] ?? 'N/A';
              final gstNumber = data['gstNumber'] ?? 'N/A';

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    onTap: () {
                      // Navigate to store details page
                    },
                    contentPadding: const EdgeInsets.all(15),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: imageUrl != null
                          ? NetworkImage(imageUrl)
                          : const AssetImage('assets/placeholder.png')
                              as ImageProvider,
                      onBackgroundImageError: (_, __) {
                        // Fallback to placeholder image
                      },
                      child: imageUrl == null
                          ? const Icon(Icons.store,
                              size: 30, color: Colors.white)
                          : null,
                    ),
                    title: Row(
                      children: [
                        Text(
                          email,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (data['approved'] ==
                            true) // Check if the store is verified
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 18,
                          )
                        else if (data['pending'] == true)
                          const Icon(
                            Icons.pending,
                            color: Colors.red,
                            size: 18,
                          )
                        else
                          const SizedBox.shrink()
                      ],
                    ),
                    subtitle: Text('GST Number: $gstNumber'),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.grey,
                      ),
                      onSelected: (String value) async {
                        if (value == 'Approved') {
                          try {
                            await FirebaseFirestore.instance
                                .collection('stores')
                                .doc(store
                                    .id) // Use the document ID to identify the store
                                .update({
                              'approved': true
                            }); // Update the verified status

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Store marked as Approved."),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error approved store: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } else if (value == 'Pending') {
                          try {
                            await FirebaseFirestore.instance
                                .collection('stores')
                                .doc(store.id)
                                .update({'approved': false, 'pending': true});

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Store marked as Pending."),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text("Error marking store as Pending: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } else if (value == 'Rejected') {
                          try {
                            await FirebaseFirestore.instance
                                .collection('stores')
                                .doc(store
                                    .id) // Use the document ID to identify the store
                                .delete();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Store Rejected successfully."),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error rejected store: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'Approved',
                          child: Text('Approved'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Pending',
                          child: Text('Pending'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Rejected',
                          child: Text('Rejected'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
