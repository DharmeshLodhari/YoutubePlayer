import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../models/active_job_listing.dart';

class JobsJobDetail extends StatefulWidget {
  const JobsJobDetail({super.key, required this.activeListingData});
  final ActiveListingData activeListingData;

  @override
  State<JobsJobDetail> createState() => _JobsJobDetailState();
}

class _JobsJobDetailState extends State<JobsJobDetail> {
  CarouselController controller = CarouselController();
  int currentIndex = 0;
  String getFormatedDate(ActiveListingData args) {
    return DateFormat('dd-MM-yyyy')
        .format(DateTime.parse(args.job!.creationDate!));
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
    return 'Active';
  }

  @override
  Widget build(BuildContext context) {
    // final args =
    //     ModalRoute.of(context)!.settings.arguments as ActiveListingData;
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: appBar(),
      // bottomSheet: ,
      body: Column(
        children: [
          if (widget.activeListingData.job!.pictures!.isNotEmpty)
            customImageSlider(widget.activeListingData),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: detailsRow(widget.activeListingData),
          ),
          const SizedBox(
            height: 20,
          ),
          acceptBtn()
        ],
      ),
    );
  }

  Row detailsRow(ActiveListingData args) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      // mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              Column(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: CustomText(title: 'Category'),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(flex: 2, child: CustomText(title: 'Date')),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          "${args.job!.category!.name}",
                          style: const TextStyle(
                            color: Color(0xff75818f),
                            fontSize: 14,
                            fontFamily: "Inter",
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          // width: 122,
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
                                getFormatedDate(args),
                                style: const TextStyle(
                                  color: Color(0xff030e36),
                                  fontSize: 14,
                                  fontFamily: "Inter",
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Column(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Expanded(flex: 3, child: CustomText(title: 'Fee')),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(flex: 2, child: CustomText(title: 'Location')),
                    ],
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          "#${args.job!.pay}",
                          style: const TextStyle(
                            color: Color(0xff3e61da),
                            fontSize: 14,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          messageDecoderWithEmoji(args.job?.state) ?? "",
                          style: const TextStyle(
                            color: Color(0xff75818f),
                            fontSize: 14,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Column(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Expanded(flex: 3, child: CustomText(title: 'posted by')),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(flex: 2, child: CustomText(title: 'Status')),
                    ],
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: Text(
                          "${args.job!.ownerName}",
                          style: const TextStyle(
                            color: Color(0xff75818f),
                            fontSize: 14,
                            fontFamily: "Inter",
                          ),
                        ),
                      ),
                      Container(
                        width: 54,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3.60),
                          color: colorStatus(args.job!.status!),
                        ),
                        child: Text(
                          textStatus(args.job!.status!),
                          style: TextStyle(
                            color: colorStatus(args.job!.status!),
                            fontSize: 10.80,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Expanded(
                        flex: 3,
                        child: SizedBox(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(title: 'Applied by'),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    "200+",
                    style: TextStyle(
                      color: Color(0xff75818f),
                      fontSize: 14,
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(title: 'Description'),
                  const SizedBox(
                    height: 6,
                  ),
                  Text(
                    "${args.job!.description}",
                    style: const TextStyle(
                      color: Color(0xff8d92a3),
                      fontSize: 14,
                      fontFamily: "Inter",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0x143e61da),
          ),
          child: SvgPicture.asset(
            'assets/images/message.svg',
            height: 17,
            width: 17,
            fit: BoxFit.none,
          ),
        )
      ],
    );
  }

  CarouselSlider customImageSlider(ActiveListingData args) {
    return CarouselSlider.builder(
      carouselController: controller,
      itemCount: args.job!.pictures!.length,
      itemBuilder: (context, index, realIndex) {
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(),
              child: CachedNetworkImage(
                imageUrl: "${args.job!.pictures![index].image}",
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    const Center(child: Icon(Icons.error)),
              ),
            ),
            Positioned(
              bottom: 10,
              left: MediaQuery.of(context).size.width * 0.45,
              child: Row(
                children: List.generate(
                    4,
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
          // autoPlay: true,
          autoPlayInterval: const Duration(seconds: 3),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: true,
          scrollDirection: Axis.horizontal,
          onPageChanged: onPageFunction),
    );
  }

  Container acceptBtn() {
    return Container(
      width: 223,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xff3e61da),
      ),
      child: const Text(
        "Accept",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: "Inter",
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void onPageFunction(index, reason) {
    currentIndex = index;
    setState(() {});
  }

  AppBar appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
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
          fontFamily: "Inter",
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Image.asset(
          'assets/images/qr_code.png',
          height: 20,
          width: 20,
        ),
        const SizedBox(
          width: 10,
        ),
        _moreOptionBtn(),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _moreOptionBtn() {
    return IconButton(
      icon: Icon(
        Icons.more_vert,
        size: 20,
        color: blackFont,
      ),
      onPressed: () {
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xfffafbff),
                        ),
                        child: SvgPicture.asset(
                          'assets/images/copy_links.svg',
                          height: 20,
                          width: 20,
                          fit: BoxFit.none,
                        )),
                    title: const Text(
                      "Copy link",
                      style: TextStyle(
                        color: Color(0xff030e36),
                        fontSize: 16,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xfffafbff),
                      ),
                      child: const Icon(
                        Icons.share,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      "Send Via",
                      style: TextStyle(
                        color: Color(0xff030e36),
                        fontSize: 16,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xfffafbff),
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      "Share in chat",
                      style: TextStyle(
                        color: Color(0xff030e36),
                        fontSize: 16,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            });
      },
    );
  }
}

class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xff030e36),
        fontSize: 12,
        fontFamily: "Inter",
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
