import 'package:chat/services/firebase.dart';
import 'package:chat/services/secure_storage.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class MyContacts {
  //make back ground task work manager
  Future<void> phoneContacts() async {
    print(await SecureStorageService().readSecureData("loaded"));
    if (await FlutterContacts.requestPermission()) {
      print("imeingia");
      List<Contact> contacts = await FlutterContacts.getContacts(
          withProperties: true, withAccounts: true, withPhoto: true);

      List<Contact> newcontats = [];

      List savedContacts =
          await SecureStorageService().readCntactsData("contacts");
      contacts.forEach((element) async {
        String phone = '';
        if (element.phones[0].number.toString().startsWith("0")) {
          phone = element.phones[0].number.toString().replaceFirst("0", "+255");
        } else {
          phone = element.phones[0].number;
        }
        bool contains =
            await SecureStorageService().containsKey(phone.replaceAll(" ", ""));
        if (contains) {
          print("emeenda ety $phone");
          List phoneName = [];
          if (savedContacts.isEmpty) {
            print("it is empty.... contacts......");
            phoneName.add(phone);
            phoneName.add(element.displayName);
            phoneName.add("Hey there im using Tuchati");
          } else {
            print(
                "saved contacts length ${savedContacts.length}...............");
            for (var cont = 0; cont < savedContacts.length; cont++) {
              print(
                  "compare contacts $phone and ${savedContacts[cont][0]}...............");
              if (phone != savedContacts[cont][0]) {
                phoneName.add(phone);
                phoneName.add(element.displayName);
                phoneName.add("Hey there im using Tuchati");
              }
            }
          }
          if (phoneName.isNotEmpty) {
            savedContacts.add(phoneName);
          }
          Contactt contactt = Contactt("contacts", savedContacts);
          await SecureStorageService().writeContactsData(contactt);
        }
      });

      await FirebaseService().storeFirebaseUsersInLocal();
    }
  }
}
