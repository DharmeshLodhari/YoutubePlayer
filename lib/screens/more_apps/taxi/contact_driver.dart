import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/taxi/map_ui.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContactDriver extends StatefulWidget {
  const ContactDriver({super.key});

  @override
  State<ContactDriver> createState() => _ContactDriverState();
}

class _ContactDriverState extends State<ContactDriver> {
  @override
  void initState() {
    super.initState();
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
        backgroundColor: Colors.white,
        appBar: appBar() as PreferredSizeWidget?,
        body: Stack(
          children: [
            // Image.asset(
            //   "assets/images/map.png",
            //   height: double.infinity,
            //   width: double.infinity,
            //   fit: BoxFit.fill,
            // ),

            MapUI(),

            // FlutterMap(
            //   mapController: mapController,
            //   options: MapOptions(
            //       center: mapPoint, zoom: 18.0, minZoom: 5, maxZoom: 18),
            //   layers: [
            //     TileLayerOptions(
            //       urlTemplate:
            //           "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            //       subdomains: ['a', 'b', 'c'],
            //       overrideTilesWhenUrlChanges: true,
            //     ),
            //     MarkerLayerOptions(
            //       markers: [
            //         Marker(
            //           point: mapPoint,
            //           builder: (ctx) => Container(
            //             child: Icon(
            //               SlydoAppIcon.location,
            //               color: blackFont,
            //               size: 28,
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
            driverDetailUI()
          ],
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left_rounded,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        "On Trip",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget driverDetailUI() {
    return Positioned(
        bottom: 0,
        right: 0,
        left: 0,
        child: Card(
          elevation: 4,
          shadowColor: dividerColor,
          color: Colors.white,
          margin: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Column(
                    children: [
                      getDriverInfo(),
                      const SizedBox(
                        height: 20,
                      ),
                      getPayButton(),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget getPayButton() {
    return getActionBtn(onTap: () {}, icon: Icons.call_outlined);
  }

  Widget getDriverInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Meet by Chevron Estate Gate",
            style: TextStyle(
                color: blackFont, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(
            height: 20,
          ),
          Divider(
            color: dividerColor,
            height: 0,
            thickness: 1,
          ),
          const SizedBox(
            height: 20,
          ),
          getDriverDetail(),
          const SizedBox(
            height: 20,
          ),
          getNotes(),
        ],
      ),
    );
  }

  Widget getNotes() {
    return CustomizedTextFormField(
      labelText: "Any pick-up notes?",
    );
  }

  Widget getDriverDetail() {
    final UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CachedNetworkImage(
              imageUrl: userBloc.user.avatar!,
              height: 80,
              width: 80,
              fit: BoxFit.fill,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ahmad Aminoff",
                  style: TextStyle(
                      color: blackFont,
                      fontSize: 22,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: darkGrey.withOpacity(0.3)),
                  child: Text(
                    "KRD 770 CK",
                    style: TextStyle(
                        color: blackFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  "Volkswagen Jetta",
                  style: TextStyle(
                      color: blackFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getActionBtn({IconData? icon, Function? onTap}) {
    return GestureDetector(
      onTap: onTap as void Function()?,
      child: Card(
        elevation: 5,
        borderOnForeground: true,
        shadowColor: dividerColor.withAlpha(125),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: SizedBox(
          height: 70,
          width: 70,
          child: Center(
            child: Icon(
              icon,
              color: blackFont,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
