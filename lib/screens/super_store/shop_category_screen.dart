import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/yarn/models/Topics/yarn_model.dart';
import 'package:Slydo/screens/more_apps/yarn/models/ask_categories_model.dart';
import 'package:Slydo/screens/more_apps/yarn/models/share_as_yarn_model.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_tab_selection.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_new_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

import '../more_apps/shopping/models/store.dart';
import '../more_apps/shopping/shopping_auth.dart';
import '../more_apps/yarn/yarn_dashboard_bloc.dart';


class ShopCategoryScreen extends StatefulWidget {
  ProductCategory? productCategories;
  ShopCategoryScreen({this.productCategories});

  @override
  State<ShopCategoryScreen> createState() => _ShopCategoryScreenState();
}

class _ShopCategoryScreenState extends State<ShopCategoryScreen> {
  late PageController _pageViewCtrl;
  UsersCategories? usersCategory;
  late UserBloc userBloc;
  late YarnDashboardBloc askViewModel;
  int currentAskTapOnHome = 0;
  List<Product> productList = [];
  bool isProductLoading = false;
  bool noProductInList = false;
  int? productCount = 0;
  String? todayDealNext = "";
  String? productNext = "";
  String? productPrevious = "";
  // GlobalKey<YarnListScreenState> topicViewStateKey =
  // GlobalKey<YarnListScreenState>();
  // GlobalKey<TrendingListScreenState> latestViewStateKey =
  // GlobalKey<TrendingListScreenState>();
  late YarnDashboardBloc yarnDashboardBloc;

  bool _tabsVisible = true;

  @override
  void initState() {
    _pageViewCtrl = PageController(initialPage: 0);
    getProductList();
    super.initState();
  }

  void _showTabs(bool visible) {
    if (_tabsVisible != visible) {
      setState(() {
        _tabsVisible = visible;
      });
    }
  }

  void getProductList() async {
    if (!isProductLoading) {
      if (productNext != null && !isProductLoading) {
        isProductLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await ShoppingAuthService()
            .listOfProduct(productNext, productPrevious, widget.productCategories!.name , otherDeals: true);

        if (result == null) {
          noProductInList = true;

          isProductLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        productCount = result['count'];
        productNext = result['next'];
        productPrevious = result['previous'];
        var tempList = result['results'];
        if (mounted) {
          setState(() {
            noProductInList = false;
            isProductLoading = false;
            productList.addAll(tempList);
          });
        }
      }
      if (productList.isEmpty) {
        if (mounted) {
          setState(() {
            noProductInList = true;
          });
        }
      } else if (productNext == null && productList.length > 6) {
        // _productScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
        //   content:
        //   Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
        //   duration: Duration(milliseconds: 500),
        // ));
      }
    }
  }

  Future<UsersCategories?> getUserCategories() async {
    // Map<String, dynamic>? result = await YarnAuth().getUsersCategories();
    // setState(() {
    //   usersCategory = result!['results'];
    // });
    // return usersCategory!;
  }

  Future<UsersCategories?> saveUserCategories(String categoryId) async {
    // Map<String, dynamic>? result =
    // await YarnAuth().saveUsersSingleCategories(categoryId);
    // setState(() {
    //   usersCategory = result!['results'];
    // });
    // return usersCategory!;
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    askViewModel = Provider.of<YarnDashboardBloc>(context);
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }


  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(50.0),
      child: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 0,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.productCategories!.name,
              overflow: TextOverflow.fade,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: yarnBlack,
              ),
            ),
          ],
        ),
        actions: [
          // Row(
          //   children: [
          //     InkWell(
          //       onTap: () {
          //         NavigationUtil.push(
          //           context,
          //           screen: SearchScreen(
          //             askCategory: widget.askCategories,
          //           ),
          //         );
          //       },
          //       child: Icon(
          //         Icons.search_rounded,
          //         color: yarnBlack,
          //         size: 26,
          //       ),
          //     ),
          //     SizedBox(width: 10),
          //     !isAddCategory()!
          //         ? InkWell(
          //       onTap: () {
          //         saveUserCategories(widget.askCategories!.id!);
          //       },
          //       child: Container(
          //         decoration: BoxDecoration(
          //           color: white,
          //           borderRadius: BorderRadius.circular(9),
          //         ),
          //         child: Padding(
          //           padding: const EdgeInsets.symmetric(
          //               horizontal: 10, vertical: 5),
          //           child: Text(
          //             'Add',
          //             style: TextStyle(
          //               color: blackFont,
          //               fontSize: 13,
          //               fontWeight: FontWeight.w600,
          //             ),
          //           ),
          //         ),
          //       ),
          //     )
          //         : InkWell(
          //       onTap: () {
          //         Navigator.pushNamed(context, Routes.USER_PROFILE,
          //             arguments: {
          //               "searchedUserName": userBloc.user.userName
          //             });
          //       },
          //       child: Container(
          //         height: 24,
          //         width: 24,
          //         decoration: BoxDecoration(shape: BoxShape.circle),
          //         child: ClipOval(
          //           child: CachedNetworkImage(
          //             imageUrl: userBloc.user.avatar!,
          //             fit: BoxFit.cover,
          //             errorWidget: imageErrorWidget,
          //           ),
          //         ),
          //       ),
          //     ),
          //     SizedBox(width: 17),
          //   ],
          // ),
        ],
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            color: yarnBlack,
            size: 26,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollUpdateNotification) {
          if (scrollNotification.scrollDelta! > 0 && _tabsVisible) {
            // Scrolling down
            _showTabs(false);
          } else if (scrollNotification.scrollDelta! < 0 && !_tabsVisible) {
            // Scrolling up
            _showTabs(true);
          }
        }

        return true;
      },
      child: Column(
        children: [
          SizedBox(
            height: 16,
          ),
          _buildCategoryAndTabs(),
          _buildPageView(),
        ],
      ),
    );
  }

  Widget _buildCategoryAndTabs() {
    return Column(
      children: [
        if (_tabsVisible) ...[
          YarnTabSelection(
            onTap: (index) {
              currentAskTapOnHome = index;
              _pageViewCtrl.jumpToPage(currentAskTapOnHome);
              if (mounted) setState(() {});
            },
            currentIndex: currentAskTapOnHome,
            firstTab: 'Latest',
            secondTab: 'Trending',
          ),
          SizedBox(
            height: 16,
          ),
          Divider(
            height: 0,
            thickness: 0.5,
            color: greySecondaryYarn,
          ),
        ],
      ],
    );
  }

  Widget _buildPageView() {
    return Expanded(
      child: PageView(
        onPageChanged: (currentPage) {
          updateCurrentAskTapOnHome(index: currentPage);
        },
        controller: _pageViewCtrl,
        children: [
          // YarnListScreen(
          //   key: topicViewStateKey,
          //   selectedCategory: widget.askCategories!.id,
          //   onPageRefresh: (bool data) {
          //     if (data == true) {
          //       _showTabs(true);
          //     }
          //   },
          // ),
          // TrendingListScreen(
          //   key: latestViewStateKey,
          //   selectedCategory: widget.askCategories!.id,
          //   onPageRefresh: (bool data) {
          //     if (data == true) {
          //       _showTabs(true);
          //     }
          //   },
          // ),
        ],
      ),
    );
  }

  void updateCurrentAskTapOnHome({required int index}) {
    setState(() {
      currentAskTapOnHome = index;
    });
  }

  Widget pageViewTabItem(
      {required int pageNum,
        required String title,
        int? currentTapIndex,
        Function? onPageTap}) {
    return InkWell(
      onTap: () => onPageTap!(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          shape: BoxShape.rectangle,
          color: Colors.white,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: blackFont,
            fontSize: 14,
            fontWeight:
            currentTapIndex == pageNum ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  bool? isAddCategory() {
    bool isAdded = false;
    if (usersCategory != null) {
      for (var usCate in usersCategory!.categories!) {
        if (widget.productCategories!.name == usCate.name) {
          isAdded = true;
          break;
        }
      }
    }
    return isAdded;
  }
}
