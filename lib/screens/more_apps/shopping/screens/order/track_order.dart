import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/auth/rider_delivery_auth.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/models/delivery_model.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/order/tracker_stepper.dart'
    as track;
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_elevated_button.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackOrder extends StatefulWidget {
  final dynamic arguments;
  const TrackOrder({super.key, required this.arguments});

  @override
  State<TrackOrder> createState() => _TrackOrderState();
}

class _TrackOrderState extends State<TrackOrder> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = true;
  final _auth = ShoppingAuthService();
  List<Map<String, dynamic>> items = [];
  DeliveryModel? deliveryModel;
  Order? order;
  int _currentStep = 0;

  @override
  void initState() {
    order = widget.arguments['order'];
    fetchOrder(order?.id.toString() ?? "");
    if (order?.journeyId != null) {
      fetchJobData();
    }
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

  Future<void> fetchJobData() async {
    isLoading = true;
    if (mounted) setState(() {});

    await RiderDeliveryAuthService()
        .fetchJob(order?.journeyId)
        .then((value) async {
      if (value != null) {
        deliveryModel = value;

        isLoading = false;
        if (mounted) setState(() {});
      }
    }).catchError((error) {
      isLoading = false;
      if (mounted) setState(() {});
      debugPrint(error.toString());
      showToast(message: error.toString());
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
        "Track Order #${order?.id ?? ""}",
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderStatus(),
          const SizedBox(
            height: 10,
          ),
          _buildLogisticInfo(),
          const SizedBox(
            height: 20,
          ),
          _buildTrackingDetails(),
        ],
      ),
    );
  }

  Widget _buildOrderStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order?.status ?? "",
          style: TextStyle(
            fontSize: 16,
            color: blackFont,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OrderStep(
                icon: Icons.inventory,
                color: navyBlue,
              ),
              DottedLine(),
              OrderStep(
                icon: Icons.local_shipping,
                color: navyBlue,
              ),
              DottedLine(),
              OrderStep(
                icon: Icons.home,
                color: navyBlue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogisticInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Logistic Info',
              style: TextStyle(
                fontSize: 16,
                color: blackFont,
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
              ),
            ),
            Text(
              'Slydo Dispatch',
              style: TextStyle(
                fontSize: 14,
                color: blackFont,
                fontWeight: FontWeight.w500,
                fontFamily: "Inter",
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          'Tracking Number : 36789021',
          style: TextStyle(
            fontSize: 14,
            color: darkGrey,
            fontWeight: FontWeight.w400,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tracking details',
          style: TextStyle(
            fontSize: 14,
            color: blackFont,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
        ),
        stepperBody(),
      ],
    );
  }

  void tapped(int step) {
    setState(() => _currentStep = step);
  }

  void continued() {
    _currentStep < 5 ? setState(() => _currentStep += 1) : null;
  }

  void cancel() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }

  Widget stepperBody() {
    return track.OrderTrackerStepper(
        type: track.StepperType.vertical,
        physics: const NeverScrollableScrollPhysics(),
        currentStep: _currentStep,
        onStepTapped: (step) => tapped(step),
        onStepContinue: continued,
        onStepCancel: cancel,
        controlsBuilder: (context, details) {
          return Container(
            color: navyBlue,
            child: Container(),
          );
        },
        steps: order?.statusTimeStamp?.map(
              (element) {
                final String statusTitle =
                    element.keys.first; // Get the key (status title)
                final String statusTimeStamp =
                    element.values.first; // Get the value (timestamp)
                return track.Step(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(statusTitle,
                              style: TextStyle(
                                  color: blackFont,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(width: 10),
                          if (statusTitle == 'Order Picked Up')
                            SvgPicture.asset(
                              'assets/images/bike_front.svg',
                            ),
                        ],
                      ),
                      Text(getOrderStatus(statusTitle)[0],
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 10,
                              fontWeight: FontWeight.w400)),
                      Text(statusTimeStamp,
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 10,
                              fontWeight: FontWeight.w400)),
                      const SizedBox(height: 5),
                      if (statusTitle == 'Order Picked Up' &&
                          deliveryModel?.isInProgress == true)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildCircleImageAndName(),
                            const SizedBox(width: 10),
                            _buildPartnerContactIcon(),
                          ],
                        ),
                    ],
                  ),
                  content: const SizedBox.shrink(),
                  isActive: true,
                  state: getOrderStatus(statusTitle)[1],
                  // state: getActiveOrderStatus(order, "New Order")
                  //     ? track.StepState.editing
                  //     : track.StepState.disabled,
                );
              },
            ).toList() ??
            []);
  }

  Widget _buildCircleImageAndName() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(80),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed("/photo-viewer",
                  arguments: deliveryModel?.dispatcherAvatar);
            },
            child: Container(
              color: Colors.white,
              child: CachedNetworkImage(
                height: 30,
                width: 30,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
                imageUrl: deliveryModel?.dispatcherAvatar ?? "",
                errorWidget: imageErrorWidget,
              ),
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          appendStringDot(deliveryModel?.dispatcherFullName ?? "", 10),
          style: TextStyle(
            fontSize: 12,
            fontFamily: "Inter",
            fontWeight: FontWeight.w500,
            color: blackFont,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPartnerContactIcon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, Routes.RIDER_MAP_STATUS,
                arguments: {"journey_details": deliveryModel});
          },
          child:
              RoundedElevatedButton(svgImg: 'assets/images/location_icon.svg'),
        ),
        const SizedBox(width: 3),
        GestureDetector(
            onTap: () {
              _makePhoneCall();
            },
            child:
                RoundedElevatedButton(svgImg: 'assets/images/call_icon.svg')),
        const SizedBox(width: 3),
        badges.Badge(
          position: badges.BadgePosition.topEnd(top: 0, end: 0),
          badgeStyle: badges.BadgeStyle(
            badgeColor: navyBlue,
          ),
          badgeContent: Text(
            "2",
            style: TextStyle(
              color: white,
              fontSize: 8,
              fontFamily: "Inter",
              fontWeight: FontWeight.w700,
            ),
          ),
          child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/chat-screen', arguments: {
                  "recipientUserName": deliveryModel?.dispatcher
                });
              },
              child:
                  RoundedElevatedButton(svgImg: 'assets/images/chat_icon.svg')),
        ),
      ],
    );
  }

  Future<void> _makePhoneCall() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: deliveryModel?.dispatcherNumber,
    );
    await launchUrl(launchUri);
  }

  String getOrderStatusTime(Order? order, String? status) {
    var time = '';
    var date = '';
    order?.statusTimeStamp?.map((e) {
      if (e[status ?? ''] != null) {
        date =
            DateFormat("EEEE, MM d 'h:mm a").format(DateTime.parse(e[status]));
        time = DateFormat("hh:mm:ss").format(DateTime.parse(e[status]));
      }
    }).toList();

    return date + time;
  }

  List getOrderStatus(String statusTitle) {
    switch (statusTitle) {
      case 'Order Placed':
        return [
          'This order has been placed successfully.',
          track.StepState.complete
        ];
      case 'Awaiting Payment':
        return [
          'Your order is onhold till payment is being confirmed.',
          track.StepState.editing
        ];
      case 'Payment Successful':
        return [
          'Payment has been receive successfully.',
          track.StepState.complete
        ];
      case 'Processing':
        return [
          'Your order is being prepared for shipment',
          track.StepState.complete
        ];
      case 'Order Picked Up':
        return [
          'Your order has been shipped and is in transit',
          track.StepState.complete
        ];
      case 'On Hold':
        return [
          'Your order is onHold till the product is restocked.',
          track.StepState.editing
        ];
      case 'Out For Delivery':
        return [
          'Your order is out for delivery and  will arrive soon',
          track.StepState.complete
        ];
      case 'Canceled':
        return ['This order has been cancelled', track.StepState.error];
      case 'Complete':
        return [
          'Your order has been delivered successfully, thank you for shopping from us',
          track.StepState.complete
        ];
      case 'Rider Assigned':
        return [
          '${deliveryModel?.acceptedBy} has been assigned to your order and he is on his way to pickup.',
          track.StepState.complete
        ];
      default:
        return ["", track.StepState.disabled];
    }
  }
}

class OrderStep extends StatelessWidget {
  final IconData icon;
  final Color color;

  const OrderStep({super.key, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }
}

class DottedLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final boxWidth = constraints.constrainWidth();
            const dashWidth = 5.0;
            const dashHeight = 2.0;
            final dashCount = (boxWidth / (2 * dashWidth)).floor();
            return Flex(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              direction: Axis.horizontal,
              children: List.generate(dashCount, (_) {
                return SizedBox(
                  width: dashWidth,
                  height: dashHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: navyBlue,
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
