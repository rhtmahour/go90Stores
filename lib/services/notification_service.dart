import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go90stores/auth_service.dart';
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

  // Add this missing method to handle background messages
  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('App opened from background notification: ${message.messageId}');
    await _handleMessage(message);

    // You can add additional navigation logic here based on the message
    // For example, navigate to a specific screen when notification is tapped
    // You'll need access to BuildContext for navigation, which might require
    // passing it from your widget or using a global navigator key
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

    final userRole = await AuthService().getCurrentUserRole();

    // Handle order notifications for stores
    if (message.data['type'] == 'new_order' &&
        userRole == AuthService.storeRole) {
      await _showOrderNotification(
        orderId: message.data['orderId'] ?? 'N/A',
        customerAddress: 'Nearby location', // You can reverse geocode here
        totalAmount:
            double.tryParse(message.data['totalAmount'].toString()) ?? 0.0,
        customerLat: double.tryParse(message.data['customerLat'].toString()),
        customerLng: double.tryParse(message.data['customerLng'].toString()),
      );
    }
    // Handle other notification types
    else {
      await _showGenericNotification(message);
    }
  }

  Future<void> _showOrderNotification({
    required String orderId,
    required String customerAddress,
    required double totalAmount,
    double? customerLat,
    double? customerLng,
  }) async {
    String distanceInfo = '';

    // Only show notification if within 500m
    if (customerLat != null && customerLng != null) {
      final storeLocation = await _getStoreLocation();
      if (storeLocation != null) {
        final distanceInMeters = await Geolocator.distanceBetween(
          storeLocation.latitude,
          storeLocation.longitude,
          customerLat,
          customerLng,
        );

        // Skip notification if beyond 500m
        if (distanceInMeters > 500) return;

        distanceInfo = ' (${distanceInMeters.toStringAsFixed(0)}m away)';
      }
    }

    // Rest of the notification code...
  }

  Future<GeoPoint?> _getStoreLocation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('stores')
        .doc(user.uid)
        .get();

    final location = doc.data()?['location'];
    if (location is GeoPoint) return location;
    return null;
  }
}
