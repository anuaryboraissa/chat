// import 'package:device_preview/device_preview.dart';
import 'dart:async';
import 'dart:io';

import 'package:chat/constants/app_colors.dart';
import 'package:chat/screens/Registration/phone.dart';
import 'package:chat/screens/Registration/profile.dart';
import 'package:chat/screens/main_tab_bar/main_tab_bar.dart';
import 'package:chat/services/cloud_messaging.dart';
import 'package:chat/services/contacts.dart';
import 'package:chat/services/firebase.dart';
import 'package:chat/services/groups.dart';
import 'package:chat/services/notification.dart';
import 'package:chat/services/secure_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
//for test different screen size
// void main() => runApp(
//       DevicePreview(
//         enabled: true,
//         builder: (context) => const MyApp(), // Wrap your app
//       ),
//     );

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
   CloudMessaging().requestPermisiion();
   //handle background message
   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
   //local notify setup
   await NotificationService().setup();
  CloudMessaging().getMyToken();
  Directory document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  await Hive.openBox<Uint8List>("groups");
  await Hive.openBox<String>("simples");
  bool userr = await SecureStorageService().containsKey("user");
  print(userr);
  //load every time on netwok connected
  loadSms();
//end load
  runApp(MyApp(
    user: userr,
  ));
}
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  CloudMessaging().handleBackGroundMessages(message);
}
  loadContacts() async {
    await MyContacts().phoneContacts();
  }

void loadSms() async {
  Timer timer = Timer(
    const Duration(seconds: 10),
    () {
      loadSmsUsers();
    },
  );
}

loadIndividualGrpMessags() async {
  Timer timer = Timer(const Duration(seconds: 10), () async {
    await FirebaseService().receiveGroupsMsgAndSaveLocal();
  });
}

loadSmsUsers() async {
  loadContacts();
  await GroupService().filterMyGroups();
  loadIndividualGrpMessags();
  await FirebaseService().getGroupMembersAndSaveLocal();
  await FirebaseService().groupMsgsDetails();
  backgroungMsgs();
}

backgroungMsgs() {
  Timer timer = Timer(
    const Duration(seconds: 10),
    () async {
      await FirebaseService().receiveMsgAndSaveLocal();
      await FirebaseService().usersSentMsgsToMe();
      
    },
  );
}

class MyApp extends StatefulWidget {
// ...

  const MyApp({super.key, required this.user});
  final bool user;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    GetMaterialApp getXApp = GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(primaryColor: AppColors.appColor),
      home: !widget.user ? Phone() : MainTabBar(),
    );

    return getXApp;
  }
}
