import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:Slydo/widget/vertical_list_item.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../data/currency.dart';
import '../../../../../routes/route_constants.dart';
import '../../../../../widget/curved_btn.dart';
import '../../../../../widget/custom_box_shadow.dart';
import '../../models/store.dart';
import '../../shopping_auth.dart';

class AddOnOptionList extends StatefulWidget {
  var arguments;

  AddOnOptionList({this.arguments, Key? key}) : super(key: key);

  @override
  _AddOnOptionListState createState() => _AddOnOptionListState();
}

class _AddOnOptionListState extends State<AddOnOptionList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // Get list of users bank account
  late UserBloc userBloc;
  int? count = 0;
  String? next = "";
  String? previous = "";
  String? productId = "";
  List<AddOnOption> addOnOptionList = [];
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;
  final _auth = ShoppingAuthService();
  bool isAPILoading = false;
  List<AddOnOption> selectedOptions = [];

  //slidable tile
  SlidableController? _slideController;

  @override
  void initState() {
    productId = widget.arguments["productId"];
    selectedOptions = widget.arguments["options"];

    getAddOnOptionList();

    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        if (next != null) {
          getAddOnOptionList();
        }
      }
    });

    _slideController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
  }

  void getAddOnOptionList() async {
    if (!isLoading) {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      final Map<String, dynamic>? result =
          await _auth.getAddOnOptionsList(productId!, next, previous);
      if (result == null) {
        isLoading = false;
        noItemInList = true;
        return;
      }
      addOnOptionList = [];
      count = result['count'];
      next = result['next'];
      previous = result['previous'];
      final tempList = result['results'];

      addOnOptionList.addAll(tempList);

      for (var allOptions in addOnOptionList) {
        for (var selectedOption in selectedOptions) {
          if (selectedOption.id == allOptions.id) {
            allOptions.isSelected = true;
          }
        }
      }

      if (mounted) {
        setState(() {
          isLoading = false;
          noItemInList = false;
        });
      }

      if (addOnOptionList.isEmpty) {
        if (mounted) {
          setState(() {
            noItemInList = true;
          });
        }
      } else if (next == null && addOnOptionList.length > 6) {
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
    Connectivity().checkConnectivity().then((value) {
      final connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        count = 0;
        next = "";
        previous = "";
        addOnOptionList = [];
        if (mounted) setState(() {});
        getAddOnOptionList();
        setState(() {
          // Call the callback function with the updated list
          //to pass the list back to edit product page
          // widget.onListRefreshed!(productVariantList);
          _refreshController.refreshCompleted();
        });
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, addOnOptionList);
        return true;
      },
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: lightGrey,
          appBar: appBar() as PreferredSizeWidget?,
          floatingActionButton: getSubmitButton(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: SmartRefresher(
              enablePullDown: true,
              header: WaterDropHeader(
                complete: Container(),
                waterDropColor: navyBlue,
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: _buildAddOnOptionList()),
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          final List<AddOnOption> addOnOption = addOnOptionList
              .where((addOnOption) => addOnOption.isSelected == true)
              .toList();
          Navigator.pop(context, addOnOption);
        },
      ),
      centerTitle: false,
      title: Text(
        AppLocalization.of(context)!.option,
        style: TextStyle(
          color: blackFont,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: <Widget>[
        addOptionBtn(),
        const SizedBox(
          width: 16,
        ),
      ],
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
        if (result != null && result is Variant) {
          //save the variant details for later use
          _onRefresh();
          // variantData = result;
          if (mounted) setState(() {});
        }
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget _buildAddOnOptionList() {
    return noItemInList
        ? NoItemInList(
            title: AppLocalization.of(context)!.noAddOnYet,
            msg: AppLocalization.of(context)!.noAddOnYetSub,
          )
        : isLoading && addOnOptionList.isEmpty
            ? buildLoadingIndicator(isLoading: isLoading)
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                //+1 for progressbar
                itemCount: addOnOptionList.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == addOnOptionList.length) {
                    return buildJumpingLoadingIndicator(isLoading: isLoading);
                  } else {
                    return _getSlidableWithLists(
                        context,
                        GestureDetector(
                          onTap: () async {
                            // toggleAddOnCheckedState(index);
                            final data = await Navigator.of(context).pushNamed(
                                Routes.PRODUCT_ADD_ON_OPTION_UPDATE,
                                arguments: {
                                  'addOnOption': addOnOptionList[index],
                                  'productId': productId,
                                });

                            // Handle the result (map) received from PRODUCT_ADD_ON_OPTION_UPDATE
                            if (data != null && data is AddOnOption) {
                              //save the add-on option details for later use
                              // _onRefresh();
                              updateItemById(data.id!, data);
                              if (mounted) setState(() {});
                            }
                          },
                          child: addOnOptionTile(
                              addOnOption: addOnOptionList[index],
                              index: index),
                        ),
                        addOnOptionList[index]);
                  }
                },
                controller: _scrollController,
              );
  }

  Widget addOnOptionTile({required AddOnOption addOnOption, int? index}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: decorateBox(),
        child: ListTile(
          // dense: variant.isDefault! ? true : false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                appendStringDot(addOnOption.name!, 14),
                maxLines: 1,
                style: TextStyle(
                  color: blackFont,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  fontFamily: "Inter",
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                'Created: ${addOnOption.createdAt} ',
                maxLines: 1,
                style: TextStyle(
                  color: darkGrey,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  fontFamily: "Inter",
                ),
              ),
            ],
          ),
          leading: checkProductImage(addOnOption),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    worldCurrencies[addOnOption.currency!]!,
                    style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: 14.0,
                        color: darkGrey,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    moneyDisplayNormalizer(
                        int.parse(addOnOption.price.toString())),
                    style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: 14.0,
                        color: darkGrey,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Expanded(
                child: Checkbox(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: addOnOption.isSelected,
                  activeColor: navyBlue,
                  onChanged: (bool? value) {
                    // Handle checkbox state change here
                    toggleAddOnCheckedState(index!);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void toggleAddOnCheckedState(int index) {
    if (index >= 0 && index < addOnOptionList.length) {
      addOnOptionList[index].isSelected = !addOnOptionList[index].isSelected;
      if (mounted) setState(() {});
    }
  }

  Widget getSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: CurvedButton(
        onPressed: isAPILoading
            ? () {}
            : () async {
                FocusScope.of(context).unfocus();

                isAPILoading = true;
                if (mounted) setState(() {});

                await loadAllCheckedAddOn();

                isAPILoading = false;
                if (mounted) setState(() {});
              },
        backgroundColor: navyBlue,
        textColor: Colors.white,
        text: "Save",
        isLoading: isAPILoading,
      ),
    );
  }

  Widget loadAllCheckedAddOn() {
    final List<AddOnOption> addOnOption = addOnOptionList
        .where((addOnOption) => addOnOption.isSelected == true)
        .toList();

    Navigator.pop(context, addOnOption);
    return Container();
  }

  Widget checkProductImage(AddOnOption addOnOption) {
    // Retrieve the first image from the 'pictures' list
    String? url = "";

    url = addOnOption.picture;

    final String imageUrl = url!.replaceAll('https//', 'https://');
    if (url == "") {
      return CircleAvatar(
        backgroundColor: navyBlue,
        radius: 25,
        child: Text(
          getInitials(addOnOption.name!).toUpperCase(),
          style: TextStyle(color: white, fontWeight: FontWeight.w700),
        ),
      );
    } else {
      return CustomBoxShadow(
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
                image: NetworkImage(
                  imageUrl,
                ),
                fit: BoxFit.cover),
          ),
        ),
      );
    }
  }

  Widget _getSlidableWithLists(
      BuildContext context, Widget bankAccountTile, AddOnOption addOnOption) {
    return Slidable(
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: const SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(bankAccountTile),
      actions: listActionSlideActions(addOnOption: addOnOption),
      // secondaryActions: listSecondaryActions(addOnOption: addOnOption),
    );
  }

  List<Widget> listSecondaryActions({required AddOnOption addOnOption}) {
    return [
      SlideActionButton(
          backgroundColor: starYellow,
          icon: Icons.edit,
          onTap: () async {
            final data = await Navigator.of(context)
                .pushNamed(Routes.PRODUCT_ADD_ON_OPTION_UPDATE, arguments: {
              'addOnOption': addOnOption,
              'productId': productId,
            });

            // Handle the result (map) received from PRODUCT_ADD_ON_OPTION_UPDATE
            if (data != null && data is AddOnOption) {
              //save the add-on option details for later use
              // _onRefresh();
              updateItemById(data.id!, data);
              if (mounted) setState(() {});
            }
          },
          title: AppLocalization.of(context)!.edit,
          slideController: _slideController),
    ];
  }

  void updateItemById(int id, AddOnOption updatedItem) {
    for (int i = 0; i < addOnOptionList.length; i++) {
      if (addOnOptionList[i].id == id) {
        addOnOptionList[i] = updatedItem;
        break; // Stop iterating once the item is found and updated
      }
    }
  }

  List<Widget> listActionSlideActions({AddOnOption? addOnOption}) {
    return [
      SlideActionButton(
          backgroundColor: mateRed,
          icon: SlydoAppIcon.remove,
          onTap: () async {
            deleteAddOnDialog(addOnOption!);
          },
          title: AppLocalization.of(context)!.delete,
          slideController: _slideController),
    ];
  }

  void deleteAddOnDialog(AddOnOption addOnOption) {
    showDialogBox(
      context: context,
      actionOneTextColor: blackFont,
      actionOneBgColor: greyBorderColor,
      actionTwoTextColor: white,
      actionTwoBgColor: mateRed,
      title: 'Delete Add-on Option',
      actionOneText: AppLocalization.of(context)!.discard,
      actionTwoText: AppLocalization.of(context)!.continueMsg,
      description: 'Are you sure you want to delete this add-on option?',
      roundedBackgroundIcon: RoundedBackgroundIcon(
        enableMargin: false,
        width: 90,
        height: 90,
        image: Image.asset('assets/images/delete_dialog_icon.png'),
      ),
      rightButtonOnPressed: () async {
        deleteAddOnOption(addOnOption);
      },
    );
  }

  void deleteAddOnOption(AddOnOption addOnOption) {
    _auth.deleteAddOnOption(addOnOption.id!).then((value) {
      if (value) {
        showToast(
            message:
                AppLocalization.of(context)!.addOnOptionDeletedSuccessfully);
        //remove the selected add-on option from the list using it id
        // _onRefresh();
        addOnOptionList.removeWhere((addOn) => addOn.id == addOnOption.id);
        if (mounted) setState(() {});
      } else {
        showToast(
            message: AppLocalization.of(context)!.addOnOptionIsNotDeleted);
      }
    }).catchError((error) {
      showToast(message: error.toString());
    });
  }

  void handleSlideAnimationChanged(Animation<double>? slideAnimation) {}

  void handleSlideIsOpenChanged(bool? isOpen) {}

  @override
  void dispose() {
    // unsecureScreen();
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }
}
