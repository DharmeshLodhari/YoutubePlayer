import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/item_display_card.dart';
import 'package:Slydo/widget/read_more_widget.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class UserInfo extends StatefulWidget {
  CustomerProfile user;

  UserInfo({@required this.user});

  @override
  _UserInfoState createState() => _UserInfoState(user: user);
}

class _UserInfoState extends State<UserInfo> {
  CustomerProfile user;
  UserBloc userBloc;

  bool isBioShowingLess = true;

  bool isProductFetched = false;
  bool isProductItemIsEmpty = true;
  bool isServiceFetched = false;
  bool isServiceItemIsEmpty = true;

  _UserInfoState({this.user});

  List<dynamic> popularProductItem = List<dynamic>();
  List<dynamic> popularServiceItem = List<dynamic>();

  bool isLoading = true;
  final auth = AuthService();

  @override
  void initState() {
    if (user.type.toLowerCase() != "user") {
      getProductItems();
      getServiceItems();
    }

    super.initState();
  }

  void getProductItems() {
    ShoppingAuthService()
        .ownersOrderProductsAndServices(
            type: "products",
            userId: user.userName,
            exclude: "8eb50b0e-0a88-441b-84b1-d00935a88a3d")
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
    });
    isProductFetched = true;
  }

  void getServiceItems() {
    ShoppingAuthService()
        .ownersOrderProductsAndServices(
            type: "services",
            userId: user.userName,
            exclude: "d54b8857-b901-405b-a4fa-f0df5d2983ba")
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
    });
    isServiceFetched = true;
  }

  CustomerProfileBloc customerProfileBloc;

  @override
  Widget build(BuildContext context) {
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        customerProfileBloc.customer = null;
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            padding: EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: <Widget>[
                      Column(
                        children: getUserAboutSection(),
                      ),
                      (user.type.toLowerCase() != "user")
                          ? Column(
                              children: [
                                SizedBox(
                                  height: 16,
                                ),
                                Divider(
                                  height: 0,
                                  color: dividerColor,
                                  thickness: 1,
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                ),
                isProductItemIsEmpty ? Container() : _buildProductList(),
                SizedBox(
                  height: 20,
                ),
                isServiceItemIsEmpty ? Container() : _buildServiceList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return Container(
      height: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
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
                    AppLocalization.of(context).seeAll,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: navyBlue),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/profile', arguments: {
                      "searchedUserName": user.userName,
                      "index": 2
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: popularProductItem.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => displayProduct(
                context: context,
                product: popularProductItem[index],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceList() {
    return Container(
      height: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
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
                    AppLocalization.of(context).seeAll,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: navyBlue),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/profile', arguments: {
                      "searchedUserName": user.userName,
                      "index": 3
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: popularServiceItem.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => displayService(
                context: context,
                service: popularServiceItem[index],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> getUserAboutSection() {
    List<Widget> list = [];

    if (user.userAbout.bio.isNotEmpty) {
      list.addAll([
        // ExpandableText(searchedUserAbout.bio),
        ReadMoreText(
          user.userAbout.bio,
          trimMode: TrimMode.Line,
          trimLines: 3,
          textAlign: TextAlign.justify,
          colorClickableText: darkGrey,
          delimiter: isBioShowingLess ? "..." : "",
          callback: (isOpen) {
            isBioShowingLess = isOpen;
            if (mounted) setState(() {});
          },
          moreStyle: TextStyle(color: darkGrey, fontWeight: FontWeight.w600),
          lessStyle: TextStyle(color: darkGrey, fontWeight: FontWeight.w600),
          trimExpandedText: "See less",
          trimCollapsedText: "See more",
          style: TextStyle(
              color: blackFont, fontSize: 14, fontWeight: FontWeight.w400),
        ),
        SizedBox(
          height: 16,
        ),
      ]);
    }

    if (user.userAbout.address.isNotEmpty) {
      list.addAll([
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RoundedBackgroundIcon(
              height: 32,
              width: 32,
              backgroundColor: iconBtnGrey,
              icon: Icon(
                SlydoAppIcon.location,
                color: blackFont,
                size: 14,
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Expanded(
              child: Text(
                user.userAbout.address,
                // textAlign: TextAlign.justify,
              ),
            )
          ],
        ),
        SizedBox(
          height: 8,
        ),
      ]);
    }

    if (user.userAbout.contact.isNotEmpty) {
      list.addAll([
        Row(
          children: [
            RoundedBackgroundIcon(
              height: 32,
              width: 32,
              backgroundColor: iconBtnGrey,
              icon: Icon(
                Icons.call,
                color: blackFont,
                size: 18,
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Expanded(child: Text(user.userAbout.contact))
          ],
        )
      ]);
    }

    return list;
  }
}
