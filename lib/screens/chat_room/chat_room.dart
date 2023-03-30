// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import 'package:chat/screens/Animation/FadeAnimation.dart';
import 'package:chat/screens/chat_room/received_message.dart';
import 'package:chat/screens/chat_room/sent_message.dart';
import 'package:chat/services/fileshare.dart';
import 'package:chat/services/firebase.dart';
import 'package:chat/services/groups.dart';
import 'package:chat/services/secure_storage.dart';
import 'package:chat/utils.dart';
import 'package:chat/widgets/spacer/spacer_custom.dart';
// / import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:swipe_to/swipe_to.dart';

import '../../../constants/app_colors.dart';
import '../../../device_utils.dart';

// class ChatMessage {
//   String messageContent;
//   String messageType;
//   ChatMessage({required this.messageContent, required this.messageType});
// }

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({
    Key? key,
    required this.user,
    required this.name,
    required this.iam,
  }) : super(key: key);
  final List<dynamic> user;
  final String name;
  final String iam;
  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController message = TextEditingController();
  late Timer timer;
  String sender = '';
  String receiver = '';
  bool sent = false;
  Future<List>? data;
  List groupMemb = [];
  List groupAdm= [];
  loadGrpMsgs() {
    timer = Timer(const Duration(seconds: 5), () async {
      await FirebaseService().receiveGroupsMsgAndSaveLocal();

      await FirebaseService().groupMsgsDetails();
    });
  }


  loadUsersMsgs() {
    timer = Timer(const Duration(seconds: 5), () async {
      await FirebaseService().receiveMsgAndSaveLocal();
      await FirebaseService().usersSentMsgsToMe();
    });
  }

  loadGroupDetails()async{
      groupMemb = await GroupService().getGroupparticipants(widget.user[0]);
      groupAdm = await GroupService().getGroupAdmins(widget.user[0]);
  }
 String senderName='';
  void loadSms() async {
    List<dynamic> logged = await SecureStorageService().readByKeyData("user");
    setState(() {
      sender = logged[0];
      senderName=logged[1];
      receiver = widget.user[0];
    });
    if (widget.user[0].length <= 9) {
   loadGroupDetails();
    
    }

    timer = Timer(
      const Duration(seconds: 5),
      ()  {
        // loadSmsUsers();

        setState(() {
          if (widget.user[0].toString().length <= 9) {
            data = SecureStorageService()
                .readGrpMsgData("grpMessages", widget.user[0]);
          } else {
            data = SecureStorageService()
                .readMsgData("messages", sender, receiver);
          }
        });
    
      },
    );

  }

  bool isTyping = false;
  var heightt = 50;
  bool isReplaying = false;
  var padd = 0;
  bool shoemoji = false;
  final focusNode = FocusNode();
  late ScrollController _scrollcontroller;
  @override
  void dispose() {
    super.dispose();
    _scrollcontroller.dispose();
  }

  String reply_to_msg = "";
  String replied_msg = "";
  bool isAdmnin=false;
    late  Box<Uint8List> groupsIcon;
  @override
  void initState() {
     groupsIcon=Hive.box<Uint8List>("groups");
    loadSms();

    super.initState();
    _scrollcontroller = ScrollController();
  }

  void bottomScroll() {
    final bottomoffset = _scrollcontroller.position.maxScrollExtent;
    _scrollcontroller.animateTo(bottomoffset,
        duration: const Duration(microseconds: 1000), curve: Curves.easeInOut);
  }

  var camera_image;
  Future getCameraImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxWidth: double.infinity);
    setState(() {
      camera_image = File(photo!.path);
    });
  }

  bool imeingia = false;
  @override
  Widget build(BuildContext context) {
    if (!imeingia) {
      loadGroupDetails();
      setState(() {
        if (widget.user[0].length <= 9) {
          data = SecureStorageService()
              .readGrpMsgData("grpMessages", widget.user[0]);
        } else {
          data = SecureStorageService()
              .readMsgData("messages", widget.iam, widget.user[0]);
        }
        imeingia = true;
      });
    }
    
    for(var x in groupAdm){
      if(x[0]==senderName){
        setState(() {
          print("yeah is admin hereeeeeeeeeeeeeeeee.........");
          isAdmnin=true;
        });
      }
    }
   
    List<String> menuitems =widget.user[0].length <= 9?["clear","refresh",isAdmnin?"edit":"exit","achieve","details"]: ["achieve","clear"];

    return WillPopScope(
      onWillPop: () async {
        setState(() {
          focusNode.canRequestFocus = false;
        });
        return true;
      },
      child: Scaffold(
        body: Container(
          height: DeviceUtils.getScaledHeight(context, 1),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.backChatGroundColor,
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  Positioned(
                    child: Container(
                      padding: const EdgeInsets.only(top: 38),
                      color: AppColors.appColor,
                      height: 100,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: Row(children: [
                                IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(
                                        Icons.arrow_back_ios_new_outlined,
                                        color: Colors.white)),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration:  BoxDecoration(
                                      image: DecorationImage(
                                          image: widget.user[0].length <= 9?MemoryImage(
                                              groupsIcon.get("${widget.user[0]}")==null?groupsIcon.get("groupDefault")!:groupsIcon.get("${widget.user[0]}")!)
                                              
                                              :MemoryImage(
                                              groupsIcon.get("userDefault")!),
                                          fit: BoxFit.fill),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                         width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.58,
                                                height: 18,
                                        child: Text(
                                          widget.user[0].length <= 9?"${widget.user[1]} ":"${widget.user[1]} ${widget.user[2]}",
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 16, color: Colors.white),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8.0, left: 8),
                                        child: widget.user[0].length <= 9
                                            ? SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.58,
                                                height: 18,
                                                child: Expanded(
                                                    child: ListView.builder(
                                                  itemCount: groupMemb.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    List member =
                                                        groupMemb[index];
                                                    return Text(
                                                      senderName==member[0]?"you,":
                                                        "${member[0]} ${member[1]},",style: const TextStyle(color: Colors.white,fontSize: 12),);
                                                  },
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                )),
                                              )
                                            :  SizedBox(
                                              height: 15,
                                              width: MediaQuery.of(context).size .width *0.58,
                                              child:  const Text(
                                                  "Last seen 08:00 AM",
                                                   overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white),
                                                ),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ])),
                          PopupMenuButton(
                            icon: const Icon(Icons.more_vert_rounded,
                                color: Colors.white),
                            onSelected: (value) {
                             switch(value){
                                
                             }
                            },
                            itemBuilder: (context) => menuitems
                                .map((e) =>
                                    PopupMenuItem(value: e, child: Text(e)))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  height: DeviceUtils.getScaledHeight(context, 0.87),
                  width: DeviceUtils.getScaledWidth(context, 1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: padd.toDouble()),
                          child: FutureBuilder(
                            future: data,
                            builder: (context, snapshot) {
                              // bottomScroll();
                              if (snapshot.hasData) {
                                
                                return ListView.builder(
                                  controller: _scrollcontroller,
                                  itemCount: focusNode.canRequestFocus
                                      ? snapshot.data!.length + 1
                                      : snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    if (index == snapshot.data!.length) {
                                      return Container(
                                        height: 70,
                                      );
                                    } else {
                                      List my_sms = snapshot.data![index];
                                      if (widget.user[0].length <= 9) {
                                      
                                        if (my_sms[2] != sender) {
                                          List mylist = my_sms[3];
                                          return SwipeTo(
                                            onRightSwipe: () {
                                              setState(() {
                                                bottomScroll();
                                                focusNode.requestFocus();
                                                isReplaying = true;
                                                reply_to_msg = my_sms[0];
                                                replied_msg = my_sms[1];
                                              });
                                            },
                                            child: mylist.isEmpty
                                                ? ReceivedMessage(
                                                    child: Text(
                                                      "${my_sms[1]}",
                                                      style: SafeGoogleFont(
                                                        'SF Pro Text',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.64,
                                                        letterSpacing: 0.5,
                                                        color:
                                                            Color(0xff323643),
                                                      ),
                                                    ),
                                                    time: "${my_sms[7]} PM",
                                                    replied_status: false,
                                                  )
                                                : ReceivedMessage(
                                                    child: Text(
                                                      "${my_sms[1]}",
                                                      style: SafeGoogleFont(
                                                        'SF Pro Text',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.64,
                                                        letterSpacing: 0.5,
                                                        color:
                                                            Color(0xff323643),
                                                      ),
                                                    ),
                                                    time: "${my_sms[7]} PM",
                                                    replied_status: true,
                                                    replied: Column(
                                                      children: [
                                                        Text("${mylist[0]}",
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15)),
                                                        Text(
                                                          "${mylist[1]}",
                                                          style: SafeGoogleFont(
                                                            'SF Pro Text',
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            height: 1.64,
                                                            letterSpacing: 0.5,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                          );
                                        } else {
                                          List mylist = my_sms[3];
                                          if (mylist.isNotEmpty) {
                                            return SentMessage(
                                              child: Text(
                                                "${my_sms[1]}",
                                                style: SafeGoogleFont(
                                                  'SF Pro Text',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.6428571429,
                                                  letterSpacing: 0.5,
                                                  color:  Color(0xffffffff),
                                                ),
                                              ),
                                              sent: sent,
                                              replied: true,
                                              replymsg: my_sms[3][1],
                                            );
                                          }
                                          return SentMessage(
                                            child: Text(
                                              "${my_sms[1]}",
                                              style: SafeGoogleFont(
                                                'SF Pro Text',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                height: 1.6428571429,
                                                letterSpacing: 0.5,
                                                color: Color(0xffffffff),
                                              ),
                                            ),
                                            replied: false,
                                            sent: sent,
                                          );
                                        }
                                        //end group.................
                                      } else {
                                        if (my_sms[2] == widget.user[0]) {
                                          return SwipeTo(
                                            onRightSwipe: () {
                                              setState(() {
                                                bottomScroll();
                                                focusNode.requestFocus();
                                                isReplaying = true;
                                                reply_to_msg = my_sms[0];
                                                replied_msg = my_sms[1];
                                              });
                                            },
                                            child: my_sms[4] == ""
                                                ? ReceivedMessage(
                                                    child: Text(
                                                      "${my_sms[1]}",
                                                      style: SafeGoogleFont(
                                                        'SF Pro Text',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.64,
                                                        letterSpacing: 0.5,
                                                        color:
                                                            Color(0xff323643),
                                                      ),
                                                    ),
                                                    time: "${my_sms[7]} PM",
                                                    replied_status: false,
                                                  )
                                                : ReceivedMessage(
                                                    child: Text(
                                                      "${my_sms[1]}",
                                                      style: SafeGoogleFont(
                                                        'SF Pro Text',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.64,
                                                        letterSpacing: 0.5,
                                                        color:
                                                            Color(0xff323643),
                                                      ),
                                                    ),
                                                    time: "${my_sms[7]} PM",
                                                    replied_status: true,
                                                    replied: Text(
                                                      "${my_sms[4]}",
                                                      style: SafeGoogleFont(
                                                        'SF Pro Text',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.64,
                                                        letterSpacing: 0.5,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ),
                                          );
                                        } else {
                                          if (my_sms[4] != "") {
                                            return SentMessage(
                                              child: Text(
                                                "${my_sms[1]}",
                                                style: SafeGoogleFont(
                                                  'SF Pro Text',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.6428571429,
                                                  letterSpacing: 0.5,
                                                  color: Color(0xffffffff),
                                                ),
                                              ),
                                              sent: sent,
                                              replied: true,
                                              replymsg: my_sms[4],
                                            );
                                          }
                                          return SentMessage(
                                            child: Text(
                                              "${my_sms[1]}",
                                              style: SafeGoogleFont(
                                                'SF Pro Text',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                height: 1.6428571429,
                                                letterSpacing: 0.5,
                                                color: Color(0xffffffff),
                                              ),
                                            ),
                                            replied: false,
                                            sent: sent,
                                          );
                                        }
                                      }
                                    }
                                  },

                                );
                              }
                       
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(13.0),
                                  child: Card(
                                    
                                    child: Text(
                                        "Once Start conversation with ${widget.user[1]} chats will be appeared here"),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width - 60,
                              height: message.text != '' && !isReplaying
                                  ? message.text.length.toDouble() + 50
                                  : isReplaying
                                      ? 200
                                      : 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.grey[700],
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color(0xffF3F3F3),
                                        blurRadius: 15,
                                        spreadRadius: 1.5),
                                  ]),
                              child: Row(children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      if (isReplaying)
                                        replayContainer(replied_msg),
                                      Expanded(
                                        child: TextFormField(
                                          focusNode: focusNode,
                                          onTap: () async {
                                            if (await data != null) {
                                              bottomScroll();
                                            }
                                            setState(() {
                                              isTyping = true;
                                              shoemoji = false;
                                              focusNode.requestFocus();
                                              focusNode.addListener(() {
                                                if (shoemoji) {
                                                  focusNode.unfocus();
                                                  focusNode.canRequestFocus =
                                                      false;
                                                }
                                              });
                                            });
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                              int unique = UniqueKey().hashCode;
                                              print("changed $unique");

                                              focusNode.addListener(() {
                                                if (shoemoji) {
                                                  focusNode.unfocus();
                                                  focusNode.canRequestFocus =
                                                      false;
                                                }
                                              });
                                              isTyping = true;
                                            });
                                          },
                                          controller: message,
                                          style: SafeGoogleFont(
                                            'SF Pro Text',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w400,
                                            height: 1.64,
                                            letterSpacing: 0.5,
                                            color: Colors.white,
                                          ),
                                          decoration: InputDecoration(
                                              contentPadding: const EdgeInsets.only(
                                                  top: 6, left: 20),
                                              prefixIcon: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 0,
                                                      left: 5,
                                                      right: 5),
                                                  child: GestureDetector(
                                                    child: IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            shoemoji = true;
                                                            focusNode.unfocus();
                                                            focusNode
                                                                    .canRequestFocus =
                                                                false;
                                                          });
                                                          print("emojiii");
                                                        },
                                                        icon: const Icon(
                                                            Icons
                                                                .emoji_emotions,
                                                            color: Colors
                                                                .white70)),
                                                  )),
                                              suffixIcon: message.text != '' ||
                                                      isReplaying
                                                  ? IconButton(
                                                      onPressed: () async {
                                                        // pickFiles();
                                                        pickFiles();
                                                      },
                                                      icon: const Icon(
                                                        Icons.file_present,
                                                        color: Colors.white70,
                                                      ))
                                                  : Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        IconButton(
                                                            onPressed: () {
                                                              getCameraImage();
                                                              print("camera");
                                                            },
                                                            icon: const Icon(
                                                              Icons.camera_alt,
                                                              color: Colors
                                                                  .white70,
                                                            )),
                                                        IconButton(
                                                            onPressed: () {
                                                              pickFiles();
                                                            },
                                                            icon: const Icon(
                                                              Icons
                                                                  .file_present,
                                                              color: Colors
                                                                  .white70,
                                                            )),
                                                      ],
                                                    ),
                                              hintText: "Send message.....",
                                              hintStyle: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white),
                                              border: InputBorder.none),
                                          maxLines: 35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: 10, right: 0, left: 0),
                              child: FloatingActionButton(
                                onPressed: () async {
                                  if (await data != null) {
                                    bottomScroll();
                                  }
                                  if (isTyping && message.text != '') {
                                    if (widget.user[0].length <= 9) {
                                      sendGroupMessage(message.text);
                                      print(
                                          "send group message...............");
                                    } else {
                                      print(
                                          "send direct message...............");
                                      sendMessage(message.text);
                                    }
                                    message.clear();
                                    setState(() {
                                      isReplaying = false;
                                    });
                                  } else {
                                    print("record audio");
                                  }
                                },
                                elevation: 10,
                                child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                        color: AppColors.appColor,
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: Center(
                                      child:
                                          !isTyping || message.text.length == 0
                                              ? const Icon(
                                                  Icons.mic,
                                                  color: Colors.white,
                                                )
                                              : const Icon(Icons.send),
                                    )),
                              ),
                            )
                          ],
                        ),
                      ),
                      shoemoji ? emojiPicker() : Container()
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget replayContainer(msg) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8, bottom: 8),
              child: Container(
                color: Colors.green,
                width: 4,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Expanded(
                    //   child: Text(
                    //     "user name",
                    //     style: TextStyle(fontWeight: FontWeight.bold),
                    //   ),
                    // ),
                    GestureDetector(
                      onTap: () {
                        //cancel reply
                        setState(() {
                          isReplaying = false;
                          focusNode.unfocus();
                          message.clear();
                        });
                      },
                      child: const Icon(Icons.cancel),
                    )
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  "$msg",
                  style: const TextStyle(color: Colors.blue),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }

  Widget emojiPicker() {
    return SizedBox(
      height: 250,
      width: MediaQuery.of(context).size.width,
      child: EmojiPicker(
        textEditingController: message,
        onBackspacePressed: () {},
        onEmojiSelected: (emoji, category) {
          setState(() {
            shoemoji = false;
            focusNode.requestFocus();
          });
          print(emoji);
        },
      ),
    );
  }

  void sendMessage(messag) async {
    print(message.text);
    String msgId = DateTime.now().millisecondsSinceEpoch.toString();
    while (await FirebaseService().checkIfMsgExist(msgId)) {
      print("msg existssssssssssss ipo ");
      msgId = DateTime.now().millisecondsSinceEpoch.toString();
    }
    String grpTest = UniqueKey().hashCode.toString();
    print(grpTest);
    String messageReplied = replied_msg;
    String seen = "0";
    DateFormat format = DateFormat("yyyy-MM-dd HH:mm");
    var nowDate = format.format(DateTime.now());
    var now = DateFormat.Hm().format(DateTime.now());

    List attributes = [
      msgId,
      messag,
      sender,
      receiver,
      messageReplied,
      seen,
      nowDate,
      now,
      "0"
    ];

    print(attributes);

    // sends!.put(msgId, attributes);
    List msgs = [];

    List messgs = await SecureStorageService().readAllMsgData("messages");
    if (messgs.isNotEmpty) {
      print("readed.................. $messgs");
      for (var x = 0; x < messgs.length; x++) {
        print("length is ..............................${messgs.length}");
        msgs.add(messgs[x]);
      }
      msgs.add(attributes);

      Message mysms = Message("messages", msgs);
      await SecureStorageService().writeMsgData(mysms);
      setState(() {
        data = SecureStorageService().readMsgData("messages", sender, receiver);
      });
    } else {
      msgs.add(attributes);

      Message mysms = Message("messages", msgs);
      await SecureStorageService().writeMsgData(mysms);
      setState(() {
        data = SecureStorageService().readMsgData("messages", sender, receiver);
      });
    }
    await FirebaseService().sendMessage(attributes);
    print("sent to firebase");

    setState(() {
      data = SecureStorageService()
          .readMsgData("messages", widget.iam, widget.user[0]);
    });
    if (replied_msg != "" || isReplaying) {
      print("return defaults");
      setState(() {
        isReplaying = false;
        reply_to_msg = "";
        replied_msg = "";
      });
    }
    loadUsersMsgs();
  }

  void pickFiles() async {
    print("imefika");
    PlatformFile? file = await FileShare().uploadFile();
    print("imepita");

    if (file != null) {
      print(file.name);
      print(file.bytes);
      print(file.size);
      print(file.path);
      print(file.extension);
    }
  }

  void checkSeen(mysm) async {
    bool sents = await SecureStorageService().containsKey(mysm);
    setState(() {
      sent = sents;
    });
  }

  void sendGroupMessage(String msg) async {
    String msgId = DateTime.now().millisecondsSinceEpoch.toString();
    while (await FirebaseService().checkIfMsgIdExist(msgId)) {
      msgId = DateTime.now().millisecondsSinceEpoch.toString();
    }
    String mysms = msg;

    DateFormat format = DateFormat("yyyy-MM-dd HH:mm");
    var nowDate = format.format(DateTime.now());
    String groupId = widget.user[0];
    List seen = [];
    List replied = [];
    List userMsg = [];
    List<dynamic> logged = await SecureStorageService().readByKeyData("user");
    if (replied_msg.toString().isNotEmpty) {
      userMsg.add("${logged[1]} ${logged[2]}");
      userMsg.add(replied_msg);
      replied.add(userMsg);
    }
    List attributes = [
      msgId,
      mysms,
      sender,
      replied,
      nowDate,
      groupId,
      "0",
      seen
    ];
    await GroupService().saveGrpMessages(attributes);
    setState(() {
      data = SecureStorageService()
          .readGrpMsgData("grpMessages", widget.user[0]);
    });
    if (replied_msg != "" || isReplaying) {
      setState(() {
        isReplaying = false;
        reply_to_msg = "";
        replied_msg = "";
      });
    }
    loadGrpMsgs();
  }
}

class DummyWaveWithPlayIcon extends StatelessWidget {
  const DummyWaveWithPlayIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleoSY (0:592)
          width: 3,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectanglejqz (0:578)
          width: 3,
          height: 14,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectangle5ex (0:581)
          width: 3,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectangleRD2 (0:585)
          width: 3,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        //     ],
        //   ),
        // ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectanglexye (0:590)
          width: 3,
          height: 26,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),

        const SizedBox(
          width: 2,
        ),

        Container(
          // rectangleSP2 (0:587)
          width: 3,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleyNx (0:582)
          width: 3,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleJg8 (0:579)
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectangleEpg (0:593)
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectanglez3A (0:586)
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectangle8QG (0:589)
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectangleHHA (0:584)
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectangle2Ve (0:598)
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),

        SizedBox(
          width: 2,
        ),
        Container(
          // rectanglenUp (0:591)
          width: 3,
          height: 26,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectangleGPz (0:588)
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectangleoep (0:583)
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),

        SizedBox(
          width: 2,
        ),
        Container(
          // rectangle9Tn (0:580)
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectangleHZz (0:594)
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectangleRw6 (0:595)
          width: 3,
          height: 10,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectanglea3J (0:596)
          width: 3,
          height: 8,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectangleifJ (0:597)
          width: 3,
          height: 6,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),

        CustomWidthSpacer(
          size: 0.05,
        ),

        Text(
          '01:3',
          style: SafeGoogleFont(
            'SF Pro Text',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.2575,
            letterSpacing: 1,
            color: Color(0xffffffff),
          ),
        ),

        CustomWidthSpacer(
          size: 0.01,
        ),

        Image.asset(
          "assets/images/play-icon.png",
          width: 25,
          height: 25,
        )
      ],
    );
  }
}

class DateDevider extends StatelessWidget {
  const DateDevider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Container(
        width: 100, // OK
        height: 35, // OK
        decoration: BoxDecoration(
          color: Color(0xffF2F3F6),
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
        ),
        child: Center(
            child: Text(
          'Today',
          style: SafeGoogleFont(
            'SF Pro Text',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.193359375,
            letterSpacing: 1,
            color: Color(0xff77838f),
          ),
        )),
      ),
    );
  }
}

// 