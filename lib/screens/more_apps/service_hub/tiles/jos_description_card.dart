import 'package:Slydo/data/currency.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/active_job_listing.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/jobs.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

class JobDescriptionCard extends StatelessWidget {
  const JobDescriptionCard(
      {Key? key,
      // required this.listingData,
      //
      required this.job
      // required this.listingData,
      })
      : super(key: key);
  final JobModel? job;

  String getTimeDifference() {
    var difference =
        DateTime.now().difference(DateTime.parse(job!.creationDate!));
    String time = '';
    print(difference.toString() + '-----');

    if (difference > Duration(hours: 24)) {
      time = difference.inDays.toString() + ' days';
    } else if (difference > Duration(hours: 1)) {
      time = difference.inHours.toString() + ' hrs';
    } else if (difference > Duration(minutes: 1)) {
      time = difference.inMinutes.toString() + ' mins';
    } else if (difference > Duration(seconds: 1)) {
      time = difference.inSeconds.toString() + ' sec';
    } else {
      time = difference.inMilliseconds.toString() + ' ms';
    }

    return time;
  }

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
                  job!.title!,
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
                    job!.status!,
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  worldCurrencies[job!.currency]!,
                  style: TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 18.0,
                      color: navyBlue,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  moneyDisplayNormalizer(int.parse(job!.pay.toString())),
                  style: TextStyle(
                      fontSize: 18.0,
                      color: navyBlue,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          height: 12,
        ),
        Text(
          job!.description!,
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
              "${getTimeDifference()} ago | Accepted By : ${job!.applicantsCount}",
              style: TextStyle(
                color: blackFont,
                fontSize: 8,
                fontFamily: "Open Sans",
                fontWeight: FontWeight.w600,
              ),
            ),
            Spacer(),
            Text(
              job!.location!,
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
