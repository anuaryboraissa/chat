// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import 'package:chat/screens/chat_room/chat_room.dart';
import 'package:chat/screens/page/models/task.dart';
import 'package:chat/services/secure_storage.dart';

class CardWidget extends StatelessWidget {
  final List contact;
  final String iam;
  const CardWidget({
    Key? key,
    required this.contact,
    required this.iam,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: const Color(0xff2da9ef),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          10,
        ),
      ),
      child: ListTile(
        onTap: () async {
          print("weit");
          String phone = contact[0].toString().replaceAll(" ", "");
          List<dynamic> user =
              await SecureStorageService().readByKeyData(phone);
          print("complete");
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                ChatRoomPage(user: user, name: contact[1].toString(), iam: iam,),
          ));
          print(user[0]);
        },
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 16,
        ),
        minLeadingWidth: 2,
        leading: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/user_3.jpg"),
                fit: BoxFit.fill),
            shape: BoxShape.circle,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            contact[1].toString(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        subtitle: Text(
          contact[2].toString(),
          style: TextStyle(
            color: Colors.blue.shade700,
            fontSize: 15,
          ),
        ),
        trailing: Text(
          "",
          style: const TextStyle(
            color: Colors.black45,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
