import 'dart:convert';
import 'dart:developer';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/environment.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/main.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/share_in_chat/ShareInChat.dart';
import 'package:Slydo/screens/more_apps/service_hub/auth/service_hub_auth.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/jobs.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';

import '../../../../utils/navigation_util.dart';
import '../../../../widget/dialog.dart';
import '../../../../widget/rounded_background_icon.dart';
import '../../messaging/chat/helpers/connection_list_manager.dart';
import '../../yarn/models/share_as_yarn_model.dart';
import '../../yarn/share_as_a_yarn_screen.dart';
import '../../yarn/yarn_auth.dart';
import '../../yarn/yarn_dashboard_bloc.dart';
import '../../yarn/yarn_report_screen.dart';

class JobsPreviewJobDetail extends StatefulWidget {
  const JobsPreviewJobDetail({
    Key? key,
    // required this.jobId,

    // this.listingId,
    required this.jobDetails,
  }) : super(key: key);
  // final String jobId;
  final Map<dynamic, dynamic> jobDetails;
  // final String? listingId;

  @override
  State<JobsPreviewJobDetail> createState() => _JobsPreviewJobDetailState();
}

class _JobsPreviewJobDetailState extends State<JobsPreviewJobDetail> {
  CarouselController carouselController = CarouselController();
  late final String jobId;
  late final String? listingId;
  late YarnDashboardBloc yarnDashboardBloc;

  bool isLoading = false;
  int currentIndex = 0;
  bool isAPILoading = false;
  String selected = "";

  List<CustomPopupMenuItem> popupMenuList = [
    CustomPopupMenuItem(
        title: "Edit Job", imageUrl: "assets/images/edit_job.svg"),
    CustomPopupMenuItem(
        title: "Copy link", imageUrl: "assets/images/copy_links.svg"),
    CustomPopupMenuItem(title: "Send Via", imageUrl: "assets/images/share.svg"),
    CustomPopupMenuItem(
        title: "Share in chat", imageUrl: "assets/images/send.svg"),
    CustomPopupMenuItem(
        title: "Applicant", imageUrl: "assets/images/delete.svg"),
    CustomPopupMenuItem(
        title: "Reviewed Applicant", imageUrl: "assets/images/delete.svg"),
    CustomPopupMenuItem(title: "Delete", imageUrl: "assets/images/delete.svg"),
  ];

  final List<String> items = [
    'Item1',
    'Item2',
    'Item3',
    'Item4',
  ];
  List<String> selectedItems = [];
  JobModel? job;
  String? activeListingId;
  late UserBloc userBloc;

  List<ChatConversation> searchedChatConnection = [];

  void getSearchedChatConnections() async {
    searchedChatConnection = await ConnectionListManager()
        .getSearchedConnectionsFromDB(searchedText: job!.ownerName);
    if (mounted) setState(() {});
  }

  void getMyJob() async {
    if (!isLoading) {
      // if (listNext != null && !isLoading) {
      isLoading = true;
      if (mounted) setState(() {});

      var result =
          await ServiceHubAuthService().retreiveListedJob(listingId: listingId);

      logger.d('tor bad......${result?.toJson()}');
      if (result == null) {
        // noJobsInList = true;

        isLoading = false;
        if (mounted) {
          setState(() {});
        }
        // showSnackbar(context, message: 'Invalid Job');
        return;
      }

      var tempList = result;
      if (mounted) {
        setState(() {
          // noJobsInList = false;
          isLoading = false;
          job = tempList.job;
          activeListingId = tempList.id;
          job!.activeListing = activeListingId;
        });
      }
      getSearchedChatConnections();
      log('job gt job ${job!.toJson()}');
    }
  }

  @override
  void initState() {
    jobId = widget.jobDetails['jobId'];
    listingId = widget.jobDetails['listingId'];
    getMyJob();
    job = widget.jobDetails['job'];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context, listen: false);
    return Scaffold(
      appBar: appBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            getJobDetails(),
            isLoading
                ? Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Shimmer.fromColors(
                      baseColor: Colors.white,
                      highlightColor: greyBorderColor,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          mainAxisSpacing: 14,
                          mainAxisExtent: 180,
                          crossAxisSpacing: 15,
                          maxCrossAxisExtent: 200,
                        ),
                        itemCount: 2,
                        itemBuilder: (context, index) {
                          return Card(
                            color: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : SizedBox.shrink(),
            Visibility(
              visible: !isLoading && job == null,
              child: Center(
                child: Column(
                  children: [
                    Lottie.asset('assets/lottie/no_moment_lottie.json'),
                    SizedBox(height: 20),
                    Text('No items at the moment'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> acceptApplicantAlert() async {
    await showDialogBox(
      context: context,
      leftButtonOnPressed: () => Navigator.pop(context),
      rightButtonOnPressed: () {
        FocusScope.of(context).unfocus();
        isAPILoading = true;
        if (mounted) setState(() {});
        applyForJob();

        isAPILoading = false;
        if (mounted) setState(() {});
      },
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: navyBlue.withOpacity(0.08),
        borderRadius: 20,
        width: 43,
        height: 43,
        icon: Icon(
          Icons.check_circle_sharp,
          color: navyBlue,
          size: 16,
        ),
        enableMargin: false,
      ),
      actionOneBgColor: greyBorderColor,
      actionOneTextColor: black,
      actionTwoBgColor: navyBlue,
      actionTwoTextColor: white,
      title: "Accept",
      description: "Are you sure you want to apply for this job?",
      actionOneText: AppLocalization.of(context)!.cancel,
      actionTwoText: AppLocalization.of(context)!.accept,
    );
  }

  Future<void> upgradeApplicantAlert() async {
    await showDialogBox(
      context: context,
      leftButtonOnPressed: () => Navigator.pop(context),
      rightButtonOnPressed: () {
        Navigator.pushNamed(context, "/choose-subscriptions");
      },
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: navyBlue.withOpacity(0.08),
        borderRadius: 20,
        width: 43,
        height: 43,
        icon: Icon(
          Icons.check_circle_sharp,
          color: navyBlue,
          size: 16,
        ),
        enableMargin: false,
      ),
      actionOneBgColor: greyBorderColor,
      actionOneTextColor: black,
      actionTwoBgColor: navyBlue,
      actionTwoTextColor: white,
      title: "Upgrade",
      description: AppLocalization.of(context)!.upgradeMessage,
      actionOneText: AppLocalization.of(context)!.cancel,
      actionTwoText: AppLocalization.of(context)!.upgrade,
    );
  }

  Future shareAsYarn() async {
    NavigationUtil.push(context,
        screen: ShareAsAyarnScreen(
            askCategories: yarnDashboardBloc.yarnCategories,
            shareAsYarnModel: ShareAsYarnModel.shareAsYarnModel,
            jobModel: job,
            callback: (params) async {
              params
                ..attachment = {
                  "job": job?.toJson().cast<String, dynamic>() ?? {},
                };
              bool data = await YarnAuth().addYarnAndQuestion(params, '');
              if (data) {
                showToast(message: "Shared in Yarn successfully");
                Navigator.pop(context);
              }
            }));
  }

  Widget getJobDetails() {
    return isLoading || job == null
        ? const SizedBox.shrink()
        : Column(
            children: [
              if (job!.pictures!.length > 0) customImageSlider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16),
                    child: getTitleRow(),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomText(
                          title: "Description",
                          fontSize: 14,
                          fontweight: FontWeight.w700,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          "${job!.description}",
                          style: const TextStyle(
                            color: Color(0xff8d92a3),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomText(
                          title: 'Due date',
                          fontSize: 14,
                          fontweight: FontWeight.w700,
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: darkGrey.withOpacity(.3)),
                              child: SvgPicture.asset(
                                'assets/images/Calendar.svg',
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              DateFormat('dd-MM-yyyy')
                                  .format(DateTime.parse(job!.dueDate!)),
                              style: const TextStyle(
                                color: Color(0xff030e36),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomText(
                          title: "Location",
                          fontSize: 14,
                          fontweight: FontWeight.w700,
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: darkGrey.withOpacity(.3)),
                              child: SvgPicture.asset(
                                'assets/images/job_location.svg',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "${job!.location}",
                              style: TextStyle(
                                color: blackFont.withOpacity(.6),
                                fontSize: 14,
                                fontFamily: "Open Sans",
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (job!.isListed!) getJobActivityStatusRow(),

                  getJobOnlineRow(),
                  const Divider(),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomText(
                          title: "Posted By",
                          fontSize: 14,
                          fontweight: FontWeight.w700,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, Routes.USER_PROFILE,
                              arguments: {"searchedUserName": job!.owner}),
                          child: Row(
                            children: [
                              CachedNetworkImage(
                                imageUrl: "${job!.ownerAvatar}",
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  width: 23.0,
                                  height: 23.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover),
                                  ),
                                ),
                                errorWidget: productAndServiceBigErrorWidget,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              userNameWithVerifiedIcon(
                                name: job!.ownerName!,
                                isVerified: userBloc.user.isVerified,
                                verifiedIconColor: verifyGreen,
                                textStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: HexColor("#151515")),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(),
                  const SizedBox(
                    height: 55,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: getSubmitData(),
                  ),
                  // getMutliSelectDropdown()
                ],
              )
            ],
          );
  }

  Column getJobOnlineRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CustomText(
                title: 'Job Mode',
                fontSize: 14,
                fontweight: FontWeight.w700,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                job!.isOnline!.toString().toLowerCase() == 'true'
                    ? 'Remote'
                    : 'On site',
                style: TextStyle(
                  color: black,
                  fontSize: 14,
                  fontFamily: "Open Sans",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Column getJobActivityStatusRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CustomText(
                title: 'Job Status',
                fontSize: 14,
                fontweight: FontWeight.w700,
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: 54,
                // height: 20,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xff3F61DB)),
                  color: const Color(0xff3F61DB).withOpacity(0.1),
                ),
                child: Text(
                  job?.status ?? '',
                  style: TextStyle(
                    color: Color(0xff3F61DB),
                    fontSize: 10.80,
                    fontFamily: "Open Sans",
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        Column(
          children: [
            job?.status?.toLowerCase() == 'open'
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomText(
                          title: 'Job Activity',
                          fontSize: 14,
                          fontweight: FontWeight.w700,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 4, 10, 4),
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: greyBorderColor),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Text(
                                      'Application Submitted',
                                      style:
                                          TextStyle(color: black, fontSize: 12),
                                    )),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                        color: navyBlue,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Icon(
                                      Icons.check,
                                      color: white,
                                      size: 7,
                                    ))
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 4, 10, 4),
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: greyBorderColor),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Text(
                                      'Application viewed',
                                      style:
                                          TextStyle(color: black, fontSize: 12),
                                    )),
                                const SizedBox(
                                  width: 25,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: darkGrey,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Container(),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 4, 10, 4),
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: greyBorderColor),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Text(
                                      'Application Accepted',
                                      style:
                                          TextStyle(color: black, fontSize: 12),
                                    )),
                                const SizedBox(
                                  width: 12,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: darkGrey,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Container(),
                                )
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomText(
                          title: 'Job Activity',
                          fontSize: 14,
                          fontweight: FontWeight.w700,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 4, 10, 4),
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: greyBorderColor),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Text(
                                      'Application Submitted',
                                      style:
                                          TextStyle(color: black, fontSize: 12),
                                    )),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                        color: navyBlue,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Icon(
                                      Icons.check,
                                      color: white,
                                      size: 7,
                                    ))
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            job?.status?.toLowerCase() == 'canceled'
                                ? Row(
                                    children: [
                                      Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 4, 10, 4),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: greyBorderColor),
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: Text(
                                            'Application Canceled',
                                            style: TextStyle(
                                                color: black, fontSize: 12),
                                          )),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                              color: mateRed,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Icon(
                                            Icons.check,
                                            color: white,
                                            size: 7,
                                          ))
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 4, 10, 4),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: greyBorderColor),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              child: Text(
                                                'Application viewed',
                                                style: TextStyle(
                                                    color: black, fontSize: 12),
                                              )),
                                          const SizedBox(
                                            width: 25,
                                          ),
                                          Container(
                                            padding: job?.status
                                                            ?.toLowerCase() ==
                                                        'in-progress' ||
                                                    job?.status
                                                            ?.toLowerCase() ==
                                                        'closed'
                                                ? const EdgeInsets.all(2)
                                                : const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                color: job?.status
                                                                ?.toLowerCase() ==
                                                            'in-progress' ||
                                                        job?.status
                                                                ?.toLowerCase() ==
                                                            'closed'
                                                    ? navyBlue
                                                    : darkGrey,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: job?.status?.toLowerCase() ==
                                                        'in-progress' ||
                                                    job?.status
                                                            ?.toLowerCase() ==
                                                        'closed'
                                                ? Icon(
                                                    Icons.check,
                                                    color: white,
                                                    size: 7,
                                                  )
                                                : Container(),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 4, 10, 4),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: greyBorderColor),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              child: Text(
                                                'Application Accepted',
                                                style: TextStyle(
                                                    color: black, fontSize: 12),
                                              )),
                                          const SizedBox(
                                            width: 12,
                                          ),
                                          Container(
                                            padding: job?.status
                                                            ?.toLowerCase() ==
                                                        'in-progress' ||
                                                    job?.status
                                                            ?.toLowerCase() ==
                                                        'closed'
                                                ? const EdgeInsets.all(2)
                                                : const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                color: job?.status
                                                                ?.toLowerCase() ==
                                                            'in-progress' ||
                                                        job?.status
                                                                ?.toLowerCase() ==
                                                            'closed'
                                                    ? navyBlue
                                                    : darkGrey,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: job?.status?.toLowerCase() ==
                                                        'in-progress' ||
                                                    job?.status
                                                            ?.toLowerCase() ==
                                                        'closed'
                                                ? Icon(
                                                    Icons.check,
                                                    color: white,
                                                    size: 7,
                                                  )
                                                : Container(),
                                          )
                                        ],
                                      ),
                                    ],
                                  )
                          ],
                        )
                      ],
                    ),
                  )
          ],
        )
      ],
    );
  }

  Row getTitleRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                title: "${job!.title}",
                fontSize: 16,
                fontweight: FontWeight.w700,
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    worldCurrencies[job!.currency!]!,
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
                  if (job!.isNegotiable!)
                    Text(
                      " Negotiable",
                      style: TextStyle(
                        color: Color(0xff030e36),
                        fontSize: 12,
                        fontFamily: "Open Sans",
                        fontWeight: FontWeight.w700,
                      ),
                    )
                ],
              ),
            ],
          ),
        ),
        userBloc.user.userName == job!.ownerName!.toLowerCase()
            ? const SizedBox.shrink()
            : searchedChatConnection.isNotEmpty &&
                    searchedChatConnection[0].userName!.toLowerCase() ==
                        job!.ownerName!.toLowerCase()
                ? InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/chat-screen', arguments: {
                        "recipientUserName": job!.ownerName!.toLowerCase()
                      });
                    },
                    child: SvgPicture.asset(
                      'yarn/chaticon'.toSVG(),
                      height: 34,
                      width: 34,
                    ),
                  )
                : InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed('/compose_message', arguments: {
                        'recipient': job!.ownerName,
                        "subject": job!.title,
                      });
                    },
                    child: SvgPicture.asset(
                      'yarn/messageicon'.toSVG(),
                      height: 34,
                      width: 34,
                    ),
                  ),
      ],
    );
  }

  Widget getSubmitData() {
    if (job!.isListed == true && userBloc.user.userName == job!.owner) {
      return getUnListNowBtn();
    } else if (job!.isListed == false && userBloc.user.userName == job!.owner) {
      return getListNowBtn();
    } else if (job!.isListed == true &&
        userBloc.user.userName != job!.owner &&
        job!.applicants!.contains(userBloc.user.userName)) {
      return Container();
    } else if (job!.isListed == true && userBloc.user.userName != job!.owner) {
      return getApplyNowBtn();
    } else {
      return Container();
    }
  }

  getListNowBtn() {
    return CurvedButton(
      onPressed: isAPILoading
          ? () {}
          : () async {
              FocusScope.of(context).unfocus();
              isAPILoading = true;
              if (mounted) setState(() {});
              createJobListing();

              isAPILoading = false;
              if (mounted) setState(() {});
            },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "List Now",
      isLoading: isAPILoading,
    );
  }

  getUnListNowBtn() {
    return CurvedButton(
      onPressed: isAPILoading
          ? () {}
          : () async {
              FocusScope.of(context).unfocus();
              isAPILoading = true;
              if (mounted) setState(() {});
              removeJobListing();

              isAPILoading = false;
              if (mounted) setState(() {});
            },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: 'Unlist Now',
      isLoading: isAPILoading,
    );
  }

  getApplyNowBtn() {
    return CurvedButton(
      onPressed: isAPILoading
          ? () {}
          : () async {
              if (userBloc.user.type == "User") {
                upgradeApplicantAlert();
              } else {
                acceptApplicantAlert();
              }
            },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: 'Apply',
      isLoading: isAPILoading,
    );
  }

  createJobListing() async {
    await ServiceHubAuthService().createListing({
      "job": job!.id,
    }).then((value) {
      print(value.toString() + 'Create Listing');
      Navigator.pushNamed(context, Routes.SUPER_HUB);
      showToast(message: AppLocalization.of(context)!.jobAddedSuccessfully);
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }

  removeJobListing() async {
    await ServiceHubAuthService().removeJobListing(listingId).then((value) {
      Navigator.pushNamed(context, Routes.SUPER_HUB);
      showToast(message: AppLocalization.of(context)!.jobRemovedFromListing);
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }

  applyForJob() async {
    await ServiceHubAuthService().applyForJob(
        {"applicant": userBloc.user.userName},
        jobId: job!.id).then((value) {
      Navigator.pushNamed(context, Routes.SUPER_HUB);
      showToast(
          message: AppLocalization.of(context)!.appliedForJobSuccessfully);
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }

  AppBar appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 16,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Job Details",
        style: TextStyle(
          color: blackFont,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        _moreOptionsBtn(),
        SizedBox(width: 12),
      ],
    );
  }

  Widget _moreOptionsBtn() {
    return Container(
      height: 34,
      width: 34,
      alignment: Alignment.center,
      child: IconButton(
          onPressed: () {
            androidBottomSheet(
              context: context,
              child: StatefulBuilder(
                builder: (context, changeState) {
                  return SizedBox(
                    height: 160,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => sendItemToUsersInChat(),
                            child: Row(
                              children: [
                                Container(
                                    height: 34,
                                    width: 34,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      color: Color(0xfffafbff),
                                    ),
                                    child: SvgPicture.asset(
                                        "assets/images/share.svg")),
                                const SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  'Share in Chat',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          InkWell(
                            onTap: () => shareAsYarn(),
                            child: Row(
                              children: [
                                Container(
                                    height: 34,
                                    width: 34,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      color: Color(0xfffafbff),
                                    ),
                                    child: SvgPicture.asset(
                                        "assets/images/share.svg")),
                                const SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  'Share in Yarn',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              NavigationUtil.push(context,
                                  screen: AddReportScreen(
                                    object: job!.toJson(),
                                    type: "job",
                                    isCommentMoment: false,
                                  ));
                            },
                            child: Row(
                              children: [
                                Container(
                                    height: 34,
                                    width: 34,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      color: Color(0xfffafbff),
                                    ),
                                    child: Icon(
                                      Icons.report,
                                      color: blackFont,
                                    )),
                                const SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  'Report',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );

            // selected = v;
            // if (selected == 'Create Job') {
            //   Navigator.pushNamed(context, Routes.JOBS_CREATE);
            // } else if (selected == 'My Job') {
            //   Navigator.pushNamed(context, Routes.MY_JOBS);
            // }
            // setState(() {});
          },
          icon: Icon(
            Icons.more_vert,
            color: blackFont,
          )),
    );
  }

  void sendItemToUsersInChat() async {
    List<ChatConversation?> listOfRecipient =
        await ShareInChat().selectShareCustomer(context);
    debugPrint("Selected users = ${listOfRecipient.length}");

    String url = AppConfig.baseUrl +
        "/api/v1/job-service/${job is JobModel ? "job" : "services"}/" +
        job!.id! +
        "/";

    Map<String, dynamic>? itemData =
        await ServiceHubAuthService().getJobOrService(url);

    listOfRecipient.forEach((recipient) {
      addProductOrServiceToChat(
          item: job, itemData: itemData, recipientUser: recipient!, url: url);
    });
  }

  void addProductOrServiceToChat(
      {Map<String, dynamic>? itemData,
      required ChatConversation recipientUser,
      String? url,
      dynamic item}) async {
    Map<String, dynamic> data = {
      "meta_data": jsonEncode(itemData),
      "check_id": Uuid().v4(),
      "conversation_id": recipientUser.conversationId,
      "author": userBloc.user.userName,
      "message": url,
      "kind": item is JobModel ? "job" : "service",
      "created_at": DateTime.now().toUtc().toString(),
      "type": "chatroom_message",
    };
    await sendDataToSocket(data);
  }

  CarouselSlider customImageSlider() {
    return CarouselSlider.builder(
      carouselController: carouselController,
      itemCount: job!.pictures!.length,
      itemBuilder: (context, index, realIndex) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    "${job!.pictures![index].image}",
                  ),
                  fit: BoxFit.cover,
                  //   width: MediaQuery.of(context).size.width,
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: MediaQuery.of(context).size.width * 0.45,
              child: Row(
                children: List.generate(
                    job!.pictures!.length,
                    (index) => Container(
                          width: 8.0,
                          height: 8.0,
                          margin: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 2.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentIndex == index
                                  ? navyBlue
                                  : Color(0xffBEC2F4)),
                        )),
              ),
            )
          ],
        );
      },
      options: CarouselOptions(
          height: 260,
          aspectRatio: 2,
          viewportFraction: 1,
          initialPage: 0,
          enableInfiniteScroll: false,
          reverse: false,
          // autoPlay: true,
          autoPlayInterval: Duration(seconds: 3),
          autoPlayAnimationDuration: Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: true,
          scrollDirection: Axis.horizontal,
          onPageChanged: onPageFunction),
    );
  }

  onPageFunction(index, reason) {
    currentIndex = index;
    setState(() {});
  }
}

class CustomText extends StatelessWidget {
  const CustomText({
    required this.title,
    required this.fontSize,
    required this.fontweight,
  });
  final String title;
  final double fontSize;
  final FontWeight fontweight;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Color(0xff030e36),
        fontSize: fontSize,
        fontFamily: "Open Sans",
        fontWeight: fontweight,
      ),
    );
  }
}

class CustomPopupMenuItem {
  final String title;
  final String imageUrl;

  CustomPopupMenuItem({required this.title, required this.imageUrl});
}
