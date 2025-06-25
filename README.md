# 🛒 go90stores - Online Grocery Store 

`go90stores` is a multi-store, role-based Flutter grocery application designed to manage B2B and B2C operations for a grocery brand with multiple stores in a city. It supports inventory management, real-time stock updates, price tracking, order notifications, and advanced admin controls.

---

## 📌 Key Features

### 👥 Role-Based Access
- **Admin**
  - Can manage all stores, grant/revoke access, and disable non-compliant stores.
  - Receives alerts for stock imbalances, expiry warnings, and unsold inventory.
- **Store Login**
  - Each store has its own login to update stock, pricing, and manage sales.
  - Can view best price offers across stores.
- **Customer (B2C)**
  - Register and place orders with no minimum quantity.
  - Orders notify stores within 500m radius; only the first store to accept gets the order.

---

## ✅ Functionality Breakdown

### 📦 Inventory and Sales Management
- 1 brand → Multiple stores in a city (e.g., 4 stores).
- Each store updates their:
  - Inventory
  - Stock levels
  - Sale prices
  - Purchase prices

### 🔐 Admin Portal
- Add, modify, and delete store accounts.
- Disable stores that violate compliance rules or protocols.
- Manage permissions and monitor product activity.

### 📝 Store Registration (B2B Onboarding)
- New stores can register via a **B2B form** with:
  - Store details
  - Aadhaar upload
  - GST number
  - Shop license
  - Owner photo (upload or camera capture)

### 📊 Price Intelligence & Reporting
- Stores update buying price per product.
- System auto-generates report for **lowest buying price per product**, including:
  - Store name
  - Product name
  - Quoted price
  - Price difference
  - Contact info

### 🛍 B2B Order Placement
- Stores can compare prices and place bulk orders.
- Products are delivered within **12 hours**.

---

## 🚨 Smart Notifications & Alerts

### 🔄 Low Stock & Expiry Alerts
- **To Store:**
  - Low stock warning
  - Products about to expire
- **To Admin:**
  - Stores with unsold/expiring stock
  - Alerts when another store has low stock of the same product

### 📍 B2C Order Notification (500m Radius Logic)
- Customer places an order.
- All stores within **500 meters** (geolocation-based) receive the order notification.
- First store to accept it, locks the order.
- All other stores are blocked from viewing it (like ride-sharing apps).

---

## 🔑 User Types

| Role     | Capabilities |
|----------|--------------|
| **Admin** | Full access to all stores, users, products, orders |
| **Store** | Manages own products, prices, stock, purchases |
| **Customer** | Registers, browses, and places orders nearby |

---

## 🛠 Tech Stack

- **Flutter** – Cross-platform mobile development
- **Firebase Firestore** – Realtime database and authentication
- **Firebase Storage** – Document & image uploads
- **Geolocator API** – Geo-distance calculation
- **Cloud Functions (optional)** – Background logic and alerts
- **Excel Parser** – For lead import & inventory updates (B2B)

---

## 🚀 Future Enhancements

- Firebase Cloud Messaging (FCM) for real-time notifications.
- Analytics dashboard for sales and pricing insights.
- QR-based store inventory imports.
- Voice assistant for customer ordering.

## 🖼️ App Screenshot

<img src="https://github.com/user-attachments/assets/0538ca3b-fa38-4613-880c-2114328b2742" alt="go90stores Screenshot" width="200"/>
<img src="https://github.com/user-attachments/assets/818ab6f6-3bee-4100-b3f9-e80b27ca9978" alt="go90stores Screenshot" width="200"/>
<img src="https://github.com/user-attachments/assets/fd73bbe7-3255-45bb-b732-4154b03b362e" alt="go90stores Screenshot" width="200"/>
<img src="https://github.com/user-attachments/assets/8ae7e04e-bad5-428f-8063-41604b652cea" alt="go90stores Screenshot" width="200"/>
<img src="https://github.com/user-attachments/assets/66a6afc7-70e9-49f6-a28b-8b3b3701e736" alt="go90stores Screenshot" width="200"/>
<img src="https://github.com/user-attachments/assets/b6da9c5b-4491-483f-842e-6797672080b8" alt="go90stores Screenshot" width="200"/>
<img src="https://github.com/user-attachments/assets/480a98cd-393a-42fd-a315-aedf3d4e223f" alt="go90stores Screenshot" width="200"/>
<img src="https://github.com/user-attachments/assets/8d68258d-47af-4e6f-b183-9716f1bbb157" alt="go90stores Screenshot" width="200"/>




---

## 📂 Folder Structure


```bash
lib/
│
├── screens/
│   ├── admin/
│   ├── store/
│   ├── customer/
│
├── models/
│
├── services/
│   └── firestore_service.dart
│
├── widgets/
│
├── main.dart

