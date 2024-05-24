import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/discount/discount_model.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_products_discount.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_services_discount.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/tab_selection.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class UserProductServiceDiscount extends StatefulWidget {
  DiscountModel item;

  UserProductServiceDiscount({
    required this.item,
    Key? key,
  }) : super(key: key);

  @override
  _UserProductServiceDiscountState createState() =>
      _UserProductServiceDiscountState();
}

class _UserProductServiceDiscountState
    extends State<UserProductServiceDiscount> {
  late PageController _pageViewController;
  int currentAskTapOnHome = 0;
  final GlobalKey _key = LabeledGlobalKey("paymentRequestListPopUpMenu");

  @override
  void initState() {
    _pageViewController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, "back pressed");
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar() as PreferredSizeWidget,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      elevation: 0.5,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: blackFont,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Attach Items",
            style: TextStyle(
                color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      shadowColor: greySecondaryYarn,
      actions: [
        getSearchBtn(),
        const SizedBox(width: 10.0),
        FilterIcon(),
        const SizedBox(width: 16.0),
      ],
    );
  }

  Widget getSearchBtn() {
    return SizedBox(
      height: 34,
      width: 34,
      child: Card(
        color: iconBtnGrey,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.search,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () async {
            String filterItem;
            if (currentAskTapOnHome == 0) {
              filterItem = "Products";
            } else {
              filterItem = "Services";
            }
            final result = await Navigator.of(context).pushNamed(
                Routes.DISCOUNT_PRODUCT_AND_SERVICE_SEARCH,
                arguments: {"item": widget.item, "filter": filterItem});

            if (result != null && result is Map<String, dynamic>) {
              Navigator.pop(context, result);
            }
          },
        ),
      ),
    );
  }

  Widget FilterIcon() {
    return SizedBox(
      key: _key,
      height: 34,
      width: 34,
      child: Card(
        color: iconBtnGrey,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.filter_alt_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        const SizedBox(
          height: 16,
        ),
        _buildTabs(),
        _buildPageView(),
      ],
    );
  }

  Widget _buildTabs() {
    return Column(
      children: [
        TabSelection(
          onTap: (index) {
            currentAskTapOnHome = index;
            _pageViewController.jumpToPage(currentAskTapOnHome);

            if (mounted) setState(() {});
          },
          currentIndex: currentAskTapOnHome,
          firstTab: 'Products',
          secondTab: 'Services',
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget _buildPageView() {
    return Expanded(
      child: PageView(
        onPageChanged: (currentPage) {
          updateCurrentAskTapOnHome(index: currentPage);
        },
        controller: _pageViewController,
        children: [
          UserProductDiscount(item: widget.item),
          UserServicesDiscount(item: widget.item),
        ],
      ),
    );
  }

  void updateCurrentAskTapOnHome({required int index}) {
    setState(() {
      currentAskTapOnHome = index;
    });
  }
}
