import 'package:Slydo/screens/more_apps/review/review_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class AddReview extends StatefulWidget {
  AddReview({Key? key, required this.arguments}) : super(key: key);

  Map<String, dynamic> arguments;

  @override
  _AddReviewState createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview> {
  final maxLines = 4;
  TextEditingController _reviewController = TextEditingController();
  int rating = 1;

  CustomerProfile? searchedUser;
  Product? product;
  Service? service;
  bool isLoading = false;
  @override
  void initState() {
    searchedUser = widget.arguments["searchedUser"];
    product = widget.arguments["product"];
    service = widget.arguments["service"];
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
            padding: EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(Icons.close),
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
              padding: EdgeInsets.fromLTRB(10, 15, 10, 0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Align(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          ClipRRect(
                            child: CachedNetworkImage(
                              imageUrl: getImage(),
                              height: 200,
                              width: 200,
                              fit: BoxFit.fill,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            getTitleName(),
                            style: TextStyle(
                              fontSize: 18,
                              color: blackFont,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            getSubTitleName(),
                            style: TextStyle(
                              fontSize: 16,
                              color: darkGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    _buildWriteUserReview(),
                    SizedBox(height: 5),
                  ],
                ),
              ),
            ),
            isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  String getImage() {
    if (product != null) {
      return product?.cover ?? "";
    } else if (service != null) {
      return service?.cover ?? "";
    }
    return searchedUser?.avatar ?? "";
  }

  String getTitleName() {
    if (product != null) {
      return messageDecoderWithEmoji(product?.name) ?? "";
    } else if (service != null) {
      return messageDecoderWithEmoji(service?.name) ?? "";
    }
    return messageDecoderWithEmoji(searchedUser?.fullName) ?? "";
  }

  String getSubTitleName() {
    if (product != null) {
      return messageDecoderWithEmoji(product?.shortDescription) ?? "";
    } else if (service != null) {
      return messageDecoderWithEmoji(service?.shortDescription) ?? "";
    }
    return messageDecoderWithEmoji(searchedUser?.userName) ?? "";
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
                    SizedBox(height: 10),
                    _buildRatingBar(),
                    SizedBox(height: 32),
                    _buildWriteReviewTextField(),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
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
    return Center(child: getClickableRatingBar(
      initialRating: 0,
      onRatingUpdate: (rate) {
        rating = rate.floor();
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
        SizedBox(
          height: 5,
        ),
        TextFormField(
          controller: _reviewController,
          maxLines: maxLines,
          onChanged: (value) {},
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: greyBorderColor, width: 1.0),
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: greyBorderColor, width: 2.0),
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void onButtonTap() async {
    Map<String, dynamic> data = {
      "text": _reviewController.text,
      "rating": rating,
    };

    isLoading = true;
    if (mounted) setState(() {});

    if (product != null) {
      await ReviewAuth().addProductReview(product!.id!, data).then((value) {
        isLoading = false;
        if (value == true) {
          Navigator.pop(context, true);
        }
      }).catchError((error) {
        isLoading = false;
        if (mounted) setState(() {});
        showToast(message: "$error");
      });
    } else if (service != null) {
      await ReviewAuth().addServiceReview(service!.id!, data).then((value) {
        isLoading = false;
        if (value == true) {
          Navigator.pop(context, true);
        }
      }).catchError((error) {
        isLoading = false;
        if (mounted) setState(() {});
        showToast(message: "$error");
      });
    } else {
      await ReviewAuth()
          .addUserReview(searchedUser!.userName!, data)
          .then((value) {
        isLoading = false;
        if (value == true) {
          Navigator.pop(context, true);
        }
      }).catchError((error) {
        isLoading = false;
        if (mounted) setState(() {});
        showToast(message: "$error");
      });
    }
  }
}
