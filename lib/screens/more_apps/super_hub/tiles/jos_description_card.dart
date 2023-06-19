import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

class JobDescriptionCard extends StatelessWidget {
  const JobDescriptionCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 343,
      height: 100,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Color(0xfffafbff),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0c31378c),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
        color: Colors.white,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Baby photoshoot",
                  style: TextStyle(
                    color: blackFont,
                    fontSize: 14,
                    fontFamily: "Open Sans",
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  width: 18,
                  height: 6,
                  child: Text(
                    "Active",
                    style: TextStyle(
                      color: Color(0xff46ce7c),
                      fontSize: 6,
                      fontFamily: "Open Sans",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),
            Text(
              "₦1,000,000.00",
              style: TextStyle(
                color: navyBlue,
                fontSize: 14,
                fontFamily: "Open Sans",
                fontWeight: FontWeight.w700,
              ),
            )
          ],
        ),
        SizedBox(
          height: 12,
        ),
        Text(
          "I need a photographer for a 1year baby photoshoot. ",
          style: TextStyle(
            color: blackFont,
            fontSize: 10,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Text(
              "2 mins ago | Accepted By : 40+",
              style: TextStyle(
                color: blackFont,
                fontSize: 8,
                fontFamily: "Open Sans",
                fontWeight: FontWeight.w600,
              ),
            ),
            Spacer(),
            Text(
              "IbadanIkeja, Lagos",
              style: TextStyle(
                color: Color(0xff030e36),
                fontSize: 8,
                fontFamily: "Open Sans",
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        )
      ]),
    );
  }
}