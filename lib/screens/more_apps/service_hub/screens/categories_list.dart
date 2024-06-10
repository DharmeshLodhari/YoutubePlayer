import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/service_hub/auth/service_hub_auth.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/list_of_categories.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class CategoriesList extends StatefulWidget {
  const CategoriesList({Key? key}) : super(key: key);

  @override
  State<CategoriesList> createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  bool isCategoryLoading = false;
  String? categoryNext = "";
  String? categoryPrevious = "";
  int? productCount = 0;
  bool noJobsInList = false;
  final GlobalKey _categoriesScaffoldMessengerKey = GlobalKey<FormState>();

  List<CategoryListData> categoriesList = [];

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final ScrollController _categoryScrollController = ScrollController();

  void getCategoriesList() async {
    if (!isCategoryLoading) {
      if (categoryNext != null && !isCategoryLoading) {
        isCategoryLoading = true;
        if (mounted) setState(() {});

        final result = await ServiceHubAuthService()
            .getListOfCategories(categoryNext, categoryPrevious);

        if (result == null) {
          noJobsInList = true;

          isCategoryLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        productCount = result.count;
        categoryNext = result.next;
        categoryPrevious = result.previous;
        final tempList = result.results;
        if (mounted) {
          setState(() {
            noJobsInList = false;
            isCategoryLoading = false;
            categoriesList.addAll(tempList!);
          });
        }
      }
      if (categoriesList.isEmpty) {
        if (mounted) {
          setState(() {
            noJobsInList = true;
          });
        }
      } else if (categoryNext == null && categoriesList.length > 6) {
        // _productScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        //   content:
        //       Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
        //   duration: Duration(milliseconds: 500),
        // ));
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
    categoryNext = "";
    productCount = 0;
    isCategoryLoading = false;
    categoriesList = [];

    categoryPrevious = "";

    getCategoriesList();
  }

  @override
  void initState() {
    super.initState();
    getCategoriesList();
    _categoryScrollController.addListener(() {
      if (_categoryScrollController.position.pixels ==
              _categoryScrollController.position.maxScrollExtent &&
          _categoryScrollController.position.pixels != 0) {
        getCategoriesList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _categoriesScaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: lightGrey,
        appBar: appBar(),
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
                controller: _categoryScrollController,
                children: [
                  getCategoryData(context),
                  const SizedBox(height: 16),
                  if (isCategoryLoading)
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
                  Visibility(
                    visible: !isCategoryLoading && categoriesList.isEmpty,
                    child: Center(
                      child: Column(
                        children: [
                          Lottie.asset('assets/lottie/no_moment_lottie.json'),
                          const SizedBox(height: 20),
                          const Text('No items at the moment'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 16,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: false,
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
      title: Text(
        "Categories",
        style: TextStyle(
          color: blackFont,
          fontFamily: "Inter",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget getCategoryData(BuildContext context) {
    if (categoriesList.isEmpty) {
      return const SizedBox.shrink();
    }
    return categoryNext == "" && isCategoryLoading
        ? const SizedBox.shrink()
        : Column(
            children: [
              GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    mainAxisSpacing: 22,
                    mainAxisExtent: 150,
                    crossAxisSpacing: 15,
                    maxCrossAxisExtent: 200,
                  ),
                  itemCount: categoriesList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, Routes.CATEGORY_JOBS,
                            arguments: categoriesList[index].slug),
                        child: CategoryCard(
                            imageUrl: categoriesList[index].image,
                            title: categoriesList[index].name),
                      ),
                    );
                  }),
            ],
          );
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    Key? key,
    required this.imageUrl,
    required this.title,
  }) : super(key: key);

  final String? imageUrl;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        // color: Color(0x7f000000),
        image: DecorationImage(
          image: NetworkImage(imageUrl!),
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5), BlendMode.srcOver),
          fit: BoxFit.cover,
        ),
      ),
      child: Text(
        title!,
        style: TextStyle(
          color: white,
          fontFamily: "Inter",
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
