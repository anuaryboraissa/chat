import 'package:chat/device_utils.dart';
import 'package:chat/screens/chat_room/widgets/chat_bubble.dart';
import 'package:chat/utils.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/spacer/spacer_custom.dart';

class SentMessage extends StatelessWidget {
  final Widget child;
  final bool sent;
  final bool replied;
  final String? replymsg;
  const SentMessage({
    Key? key,
    required this.child,
    required this.sent,
    required this.replied,
    this.replymsg,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messageTextGroup = Flexible(
        child: Column(
      children: [
        Align(
          alignment: Alignment
              .topRight, //Change this to Alignment.topRight or Alignment.topLeft
          child: Column(
            children: [
              CustomPaint(
                painter: ChatBubble(
                    color: AppColors.appColor, alignment: Alignment.topRight),
                child: Container(
                  constraints: BoxConstraints(
                      minWidth: 100,
                      maxWidth: DeviceUtils.getScaledWidth(context, 0.6)),
                  child: !replied
                      ? Padding(
                          padding: EdgeInsets.only(
                              left: 10, right: 20, top: 10, bottom: 10),
                          child: child,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IntrinsicHeight(
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, bottom: 8, left: 8),
                                    child: Container(
                                      color: Colors.green,
                                      width: 4,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 10,
                                          right: 20,
                                          top: 10,
                                          bottom: 10),
                                      child: Text(
                                        "$replymsg",
                                        style: SafeGoogleFont('SF Pro Text',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            height: 1.6428571429,
                                            letterSpacing: 0.5,
                                            color: Colors.white54),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 10, right: 20, top: 10, bottom: 10),
                              child: child,
                            )
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
        // CustomHeightSpacer(
        //   size: 0.001,
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Spacer(),
            sent
                ? Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.check, color: Colors.black45, size: 15),
                        SizedBox(
                          width: 1,
                        ),
                        Icon(Icons.check, color: Colors.black45, size: 15),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.check, color: Colors.black45, size: 15),
                  ),
            // Text(
            //   time,
            //   textAlign: TextAlign.right,
            //   // style: SafeGoogleFont(
            //   //   'SF Pro Text',
            //   //   fontSize: 12,
            //   //   fontWeight: FontWeight.w400,
            //   //   height: 1.2575,
            //   //   letterSpacing: 1,
            //   //   color: Color(0xff77838f),
            //   // ),
            // ),
          ],
        )
      ],
    ));

    return Padding(
      padding: EdgeInsets.only(right: 10.0, left: 10, top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          SizedBox(height: 30),
          messageTextGroup,
        ],
      ),
    );
  }
}
