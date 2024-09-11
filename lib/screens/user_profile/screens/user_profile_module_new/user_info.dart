import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/user_profile/models/user.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/item_display_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserInfo extends StatefulWidget {
  CustomerProfile? user;
  void Function(int index)? changeIndex;
  UserInfo({super.key, required this.user, this.changeIndex});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  UserBloc? userBloc;

  bool isBioShowingLess = true;
  bool isServiceFetched = false;
  bool isProductFetched = false;
  bool isProductItemIsEmpty = true;
  bool isServiceItemIsEmpty = true;

  _UserInfoState();

  List<dynamic> popularProductItem = [];
  List<dynamic> popularServiceItem = [];

  bool isLoading = true;
  final auth = AuthService();

  @override
  void initState() {
    if (widget.user!.type!.toLowerCase() != "user") {
      getProductItems();
      getServiceItems();
    }

    super.initState();
  }

  void getProductItems() async {
    await ShoppingAuthService()
        .ownersOrderProductsAndServices(
            type: "products", userId: widget.user!.userName)
        .then((value) {
      if (value.isNotEmpty) {
        if (mounted) {
          setState(() {
            isProductItemIsEmpty = false;
            popularProductItem = value;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isProductItemIsEmpty = true;
          });
        }
      }
    }).catchError((error) {
      debugPrint("ERROR:- $error");
    });
    isProductFetched = true;
  }

  void getServiceItems() async {
    await ShoppingAuthService()
        .ownersOrderProductsAndServices(
            type: "services", userId: widget.user!.userName)
        .then((value) {
      if (value.isNotEmpty) {
        if (mounted) {
          setState(() {
            isServiceItemIsEmpty = false;
            popularServiceItem = value;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isServiceItemIsEmpty = true;
          });
        }
      }
    }).catchError((error) {
      debugPrint("ERROR:- $error");
    });
    isServiceFetched = true;
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: <Widget>[
                      Column(
                        children: getUserAboutSection(),
                      ),
                      if (widget.user!.type!.toLowerCase() != "user")
                        Column(
                          children: [
                            const SizedBox(height: 16),
                            Divider(
                              height: 0,
                              color: dividerColor,
                              thickness: 1,
                            ),
                            const SizedBox(height: 16),
                          ],
                        )
                      else
                        Container(),
                    ],
                  ),
                ),
                if (isProductItemIsEmpty) Container() else _buildProductList(),
                const SizedBox(
                  height: 20,
                ),
                if (isServiceItemIsEmpty) Container() else _buildServiceList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return SizedBox(
      height: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Popular products",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: blackFont,
                  ),
                ),
                GestureDetector(
                  child: Text(
                    AppLocalization.of(context)!.seeAll,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: navyBlue),
                  ),
                  onTap: () {
                    widget.changeIndex!(2);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: popularProductItem.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => DisplayProduct(
                product: popularProductItem[index],
                giveRightPadding: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceList() {
    return SizedBox(
      height: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Popular services",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: blackFont,
                  ),
                ),
                GestureDetector(
                  child: Text(
                    AppLocalization.of(context)!.seeAll,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: navyBlue),
                  ),
                  onTap: () {
                    widget.changeIndex!(3);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: popularServiceItem.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => DisplayService(
                service: popularServiceItem[index],
                giveRightPadding: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> getUserAboutSection() {
    final List<Widget> list = [];

    // if (widget.user!.userAbout!.bio.isNotEmpty) {
    //   list.addAll([
    //     // ExpandableText(searchedUserAbout.bio),
    //     ReadMoreText(
    //       widget.user!.userAbout!.bio,
    //       trimMode: TrimMode.Line,
    //       trimLines: 3,
    //       textAlign: TextAlign.justify,
    //       colorClickableText: darkGrey,
    //       delimiter:  "...",
    //       callback: (isOpen) {
    //         isBioShowingLess = isOpen;
    //         if (mounted) setState(() {});
    //       },
    //       moreStyle: TextStyle(color: darkGrey, fontWeight: FontWeight.w600),
    //       lessStyle: TextStyle(color: darkGrey, fontWeight: FontWeight.w600),
    //       trimExpandedText: "See less",
    //       trimCollapsedText: "See more",
    //       style: TextStyle(
    //           color: blackFont, fontSize: 14, fontWeight: FontWeight.w400),
    //     ),
    //     SizedBox(
    //       height: 16,
    //     ),
    //   ]);
    // }

    // if (widget.user?.userAbout?.userAddress?.addressLine1 != null &&
    //     widget.user!.userAbout!.userAddress!.addressLine1!.isNotEmpty) {
    //   list.addAll([
    //     Row(
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: [
    //         RoundedBackgroundIcon(
    //           height: 32,
    //           width: 32,
    //           backgroundColor: iconBtnGrey,
    //           icon: Icon(
    //             SlydoAppIcon.location,
    //             color: blackFont,
    //             size: 14,
    //           ),
    //         ),
    //         SizedBox(width: 12),
    //         GetFullAddressWidget(user: widget.user!),
    //       ],
    //     ),
    //     SizedBox(
    //       height: 8
    //     ),
    //   ]);
    // }

    // if (widget.user!.userAbout!.contact.isNotEmpty) {
    //   list.addAll([
    //     Row(
    //       children: [
    //         RoundedBackgroundIcon(
    //           height: 32,
    //           width: 32,
    //           backgroundColor: iconBtnGrey,
    //           icon: Icon(
    //             Icons.call,
    //             color: blackFont,
    //             size: 18,
    //           ),
    //         ),
    //         SizedBox(
    //           width: 12,
    //         ),
    //         Expanded(child: Text(widget.user!.userAbout!.contact))
    //       ],
    //     )
    //   ]);
    // }

    return list;
  }
}
