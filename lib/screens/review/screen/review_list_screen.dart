import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/review/models/review.dart';
import 'package:Slydo/screens/review/review_auth.dart';
import 'package:Slydo/screens/review/tiles/review_tile.dart';
import 'package:Slydo/screens/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewListScreen extends StatefulWidget {
  const ReviewListScreen({super.key, required this.arguments});

  final Map<String, dynamic> arguments;

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  // this variable responsible for product pagination
  int? reviewCount = 0;
  String? reviewNext = "";
  String? reviewPrevious = "";
  List<Review> reviewList = [];

  bool isLoading = false;
  bool noReviewInList = false;
  final ScrollController _scrollController = ScrollController();

  CustomerProfile? reviewedUser;
  Product? product;
  Service? service;
  double rating = 0.0;

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    reviewedUser = widget.arguments["reviewedUser"];
    product = widget.arguments["reviewedProduct"];
    service = widget.arguments["reviewedService"];

    getProductList();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getProductList();
      }
    });

    super.initState();
  }

  void getProductList() async {
    if (!isLoading) {
      if (reviewNext != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result;

        if (product != null) {
          result =
              await ReviewAuth().fetchProductReviews(productId: product?.id);
        } else if (service != null) {
          result =
              await ReviewAuth().fetchServiceReviews(serviceId: service?.id);
        } else {
          result = await ReviewAuth()
              .fetchUserReviews(userName: reviewedUser?.userName);
        }

        // debugPrint('REVIEW LIST :: $result');

        // if(result['error'] == 'review not found'){
        //   if (mounted) {
        //     setState(() {
        //       noReviewInList = true;
        //     });
        //   }
        // }

        if (result.isEmpty) {
          isLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        reviewCount = result['count'];
        reviewNext = result['next'];
        reviewPrevious = result['previous'];
        final List? tempList = result['results'];

        if (tempList != null) {
          final List<Review> list =
              tempList.map((e) => Review.fromJson(e)).toList();

          if (mounted) {
            setState(() {
              noReviewInList = false;
              isLoading = false;
              reviewList.addAll(list);
            });
          }
        }
      }
      // debugPrint('REVIEW LIST  34 ::: $reviewList');

      if (reviewList.isEmpty) {
        if (mounted) {
          // debugPrint('REVIEW LIST   empty::: $reviewList');

          setState(() {
            isLoading = false;
            noReviewInList = true;
          });
        }
      } else if (reviewNext == null && reviewList.length > 6) {
        _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  String getReviewTotal() {
    if (product != null) {
      rating = product?.rating ?? 0.0;
      return product?.rating?.toString() ?? "0";
    }
    if (service != null) {
      rating = service?.rating ?? 0.0;
      return service?.rating?.toString() ?? "0";
    }
    return "5";
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: lightGrey,
        appBar: AppBar(
          title: Text(
            "Reviews($reviewCount)",
            style: TextStyle(
              color: blackFont,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
            child: Column(
              children: [
                Align(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: getReviewTotal(),
                              style: TextStyle(
                                fontSize: 18,
                                color: blackFont,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: '/5.0',
                              style: TextStyle(
                                fontSize: 14,
                                color: blackFont,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildRatingBar(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (isLoading)
                  Expanded(
                    child: Center(
                      child: CircularLoadingIndicator(),
                    ),
                  )
                else
                  noReviewInList
                      ? Expanded(child: NoItemInList(msg: "No Review yet"))
                      : Expanded(
                          child: ListView.builder(
                            itemBuilder: (context, index) => ReviewTile(
                              review: reviewList[index],
                              product: product,
                              reviewedUser: reviewedUser,
                              service: service,
                            ),
                            itemCount: reviewList.length,
                          ),
                        ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingBar() {
    return Center(
      child: RatingBar.builder(
        ignoreGestures: true,
        initialRating: rating.toDouble(),
        minRating: 1,
        direction: Axis.horizontal,
        itemSize: 15,
        allowHalfRating: true,
        itemCount: 5,
        itemPadding: const EdgeInsets.symmetric(horizontal: 2),
        itemBuilder: (context, _) => Icon(
          SlydoAppIcon.star,
          color: starYellow,
        ),
        onRatingUpdate: (rate) {
          rating = rate;
        },
        unratedColor: starYellow.withOpacity(0.2),
        glowColor: starYellow.withOpacity(0.2),
      ),
    );
  }
}
