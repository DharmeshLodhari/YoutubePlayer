import 'dart:convert';
import 'dart:developer';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../../../data/state_notifier.dart';
import '../../../../../routes/route_constants.dart';
import '../../../../../utils/util.dart';
import '../../../user_profile/models/job_service_model.dart';

class JobCardChatDescription extends StatefulWidget {
  JobCardChatDescription({Key? key, required this.jobMessage})
      : super(key: key);
  final jobMessage;

  @override
  State<JobCardChatDescription> createState() => _JobCardChatDescriptionState();
}

class _JobCardChatDescriptionState extends State<JobCardChatDescription> {
  late UserBloc userBloc;

  JobServiceToChatModel? jobServiceToChatModel;

  Map<String, dynamic>? data;
  Map<String, dynamic>? authorData;

  String getTimeDifference(String date) {
    var difference = DateTime.now().difference(DateTime.parse(date));
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

  @override
  Widget build(BuildContext context) {
    log('message${widget.jobMessage.toString()}');
    userBloc = Provider.of<UserBloc>(context);

    if (widget.jobMessage!["meta_data"] is String) {
      data = jsonDecode(widget.jobMessage["meta_data"]);
    } else if (widget.jobMessage!["meta_data"] is Map) {
      data = widget.jobMessage["meta_data"];
    }

    jobServiceToChatModel = JobServiceToChatModel.fromJson(data!);

    bool isSend = widget.jobMessage['author'] == userBloc.user.userName;

    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, Routes.MY_JOB_DETAILS, arguments: {
        'jobId': jobServiceToChatModel!.id,
        'listingId': '',
        'job': jobServiceToChatModel
      }),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              isSend ? Container() : Container(width: 20),
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width / 1.30,
                    minWidth: MediaQuery.of(context).size.width / 2.40,
                    minHeight: 50),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 130,
                                child: Text(
                                  jobServiceToChatModel?.title ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: blackFont,
                                    fontSize: 14,
                                    fontFamily: "Open Sans",
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 6, 10, 6),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: jobServiceToChatModel?.status ==
                                            'closed'.toLowerCase()
                                        ? Colors.red.withOpacity(.4)
                                        : Color(0xff46ce7c).withOpacity(.4)),
                                child: Text(
                                  jobServiceToChatModel?.status ?? '',
                                  style: TextStyle(
                                    color: jobServiceToChatModel?.status ==
                                            'closed'.toLowerCase()
                                        ? Colors.red
                                        : const Color(0xff46ce7c),
                                    fontSize: 10,
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
                          SizedBox(
                            width: 200,
                            child: Text(
                              jobServiceToChatModel?.description ?? '',
                              maxLines: 3,
                              style: TextStyle(
                                color: blackFont,
                                fontSize: 12.6,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                worldCurrencies[
                                    jobServiceToChatModel?.currency]!,
                                style: TextStyle(
                                    fontFamily: "Roboto",
                                    fontSize: 14.0,
                                    color: navyBlue,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                moneyDisplayNormalizer(int.parse(
                                    jobServiceToChatModel!.pay!.toString())),
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
                                jobServiceToChatModel!.location!
                                    .toCapitalized(),
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
                          Text(
                            "${getTimeDifference(jobServiceToChatModel!.creationDate!)} ago | Applied by : ${jobServiceToChatModel!.applicantsCount}",
                            style: TextStyle(
                              color: darkGrey,
                              fontSize: 10,
                              fontFamily: "Open Sans",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    ]),
              ),
              isSend
                  ? Container(
                      width: 20,
                      child: isSend
                          ? Center(
                              child:
                                  getMessageTick(message: widget.jobMessage!),
                            )
                          : Container(),
                    )
                  : Container(),
            ],
          ),
          SizedBox(
            height: 1,
          ),
          Row(
            mainAxisAlignment:
                isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              isSend
                  ? Container()
                  : SizedBox(
                      width: 20,
                    ),
              Text(
                formatTime(jobServiceToChatModel!.creationDate!),
                style: TextStyle(
                    color: darkGrey, fontSize: 10, fontWeight: FontWeight.w500),
              ),
              isSend
                  ? SizedBox(
                      width: 20,
                    )
                  : Container(),
            ],
          )
        ],
      ),
    );
  }
}
