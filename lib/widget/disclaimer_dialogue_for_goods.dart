import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

Future<bool> showDisclaimerDialogueForGoods(BuildContext context) async {
  bool? result = await showDialog<bool>(
    barrierDismissible: false,
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, rentDurationStateSetter) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          contentPadding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: MediaQuery.of(context).size.width - 40,
                child: Card(
                  elevation: 2,
                  shadowColor: Colors.transparent,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: EdgeInsets.only(top: 16, bottom: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  color: Colors.white,
                                  child: Text(
                                    "Disclaimer",
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    style: TextStyle(
                                        color: blackFont,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Container(
                                  color: Colors.white,
                                  child: Text(
                                    "Before you make payment, you are advised to verify that the goods and service you want to purchase are genuine and that they meet your desired quality. Goods and services found on Slydo are listed by users. Slydo cannot be held responsible for their status or condition.",
                                    style: TextStyle(
                                        color: blackFont,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                child: Text("Cancel",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: blackFont,
                                        fontWeight: FontWeight.w600)),
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                              ),
                              TextButton(
                                child: Text("OK",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: blackFont,
                                        fontWeight: FontWeight.w600)),
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: (MediaQuery.of(context).size.width - 100) / 2,
                top: -30,
                child: ClipOval(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: dividerColor, width: 1.5),
                        borderRadius: BorderRadius.circular(60)),
                    height: 60,
                    width: 60,
                    child: Center(
                      child: Image.asset(
                        "assets/images/app_logo_navyBlue.png",
                        height: 45,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    ),
  );

  if (result != null) {
    if (result) return true;
    return false;
  }
  return false;
}
