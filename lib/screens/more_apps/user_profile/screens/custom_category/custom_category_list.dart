import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/forms/add_edit_discount.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/discount/discount_model.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/navigation_util.dart';

import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/dialog.dart';

import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

// ignore: must_be_immutable
class CustomCategoryList extends StatefulWidget {
  CustomCategoryList({Key? key}) : super(key: key);

  @override
  _CustomCategoryListState createState() => _CustomCategoryListState();
}

class _CustomCategoryListState extends State<CustomCategoryList> {
  // this variable responsible for product pagination
  int? itemCount = 0;
  String? next = "";
  String? previous = "";
  List<ProductCategory> itemList = [];
  ScrollController _scrollController = new ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _messengerScaffoldKey =
      new GlobalKey<ScaffoldMessengerState>();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;
  UserBloc? userBloc;

  TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    Future.delayed(Duration(seconds: 1), () {
      this.getList();
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getList();
      }
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    userBloc = Provider.of<UserBloc>(context);
    super.didChangeDependencies();
  }

  void _onProductRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        itemCount = 0;
        next = "";
        previous = "";
        itemList = [];
        debugPrint("Refresh called on discount!!  ");
        getList();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }

  void getList({bool fetchFresh = false}) async {
    if (fetchFresh) {
      itemCount = 0;
      next = "";
      previous = "";
      itemList = [];
    }

    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        List<ProductCategory> result = await ShoppingAuthService()
            .obtainCustomCategory(userBloc!.user.userName);

        if (result == null) {
          isLoading = false;
          noItemInList = true;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        // itemCount = result['count'];
        // next = result['next'];
        // previous = result['previous'];
        // var tempList = result['results'];
        if (mounted) {
          setState(() {
            noItemInList = false;
            isLoading = false;
            itemList.addAll(result);
          });
        }
      }
      if (itemList.isEmpty) {
        if (mounted) {
          setState(() {
            noItemInList = true;
          });
        }
      } else if (next == null && itemList.length > 6) {
        _messengerScaffoldKey.currentState!.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  addCategory() {
    showDialogBoxWithInput(
      context: context,
      actionOneTextColor: white,
      actionOneBgColor: navyBlue,
      actionTwoTextColor: blackFont,
      actionTwoBgColor: greyBorderColor,
      actionOneText: "Save",
      content: Padding(
        padding: const EdgeInsets.only(left: 0.0, right: 0, top: 20),
        child: Column(
          children: [
            Text("Add Custom Category",
                style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
                textAlign: TextAlign.center),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: CustomizedTextFormField(
                labelText: "Name",
                controller: _controller,
                validator: (val) {
                  if (val.isNotEmpty) {
                    return null;
                  }
                  return AppLocalization.of(context)!
                      .pleaseEnterManufacturerName;
                },
                onChanged: (val) {
                  // productManufacturer = val;
                },
              ),
            ),
          ],
        ),
      ),
      leftButtonOnPressed: () async {
        if (_controller.text.isNotEmpty) {
          bool result = await ShoppingAuthService()
              .createCustomCategory(_controller.text);
          _onProductRefresh();
          _controller.clear();
          Navigator.pop(context);
          
           
        }
      },
    );
  }

  deleteOrEditCategory(ProductCategory prod) {
    _controller.text = prod.name;
    showDialogBoxWithInput(
        context: context,
        actionOneTextColor: white,
        actionOneBgColor: mateRed,
        actionTwoTextColor: white,
        actionTwoBgColor: navyBlue,
        actionOneText: "Delete",
        actionTwoText: "Update",
        firstActionPrimary: false,
        content: Padding(
          padding: const EdgeInsets.only(left: 0.0, right: 0, top: 20),
          child: Column(
            children: [
              Text("Edit Custom Category",
                  style: TextStyle(
                      color: blackFont,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0),
                  textAlign: TextAlign.center),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: CustomizedTextFormField(
                  labelText: "Name",
                  controller: _controller,
                  validator: (val) {
                    if (val.isNotEmpty) {
                      return null;
                    }
                    return AppLocalization.of(context)!
                        .pleaseEnterManufacturerName;
                  },
                  onChanged: (val) {
                    // productManufacturer = val;
                  },
                ),
              ),
              SizedBox(height: 5)
            ],
          ),
        ),
        leftButtonOnPressed: () async {
          bool result = await ShoppingAuthService().deleteCustomCategory(prod.id);
            _onProductRefresh();
            _controller.clear();
          Navigator.pop(context);
      
        },
        rightButtonOnPressed: () async {
          bool result =
              await ShoppingAuthService().editCustomCategory(_controller.text, prod.id);
            _onProductRefresh();
            _controller.clear();
          Navigator.pop(context);
        });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _messengerScaffoldKey,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: _buildAppBar() as PreferredSizeWidget,
        body: Container(
          color: white,
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _refreshController,
            onRefresh: _onProductRefresh,
            child: noItemInList
                ? NoItemInList(msg: AppLocalization.of(context)!.noResultFound
                    // msg: AppLocalization.of(context)!.noProducts,
                    )
                : isLoading
                    ? _buildShimmerEffect()
                    : _buildItemList(),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.white,
      highlightColor: greyBorderColor,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            height: 90,
            margin: const EdgeInsets.symmetric(vertical: 16.0),
            child: CustomBoxShadow(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: selectedListItemBackgroundBlue),
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.zero,
                shadowColor: boxShadowTwo,
                color: white,
                child: Container(
                  padding:
                      EdgeInsets.only(top: 23 , left: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 10,
                              width: 50,
                              color: Colors.blueGrey,
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Container(
                              height: 8,
                              width: 50,
                              color: Colors.blueGrey,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 10,
                        width: 50,
                        color: Colors.blueGrey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        'Custom Category',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: yarnBlack,
          height: 1.3,
        ),
      ),
      centerTitle: false,
      titleSpacing: 16,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context, "back pressed");
        },
      ),
      shadowColor: greySecondaryYarn,
      actions: _buildAppBarActions(),
      elevation: 0.5,
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      RoundedBackgroundIcon(
          backgroundColor: Color.fromRGBO(0, 0, 0, 0),
          onTap: () async {
            addCategory();
          },
          height: 20,
          width: 20,
          icon: SvgPicture.asset(
            "add_payment".toSVG(),
            height: 12,
            width: 12,
          )),
      SizedBox(width: 30),
    ];
  }

  Widget _buildItemList() {
    return next == "" && isLoading
        ? SizedBox.shrink()
        : Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              controller: _scrollController,
              physics: NeverScrollableScrollPhysics(),
              itemCount: itemList.length,
              itemBuilder: (context, index) {
                return itemTile(index);
              },
            ),
          );
  }

  Widget itemTile(int index) {
    return InkWell(
      onTap: () async {
        deleteOrEditCategory(itemList[index]);
      },
      child: Container(
        height: 90,
        margin: const EdgeInsets.symmetric(vertical: 16.0),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: selectedListItemBackgroundBlue, width: 1),
              borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.zero,
          color: white,
          child: Container(
            padding: EdgeInsets.only(top: 23, left: 15),
            child: Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    messageDecoderWithEmoji(itemList[index].name) ??
                        itemList[index].name ??
                        "",
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: "Inter",
                        color: blackFont),
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
