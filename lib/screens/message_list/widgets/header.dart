// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:chat/screens/groupcreate/addmembers.dart';
import 'package:chat/utils.dart';
import 'package:chat/widgets/spacer/spacer_custom.dart';

import '../../../../constants/app_colors.dart';
import '../../../../device_utils.dart';

class HeaderWithSearchBar extends StatelessWidget {
  const HeaderWithSearchBar({
    Key? key,
    required this.activeIndexx,
    required this.refreshed,
    this.seching,
    required this.controller,
  }) : super(key: key);
  final RxInt activeIndexx;
  final Function()? refreshed;
  final Function()? seching;
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    bool tapped=false;
    List menuitems = [
      GestureDetector(
                onTap: refreshed,
                child: Row(
                  children: [
                    Icon(Icons.people_alt_outlined),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      "Refresh",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2575,
                        letterSpacing: 1,
                      ),
                    )
                  ],
                ),
              ),
      Obx(
        () => activeIndexx.value == 2
            ? GestureDetector(
                onTap: () {
                  //create group
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const Addparticipant(),
                  ));
                },
                child: Row(
                  children: [
                    const Icon(Icons.people_alt_outlined),
                    const SizedBox(
                      width: 3,
                    ),
                    Text(
                      "New Group",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2575,
                        letterSpacing: 1,
                      ),
                    )
                  ],
                ),
              )
            : GestureDetector(
                onTap: () {
                  print("contact......");
                },
                child: Row(
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(
                      width: 3,
                    ),
                    Text(
                      "New Contact",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2575,
                        letterSpacing: 1,
                      ),
                    )
                  ],
                ),
              ),
      )
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 4, 24),
      width: double.infinity,
      height: 113,
      decoration: BoxDecoration(
        color: AppColors.appColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Tuchati",style: TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.bold),),
          const Spacer(),

      IconButton(onPressed: seching, icon: const Icon(Icons.search,color: Colors.white,)),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            position: PopupMenuPosition.under,
            onSelected: (value) {
              print(value);
            },
            itemBuilder: (context) => menuitems
                .map((e) => PopupMenuItem(value: e, child: e))
                .toList(),
          ),
          
        ],
      ),
    );
  }

  void searching(String value) {
    
  }
}

mixin searched {
}
