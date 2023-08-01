// ignore_for_file: unrelated_type_equality_checks

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

class MyJobsDetails extends StatefulWidget {
  const MyJobsDetails({
    Key? key,
    // required this.jobId,

    // this.listingId,
    required this.jobDetails,
  }) : super(key: key);
  // final String jobId;
  final Map<dynamic, dynamic> jobDetails;
  // final String? listingId;

  @override
  State<MyJobsDetails> createState() => _MyJobsDetailsState();
}

class _MyJobsDetailsState extends State<MyJobsDetails> {
  CarouselController carouselController = CarouselController();
  late final String jobId;
  // late final String? listingId;

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
  late UserBloc userBloc;
  List<ChatConversation> searchedChatConnection = [];

  ScrollController? _scrollController;

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

      var result = await ServiceHubAuthService().retreiveJob(jobId: jobId);
      log('tor bad......${result?.toJson()}');

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
          job = tempList;
        });
        getSearchedChatConnections();
      }
    }
  }

  void deleteJob() async {
    bool done = await ServiceHubAuthService().deleteMyJob(jobId);
    if (done) {
      showSnackbar(context, message: 'Job Deleted Successfully');
      Navigator.pushReplacementNamed(context, Routes.MY_JOBS);
    } else {
      showSnackbar(context,
          message: 'Job Cannot be deleted this time. Try again later');
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    jobId = widget.jobDetails['jobId'];
    _scrollController = ScrollController();
    getMyJob();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context, listen: false);
    return Scaffold(
      appBar: appBar(),
      body: Stack(children: [
        SingleChildScrollView(
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
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
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
                  : const SizedBox.shrink(),
              Visibility(
                visible: !isLoading && job == null,
                child: Center(
                  child: Column(
                    children: [
                      Lottie.asset('assets/lottie/no_moment_lottie.json'),
                      const SizedBox(height: 20),
                      const Text('No items at the moment'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 1,
          right: 1,
          left: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
            child: getSubmitData(),
          ),
        )
      ]),
    );
  }

  Future<void> cancelApplicant() async {
    await showDialogBox(
      context: context,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: mateRed.withOpacity(0.08),
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
      title: "Cancel",
      description: "Are you sure you want to cancel your application ?",
      actionOneText: 'Keep',
      actionTwoText: AppLocalization.of(context)!.cancel,
      leftButtonOnPressed: () => Navigator.pop(context),
      rightButtonOnPressed: () {
        FocusScope.of(context).unfocus();
        isAPILoading = true;
        if (mounted) setState(() {});
        cancelApplication();

        isAPILoading = false;
        if (mounted) setState(() {});
      },
    );
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
                              "${job!.location}".toCapitalized(),
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
                  getJobActivityStatusRow(),
                  getJobActivity(job!.status!),
                  getJobOnlineRow(),
                  job?.status?.toLowerCase() == 'in-progress' ||
                          job?.status?.toLowerCase() == 'closed'
                      ? getPaymentStatusRow()
                      : const SizedBox.shrink(),
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
                              // Text(
                              //   "${job!.ownerName}",
                              //   style: TextStyle(
                              //     color: blackFont,
                              //     fontSize: 14,
                              //     fontFamily: "Open Sans",
                              //     fontWeight: FontWeight.w600,
                              //   ),
                              // ),
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
                ],
              )
            ],
          );
  }

  Color colorStatus(String status) {
    if (status.toLowerCase() == 'open') {
      return const Color(0xff3F61DB);
    }
    if (status.toLowerCase() == 'in-progress') {
      return Colors.yellow.shade700;
    }
    if (status.toLowerCase() == 'closed') {
      return Colors.green.shade400;
    }
    if (status.toLowerCase() == 'canceled') {
      return Colors.red.shade400;
    }
    if (status.toLowerCase() == 'draft') {
      return Colors.blueGrey;
    }
    return const Color(0xff3F61DB);
  }

  String textStatus(String status) {
    if (status.toLowerCase() == 'open') {
      return 'Open';
    }
    if (status.toLowerCase() == 'in-progress') {
      return 'In-Progress';
    }
    if (status.toLowerCase() == 'closed') {
      return 'Completed';
    }
    if (status.toLowerCase() == 'canceled') {
      return 'Canceled';
    }
    if (status.toLowerCase() == 'draft') {
      return 'Draft';
    }
    return 'Active';
  }

  Color colorPayStatus(String status) {
    if (status.toLowerCase() == 'in-progress') {
      return Colors.yellow.shade400;
    }
    return const Color(0xff3F61DB);
  }

  String textPayStatus(String status) {
    if (status.toLowerCase() == 'in-progress') {
      return 'Pending';
    }
    return 'Paid';
  }

  getPaymentStatusRow() {
    return Column(
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CustomText(
                title: 'Payment',
                fontSize: 14,
                fontweight: FontWeight.w700,
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorPayStatus(job!.status!)),
                  color: colorPayStatus(job!.status!).withOpacity(0.1),
                ),
                child: Text(
                  textPayStatus(job!.status!),
                  style: TextStyle(
                    color: colorStatus(job!.status!),
                    fontSize: 10.80,
                    fontFamily: "Open Sans",
                    fontWeight: FontWeight.w600,
                  ),
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
                // width: 54,
                // height: 20,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorStatus(job!.status!)),
                  color: colorStatus(job!.status!).withOpacity(0.1),
                ),
                child: Text(
                  textStatus(job!.status!),
                  style: TextStyle(
                    color: colorStatus(job!.status!),
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

  Widget getJobActivity(String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
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
          CustomText(
              title: "Applied : ${job!.applicantsCount}",
              fontSize: 12,
              fontweight: FontWeight.w600),
        ],
      ),
    );
  }

  Column getDateColumn(String title, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          title: title,
          fontSize: 12,
          fontweight: FontWeight.w700,
        ),
        Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xfffafbff),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 18,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                DateFormat('dd-MM-yyyy').format(DateTime.parse(date)),
                style: const TextStyle(
                  color: Color(0xff030e36),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
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
              const SizedBox(
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
                    const Text(
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
                        "recipientUserName": job!.ownerName!.toLowerCase(),
                      });
                    },
                    child: SvgPicture.asset(
                      'yarn/chaticon'.toSVG(),
                      height: 35,
                      width: 35,
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
                      height: 35,
                      width: 35,
                    ),
                  ),
      ],
    );
  }

  Widget getSubmitData() {
    if (job != null) {
      if (userBloc.user.userName == job!.owner) {
        if (job!.isListed == true) {
          return getUnListNowBtn();
        } else {
          return getListNowBtn();
        }
      } else {
        if (job!.isListed == true) {
          if (job!.applicants!.contains(userBloc.user.userName)) {
            if (job!.assignee == userBloc.user.userName) {
              return Container();
            }
            return cancelApplicationNowBtn();
          }
          return getApplyNowBtn();
        } else {
          return Container();
        }
      }
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
              removeJobFromActiveListing();

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
              FocusScope.of(context).unfocus();
              isAPILoading = true;
              if (mounted) setState(() {});
              applyForJob();

              isAPILoading = false;
              if (mounted) setState(() {});
            },
      backgroundColor: Colors.black,
      textColor: Colors.white,
      text: 'Apply',
      isLoading: isAPILoading,
      borderRadius: 20,
    );
  }

  cancelApplicationNowBtn() {
    return CurvedButton(
      onPressed: isAPILoading
          ? () {}
          : () async {
              cancelApplicant();
            },
      backgroundColor: Colors.black,
      textColor: Colors.white,
      text: 'Cancel Application',
      isLoading: isAPILoading,
      borderRadius: 20,
    );
  }

  createJobListing() async {
    await ServiceHubAuthService().createListing({
      "job": job!.id,
    }).then((value) {
      print('${value}Create Listing');
      Navigator.pushNamed(context, Routes.SUPER_HUB);
      showToast(message: AppLocalization.of(context)!.jobAddedSuccessfully);
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }

  removeJobFromActiveListing() async {
    await ServiceHubAuthService()
        .removeJobListing(job!.activeListing)
        .then((value) {
      Navigator.pushNamed(context, Routes.SUPER_HUB);
      showToast(message: AppLocalization.of(context)!.jobRemovedFromListing);
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }

  applyForJob() async {
    await ServiceHubAuthService().applyForJob(
        {"applicant": "${userBloc.user.userName}"},
        jobId: job!.id).then((value) {
      Navigator.pushNamed(context, Routes.SUPER_HUB);
      showToast(
          message: AppLocalization.of(context)!.appliedForJobSuccessfully);
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }

  cancelApplication() async {
    await ServiceHubAuthService().cancelApplicationForJob(
        {"applicant": "${userBloc.user.userName}"},
        jobId: job!.id).then((value) {
      Navigator.pushNamed(context, Routes.SUPER_HUB);
      showToast(
          message: AppLocalization.of(context)!
              .cancelledApplicactionForJobSuccessfully);
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
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _moreOptionsBtn() {
    return Container(
        width: 34,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          color: Color(0xfffafbff),
        ),
        child: IconButton(
          onPressed: () {
            androidBottomSheet(
              context: context,
              child: StatefulBuilder(
                builder: (context, changeState) {
                  return SizedBox(
                    height: getDropDownWidget().length < 4 ? 100 : 240,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Scrollbar(
                          thumbVisibility: true,
                          controller: _scrollController,
                          child: ListView.builder(
                              controller: _scrollController,
                              itemCount: getDropDownWidget().length,
                              itemBuilder: (context, index) {
                                return getDropDownWidget()[index];
                              }),
                        )),
                  );
                },
              ),
            );
          },
          icon: Icon(
            Icons.more_vert,
            color: blackFont,
          ),
        ));
  }

  List<Widget> getDropDownWidget() {
    var menu = [
      InkWell(
        onTap: () =>
            Navigator.pushNamed(context, Routes.EDIT_JOB, arguments: job),
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
                child: SvgPicture.asset("assets/images/edit_job.svg")),
            const SizedBox(
              width: 20,
            ),
            Text(
              'Edit Job',
              style: TextStyle(
                  fontSize: 16, color: black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      const SizedBox(
        height: 12,
      ),
      InkWell(
        onTap: () => sendItemToUsersInChat(),
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
                child: SvgPicture.asset("assets/images/share.svg")),
            const SizedBox(
              width: 20,
            ),
            Text(
              'Share in Chat',
              style: TextStyle(
                  fontSize: 16, color: black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      const SizedBox(
        height: 12,
      ),
      InkWell(
        onTap: () => shareAsYarn(),
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
                child: SvgPicture.asset("assets/images/share.svg")),
            const SizedBox(
              width: 20,
            ),
            Text(
              'Share in Yarn',
              style: TextStyle(
                  fontSize: 16, color: black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      const SizedBox(
        height: 12,
      ),
      InkWell(
        onTap: () => deleteJob(),
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
                child: SvgPicture.asset("assets/images/delete.svg")),
            const SizedBox(
              width: 20,
            ),
            Text(
              'Delete',
              style: TextStyle(
                  fontSize: 16, color: black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ];

    if (job!.owner != userBloc.user.userName) {
      return [
        InkWell(
          onTap: () => sendItemToUsersInChat(),
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
                  child: SvgPicture.asset("assets/images/share.svg")),
              const SizedBox(
                width: 20,
              ),
              Text(
                'Share in Chat',
                style: TextStyle(
                    fontSize: 16, color: black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        InkWell(
          onTap: () {
            Navigator.pop(context);
            NavigationUtil.push(context,
                screen: AddReportScreen(
                  object: job!.toJson(),
                  type: "job",
                  isJobService: true,
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
                    fontSize: 16, color: black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ];
    }
    if (job!.isListed!) {
      menu.add(
        Column(
          children: [
            const SizedBox(
              height: 12,
            ),
            InkWell(
              onTap: () => Navigator.pushNamed(
                  context, Routes.JOBS_APPLICANT_LIST,
                  arguments: job),
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
                        Icons.person,
                        color: blackFont,
                      )),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Applicant',
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
      );
    }
    return menu;
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
                  "job": job?.toJson().cast<String, dynamic>() ?? {}
                };
              bool data = await YarnAuth().addYarnAndQuestion(params, '');
              if (data) {
                showToast(message: "Shared in Yarn successfully");
                Navigator.pop(context);
              }
            }));
  }

  void sendItemToUsersInChat() async {
    List<ChatConversation?> listOfRecipient =
        await ShareInChat().selectShareCustomer(context);
    debugPrint("Selected users = ${listOfRecipient.length}");

    String url =
        "${AppConfig.baseUrl}/api/v1/job-service/${job is JobModel ? "job" : "services"}/${job!.id!}/";

    Map<String, dynamic>? itemData =
        await ServiceHubAuthService().getJobOrService(url);

    listOfRecipient.forEach((recipient) {
      addJobToChat(
          item: job, itemData: itemData, recipientUser: recipient!, url: url);
    });
  }

  void addJobToChat(
      {Map<String, dynamic>? itemData,
      required ChatConversation recipientUser,
      String? url,
      dynamic item}) async {
    Map<String, dynamic> data = {
      "meta_data": jsonEncode(itemData),
      "check_id": const Uuid().v4(),
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
                          margin: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 2.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentIndex == index
                                  ? navyBlue
                                  : const Color(0xffBEC2F4)),
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
          autoPlayInterval: const Duration(seconds: 3),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
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
        color: const Color(0xff030e36),
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
