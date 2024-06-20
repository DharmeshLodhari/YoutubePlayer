import 'package:Slydo/data/currency.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/order_detail_item_tile_new.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/order_status_list.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_shimmer.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailPageNew extends StatefulWidget {
  final dynamic arguments;
  const OrderDetailPageNew({super.key, required this.arguments});

  @override
  State<OrderDetailPageNew> createState() => _OrderDetailPageNewState();
}

class _OrderDetailPageNewState extends State<OrderDetailPageNew> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Order? order;
  bool isLoading = true;
  final _auth = ShoppingAuthService();
  List<Map<String, dynamic>> items = [];
  TextEditingController userNoteController = TextEditingController();

  @override
  void initState() {
    order = widget.arguments['order'];
    fetchOrder(order?.id.toString() ?? "");
    userNoteController.text = order?.note ?? "";
    // getAddressList();
    // statusOfOrder = order?.status?.toLowerCase();
    // statusOfOrderCopy = order?.status?.toLowerCase();
    // // _slideController = SlidableController(
    // //   onSlideAnimationChanged: handleSlideAnimationChanged,
    // //   onSlideIsOpenChanged: handleSlideIsOpenChanged,
    // // );
    // fetchOrder(order?.id.toString() ?? "");
    // if (order?.journeyId != null) {
    //   fetchJobData();
    // }
    super.initState();
  }

  void fetchOrder(String orderId) async {
    setState(() {
      isLoading = true;
    });
    _auth.getOrder(orderId).then((value) {
      if (value != null) {
        debugPrint('VALUE :: $value');
        if (mounted) {
          setState(() {
            order = value;
            items = order?.items ?? [];
            isLoading = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: lightGrey,
        appBar: appBar() as PreferredSizeWidget?,
        body: SingleChildScrollView(
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
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
      centerTitle: false,
      title: Text(
        "Ref # :${order?.id ?? ""}",
        style: TextStyle(
          color: blackFont,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: "Inter",
        ),
      ),
    );
  }

  Widget _buildBody() {
    return isLoading
        ? const YarnShimmer()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderStatus(),
              Divider(
                color: greySecondaryYarn,
              ),
              _buildAllDetails(),
            ],
          );
  }

  Widget _buildAllDetails() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      // padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildCustomerName(),
              getItemTileUi(index),
            ]),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              color: greySecondaryYarn,
              thickness: 5,
            ),
          ),
          checkoutWidget(),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              color: greySecondaryYarn,
              thickness: 5,
            ),
          ),
          _buildNoteAndOrderDetails(),
        ],
      ),
    );
  }

  Widget _buildCustomerName() {
    return Text(
      order?.customerName ?? "",
      style: TextStyle(
        color: darkGrey,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: "Inter",
      ),
    );
  }

  StatefulWidget getItemTileUi(int index) {
    if (items[index]["type"] == "product") {
      return OrderTileForProductNew(
        item: items[index],
      );
    }
    return OrderTileForService(
      items[index],
    );
  }

  Widget _buildOrderStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Text(
        "Status : ${order?.status}",
        style: TextStyle(
          color: blackFont,
          fontSize: 16,
          fontFamily: "Inter",
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget checkoutWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                AppLocalization.of(context)!.subTotal,
                style: TextStyle(
                  fontSize: 14,
                  color: black,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Inter",
                ),
              ),
              Row(
                children: [
                  Text(
                    worldCurrencies[order?.currency!]!,
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: black,
                    ),
                  ),
                  Text(
                    moneyDisplayNormalizer(order?.totalPrice),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: black,
                      fontFamily: "Inter",
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                AppLocalization.of(context)!.shipping,
                style: TextStyle(
                  fontSize: 14,
                  color: black,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Inter",
                ),
              ),
              Row(
                children: [
                  Text(
                    worldCurrencies[order?.currency!]!,
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: black,
                    ),
                  ),
                  Text(
                    moneyDisplayNormalizer(0),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: black,
                      fontFamily: "Inter",
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                AppLocalization.of(context)!.tax,
                style: TextStyle(
                  fontSize: 14,
                  color: black,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Inter",
                ),
              ),
              Row(
                children: [
                  Text(
                    worldCurrencies[order?.currency!]!,
                    style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: black),
                  ),
                  Text(
                    moneyDisplayNormalizer(0),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: black,
                      fontFamily: "Inter",
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                AppLocalization.of(context)!.total,
                style: TextStyle(
                  fontSize: 14,
                  color: black,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Inter",
                ),
              ),
              Row(
                children: [
                  Text(
                    worldCurrencies[order?.currency!]!,
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: navyBlue,
                    ),
                  ),
                  Text(
                    moneyDisplayNormalizer(order?.totalPrice),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: navyBlue,
                      fontFamily: "Inter",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoteAndOrderDetails() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotes(),
            const SizedBox(
              height: 15,
            ),
            _buildOrderDetails(),
            const SizedBox(
              height: 15,
            ),
            _buildButtons(),
          ],
        ));
  }

  Widget _buildNotes() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalization.of(context)!.note,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: blackFont,
                fontFamily: "Inter",
              ),
            ),
            const Icon(
              SlydoAppIcon.edit,
              size: 14,
            ),
          ],
        ),
        const SizedBox(height: 5),
        _buildNoteTextField(),
      ],
    );
  }

  Widget _buildNoteTextField() {
    return TextField(
      controller: userNoteController,
      maxLines: 3,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: greyBorderColor, // Border color
            width: 1.0,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: greyBorderColor, // Border color
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: navyBlue, // Change the focus color here
            width: 1.0,
          ),
        ),
        filled: true,
        fillColor: white,
        // Background color
      ),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: darkGrey,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildOrderDetails() {
    final DateFormat dateFormat = DateFormat("MMMM dd, yyyy");
    final DateTime dateTime = DateTime.parse(order?.date.toString() ?? "");
    final String date = dateFormat.format(dateTime);
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: greyBorderColor,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalization.of(context)!.orderDetail,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: blackFont,
              fontFamily: "Inter",
            ),
          ),
          const SizedBox(height: 10.0),
          OrderDetailRow(
            title: 'Order No',
            detail: '#1782903',
          ),
          const SizedBox(
            height: 3,
          ),
          OrderDetailRow(
            title: 'Order placed on',
            detail: date,
          ),
          const SizedBox(
            height: 3,
          ),
          OrderDetailRow(
            title: 'Payment Method',
            detail: order?.paymentType ?? "",
          ),
          const SizedBox(
            height: 3,
          ),
          OrderDetailRow(
            title: 'Address',
            detail: 'No 5, Adetutu street, ikeja, lagos, Nigeria, 100001',
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildTrackOrder(),
          const SizedBox(
            width: 25,
          ),
          _buildWriteReview(),
        ],
      ),
    );
  }

  Widget _buildUpdateStatus() {
    return Expanded(
      child: MaterialButton(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        color: navyBlue,
        onPressed: () {
          showBottomSheetDialog(order?.id);
        },
        disabledColor: darkGrey.withOpacity(0.5),
        child: Text(
          "Update Status",
          style: TextStyle(
            color: white,
            fontSize: 14,
            fontFamily: "Inter",
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildWriteReview() {
    return Expanded(
      child: MaterialButton(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        color: navyBlue,
        onPressed: () async {
          await Navigator.pushNamed(context, Routes.WRITE_REVIEW_PAGE,
              arguments: {"order": order});
        },
        disabledColor: darkGrey.withOpacity(0.5),
        child: Text(
          "Write a review",
          style: TextStyle(
            color: white,
            fontSize: 14,
            fontFamily: "Inter",
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTrackOrder() {
    return Expanded(
      child: MaterialButton(
        shape: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
            borderSide: BorderSide(color: navyBlue)),
        color: white,
        onPressed: () async {
          await Navigator.pushNamed(context, Routes.TRACK_ORDER,
              arguments: {"order": order});
        },
        child: Text(
          "Track Order",
          style: TextStyle(
            color: navyBlue,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
        ),
      ),
    );
  }

  void showBottomSheetDialog(String? orderId) async {
    await androidBottomSheet(
      enableDrag: true,
      context: context,
      child: OrderStatusList(orderId: orderId ?? ""),
    );
  }
}

class OrderDetailRow extends StatelessWidget {
  final String title;
  final String detail;

  const OrderDetailRow({super.key, required this.title, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              '$title : ',
              style: TextStyle(
                fontSize: 14,
                color: blackFont,
                fontWeight: FontWeight.w500,
                fontFamily: "Inter",
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              detail,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: darkGrey,
                fontFamily: "Inter",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
