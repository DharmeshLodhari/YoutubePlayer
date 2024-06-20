import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/order_detail_item_tile_new.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/order_status_list.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class OrderTileNew extends StatefulWidget {
  const OrderTileNew({super.key, this.order});

  final Order? order;

  @override
  State<OrderTileNew> createState() => _OrderTileNewState();
}

class _OrderTileNewState extends State<OrderTileNew> {
  late UserBloc userBloc;
  bool isLoading = true;
  final _auth = ShoppingAuthService();
  Order? order;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    fetchOrder(widget.order?.id.toString() ?? "");
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
    userBloc = Provider.of<UserBloc>(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              orderNumberAndAmount(),
              const SizedBox(
                height: 10,
              ),
              orderStatusAndDate(),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: Divider(
                  color: greySecondaryYarn,
                ),
              ),
              if (isLoading)
                _buildShimmerView()
              else
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  // padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (items[index]["qty"] == 1)
                        Text(
                          widget.order?.customerName ?? "",
                          style: TextStyle(
                            color: darkGrey,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Inter",
                          ),
                        )
                      else
                        Container(),
                      getItemTileUi(index),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildTrackOrder(),
                          const SizedBox(
                            width: 10,
                          ),
                          _buildUpdateStatus(),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Divider(
            color: greySecondaryYarn,
            thickness: 5,
          ),
        ),
      ],
    );
  }

  Widget getItemTileUi(int index) {
    if (items[index]["type"] == "product") {
      return OrderTileForProductNew(
        item: items[index],
      );
    }
    return OrderTileForService(
      items[index],
    );
  }

  Widget orderNumberAndAmount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Ref N: ${widget.order?.id}",
          style: TextStyle(
            color: blackFont,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: "Inter",
          ),
        ),
        Row(
          children: [
            Text(
              "Total: ",
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                fontFamily: "Inter",
              ),
            ),
            Text(
              worldCurrencies[widget.order?.currency] ?? "",
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: "Inter",
              ),
            ),
            Text(
              moneyDisplayNormalizer(widget.order?.totalPrice),
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                fontFamily: "Inter",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget orderStatusAndDate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              widget.order?.status ?? "",
              style: TextStyle(
                color: blackFont,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: "Inter",
              ),
              maxLines: 1,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              "(${widget.order?.qty ?? "0"} item)",
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                fontFamily: "Inter",
              ),
            ),
          ],
        ),
        getDateTime(),
      ],
    );
  }

  Widget _buildUpdateStatus() {
    return MaterialButton(
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      color: navyBlue,
      onPressed: () {
        showBottomSheetDialog(widget.order?.id);
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
    );
  }

  Widget _buildTrackOrder() {
    return MaterialButton(
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
    );
  }

  void showBottomSheetDialog(String? orderId) async {
    await androidBottomSheet(
      enableDrag: true,
      context: context,
      child: OrderStatusList(orderId: orderId ?? ""),
    );
  }

  Widget getDateTime() {
    debugPrint(widget.order?.createdAt);
    final DateTime orderTime =
        DateTime.parse(widget.order?.createdAt ?? '').toLocal();
    final String date = DateFormat("MMM d, yyyy").format(orderTime);
    return Text(
      date,
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(
        color: blackFont,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildShimmerView() {
    return Shimmer.fromColors(
      baseColor: Colors.white,
      highlightColor: greyBorderColor,
      child: Row(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.grey,
                shape: BoxShape.rectangle),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 15,
                  decoration: BoxDecoration(
                      color: greyBackground,
                      borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  width: 100,
                  height: 15,
                  decoration: BoxDecoration(
                      color: greyBackground,
                      borderRadius: BorderRadius.circular(4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
