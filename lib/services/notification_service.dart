import 'package:cloud_firestore_platform_interface/src/geo_point.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  // Singleton instance
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  // Firebase and notifications instances
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationsInitialized = false;

  // Static background message handler
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    await instance._handleMessage(message);
    print('Handling a background message ${message.messageId}');
  }

  // Initialize all notification services
  Future<void> initialize() async {
    await _requestPermission();
    await _setupFlutterNotifications();
    await _setupMessageHandlers();
    await _saveFCMToken();
  }

  // Request notification permissions
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  // Setup local notifications
  Future<void> _setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationsInitialized) return;

    // Android channel for order notifications
    const androidChannel = AndroidNotificationChannel(
      'order_channel', // Changed from 'order_channel' to fix typo
      'Order Notifications',
      description: 'Notifications for new orders',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    // Create the Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Initialization settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        print('Notification Tapped: ${details.payload}');
        // Handle notification tapped logic here
      },
    );

    _isFlutterLocalNotificationsInitialized = true;
  }

  // Setup all message handlers
  Future<void> _setupMessageHandlers() async {
    // Background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      _handleMessage(message);
    });

    // When app is opened from background state
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // When app is opened from terminated state
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  // Show generic notification
  Future<void> _showGenericNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'order_channel',
          'Order Notifications',
          channelDescription: 'Notifications for new orders',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data.toString(),
    );
  }

  // Show order-specific notification
  Future<void> _showOrderNotification({
    required String orderId,
    required String customerAddress,
    required double totalAmount,
  }) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'order_channel',
      'Order Notifications',
      channelDescription: 'Notifications for new orders',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      enableVibration: true,
    );

    const iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      orderId.hashCode,
      'New Order #$orderId',
      'Amount: \$${totalAmount.toStringAsFixed(2)} - $customerAddress',
      platformChannelSpecifics,
      payload: 'order_$orderId',
    );
  }

  // Save FCM token and store location to server
  Future<void> _saveFCMToken() async {
    try {
      String? token = await _messaging.getToken();
      if (token == null) {
        print('Failed to get FCM token');
        return;
      }

      print('FCM Token: $token');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      await _sendTokenToServer(token);
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  // Send token and location to server
  Future<void> _sendTokenToServer(String token) async {
    try {
      // Check location permission first
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Create GeoFirePoint for the store
      final storeLocation = GeoFirePoint(
        GeoPoint(position.latitude, position.longitude),
      );

      // Send to your server
      final response = await http.post(
        Uri.parse('https://your-api.com/api/stores/register'),
        body: json.encode({
          'fcm_token': token,
          'location': {
            'geopoint': storeLocation.data,
            'latitude': position.latitude,
            'longitude': position.longitude,
          }
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Token and location sent successfully');
      } else {
        print('Failed to send token and location: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending token to server: $e');
    }
  }

// In NotificationService.dart, update _handleMessage:
  Future<void> _handleMessage(RemoteMessage message) async {
    print('Handling message: ${message.data}');

    // Handle order notifications
    if (message.data['type'] == 'new_order') {
      final orderId = message.data['order_id'] ?? 'N/A';
      final customerAddress =
          message.data['customer_address'] ?? 'Unknown address';
      final totalAmount =
          double.tryParse(message.data['total_amount'].toString()) ?? 0.0;

      await _showOrderNotification(
        orderId: orderId,
        customerAddress: customerAddress,
        totalAmount: totalAmount,
      );
    }
    // Handle low stock notifications
    else if (message.data['type'] == 'low_stock') {
      // This will be handled by the realtime database listener in MyStore
    }
    // Generic notifications
    else {
      await _showGenericNotification(message);
    }
  }

  // Handle notification when app is opened from a notification
  void _handleBackgroundMessage(RemoteMessage message) {
    print('App opened from notification: ${message.messageId}');
    // You can add navigation logic here based on the message
    _handleMessage(message);
  }

  // Send order to nearby stores (500m radius)
  Future<void> sendOrderToNearbyStores({
    required String orderId,
    required double customerLat,
    required double customerLng,
    required String address,
    required double amount,
  }) async {
    try {
      final center = GeoFirePoint(
        GeoPoint(customerLat, customerLng),
      );

      final response = await http.post(
        Uri.parse('https://your-api.com/api/orders/notify'),
        body: json.encode({
          'order_id': orderId,
          'center': center.data,
          'radius': 0.5, // 500m radius
          'address': address,
          'amount': amount,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Order notification sent to nearby stores');
      } else {
        print('Failed to notify stores: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending order to nearby stores: $e');
    }
  }
}
