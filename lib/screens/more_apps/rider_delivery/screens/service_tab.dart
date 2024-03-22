import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ServiceTab extends StatefulWidget {
  ServiceTab({
    Key? key,
    this.onPageRefresh,
  }) : super(key: key);

  Function(bool)? onPageRefresh;

  @override
  State<ServiceTab> createState() => ServiceTabState();
}

class ServiceTabState extends State<ServiceTab> {
  final GlobalKey<ScaffoldMessengerState> _serviceScaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  ScrollController _serviceScrollController = new ScrollController();

  String? TodayDate;
  String? Amount = "3000";
  int? km = 2;
  int? items = 5;
  int? kg = 38;

  void myDate() {
    var now = DateTime.now();
    var formatter = DateFormat('d MMMM,y');
    String formattedDate = formatter.format(now);
    TodayDate = formattedDate;
  }

  @override
  void initState() {
    myDate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _serviceScaffoldMessengerKey,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: _buildService(),
          ),
        ),
      ),
    );
  }

  Widget _buildService() {
    return SingleChildScrollView(
      controller: _serviceScrollController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              "Delivery request around you",
              style: TextStyle(
                color: blackFont,
                fontSize: 14,
                fontFamily: "Inter",
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 5.0),
          _buildServiceList(),
        ],
      ),
    );
  }

  Widget _buildServiceList() {
    return ListView.builder(
      itemCount: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: greyBorderColor,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateAndWaitingButton(),
                    _buildLogoAndDeliveryAndAmount(),
                    _buildItemsAndKg(),
                    SizedBox(height: 10.0),
                    _buildIconAndAddressAndPickup(),
                    SizedBox(height: 10.0),
                    _buildButtonCancelAndPickup(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.0),
          ],
        );
      },
    );
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        _refreshPage();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }

  _refreshPage() {}

  Widget _buildDateAndWaitingButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildDate()),
        _buildWaitingButton(),
      ],
    );
  }

  Widget _buildDate() {
    return Text(
      TodayDate.toString(),
      style: TextStyle(
        fontWeight: FontWeight.w700,
        color: darkGrey,
        fontSize: 12,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildWaitingButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: lightGreyYarn,
      ),
      child: Text(
        'Awaiting Pickup',
        style: TextStyle(
          color: darkGrey,
          fontSize: 8,
          fontWeight: FontWeight.w600,
          fontFamily: "Inter",
        ),
      ),
    );
  }

  Widget _buildLogoAndDeliveryAndAmount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildLogo(),
            _buildVerticalDivider(),
            _buildDelivery(),
          ],
        ),
        Row(
          children: [
            _buildEst(),
            _buildAmount(),
          ],
        )
      ],
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/rider/kfc.png',
      height: 24,
      width: 24,
      fit: BoxFit.fill,
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 50,
      child: VerticalDivider(
        color: greySecondaryYarn,
        thickness: 1,
        indent: 10,
        endIndent: 10,
        width: 20,
      ),
    );
  }

  Widget _buildDelivery() {
    return Text(
      'Delivery',
      style: TextStyle(
        color: black,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildEst() {
    return Text(
      "Est ",
      style: TextStyle(
        color: darkGrey,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildAmount() {
    return Text(
      "₦${Amount}",
      style: TextStyle(
        color: yarnBlack,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildItemsAndKg() {
    return Text(
      "${items} Items (${kg}Kg)",
      style: TextStyle(
        color: black,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildIconAndAddressAndPickup() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildIconImage(),
        SizedBox(width: 7.0),
        Expanded(child: _buildMainAddressColumn())
      ],
    );
  }

  Widget _buildIconImage() {
    return SvgPicture.asset(
      'assets/images/rider/ic_route.svg',
      height: 65,
    );
  }

  Widget _buildMainAddressColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KFC, O&O Filling station berger expressway',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: darkGrey,
            fontSize: 12,
            fontFamily: "Inter",
          ),
        ),
        Text(
            'Pickup by ${DateFormat.jm().format(DateTime.now()).toString()} (${km}Km)',
            style: TextStyle(
              color: navyBlue,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: "Inter",
            )),
        SizedBox(height: 20),
        Text(
          'Festus street ,Agege',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: darkGrey,
            fontSize: 12,
            fontFamily: "Inter",
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Deliver by ${DateFormat.jm().format(DateTime.now()).toString()} (${km}Km)',
              style: TextStyle(
                color: navyBlue,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: "Inter",
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 15.0),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: darkGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButtonCancelAndPickup() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          Expanded(
            child: CurvedButton(
              onPressed: () {},
              backgroundColor: greyBorderColor,
              textColor: yarnBlack,
              fontSize: 15,
              text: 'Cancel',
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: CurvedButton(
              onPressed: () {},
              backgroundColor: navyBlue,
              textColor: white,
              fontSize: 15,
              text: 'Pickup (in 2mins)',
            ),
          ),
        ],
      ),
    );
  }
}
