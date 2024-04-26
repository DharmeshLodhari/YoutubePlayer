import 'package:Slydo/screens/more_apps/review/models/review.dart';
import 'package:Slydo/screens/more_apps/review/review_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class EditUserReview extends StatefulWidget {
  const EditUserReview({Key? key, required this.arguments}) : super(key: key);

  final Map<String, dynamic> arguments;

  @override
  _EditUserReviewState createState() => _EditUserReviewState();
}

class _EditUserReviewState extends State<EditUserReview> {
  final maxLines = 4;
  final TextEditingController _reviewController = TextEditingController();
  int rating = 1;

  CustomerProfile? reviewedUser;
  Product? product;
  Service? service;

  Review? review;

  bool isLoading = false;
  @override
  void initState() {
    reviewedUser = widget.arguments["reviewedUser"];
    product = widget.arguments["reviewedProduct"];
    service = widget.arguments["reviewedService"];
    review = widget.arguments["review"];

    _reviewController.text = messageDecoderWithEmoji(review!.text!)!;
    rating = review!.rating!;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Write review",
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
        child: Stack(
          children: [
            Container(
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
                          const SizedBox(height: 20),
                          Text(
                            getTitle(),
                            style: TextStyle(
                              fontSize: 18,
                              color: blackFont,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            getSubTitle(),
                            style: TextStyle(
                              fontSize: 16,
                              color: blackFont,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildWriteUserReview(),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
            ),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              Container()
          ],
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

  Widget _buildWriteUserReview() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
      child: Column(
        children: [
          CustomBoxShadow(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.zero,
              shadowColor: lightGrey,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    _buildRatingBar(),
                    const SizedBox(height: 32),
                    _buildWriteReviewTextField(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          CurvedButton(
            onPressed: onButtonTap,
            text: "Submit",
            textColor: Colors.white,
          )
        ],
      ),
    );
  }

  Widget _buildRatingBar() {
    return Center(
        child: getClickableRatingBar(
      initialRating: rating.toDouble(),
      onRatingUpdate: (rate) {
        {
          rating = rate.floor();
        }
      },
    ));
  }

  Widget _buildWriteReviewTextField() {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Write something',
            style: TextStyle(
              fontSize: 14,
              color: darkGrey,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        TextFormField(
          controller: _reviewController,
          maxLines: maxLines,
          onChanged: (value) {},
          decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: greyBorderColor, width: 1.0),
              borderRadius: const BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: greyBorderColor, width: 2.0),
              borderRadius: const BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void onButtonTap() async {
    final Map<String, dynamic> data = {
      "text": _reviewController.text,
      "rating": rating,
    };

    isLoading = true;
    if (mounted) setState(() {});

    if (product != null) {
      await ReviewAuth().updateProductReview(review!, data).then((value) {
        isLoading = false;

        review = value;
        Navigator.pop(context, review);
      }).catchError((error) {
        isLoading = false;
        if (mounted) setState(() {});
        showToast(message: "$error");
      });
    } else if (service != null) {
      await ReviewAuth().updateServiceReview(review!, data).then((value) {
        isLoading = false;
        review = value;
        Navigator.pop(context, review);
      }).catchError((error) {
        isLoading = false;
        if (mounted) setState(() {});
        showToast(message: "$error");
      });
    } else {
      await ReviewAuth().updateUserReview(review!, data).then((value) {
        isLoading = false;

        review = value;
        Navigator.pop(context, review);
      }).catchError((error) {
        isLoading = false;
        if (mounted) setState(() {});
        showToast(message: "$error");
      });
    }
  }
}
