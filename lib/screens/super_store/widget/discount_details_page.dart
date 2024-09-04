// import 'package:Slydo/data/environment.dart';
import 'package:Slydo/data/state_notifiers/basket_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/product_view_more_details.dart';
// import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/product_view_more_details.dart';
// import 'package:Slydo/screens/super_store/models/product_industry_model.dart';
import 'package:Slydo/screens/super_store/widget/section_products.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/navigation_util.dart';
// import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/custom_pagination.dart';
import 'package:Slydo/widget/empty_page.dart';
import 'package:Slydo/widget/item_display_card.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class DiscountDetailsPage extends StatefulWidget {
  final Function(bool)? onPageRefresh;
  final String? category;
  final String industry;
  final String? nextUrl;
  final String? type;
  final String? categoryId;
  final String? industryId;
  final dynamic arguments;

  const DiscountDetailsPage({
    super.key,
    this.onPageRefresh,
    this.category,
    required this.industry,
    this.nextUrl,
    this.type,
    this.categoryId,
    this.industryId,
    this.arguments,
  });

  @override
  State<DiscountDetailsPage> createState() => DiscountDetailsPageState();
}

class DiscountDetailsPageState extends State<DiscountDetailsPage> {
  List<Product> productList = [];
  List<Product> superStoreProductTab = [];
  int productHorizontalLength = 10;
  bool isProductLoading = false;
  bool dealsOfDayEmpty = false;
  bool noProductInList = false;
  int? productCount = 0;
  String? productNext = "";
  String? productPrevious = "";
  late BasketBloc basketBloc;
  List rowHeaders = [];
  bool _isSnackBarShowing = false;
  String url = "";

  final GlobalKey<ScaffoldMessengerState> _productScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String _currentCategory = '';

  AppBar appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 16,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: Text(
        'Deal of the day',
        style: TextStyle(
          color: blackFont,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: const [
        // _cartBtn(),
        // SizedBox(width: 12),
      ],
    );
  }

  Future<void> listOfSuperStores() async {
    if (mounted) {
      isProductLoading = true;
    }
    final Map<String, dynamic>? result =
        await ShoppingAuthService().listOfSuperStores(sectionUrl: productNext);
    setState(() {
      rowHeaders = result!['store'];
      isProductLoading = false;
    });
  }

  void loadUrl() {
    if (widget.nextUrl != null && widget.nextUrl != "") {
      productNext = widget.nextUrl;
    }
  }

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.category!;
    loadUrl();
    widget.type != null
        ? listOfSuperStores()
        : getProductList(_currentCategory);
  }

  @override
  void didUpdateWidget(DiscountDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.category != _currentCategory) {
      _currentCategory = widget.category!;
      debugPrint('CALLING OTHER ::: $_currentCategory');
      // _refreshPage(); // Reload shop list when category changes
    }
  }

  void getProductList(String category) async {
    if (!isProductLoading) {
      if (productNext != null && !isProductLoading) {
        isProductLoading = true;
        if (mounted) setState(() {});

        final Map<String, dynamic>? result = await ShoppingAuthService()
            .listOfProduct(
                productNext, productPrevious, _currentCategory, false,
                otherDeals: true);
        if (result == null) {
          noProductInList = true;

          isProductLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        productCount = result['count'];
        productPrevious = result['previous'];
        final tempList = result['results'];
        if (mounted) {
          setState(() {
            productNext = result['next'];
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
            isProductLoading = false;
          });
        }
      } else if (productNext == null &&
          productList.length > 6 &&
          !_isSnackBarShowing) {
        _isSnackBarShowing = true;
        _productScaffoldMessengerKey.currentState
            ?.showSnackBar(SnackBar(
              content: Text(
                  AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
              duration: const Duration(milliseconds: 500),
            ))
            .closed
            .then((_) {
          _isSnackBarShowing = false;
        });
      }
    }
  }

  void _onRefresh() async {
    if (await checkConnection(context)) {
      _refreshPage();
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  void _refreshPage() {
    productNext = "";
    productCount = 0;
    productPrevious = "";
    isProductLoading = false;
    productList = [];

    loadUrl();
    widget.type != null
        ? listOfSuperStores()
        : getProductList(_currentCategory);
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // if (_productScrollController.position.pixels == 0) {
      //   // Scroll controller is at the top
      //   widget.onPageRefresh!(true);
      //   if (mounted) setState(() {});
      // }
    });

    return CustomPagination(
      onScrollEnd: () async {
        if (widget.type == null) {
          getProductList(_currentCategory);
        }
      },
      child: ScaffoldMessenger(
        key: _productScaffoldMessengerKey,
        child: Scaffold(
          backgroundColor: lightGrey,
          // appBar: appBar(),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SmartRefresher(
                enablePullDown: true,
                header: WaterDropHeader(
                  complete: Container(),
                  waterDropColor: navyBlue,
                ),
                controller: _refreshController,
                onRefresh: _onRefresh,
                child: ListView(
                  children: [
                    if (widget.type != null && rowHeaders.isNotEmpty)
                      ...rowHeaders.map((headers) => rowTitle(headers)),
                    if (rowHeaders.isEmpty &&
                        !isProductLoading &&
                        productList.isEmpty &&
                        widget.type != null)
                      EmptyPage(
                        msg: AppLocalization.of(context)!.noResultFound,
                      ),
                    if (widget.type == null) superStoreProducts(),
                    const SizedBox(height: 16),
                    if (isProductLoading && productList.isEmpty)
                      Shimmer.fromColors(
                        baseColor: Colors.white,
                        highlightColor: greyBorderColor,
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            mainAxisSpacing: 14,
                            mainAxisExtent: 180,
                            crossAxisSpacing: 15,
                            maxCrossAxisExtent: 200,
                          ),
                          itemCount: 2,
                          itemBuilder: (context, index) {
                            return Card(
                              color: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      const SizedBox.shrink(),

                    // Visibility(
                    //   visible: widget.type != null ? !isProductLoading &&
                    //       !isTodayDealLoading &&
                    //       todaysDealList.isEmpty &&
                    //      rowHeaders.isEmpty : !isProductLoading &&
                    //             !isTodayDealLoading &&
                    //             todaysDealList.isEmpty &&
                    //             productList.isEmpty ,
                    //   child:  EmptyPage(msg:   AppLocalization.of(context)!.noResultFound,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewMoreStore(BuildContext context) {
    return InkWell(
      onTap: () {
        // for (final product in todaysDealList) {
        NavigationUtil.push(
          context,
          screen: ProductViewMoreDetails(
            industryId: widget.industryId,
            // appTitle: product.name,
          ),
        );
        // }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "View more",
            style: TextStyle(
              color: navyBlue,
              fontSize: 12,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios_sharp,
            color: navyBlue,
            size: 12,
          ),
        ],
      ),
    );
  }

  Widget rowTitle(Map<String, dynamic> headers) {
    return SectionProducts(headers: headers);
  }

  Widget superStoreProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (noProductInList)
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: NoItemInList(
              msg: AppLocalization.of(context)!.noResultFound,
            ),
          )
        else ...[
          const SizedBox(height: 2),
          Container(
            margin: const EdgeInsets.only(bottom: 15.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Found $productCount ${widget.industry}",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  fontFamily: "Inter",
                  color: blackFont,
                ),
              ),
            ),
          ),
        ],
        if (isProductLoading && productList.isEmpty)
          buildLoadingIndicator(isLoading: isProductLoading)
        else
          CustomScrollView(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            slivers: <Widget>[
              SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (c, i) => SizedBox(
                    child: SuperStoreSingleCard(
                      product: productList[i],
                    ),
                  ),
                  childCount: productList.length,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  // mainAxisSpacing: 5,
                  mainAxisExtent: 250,
                  // crossAxisSpacing: 5,
                  maxCrossAxisExtent: 200,
                ),
              ),
              SliverToBoxAdapter(
                child:
                    buildJumpingLoadingIndicator(isLoading: isProductLoading),
              ),
            ],
          ),
      ],
    );
  }

  Widget searchBox() {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          selectionHandleColor: navyBlue,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed("/search-product");
        },
        child: IgnorePointer(
          ignoring: true,
          child: TextFormField(
            readOnly: true,
            style: TextStyle(
              fontSize: 16,
              fontFamily: "Inter",
              color: blackFont,
              fontWeight: FontWeight.w600,
            ),
            cursorWidth: 1.5,
            cursorColor: navyBlue,
            decoration: InputDecoration(
              hintStyle: TextStyle(
                fontSize: 14,
                fontFamily: "Inter",
                fontWeight: FontWeight.w600,
                color: darkGrey,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  SlydoAppIcon.search,
                  color: darkGrey,
                  size: 14,
                ),
                onPressed: () {},
              ),
              hintText: "Search",
              fillColor: Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              prefix: const Padding(
                padding: EdgeInsets.only(left: 16),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: dividerColor,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: navyBlue,
                  width: 1.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: dividerColor,
                  width: 1.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: dividerColor,
                  width: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SuperStoreSingleCard extends StatelessWidget {
  final Product product;

  const SuperStoreSingleCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return DisplayProduct(product: product, giveRightPadding: false);
  }
}
