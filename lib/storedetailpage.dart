import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void showStoreDetailsDialog(BuildContext context, String storeId) async {
  showDialog(
    context: context,
    builder: (context) {
      return FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('stores').doc(storeId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return AlertDialog(
              title: const Text("Store Details"),
              content: const Text("Store not found."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            );
          }

          final storeData = snapshot.data!.data() as Map<String, dynamic>;
          final String storename = storeData['storename'] ?? 'N/A';
          final String email = storeData['email'] ?? 'N/A';
          final String phone = storeData['phone'] ?? 'N/A';
          final String address = storeData['address'] ?? 'N/A';
          final String gstNumber = storeData['gstNumber'] ?? 'N/A';
          final String status = storeData['status'] ?? 'N/A';
          final String imageUrl = storeData['storeImage'] ?? '';

          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              width:
                  MediaQuery.of(context).size.width * 0.9, // Responsive width
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Store Name & Gradient Background
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.blueAccent, Colors.purpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        storename,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Store Image (if available)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.store,
                                size: 100,
                                color: Colors.green,
                              ),
                            )
                          : const Icon(
                              Icons.storefront,
                              size: 80,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Store Details with Icons
                  _buildDetailRow(Icons.email, "Email:", email),
                  _buildDetailRow(Icons.phone, "Phone:", phone),
                  _buildDetailRow(Icons.location_on, "Address:", address),
                  _buildDetailRow(
                      Icons.confirmation_number, "GST Number:", gstNumber),

                  // Status Badge
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.info, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text("Status:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      _buildStatusBadge(status),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Close Button
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        "Close",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// Widget to Build Each Detail Row with an Icon
Widget _buildDetailRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 20),
        const SizedBox(width: 8),
        Text(
          "$label ",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                color: Colors.purple, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

// Status Badge with Colors
Widget _buildStatusBadge(String status) {
  Color badgeColor;
  switch (status.toLowerCase()) {
    case "approved":
      badgeColor = Colors.blueAccent;
      break;
    case "pending":
      badgeColor = Colors.orange;
      break;
    case "rejected":
      badgeColor = Colors.red;
      break;
    default:
      badgeColor = Colors.grey;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: badgeColor.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: badgeColor),
    ),
    child: Text(
      status.toUpperCase(),
      style: TextStyle(fontWeight: FontWeight.bold, color: badgeColor),
    ),
  );
}
