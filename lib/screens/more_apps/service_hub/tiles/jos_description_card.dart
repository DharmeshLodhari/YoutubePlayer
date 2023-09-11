// ignore_for_file: must_be_immutable

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/jobs.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../../routes/route_constants.dart';

class JobDescriptionCard extends StatelessWidget {
  JobDescriptionCard({
    Key? key,
    required this.job,
  }) : super(key: key);
  final JobModel? job;
  String? user;

  String getTimeDifference() {
    var difference =
        DateTime.now().difference(DateTime.parse(job!.creationDate!));
    String time = '';
    print(difference.toString() + '-----');
    if (difference > const Duration(hours: 24)) {
      time = difference.inDays.toString() + ' days';
    } else if (difference > const Duration(hours: 1)) {
      time = difference.inHours.toString() + ' hrs';
    } else if (difference > const Duration(minutes: 1)) {
      time = difference.inMinutes.toString() + ' mins';
    } else if (difference > const Duration(seconds: 1)) {
      time = difference.inSeconds.toString() + ' sec';
    } else {
      time = difference.inMilliseconds.toString() + ' ms';
    }

    return time;
  }

  Color colorStatus(String status) {
    if (status.toLowerCase() == 'open') {
      return const Color(0xff3F61DB);
    }
    if (status.toLowerCase() == 'closed') {
      return Colors.red.shade400;
    }
    if (status.toLowerCase() == 'completed') {
      return Colors.green.shade400;
    }
    if (status.toLowerCase() == 'canceled') {
      return Colors.red.shade400;
    }
    if (status.toLowerCase() == 'in-progress' && user == job?.ownerName ||
        user == job?.owner) {
      return Colors.yellow.shade700;
    } else if (status.toLowerCase() == 'in-progress' && job?.assignee != user) {
      return Colors.red.shade400;
    } else {
      return Colors.yellow.shade700;
    }
  }

  String textStatus(String status) {
    if (status.toLowerCase() == 'open') {
      return 'Open';
    }
    if (status.toLowerCase() == 'completed') {
      return 'Completed';
    }
    if (status.toLowerCase() == 'closed') {
      return 'Closed';
    }
    if (status.toLowerCase() == 'canceled') {
      return 'Canceled';
    }
    if (status.toLowerCase() == 'in-progress' && user == job?.ownerName ||
        user == job?.owner) {
      return 'In-Progress';
    } else if (status.toLowerCase() == 'in-progress' && job?.assignee != user) {
      return 'Closed';
    } else {
      return 'In-Progress';
    }
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserBloc>(context).user.userName;
    print('$user && ${job?.owner}');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xfffafbff),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0c31378c),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
        color: Colors.white,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  job!.title!,
                  style: TextStyle(
                    color: blackFont,
                    fontSize: 16,
                    fontFamily: "Open Sans",
                    fontWeight: FontWeight.w600,
                  ),
                ),
                job?.assignee != null && user != job?.assignee &&
                      job!.isListed == false &&
                      job!.applicants!.contains(user)
                  ? Container(
                      width: 54,
                      // height: 20,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: red),
                        color: red.withOpacity(0.1),
                      ),
                      child: Text(
                        'closed',
                        style: TextStyle(
                          color: red,
                          fontSize: 10.80,
                          fontFamily: "Open Sans",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ):Container(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: colorStatus(job!.status!).withOpacity(.4)),
                  child: Text(
                    textStatus(job!.status!),
                    style: TextStyle(
                      color: colorStatus(job!.status!),
                      fontSize: 12,
                      fontFamily: "Open Sans",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              job!.description!,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: blackFont,
                fontSize: 12.6,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  worldCurrencies[job!.currency]!,
                  style: TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 14.0,
                      color: navyBlue,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  moneyDisplayNormalizer(int.parse(job!.pay.toString())),
                  style: TextStyle(
                      fontSize: 14.0,
                      color: navyBlue,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 12,
        ),
        Row(
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/images/job_location.svg',
                  color: darkGrey,
                  height: 14,
                  width: 14,
                ),
                const SizedBox(
                  width: 6,
                ),
                Text(
                  job!.location!.toCapitalized(),
                  style: TextStyle(
                    color: darkGrey,
                    fontSize: 10,
                    fontFamily: "Open Sans",
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                if (job!.applicantsCount! > 0) {
                  Navigator.pushNamed(context, Routes.JOBS_APPLICANT_LIST,
                      arguments: job);
                } else {}
              },
              child: Text(
                "${getTimeDifference()} ago | Applied by : ${job!.applicantsCount}",
                style: TextStyle(
                  color: darkGrey,
                  fontSize: 10,
                  fontFamily: "Open Sans",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        )
      ]),
    );
  }
}
