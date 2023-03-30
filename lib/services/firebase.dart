import 'dart:convert';

import 'package:chat/services/secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class FirebaseService {
  Future<bool> postUserData(uid, firstname, lastname, phone, context) async {
    try {
      DateTime now = DateTime.now();
      var created = DateFormat("yyyy-MM-dd hh:mm:ss").format(now);
      final firebase =
          FirebaseFirestore.instance.collection("Users").doc("$uid");
      final json = {
        'uid': uid,
        'first_name': firstname,
        "last_name": lastname,
        "phone": phone,
        "created": created,
        "hide": false
      };
      firebase.set(json);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registered successfully!!'),
          duration: Duration(milliseconds: 1500),
          width: 280.0,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration failed'),
          duration: Duration(milliseconds: 1500),
          width: 280.0,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
  }

  Future<bool> sendOTP(String phone, context) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      timeout: Duration(seconds: 20),
      phoneNumber: '$phone',
      verificationCompleted: (PhoneAuthCredential credential) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account is successfully verified'),
            duration: Duration(milliseconds: 1500),
            width: 280.0,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('The provided phone number is not valid. $phone'),
              duration: Duration(milliseconds: 1500),
              width: 280.0,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (e.code == 'too-many-requests') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Too many requests.. Please try again later'),
              duration: Duration(milliseconds: 1500),
              width: 280.0,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('otp send failed.....${e.code}'),
            duration: Duration(milliseconds: 1500),
            width: 280.0,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      codeSent: (String verificationId, int? resendToken) async {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Verification code is successfully sent to $phone....'),
            duration: Duration(milliseconds: 1500),
            width: 280.0,
            behavior: SnackBarBehavior.floating,
          ),
        );
        await SecureStorageService()
            .writeKeyValueData("otp", "$verificationId");
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Server timed out while send sms to $phone...."),
            duration: Duration(milliseconds: 1500),
            width: 280.0,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );

    return true;
  }

  Future storeFirebaseUsersInLocal() async {
    FirebaseFirestore.instance.collection("Users").get().then((value) {
      value.docs.forEach((element) async {
        print(element['phone']);
        List<String> user = [
          element['uid'],
          element['first_name'],
          element['last_name']
        ];
        StorageItem item = StorageItem(element['phone'], user);
        await SecureStorageService().writeSecureData(item);
        print("user saved locally");
      });
    });
  }

  Future sendMessage(List message) async {
    final firebase =
        FirebaseFirestore.instance.collection("Messages").doc("${message[0]}");

    final msg = {
      'msg_id': message[0],
      'msg': message[1],
      "sender": message[2],
      "receiver": message[3],
      "replied": message[4],
      "seen": message[5],
      "date": message[6],
      "time": message[7]
    };
    firebase.set(msg).whenComplete(() async {
      await SecureStorageService().writeKeyValueData("${message[0]}", "1");
      print(
          "completed .................................${msg["msg"]} sent and saved");
    });
  }

  Future sendGrpMessage(List message) async {
    final firebase = FirebaseFirestore.instance
        .collection("GroupMessages")
        .doc("${message[0]}");

    final msg = {
      'msg_id': message[0],
      'msg': message[1],
      "sender": message[2],
      "replied": message[3],
      "created": message[4],
      "grp_id": message[5],
      "sent": message[6],
      "seen": message[7],
    };
    firebase.set(msg).whenComplete(() async {
      await SecureStorageService().writeKeyValueData("${message[0]}", "1");
      print(
          "completed .................................${msg["msg"]} sent and saved");
    });
  }

  Future<bool> checkIfGrpExist(String groupId) async {
    try {
      bool itExists = false;
      FirebaseFirestore.instance.collection("Groups").get().then((value) {
        value.docs.forEach((element) {
          if (element["grp_id"] == groupId) {
            itExists = true;
          }
        });
      });
      return itExists;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkIfMsgExist(String msgId) async {
    try {
      bool itExists = false;
      FirebaseFirestore.instance.collection("Messages").get().then((value) {
        value.docs.forEach((element) {
          if (element["msg_id"] == msgId) {
            itExists = true;
          }
        });
      });
      return itExists;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkIfMsgIdExist(String msgId) async {
    try {
      bool itExists = false;
      FirebaseFirestore.instance
          .collection("GroupMessages")
          .get()
          .then((value) {
        value.docs.forEach((element) {
          if (element["msg_id"] == msgId) {
            itExists = true;
          }
        });
      });
      return itExists;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createGroup(List group) async {
    final firebase =
        FirebaseFirestore.instance.collection("Groups").doc("${group[0]}");

    storage.UploadTask uploadTask;
    storage.Reference ref = storage.FirebaseStorage.instance
        .ref()
        .child("groupIcons")
        .child("/${group[0]}");
    uploadTask = ref.putFile(group[3]);
    await uploadTask.whenComplete(() {
      print("group icon uploaded successfully");
    });
    String iconPath = await ref.getDownloadURL();
    final grp = {
      'grp_id': group[0],
      'name': group[1],
      'created': group[2],
      "decription": group[4],
      "participants": group[5],
      "admins": group[6],
      "icon": iconPath
    };
    firebase.set(grp).whenComplete(() {
      print(
          "completed .................................${grp["name"]} saved to firebase");
    });
    return true;
  }

  Future<bool> updateGroup(String groupId, List group) async {
    final firebase =
        FirebaseFirestore.instance.collection("Groups").doc("$groupId}");
    Map<String, dynamic> participants = {};
    Map<String, dynamic> admins = {};
    for (var partici = 0; partici < group[5].length; partici++) {
      participants["uid$partici"] = group[5][partici][0];
      participants["name$partici"] = group[5][partici][1];
    }
    for (var admin = 0; admin < group[6].length; admin++) {
      admins["uid$admin"] = group[6][admin][0];
      admins["name$admin"] = group[6][admin][1];
    }
    storage.UploadTask uploadTask;
    storage.Reference ref = storage.FirebaseStorage.instance
        .ref()
        .child("groupIcons")
        .child("/${group[0]}");
    uploadTask = ref.putFile(group[3]);
    await uploadTask.whenComplete(() {
      print("group icon uploaded successfully");
    });
    String iconPath = await ref.getDownloadURL();
    final grp = {
      'grp_id': group[0],
      'name': group[1],
      'created': group[2],
      "decription": group[4],
      "participants": participants,
      "admins": admins,
      "icon": iconPath
    };
    firebase.update(grp).whenComplete(() =>
        print("group $groupId changes committed successfully............."));
    return true;
  }

  Future<void> leftGroup(String groupId, String uid) async {
    FirebaseFirestore.instance
        .collection("Lefts")
        .doc("$groupId}")
        .get()
        .then((value) {
      final firebase =
          FirebaseFirestore.instance.collection("Lefts").doc(groupId);

      if (value.exists) {
        print("doc exists going to update it...............");
        List uidd = jsonDecode(value.data()!["uid"]);
        uidd.add(uid);
        final json = {"uid": jsonEncode(uidd)};
        firebase.update(json).whenComplete(
            () => print("left to group $groupId committed..............."));
      } else {
        print("doc doesn't exists going to set it...............");

        List uids = [];
        uids.add(uid);
        final json = {"group_id": groupId, "uid": jsonEncode(uids)};
        firebase.set(json).whenComplete(
            () => print("left to group $groupId committed..............."));
      }
    });
  }

//load group replies
  Future receiveGroupsMsgAndSaveLocal() async {
    print(
        "loading groups replies.............................................");
    List localmsgs = await SecureStorageService().readModalData("grpMessages");
    List<dynamic> logged = await SecureStorageService().readByKeyData("user");
    String senderId = logged[0];
    List mygroups = await SecureStorageService().readModalData("groups");
    if (mygroups.isNotEmpty) {
      for (var grp = 0; grp < mygroups.length; grp++) {
        if (mygroups[grp][4].contains(senderId)) {
          FirebaseFirestore.instance
              .collection("GroupMessages")
              .where("grp_id", isEqualTo: mygroups[grp][0])
              .get()
              .then((value) async {
            value.docs.forEach((element) async {
              //check if group is participant
              List msggg = [
                element["msg_id"],
                element["msg"],
                element["sender"],
                element["replied"],
                element["created"],
                element["grp_id"],
                element["sent"],
                element["seen"],
              ];
              bool tester = false;
              bool isEmty = false;
              if (localmsgs.isEmpty) {
                localmsgs.add(msggg);
                isEmty = true;
              } else {
                for (var msg = 0; msg < localmsgs.length; msg++) {
                  if (localmsgs[msg][0] == element["msg_id"]) {
                    tester = true;
                  }
                }
              }
              if (!isEmty && !tester) {
                localmsgs.add(msggg);
              }
            });
            Modal mysms = Modal("grpMessages", localmsgs);
            await SecureStorageService().writeModalData(mysms);
          });
        }
      }
    }
  }

  Future receiveMsgAndSaveLocal() async {
    print("loading replies.............................................");

    FirebaseFirestore.instance.collection("Messages").get().then((value) async {
      List localmsgs = await SecureStorageService().readAllMsgData("messages");
      List<dynamic> logged = await SecureStorageService().readByKeyData("user");
      String senderId = logged[0];
      value.docs.forEach((element) async {
        if (element["receiver"] == senderId) {
          List msggg = [
            element["msg_id"],
            element["msg"],
            element["sender"],
            element["receiver"],
            element["replied"],
            element["seen"],
            element["date"],
            element["time"]
          ];
          bool tester = false;
          bool changes = false;
          for (var msg = 0; msg < localmsgs.length; msg++) {
            if (element["msg_id"] == localmsgs[msg][0]) {
              tester = true;
            }
          }

          if (!tester) {
            localmsgs.add(msggg);
          }
        }
      });

      Message mysmss = Message("messages", localmsgs);
      await SecureStorageService().writeMsgData(mysmss);
    });
    print(" firebase........ load success.");
  }

  Future groupMsgsDetails() async {
    // await SecureStorageService().deleteByKeySecureData("grpSmsDetails");
    print("hellow group access vpii.....................");
    List mygroups = await SecureStorageService().readModalData("groups");

    List groupMessages =
        await SecureStorageService().readModalData("grpMessages");
    List<dynamic> logged = await SecureStorageService().readByKeyData("user");
    List grpSmsDetails =
        await SecureStorageService().readUsersSentToMe("grpSmsDetails");

    String mimi = logged[0];
    var totalGrpsms = 0;
    for (var grp in mygroups) {
      List group = [];
      var unreaded = 0;
      var lastMsg = "";
      var timeSent = "";
      for (var msg = 0; msg < groupMessages.length; msg++) {
        if (grp[0] == groupMessages[msg][5]) {
          // print("imeingia apaa..........ety");
          List seen = groupMessages[msg][7];
          if (seen.isEmpty && groupMessages[msg][2] != mimi) {
            unreaded = unreaded + 1;
          } else if (seen.isNotEmpty &&
              groupMessages[msg][2] != mimi &&
              !seen.contains(mimi)) {
            unreaded = unreaded + 1;
          }
          lastMsg = groupMessages[msg][1];
          var format = DateFormat("yyyy-MM-dd");
          var now = format.format(DateTime.now());
          timeSent = groupMessages[msg][4].toString().split(" ").removeAt(0);
          if (timeSent == now) {
            timeSent = groupMessages[msg][4].toString().split(" ").removeAt(1);
          }
        }
      }
      group.add(grp[0]);
      group.add(grp[1]);
      group.add(unreaded);
      group.add(lastMsg);
      group.add(timeSent);
      if (unreaded != 0) {
        totalGrpsms = totalGrpsms + 1;
      }

      bool tester2 = false;
      bool isEmptyy = false;
      if (grpSmsDetails.isEmpty) {
        isEmptyy = true;
        grpSmsDetails.add(group);
      } else {
        for (var us = 0; us < grpSmsDetails.length; us++) {
          if (grp[0] == grpSmsDetails[us][0]) {
            tester2 = true;
          }
          if(grp[0] == grpSmsDetails[us][0]){
            if(lastMsg != grpSmsDetails[us][3]){
            grpSmsDetails[us][3] = lastMsg;
            }
             if(unreaded != grpSmsDetails[us][2]){
               grpSmsDetails[us][2] = unreaded;
            }
             if(timeSent != grpSmsDetails[us][4]){
               grpSmsDetails[us][4] = timeSent;
            }
          }
       
        }
      }

      if (!tester2 && !isEmptyy) {
        grpSmsDetails.add(group);
      }
    }
    Box<String> myGrpSms=Hive.box<String>("simples");
    myGrpSms.put("grpMessags", totalGrpsms.toString());
    await SecureStorageService().deleteByKeySecureData("totalGrpSms");
        List newSorted=grpSmsDetails..sort((a,b) {
          if(a[4].toString().length==b[4].toString().length){
            return a[4].toString().compareTo(b[4].toString());
          }
          else{
            return b[4].toString().length.compareTo(a[4].toString().length);
          }
        });
    Modal grpdetails = Modal("grpSmsDetails", newSorted);
    await SecureStorageService().writeModalData(grpdetails);
  }

  Future usersSentMsgsToMe() async {
    FirebaseFirestore.instance.collection("Users").get().then((user) async {
      List<dynamic> logged = await SecureStorageService().readByKeyData("user");
      String senderId = logged[0];

      print("key user sent exists  .........");

      List sentToMe =
          await SecureStorageService().readUsersSentToMe("usersToMe");
      List localmsgs = await SecureStorageService().readAllMsgData("messages");
      int totalMsgs = 0;
      user.docs.forEach((element) {
        if (element["uid"] != senderId) {
          List userrr = [
            element["uid"],
            element["first_name"],
            element["last_name"],
            element["phone"],
            element["created"],
            element["hide"],
          ];

          int numberMsgs = 0;
          String lastMsg = "";
          String timeSent = "";
          String msgId = '';
          for (var msg = 0; msg < localmsgs.length; msg++) {
            if (senderId == localmsgs[msg][3] && localmsgs[msg][5] == "0") {
              numberMsgs = numberMsgs + 1;
            }
            if (localmsgs[msg][2] == senderId) {
              lastMsg = "you: ${localmsgs[msg][1]}";
            } else {
              lastMsg = "${localmsgs[msg][1]}";
            }

            timeSent = localmsgs[msg][7];
          }
          print("users sent to me total em apaaa ${sentToMe[0].length}");
          bool tester2 = false;
          if (numberMsgs != 0) {
            totalMsgs = totalMsgs + 1;
          }

          print("tester is ..........$tester2 user.........${element["uid"]} ");
          userrr.add(numberMsgs);
          userrr.add(lastMsg);
          userrr.add(timeSent);
          for (var us = 0; us < sentToMe.length; us++) {
            print(
                "compare ;;;;;;;;;;;;;;;;;;....... ${element["uid"]}.............${sentToMe[us][0]}");
            if (element["uid"] == sentToMe[us][0]) {
              tester2 = true;
            }
            if (tester2 &&
                (lastMsg != sentToMe[us][7] || numberMsgs != sentToMe[us][6])) {
              print("performing changesss.........");
              sentToMe[us] = userrr;
            }
          }

          if (!tester2) {
            sentToMe.add(userrr);
          }
        }
      }
          //write total messages

          );
      //write toal sms
      await SecureStorageService()
          .writeKeyValueData("totalSms", totalMsgs.toString());
      Userr myuser = Userr("usersToMe", sentToMe);
      await SecureStorageService().writeUserSentToMe(myuser);
    });
  }

  Future updateMsgs(Map<String, dynamic> message) async {
    final firebase = FirebaseFirestore.instance
        .collection("Messages")
        .doc("${message["msg_id"]}");
    firebase.update(message).whenComplete(() {
      print("update commited success..........");
    });
    print("message ...........$message updated.....");
  }

  Future getGroupMembersAndSaveLocal() async {
    print("loading group members and to local....................");
    List myAdmins=[];
    List mymembers = [];
    List groupMemberss =
        await SecureStorageService().readModalData("groupMembers");
         List groupAdminss =
        await SecureStorageService().readModalData("groupAdmins");
    FirebaseFirestore.instance.collection("Groups").get().then((value) {
   
      value.docs.forEach((element) {
         List groupMembers = [];
         List groupAdmins = [];
        List members = element["participants"];
        List admins = element["admins"];
        groupMembers.add(element["grp_id"]);
        groupAdmins.add(element["grp_id"]);

        FirebaseFirestore.instance
            .collection("Users")
            .get()
            .then((value) async {
          value.docs.forEach((element) {
            List member = [];
            List admin = [];
            if (members.contains(element["uid"])) {
              member.add(element["first_name"]);
              member.add(element["last_name"]);
              member.add(element["phone"]);
            }
              if (admins.contains(element["uid"])) {
              admin.add(element["first_name"]);
              admin.add(element["last_name"]);
              admin.add(element["phone"]);
            }
            if (member.isNotEmpty) {
              bool test=false;
              bool emt=false;
              if(mymembers.isEmpty){
                mymembers.add(member);
                emt=true;
              }
              else{
                for(var m=0;m<mymembers.length;m++){
                  if(element["first_name"]==mymembers[m][0]){
                    test=true;
                  }
                }
              }
              if(!test && !emt){
                  mymembers.add(member);
              }
              
            }
                 if (admin.isNotEmpty) {
              bool test=false;
              bool emt=false;
              if(myAdmins.isEmpty){
                myAdmins.add(admin);
                emt=true;
              }
              else{
                for(var m=0;m<myAdmins.length;m++){
                  if(element["first_name"]==myAdmins[m][0]){
                    test=true;
                  }
                }
              }
              if(!test && !emt){
                  myAdmins.add(admin);
              }
              
            }
            
          });
          groupMembers.add(mymembers);
          groupAdmins.add(myAdmins);
          bool isEmptyy = false;
          bool tester = false;
            bool isEmptyy2 = false;
          bool tester2 = false;
          if (groupMemberss.isEmpty) {
            isEmptyy = true;
            groupMemberss.add(groupMembers);
          } else {
            for (var grp = 0; grp < groupMemberss.length; grp++) {
              if (groupMemberss[grp][0] == element["grp_id"]) {
                tester = true;
              }
            }
          }
          if (!tester && !isEmptyy) {
            groupMemberss.add(groupMembers);
          }
            if (groupAdminss.isEmpty) {
            isEmptyy2 = true;
            groupAdminss.add(groupAdmins);
          } else {
            for (var grp = 0; grp < groupAdminss.length; grp++) {
              if (groupAdminss[grp][0] == element["grp_id"]) {
                tester2 = true;
              }
            }
          }
          if (!tester2 && !isEmptyy2) {
            groupAdminss.add(groupAdmins);
          }
          print("group admins $groupAdmins");
          Modal groupMemb = Modal("groupMembers", groupMemberss);
          await SecureStorageService().writeModalData(groupMemb);
           Modal groupAdm = Modal("groupAdmins", groupAdminss);
          await SecureStorageService().writeModalData(groupAdm);
        });
      });
    });
  }
}
