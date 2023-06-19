import 'dart:convert';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/environment.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/share_in_chat/ShareInChat.dart';
import 'package:Slydo/screens/more_apps/service_hub/auth/service_hub_auth.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/jobs.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/retrieve_job_model.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';
// import 'package:flutter/src/foundation/key.dart';
// import 'package:flutter/src/widgets/container.dart';
// import 'package:flutter/src/widgets/framework.dart';

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

  void getMyJob() async {
    if (!isLoading) {
      // if (listNext != null && !isLoading) {
      isLoading = true;
      if (mounted) setState(() {});

      var result =
          await ServiceHubAuthService().retreiveListedJob(listingId: listingId);

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
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    jobId = widget.jobDetails['jobId'];
    listingId = widget.jobDetails['listingId'];
    getMyJob();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Scaffold(
      appBar: appBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            getJobDetails(),
            isLoading
                ? Shimmer.fromColors(
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

  Widget getJobDetails() {
    return isLoading || job == null
        ? SizedBox.shrink()
        : Column(
            children: [
              if (job!.pictures!.length > 0) customImageSlider(),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getTitleRow(),
                    SizedBox(
                      height: 30,
                    ),
                    Divider(),
                    SizedBox(
                      height: 10,
                    ),
                    CustomText(
                      title: "Job Description",
                      fontSize: 12,
                      fontweight: FontWeight.w700,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "${job!.description}",
                      style: TextStyle(
                        color: Color(0xff8d92a3),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Divider(),
                    SizedBox(
                      height: 10,
                    ),
                    getStartandEndDate(),
                    SizedBox(
                      height: 20,
                    ),
                    CustomText(
                      title: "Location",
                      fontSize: 12,
                      fontweight: FontWeight.w700,
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      "${job!.location}",
                      style: TextStyle(
                        color: Color(0xff75818f),
                        fontSize: 14,
                        fontFamily: "Open Sans",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    if (job!.isListed!) getJobActivityStatusRow(),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(),
                    SizedBox(
                      height: 20,
                    ),
                    CustomText(
                      title: "Posted By",
                      fontSize: 12,
                      fontweight: FontWeight.w700,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          child: CachedNetworkImage(
                            imageUrl: "${job!.ownerAvatar}",
                            fit: BoxFit.fitWidth,
                            width: double.infinity,
                            errorWidget: productAndServiceBigErrorWidget,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "${job!.ownerName}",
                          style: TextStyle(
                            color: Color(0xff75818f),
                            fontSize: 14,
                            fontFamily: "Open Sans",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 55,
                    ),
                    getSubmitData(),
                    // getMutliSelectDropdown()
                  ],
                ),
              )
            ],
          );
  }

  Row getJobActivityStatusRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                title: 'Job Activity',
                fontSize: 12,
                fontweight: FontWeight.w700,
              ),
              SizedBox(
                height: 10,
              ),
              CustomText(
                  title: "Applied : ${job!.applicantsCount}",
                  fontSize: 12,
                  fontweight: FontWeight.w600),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                title: 'Job Status',
                fontSize: 12,
                fontweight: FontWeight.w700,
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: 54,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.60),
                  color: Color(0xff46ce7c).withOpacity(0.2),
                ),
                child: Text(
                  "Active",
                  style: TextStyle(
                    color: Color(0xff46ce7c),
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

  Row getStartandEndDate() {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: getDateColumn("Start Date", job!.creationDate!),
        ),
        Expanded(
          flex: 3,
          child: getDateColumn("End Date", job!.dueDate!),
        ),
      ],
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
          // width: 122,
          height: 34,
          padding: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color(0xfffafbff),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 18,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                "${DateFormat('dd-MM-yyyy').format(DateTime.parse(date))}",
                style: TextStyle(
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
        Image.asset(
          'assets/images/qr_code.png',
          height: 40,
          width: 40,
        ),
      ],
    );
  }

  Widget getSubmitData() {
    if (job!.isListed == true && userBloc.user.userName == job!.owner) {
      return getUnlistNowBtn();
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

    // return CurvedButton(
    //   onPressed: isAPILoading
    //       ? () {}
    //       : () async {
    //           FocusScope.of(context).unfocus();
    //           isAPILoading = true;
    //           if (mounted) setState(() {});
    //           createJobListing();
    //           // await addProduct();
    //           // Navigator.pushNamed(context, Routes.SUPER_HUB);

    //           isAPILoading = false;
    //           if (mounted) setState(() {});
    //         },
    //   backgroundColor: navyBlue,
    //   textColor: Colors.white,
    //   text: job!.isListed! ? 'Unlist Now' : "List Now",
    //   isLoading: isAPILoading,
    // );
  }

  // {{baseUrl}}/api/v1/job-service/listing/<listingId>
  // {{baseUrl}}/api/v1/job-service/listing/7991471c-3b7a-43e1-8d48-4d808f9abf89
  // {
  //   'job': '0515f72f-0eaf-4054-820d-7dced47fd486'
  // }
  // {
  //   'job': <jobId>
  // }

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

  getUnlistNowBtn() {
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
              FocusScope.of(context).unfocus();
              isAPILoading = true;
              if (mounted) setState(() {});
              applyForJob();

              isAPILoading = false;
              if (mounted) setState(() {});
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
        // Image.asset(
        //   'assets/images/qr_code.png',
        //   height: 20,
        //   width: 20,
        // ),
        // SizedBox(
        //   width: 10,
        // ),
        _moreOptionsBtn(),
        SizedBox(width: 12),
      ],
    );
  }

  PopupMenuButton<String> _moreOptionsBtn() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        // selected = v;
        if (value == 'Share in Chat') {
          sendItemToUsersInChat();
        }

        setState(() {});
      },
      icon: Container(
        height: 34,
        width: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          color: Color(0xfffafbff),
        ),
        child: Icon(
          Icons.more_vert,
          color: blackFont,
        ),
      ),
      itemBuilder: (BuildContext context) {
        return [
          getShareInChatBtn(),
          getReportBtn(),
        ];
      },
    );
  }

  PopupMenuItem<String> getEditBtn() {
    return PopupMenuItem<String>(
      // value: choice.title,
      child: ListTile(
        leading: Container(
            height: 34,
            width: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              color: Color(0xfffafbff),
            ),
            child: SvgPicture.asset("assets/images/edit_job.svg")),
        title: Text('Edit Job'),
      ),
      // onTap: () {},
    );
  }

  PopupMenuItem<String> getCopyLink() {
    return PopupMenuItem<String>(
      // value: choice.title,
      child: ListTile(
        leading: Container(
            height: 34,
            width: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              color: Color(0xfffafbff),
            ),
            child: SvgPicture.asset("assets/images/send.svg")),
        title: Text('Send Via'),
      ),
      // onTap: () {},
    );
  }

  PopupMenuItem<String> getDeleteBtn() {
    return PopupMenuItem<String>(
      // value: choice.title,
      child: ListTile(
        leading: Container(
            height: 34,
            width: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              color: Color(0xfffafbff),
            ),
            child: SvgPicture.asset("assets/images/delete.svg")),
        title: Text('Delete'),
      ),
      onTap: () {},
    );
  }

  PopupMenuItem<String> getShareInChatBtn() {
    return PopupMenuItem<String>(
      value: 'Share in Chat',
      child: ListTile(
        leading: Container(
            height: 34,
            width: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              color: Color(0xfffafbff),
            ),
            child: SvgPicture.asset("assets/images/share.svg")),
        title: Text('Share in Chat'),
      ),
      onTap: () {},
    );
  }

  PopupMenuItem<String> getReviewApplicantBtn() {
    return PopupMenuItem<String>(
      value: 'Review Applicant',
      child: ListTile(
        leading: Container(
            height: 34,
            width: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              color: Color(0xfffafbff),
            ),
            child: Icon(
              Icons.visibility,
              color: blackFont,
            )),
        title: Text('Review Applicant'),
      ),
      onTap: () {},
    );
  }

  PopupMenuItem<String> getReportBtn() {
    return PopupMenuItem<String>(
      value: 'Report',
      child: ListTile(
        leading: Container(
            height: 34,
            width: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              color: Color(0xfffafbff),
            ),
            child: Icon(
              Icons.report,
              color: blackFont,
            )),
        title: Text('Report'),
      ),
      // onTap: () {
      //   print('applicant');
      //   Navigator.pushNamed(context, Routes.JOBS_SEARCH);
      // },
    );
  }

  void sendItemToUsersInChat() async {
    List<ChatConversation?> listOfRecipient =
        await ShareInChat().selectShareCustomer(context);
    debugPrint("Selected users = ${listOfRecipient.length}");

    String url = AppConfig.baseUrl +
        "/api/v1/${job is JobModel ? "job" : "services"}/" +
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
      "author": userBloc?.user.userName,
      "message": url,
      "kind": item is JobModel ? "product" : "service",
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
          enableInfiniteScroll: true,
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
