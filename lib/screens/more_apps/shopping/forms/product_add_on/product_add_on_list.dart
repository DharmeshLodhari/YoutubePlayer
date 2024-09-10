import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:Slydo/widget/vertical_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../routes/route_constants.dart';
import '../../../../../widget/curved_btn.dart';
import '../../models/store.dart';
import '../../shopping_auth.dart';

class ProductAddOnList extends StatefulWidget {
  final dynamic arguments;

  const ProductAddOnList({this.arguments, super.key});

  @override
  State<ProductAddOnList> createState() => _ProductAddOnListState();
}

class _ProductAddOnListState extends State<ProductAddOnList>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // Get list of users bank account
  late UserBloc userBloc;
  int? count = 0;
  String? next = "";
  String? previous = "";
  String? productId = "";
  bool? isForCheckboxSelection = false;
  List<AddOns> productAddOnList = [];
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;
  final _auth = ShoppingAuthService();
  bool isAPILoading = false;

  @override
  void initState() {
    productId = widget.arguments["productId"];
    isForCheckboxSelection = widget.arguments["isForCheckboxSelection"];

    getAddOnList();

    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getAddOnList();
      }
    });
  }

  void getAddOnList() async {
    if (!isLoading) {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      final Map<String, dynamic> result =
          await _auth.getAddOnsList(productId!, next, previous);
      if (result == null) {
        isLoading = false;
        noItemInList = true;
        return;
      }

      productAddOnList = [];
      count = result['count'];
      next = result['next'];
      previous = result['previous'];
      final tempList = result['results'];

      productAddOnList.addAll(tempList);

      if (mounted) {
        setState(() {
          isLoading = false;
          noItemInList = false;
        });
      }

      if (productAddOnList.isEmpty) {
        if (mounted) {
          setState(() {
            noItemInList = true;
          });
        }
      } else if (next == null && productAddOnList.length > 6) {
        _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  // refresh the list when lifecycle called onResume method
  void _onRefresh() async {
    //check network connectivity and if true then refresh the list
    if (await checkConnection(context)) {
      count = 0;
      next = "";
      previous = "";
      productAddOnList = [];
      if (mounted) setState(() {});
      getAddOnList();
      setState(() {
        // Call the callback function with the updated list
        //to pass the list back to edit product page
        // widget.onListRefreshed!(productVariantList);
        _refreshController.refreshCompleted();
      });
    } else {
      _refreshController.refreshCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        // Navigator.pop(context, productAddOnList);
        Navigator.pop(context);
        return true;
      },
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          appBar: appBar() as PreferredSizeWidget?,
          body: SlidableAutoCloseBehavior(
            closeWhenOpened: true,
            child: SmartRefresher(
              enablePullDown: true,
              header: WaterDropHeader(
                complete: Container(),
                waterDropColor: navyBlue,
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: _buildBody(),
            ),
          ),
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            color: navyBlue,
            size: 24,
          ),
          onPressed: () async {
            // List<AddOns> addOnList = productAddOnList
            //     .where((addOn) => addOn.isChecked == true)
            //     .toList();
            // Navigator.pop(context, addOnList);
            Navigator.of(context).pop();
          }),
      centerTitle: false,
      title: Text(
        AppLocalization.of(context)!.addOn,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        addOptionBtn(),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Select from the available add-ons or create a new add-ons.',
            style: TextStyle(
                color: darkGrey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: "Inter"),
          ),
          Expanded(child: _buildProductAddOnList()),
        ],
      ),
    );
  }

  Widget addOptionBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.add,
        size: 16,
        color: blackFont,
      ),
      onTap: () async {
        final result = await Navigator.of(context)
            .pushNamed(Routes.NEW_ADD_ON, arguments: {
          'option': 'edit',
          'productId': productId,
        });

        // Handle the result (map) received from Product Add New Option
        if (result != null && result is AddOns) {
          //save the variant details for later use
          // _onRefresh();
          productAddOnList.add(result);
          if (mounted) setState(() {});
        }
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget _buildProductAddOnList() {
    return Stack(
      children: [
        if (noItemInList)
          NoItemInList(
            title: AppLocalization.of(context)!.noAddOnYet,
            msg: AppLocalization.of(context)!.noAddOnYetSub,
          )
        else
          isLoading && productAddOnList.isEmpty
              ? buildLoadingIndicator(isLoading: isLoading)
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                  //+1 for progressbar
                  itemCount: productAddOnList.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == productAddOnList.length) {
                      return buildJumpingLoadingIndicator(isLoading: isLoading);
                    } else {
                      return _getSlidableWithLists(
                        context,
                        GestureDetector(
                          onTap: () async {
                            // if (isForCheckboxSelection == true)
                            //   toggleAddOnCheckedState(index);
                            final data = await Navigator.of(context)
                                .pushNamed(Routes.UPDATE_ADD_ON, arguments: {
                              'addOns': productAddOnList[index],
                              'productId': productId,
                            }).whenComplete(() => getAddOnList());

                            // Handle the result (map) received from PRODUCT_VARIANT_UPDATE
                            if (data != null && data is AddOns) {
                              //save the variant details for later use
                              _onRefresh();
                              if (mounted) setState(() {});
                            }
                          },
                          child: productAddOnTile(
                              addOns: productAddOnList[index], index: index),
                        ),
                        productAddOnList[index],
                      );
                    }
                  },
                  controller: _scrollController,
                ),
        Positioned(
          bottom: 25, // Adjust the distance from the bottom as needed
          right: 25,
          left: 25,

          child: getSubmitButton(),
        ),
      ],
    );
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: isAPILoading
          ? () {}
          : () async {
              FocusScope.of(context).unfocus();

              isAPILoading = true;
              if (mounted) setState(() {});

              loadAllCheckedAddOn();

              isAPILoading = false;
              if (mounted) setState(() {});
            },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Save",
      isLoading: isAPILoading,
    );
  }

  Widget loadAllCheckedAddOn() {
    final List<AddOns> addOnList =
        productAddOnList.where((addOn) => addOn.isChecked == true).toList();

    Navigator.pop(context, addOnList);
    return Container();
  }

  Widget productAddOnTile({required AddOns addOns, int? index}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          // dense: variant.isDefault! ? true : false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appendStringDot(addOns.name!, 20),
                maxLines: 1,
                style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    fontFamily: "Inter"),
              ),
              const SizedBox(height: 5.0),
              Text(
                '${addOns.options!.length} items',
                maxLines: 1,
                style: TextStyle(
                    color: darkGrey,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    fontFamily: "Inter"),
              ),
            ],
          ),
          trailing: isForCheckboxSelection == true
              ? Checkbox(
                  value: addOns.isChecked ?? false,
                  activeColor: navyBlue,
                  onChanged: (bool? value) {
                    // Handle checkbox state change here
                    toggleAddOnCheckedState(index!);
                  },
                )
              : null,
        ),
      ),
    );
  }

  void toggleAddOnCheckedState(int index) {
    if (index >= 0 && index < productAddOnList.length) {
      productAddOnList[index].isChecked = !productAddOnList[index].isChecked!;
      if (mounted) setState(() {});
    }
  }

  Widget _getSlidableWithLists(
      BuildContext context, Widget bankAccountTile, AddOns addOns) {
    return Slidable(
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: listActionSlideActions(addOns: addOns),
      ),
      child: VerticalListItem(bankAccountTile),
      // secondaryActions: listSecondaryActions(addOns: addOns),
    );
  }

  List<Widget> listSecondaryActions({required AddOns addOns}) {
    return [
      SlideActionButton(
        borderRadius: BorderRadius.circular(5),
        padding: EdgeInsets.zero,
        backgroundColor: starYellow,
        icon: Icons.edit,
        onPressed: (con) async {
          final data = await Navigator.of(context)
              .pushNamed(Routes.UPDATE_ADD_ON, arguments: {
            'addOns': addOns,
            'productId': productId,
          });

          // Handle the result (map) received from PRODUCT_VARIANT_UPDATE
          if (data != null && data is AddOns) {
            //save the variant details for later use
            _onRefresh();
            if (mounted) setState(() {});
          }
        },
        label: AppLocalization.of(context)!.edit,
      ),
    ];
  }

  List<Widget> listActionSlideActions({AddOns? addOns}) {
    return [
      SlideActionButton(
        borderRadius: BorderRadius.circular(5),
        padding: EdgeInsets.zero,
        backgroundColor: mateRed,
        icon: SlydoAppIcon.remove,
        onPressed: (con) async {
          deleteAddOnDialog(addOns);
        },
        label: AppLocalization.of(context)!.delete,
      ),
    ];
  }

  void deleteAddOnDialog(AddOns? addOns) {
    showDialogBox(
      context: context,
      actionOneTextColor: blackFont,
      actionOneBgColor: greyBorderColor,
      actionTwoTextColor: white,
      actionTwoBgColor: mateRed,
      title: 'Delete Add-on',
      actionOneText: AppLocalization.of(context)!.discard,
      actionTwoText: AppLocalization.of(context)!.continueMsg,
      description: 'Are you sure you want to delete this add-on?',
      roundedBackgroundIcon: RoundedBackgroundIcon(
        enableMargin: false,
        width: 90,
        height: 90,
        image: Image.asset('assets/images/delete_dialog_icon.png'),
      ),
      rightButtonOnPressed: () async {
        deleteAddOn(addOns);
      },
    );
  }

  void deleteAddOn(AddOns? addOns) {
    _auth.deleteAddOn(addOns!.id!).then((value) {
      if (value) {
        showToast(
            message: AppLocalization.of(context)!.addOnDeletedSuccessfully);
        //remove the selected add-on from the list using it id
        // _onRefresh();
        productAddOnList.removeWhere((addOn) => addOn.id == addOns.id);
        if (mounted) setState(() {});
      } else {
        showToast(message: AppLocalization.of(context)!.addOnIsNotDeleted);
      }
    }).catchError((error) {
      showToast(message: error.toString());
    });
  }

  @override
  void dispose() {
    // unsecureScreen();
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }
}
