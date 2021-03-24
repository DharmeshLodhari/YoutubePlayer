import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

import 'get_connection_list_for_sharing.dart';

class ShareInChat {
  Future<void> selectUsersToShare(BuildContext context) async {
    await showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding: EdgeInsets.only(bottom: 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              "Share",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: blackFont,
                                  fontSize: 18),
                            ),
                          ),
                        ),
                        MaterialButton(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Send",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                          color: navyBlue,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Expanded(child: GetUserConnectionList())
                  ],
                ),
              ));
        });
  }

  Future<List<CustomerProfile>> selectShareCustomer(
      BuildContext context) async {
    await selectUsersToShare(context);

    return [];
  }
}
