
# 🛒 go90stores - Smart Grocery Management System

**go90stores** is a Flutter-based multi-role grocery platform designed for seamless store and customer management. It offers robust support for B2B store onboarding, inventory management, admin control, and hyperlocal B2C order routing using geolocation.

---

## 🚀 Key Features

### 🏬 Multi-Store Management (Admin Panel)
- One **brand** can manage multiple **stores** (e.g., 4 stores in 1 city).
- Each store operates with its **individual login** to manage:
  - Inventory
  - Stock updates
  - Sales tracking
- **Admin Controls**:
  - Add, update, or remove store accounts.
  - Grant or revoke portal access.
  - Disable stores not complying with terms, rules, or protocols.

---

### 🧾 B2B Store Registration
- New stores can register via a **self-service B2B registration form**.
- Required uploads:
  - Store name and contact details
  - Aadhaar card
  - GST number
  - Shop registration license
  - Owner’s photo (upload or capture using device camera)

---

### 💰 Purchase Price Management & Reporting
- Stores can update **purchase price** per product.
- Automated system report:
  - **Lowest price per product** across all stores.
  - Report includes:
    - Quoted price
    - Store name
    - Product name
    - Price difference from the last lowest rate
    - Store contact number

---

### 🛍️ Internal B2B Ordering
- Stores can see the **best available prices** on the portal.
- Place internal B2B orders with a guaranteed **12-hour delivery** window.

---

### 📦 Stock & Expiry Alerts
- **Low stock alerts** sent directly to the concerned store.
- **Admin receives alerts** for:
  - Unsold stock
  - Near-expiry products
  - Stores running low on about-to-expire products

---

### 🧠 Intelligent Product Expiry Management
- Stores receive notifications for **products nearing expiry**.
- Admin receives alerts for **other stores** that are **low** on the same product — enabling proactive redistribution.

---

### 📍 B2C Geo-Based Order Routing
- B2C customers can:
  - Register with basic information.
  - Browse and place orders (no minimum quantity).
- When an order is placed:
  - Notifications sent to **all nearby stores** (within 500 meters).
  - **First store to accept** gets exclusive access to fulfill the order (similar to cab booking models).
  - All other notifications automatically expire for remaining stores.

---

## 🛠️ Tech Stack

- **Frontend**: Flutter (cross-platform)
- **Backend**: Firebase / Firestore
- **Authentication**: Firebase Auth
- **Realtime Database & Geo Queries**: Firestore + Geohashing
- **File Uploads**: Firebase Storage
- **Location Services**: Geolocator / Google Maps
- **State Management**: Provider / Riverpod (as per app structure)
- **Notifications**: Firebase Cloud Messaging (FCM)

---

## 🧪 Future Enhancements

- Store compliance analytics dashboard
- Advanced filtering in product price comparison reports
- Delivery tracking system for B2C and B2B orders
- Push notification scheduler for expiry reminders

---

## 📷 Screenshots & Demo

> _Coming soon: UI mockups, flow diagrams, and short video demo._

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🤝 Contribution

We welcome contributions! Please raise an issue or fork the repo and submit a PR.

---

## 📫 Contact

For queries or collaborations, contact: **admin@go90stores.com**

