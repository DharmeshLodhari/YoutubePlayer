import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../tiles/jos_description_card.dart';

class JobsDashboard extends StatefulWidget {
  const JobsDashboard({Key? key});

  @override
  State<JobsDashboard> createState() => _JobsDashboardState();
}

class _JobsDashboardState extends State<JobsDashboard> {
  bool todaysDealsEmpty = false;
  bool isTodayDealLoading = false;

  List<Service> productList = [];
  bool isProductLoading = false;
  bool noProductInList = false;
  int? productCount = 0;
  String? todayDealNext = "";
  String? productNext = "";
  String? todayDealPrevious = "";
  String? productPrevious = "";
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List status = ['Active', 'Closed', 'Pending'];

  void _onRefresh() async {
    if (await checkConnection(context)) {
      _refreshPage();
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  void _refreshPage() {
    productNext = "";
    productCount = 0;
    productPrevious = "";
    isProductLoading = false;
    productList = [];

    todayDealNext = "";
    todayDealPrevious = "";
    isTodayDealLoading = false;
    //todaysDealList = [];

    // getProductList();
    //getTodaysDealProducts();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SmartRefresher(
        controller: _refreshController,
        header: WaterDropHeader(
          complete: Container(),
          waterDropColor: navyBlue,
        ),
        onRefresh: _onRefresh,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          color: lightGrey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              browseCategoryRow(),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 150,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                    itemCount: 6,
                    scrollDirection: Axis.horizontal,
                    // shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, Routes.CATEGORY_JOBS),
                          child: categoryCard(),
                        ),
                      );
                    }),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                "Jobs you might like",
                style: TextStyle(
                  color: Color(0xff030e36),
                  fontSize: 16,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Flexible(
                fit: FlexFit.loose,
                child: ListView.builder(
                    itemCount: 6,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, Routes.JOB_DETAILS),
                          child: const JobDescriptionCard(),
                        ),
                      );
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }

  Container categoryCard() {
    return Container(
      width: 150,
      height: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        // color: Color(0x7f000000),
        image: DecorationImage(
          image: const AssetImage("assets/images/bg1.png"),
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5), BlendMode.srcOver),
          fit: BoxFit.cover,
        ),
      ),
      child: Text(
        "Photography",
        style: TextStyle(
          color: white,
          fontSize: 16,
          fontFamily: "Inter",
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Row browseCategoryRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Browse Category",
            style: TextStyle(
              color: blackFont,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Row(
          children: [
            Text(
              "view more",
              style: TextStyle(
                color: navyBlue,
                fontSize: 12,
                fontFamily: "Inter",
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: navyBlue,
              size: 12,
            ),
          ],
        )
      ],
    );
  }
}
