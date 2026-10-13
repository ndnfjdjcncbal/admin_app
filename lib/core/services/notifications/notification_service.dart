import 'dart:async';
import 'dart:convert';

import 'package:adminapp/core/constants/api_client/link_api.dart';
import 'package:adminapp/core/errors/exceptions.dart';
import 'package:adminapp/core/network/dio_consumer.dart';
import 'package:adminapp/core/routes/app_routes.dart';
import 'package:adminapp/core/services/Mysevice.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const _orderNotificationChannel = AndroidNotificationChannel(
  'order_updates',
  'تحديثات الطلبات',
  description: 'إشعارات تحديث حالة الطلب',
  importance: Importance.max,
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.notification != null) {
    return;
  }

  final notifications = FlutterLocalNotificationsPlugin();
  await _initializeLocalNotifications(notifications);
  await _showOrderNotification(notifications, message);
}

Future<void> _initializeLocalNotifications(
  FlutterLocalNotificationsPlugin notifications, {
  DidReceiveNotificationResponseCallback? onNotificationTap,
}) async {
  await notifications.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
    onDidReceiveNotificationResponse: onNotificationTap,
  );
  await notifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(_orderNotificationChannel);
}

Future<void> _showOrderNotification(
  FlutterLocalNotificationsPlugin notifications,
  RemoteMessage message,
) async {
  final title =
      message.notification?.title ?? message.data['title']?.toString();
  final body = message.notification?.body ?? message.data['body']?.toString();

  if (body == null || body.trim().isEmpty) {
    debugPrint('Notification body is empty');
    return;
  }

  await notifications.show(
    id:
        message.messageId?.hashCode ??
        DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
    title: title,
    body: body,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'order_updates',
        'تحديثات الطلبات',
        channelDescription: 'إشعارات تحديث حالة الطلب',
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.status,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    payload: jsonEncode(message.data),
  );
}

class NotificationService {
  NotificationService(this._myServices, this._apiConsumer);

  late final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final Myservice _myServices;
  final DioConsumer _apiConsumer;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _initializeLocalNotifications(
      _localNotifications,
      onNotificationTap: (_) => _openOrders(),
    );
    final localLaunchDetails = await _localNotifications
        .getNotificationAppLaunchDetails();
    if (localLaunchDetails?.didNotificationLaunchApp ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openOrders());
    }

    _messaging.onTokenRefresh.listen(
      (token) => unawaited(_syncTokenForCurrentUser(token)),
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('FCM token refresh failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      },
    );

    FirebaseMessaging.onMessage.listen(
      (message) =>
          unawaited(_showOrderNotification(_localNotifications, message)),
    );
    FirebaseMessaging.onMessageOpenedApp.listen(_openOrdersForMessage);
    _initialized = true;

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openOrders());
    }
  }

  Future<void> syncTokenForUser(String userId) async {
    try {
      await init();
      final permission = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (permission.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint(
          'Notification permission was denied; FCM token was not synced.',
        );
        return;
      }
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );

      final token = await _messaging.getToken();
      if (token == null) {
        debugPrint(
          'FCM token is not available; token was not sent to the API.',
        );
        return;
      }
      await _saveToken(userId, token);
    } on FirebaseException catch (error, stackTrace) {
      debugPrint(
        'Could not get FCM token (${error.code}): ${error.message ?? error}',
      );
      debugPrintStack(stackTrace: stackTrace);
    } on PlatformException catch (error, stackTrace) {
      debugPrint(
        'Could not get FCM token (${error.code}): ${error.message ?? error}',
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _openOrdersForMessage(RemoteMessage message) {
    _openOrders();
  }

  void _openOrders() {
    final navigator = AppRoutes.navigatorKey.currentState;
    if (navigator == null) {
      debugPrint(
        'Notification navigation skipped because navigator is not ready.',
      );
      return;
    }

    final currentRoute = ModalRoute.of(navigator.context)?.settings.name;

    if (currentRoute != AppRoutes.home) {
      navigator.pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    }
  }

  Future<void> _syncTokenForCurrentUser(String token) async {
    final userId = _myServices.sharedPreferences.getString('user_id');
    if (userId == null || userId.isEmpty) {
      return;
    }

    await _saveToken(userId, token);
  }

  Future<void> _saveToken(String userId, String token) async {
    try {
      final response = await _apiConsumer.post(
        ApiConstants.update_fcm_token,
        data: {'user_id': userId, 'fcm_token': token},
      );
      debugPrint(
        'FCM token saved for user $userId: ${response.data ?? response.statusCode}',
      );
    } on NetworkException catch (error, stackTrace) {
      debugPrint('Network error while saving FCM token: ${error.message}');
      debugPrintStack(stackTrace: stackTrace);
    } on ServerException catch (error, stackTrace) {
      debugPrint('Server rejected FCM token: ${error.message}');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
