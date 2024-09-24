import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/user_profile/utils.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// ignore: must_be_immutable
class CustomCategoryList extends StatefulWidget {
  CustomCategoryList({super.key, this.arguments});

  dynamic arguments;

  @override
  State<CustomCategoryList> createState() => _CustomCategoryListState();
}

class _CustomCategoryListState extends State<CustomCategoryList> {
  // this variable responsible for product pagination
  int? itemCount = 0;
  String? next = "";
  String? previous = "";
  List<ProductCategory> itemList = [];
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _messengerScaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;
  bool saveRequired = false;
  UserBloc? userBloc;
  Map<String, dynamic> reorderedBoolMap = {};
  final Map<String, dynamic> data = {};

  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1), () {
      getList();
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
    if (await checkConnection(context)) {
      itemCount = 0;
      next = "";
      previous = "";
      itemList = [];
      // debugPrint("Refresh called on discount!!  ");
      getList();
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
    }
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

        final List<ProductCategory> result = await ShoppingAuthService()
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
        _messengerScaffoldKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  void addCategory() {
    showDialogBoxWithInput(
      context: context,
      actionOneTextColor: white,
      actionOneBgColor: navyBlue,
      actionTwoTextColor: blackFont,
      actionTwoBgColor: greyBorderColor,
      actionOneText: "Save",
      content: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Spacer(),
                Text("Add Custom Category",
                    style: TextStyle(
                        color: blackFont,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                    textAlign: TextAlign.center),
                const Spacer(),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.highlight_off_rounded))
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: CustomizedTextFormField(
              labelText: "Name",
              controller: _controller,
              validator: (val) {
                if (val.isNotEmpty) {
                  return null;
                }
                return AppLocalization.of(context)!.pleaseEnterManufacturerName;
              },
              onChanged: (val) {
                // productManufacturer = val;
              },
            ),
          ),
        ],
      ),
      leftButtonOnPressed: () async {
        if (_controller.text.isNotEmpty) {
          final bool result = await ShoppingAuthService()
              .createCustomCategory(_controller.text);
          _onProductRefresh();
          _controller.clear();
          Navigator.pop(context);
        }
      },
    );
  }

  void deleteOrEditCategory(ProductCategory prod, int index) {
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
        content: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 10),
              child: Row(
                children: [
                  const Spacer(),
                  Text("Edit Custom Category",
                      style: TextStyle(
                          color: blackFont,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0),
                      textAlign: TextAlign.center),
                  const Spacer(),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.highlight_off_rounded))
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
            const SizedBox(height: 5)
          ],
        ),
        leftButtonOnPressed: () async {
          deleteCategoryDialog(prod.id);
        },
        rightButtonOnPressed: () async {
          final bool result = await ShoppingAuthService()
              .editCustomCategory(_controller.text, prod.id);
          _onProductRefresh();
          _controller.clear();
          Navigator.pop(context);
        });
  }

  void deleteCategoryDialog(dynamic id) {
    showDialogBox(
      context: context,
      actionOneTextColor: blackFont,
      actionOneBgColor: greyBorderColor,
      actionTwoTextColor: white,
      actionTwoBgColor: mateRed,
      title: 'Delete Custom Category',
      actionOneText: AppLocalization.of(context)!.discard,
      actionTwoText: AppLocalization.of(context)!.continueMsg,
      description: 'Are you sure you want to delete this custom category?',
      roundedBackgroundIcon: RoundedBackgroundIcon(
        enableMargin: false,
        width: 90,
        height: 90,
        image: Image.asset('assets/images/delete_dialog_icon.png'),
      ),
      rightButtonOnPressed: () async {
        final bool result =
            await ShoppingAuthService().deleteCustomCategory(id);
        _onProductRefresh();
        _controller.clear();
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _messengerScaffoldKey,
      child: WillPopScope(
        onWillPop: () async {
          if (widget.arguments != null && widget.arguments["isHome"] == true) {
            Navigator.pop(context);
          } else {
            Navigator.popUntil(context, ModalRoute.withName(Routes.DASHBOARD));
            Navigator.pushNamed(context, Routes.USER_PROFILE,
                arguments: {"searchedUserName": userBloc?.user.userName});
          }
          return true;
        },
        child: Scaffold(
          key: _scaffoldKey,
          appBar: _buildAppBar() as PreferredSizeWidget,
          body: Container(
            color: white,
            padding: const EdgeInsets.symmetric(horizontal: 4),
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
                      ? buildShimmerEffect()
                      : _buildItemList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
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
        onPressed: () async {
          if (widget.arguments != null && widget.arguments["isHome"] == true) {
            Navigator.pop(context);
          } else {
            Navigator.popUntil(context, ModalRoute.withName(Routes.DASHBOARD));
            Navigator.pushNamed(context, Routes.USER_PROFILE,
                arguments: {"searchedUserName": userBloc?.user.userName});
          }
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
          backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
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
      const SizedBox(width: 30),
    ];
  }

  Widget _buildItemList() {
    return next == "" && isLoading
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: ReorderableListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itemList.length,
                itemBuilder: (context, index) {
                  final int key = itemList[index].id;
                  return ReorderableDragStartListener(
                    key: ValueKey(key),
                    index: index,
                    child: itemTile(index),
                  );
                },
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final entry = itemList.removeAt(oldIndex);
                    itemList.insert(newIndex, entry);
                    reorderedBoolMap = Map.fromEntries(
                      itemList.map(
                        (item) => MapEntry(item.name, item.id),
                      ),
                    );
                    saveRequired = true;
                    for (int index = 0; index < itemList.length; index++) {
                      final customCategory = itemList[index];
                      data.addAll({"${customCategory.id}": index + 1});
                    }
                    ShoppingAuthService()
                        .reOrderCustomCategory(data, userBloc?.user.userName);
                  });
                },
              ),
            ),
          );
  }

  Widget itemTile(int index) {
    return InkWell(
      onTap: () async {
        deleteOrEditCategory(itemList[index], index);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: selectedListItemBackgroundBlue, width: 1),
              borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.zero,
          color: white,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              messageDecoderWithEmoji(itemList[index].name) ??
                  itemList[index].name,
              maxLines: 1,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  fontFamily: "Inter",
                  color: blackFont),
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
