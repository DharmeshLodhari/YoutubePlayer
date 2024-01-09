import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class KYCProofTile extends StatelessWidget {
  KYCProofTile({super.key, required this.item});

  late RiderRegistrationBloc riderRegistrationBloc;
  Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    riderRegistrationBloc = Provider.of<RiderRegistrationBloc>(context);
    return GestureDetector(
      onTap: () {
        riderRegistrationBloc.updateKYCType(item["type"]);
        Navigator.of(context).pushNamed(Routes.STEPS_INFO);
      },
      child: Card(
        elevation: 20,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: selectedListItemBackgroundBlue),
            borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.symmetric(vertical: 5),
        shadowColor: boxShadowTwo,
        color: white,
        child: Container(
          decoration: decorateBox(),
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item["title"],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: blackFont,
                        fontFamily: "Inter",
                      ),
                    ),
                    Checkbox(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(25.0))),
                      focusColor: navyBlue,
                      activeColor: navyBlue,
                      checkColor: Colors.white,
                      value: riderRegistrationBloc.isPhotoAdded(item["type"]),
                      onChanged: (value) {},
                    ),
                  ],
                ),
                Text(
                  item["subtitle"],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: darkGrey,
                    fontFamily: "Inter",
                  ),
                ),
                SizedBox(height: 10.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
