import 'package:firebase_messaging/firebase_messaging.dart';

class CloudMessaging {
  getMyToken() async {
    await FirebaseMessaging.instance.getToken().then((value) {
      // ignore: avoid_print
      print(
          "my token for cloud messaging is of..................... is $value");
    });
  }

  requestPermisiion() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
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

  handleForegroundMessages() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }
 handleBackGroundMessages(RemoteMessage message)async{
 
  print("Handling a background message: ${message.messageId}");
 }
}
