import 'package:Slydo/screens/more_apps/review/models/review.dart';
import 'package:Slydo/screens/more_apps/review/tiles/review_tile.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ReviewDetailScreen extends StatefulWidget {
  ReviewDetailScreen({super.key, required this.arguments});
  final Map<String, dynamic> arguments;

  @override
  _ReviewDetailScreenState createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  Review? review;
  CustomerProfile? reviewedUser;
  Product? product;
  Service? service;

  @override
  void initState() {
    review = widget.arguments["review"];
    reviewedUser = widget.arguments["reviewedUser"];
    product = widget.arguments["reviewedProduct"];
    service = widget.arguments["reviewedService"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Review detail",
          style: TextStyle(
            color: blackFont,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(Icons.close),
              color: Colors.black,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: getImageUrl(),
                          height: 200,
                          width: 200,
                          fit: BoxFit.fill,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        messageDecoderWithEmoji(getTitle())!,
                        style: TextStyle(
                          fontSize: 18,
                          color: blackFont,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        messageDecoderWithEmoji(getSubTitle())!,
                        style: TextStyle(
                          fontSize: 16,
                          color: blackFont,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                _buildUserReview(),
                const SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getImageUrl() {
    if (product != null) {
      return product?.cover ?? "";
    } else if (service != null) {
      return service?.cover ?? "";
    }
    return reviewedUser?.avatar ?? "";
  }

  String getTitle() {
    if (product != null) {
      return messageDecoderWithEmoji(product?.name) ?? "";
    } else if (service != null) {
      return messageDecoderWithEmoji(service?.name) ?? "";
    }
    return reviewedUser?.fullName ?? "";
  }

  String getSubTitle() {
    if (product != null) {
      return messageDecoderWithEmoji(product?.shortDescription) ?? "";
    } else if (service != null) {
      return messageDecoderWithEmoji(service?.shortDescription) ?? "";
    }
    return reviewedUser?.userName ?? "";
  }

  Widget _buildUserReview() {
    return ReviewTile(
        review: review,
        reviewedUser: reviewedUser,
        product: product,
        service: service,
        isNavigable: false);
  }
}
