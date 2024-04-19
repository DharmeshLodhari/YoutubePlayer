import 'package:Slydo/utils/util.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class JobsJobDetail extends StatefulWidget {
  const JobsJobDetail({Key? key}) : super(key: key);

  @override
  State<JobsJobDetail> createState() => _JobsJobDetailState();
}

class _JobsJobDetailState extends State<JobsJobDetail> {
  CarouselController controller = CarouselController();
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: appBar(),
      // bottomSheet: ,
      body: Column(
        children: [
          customImageSlider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: detailsRow(),
          ),
          const SizedBox(
            height: 20,
          ),
          acceptBtn()
        ],
      ),
    );
  }

  Row detailsRow() {
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
                  Row(
                    children: [
                      const Expanded(
                        flex: 3,
                        child: CustomText(title: 'Category'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Expanded(flex: 2, child: CustomText(title: 'Date')),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(
                        flex: 3,
                        child: Text(
                          "Photography",
                          style: TextStyle(
                            color: Color(0xff75818f),
                            fontSize: 14,
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
                              const Text(
                                "13/08/2020",
                                style: TextStyle(
                                  color: Color(0xff030e36),
                                  fontSize: 14,
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
                  Row(
                    children: [
                      const Expanded(flex: 3, child: CustomText(title: 'Fee')),
                      const SizedBox(
                        height: 10,
                      ),
                      const Expanded(
                          flex: 2, child: CustomText(title: 'Location')),
                    ],
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Row(
                    children: [
                      const Expanded(
                        flex: 3,
                        child: Text(
                          "#1,000,000",
                          style: TextStyle(
                            color: Color(0xff3e61da),
                            fontSize: 14,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Expanded(
                        flex: 2,
                        child: Text(
                          "Ikeja, Lagos",
                          style: TextStyle(
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
                  Row(
                    children: [
                      const Expanded(
                          flex: 3, child: CustomText(title: 'posted by')),
                      const SizedBox(
                        height: 10,
                      ),
                      const Expanded(
                          flex: 2, child: CustomText(title: 'Status')),
                    ],
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Row(
                    children: [
                      const Expanded(
                        flex: 8,
                        child: Text(
                          "Tolu.nimi",
                          style: TextStyle(
                            color: Color(0xff75818f),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        width: 54,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3.60),
                          color: const Color(0xff46ce7c).withOpacity(0.2),
                        ),
                        child: const Text(
                          "active",
                          style: TextStyle(
                            color: Color(0xff46ce7c),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(title: 'Applied by'),
                  const SizedBox(
                    height: 6,
                  ),
                  const Text(
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
                  const Text(
                    "I need a photographer for a 1year baby photoshoot. ",
                    style: TextStyle(
                      color: Color(0xff8d92a3),
                      fontSize: 14,
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

  CarouselSlider customImageSlider() {
    return CarouselSlider.builder(
      carouselController: controller,
      itemCount: 4,
      itemBuilder: (context, index, realIndex) {
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    "assets/images/bg1.png",
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
          autoPlay: true,
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
              return Container(
                child: Column(
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
                ),
              );
            });
      },
    );
  }
}

class CustomText extends StatelessWidget {
  const CustomText({
    Key? key,
    required this.title,
  }) : super(key: key);

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
