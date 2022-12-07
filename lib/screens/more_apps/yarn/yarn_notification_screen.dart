import 'package:Slydo/screens/more_apps/yarn/widgets/notification_view.dart';
import 'package:flutter/material.dart';

import '../../../utils/colors.dart';

class YarnNotification extends StatefulWidget {
  const YarnNotification({Key? key}) : super(key: key);

  @override
  State<YarnNotification> createState() => _YarnNotificationState();
}

class _YarnNotificationState extends State<YarnNotification> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        "Notification",
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: blackFont,
        ),
      ),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 26,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Divider(),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 10),
            itemCount: 3,
            itemBuilder: (context, index) {
              return AskNotificationView();
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
          ),
        )
      ],
    );
  }
}
