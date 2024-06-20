import 'dart:io';

import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/order_detail_item_tile_new.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

class WriteReviewPage extends StatefulWidget {
  const WriteReviewPage({super.key, required this.arguments});

  final dynamic arguments;

  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late UserBloc userBloc;
  bool isLoading = true;
  final _auth = ShoppingAuthService();
  Order? order;
  List<Map<String, dynamic>> items = [];
  TextEditingController reviewController = TextEditingController();
  String? croppedImage;
  int rating = 1;

  @override
  void initState() {
    order = widget.arguments['order'];
    fetchOrder(order?.id.toString() ?? "");
    super.initState();
  }

  void fetchOrder(String orderId) async {
    setState(() {
      isLoading = true;
    });
    _auth.getOrder(orderId).then((value) {
      if (value != null) {
        debugPrint('VALUE :: $value');
        if (mounted) {
          setState(() {
            order = value;
            items = order?.items ?? [];
            isLoading = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: lightGrey,
        appBar: appBar() as PreferredSizeWidget?,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildBody(),
          ),
        ),
        floatingActionButton: floatingActionBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
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
      centerTitle: false,
      title: Text(
        "Write a review",
        style: TextStyle(
          color: blackFont,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: "Inter",
        ),
      ),
    );
  }

  Widget _buildBody() {
    return isLoading
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            // padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${order?.customerName} (${items[index]["qty"]} Items)",
                  style: TextStyle(
                    color: darkGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Inter",
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  child: Divider(
                    color: greySecondaryYarn,
                  ),
                ),
                getItemTileUi(index),
                const SizedBox(
                  height: 10,
                ),
                _buildRating(),
                const SizedBox(
                  height: 15,
                ),
                _buildReview(),
                const SizedBox(
                  height: 15,
                ),
                _buildPicture(),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(
                    thickness: 5,
                    color: greySecondaryYarn,
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalization.of(context)!.review,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: blackFont,
            fontFamily: "Inter",
          ),
        ),
        const SizedBox(height: 5),
        _buildReviewTextField(),
      ],
    );
  }

  Widget _buildPicture() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Picture (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: blackFont,
            fontFamily: "Inter",
          ),
        ),
        const SizedBox(height: 3),
        if (croppedImage != null) showImage() else addImage(),
      ],
    );
  }

  Widget addImage() {
    return CustomBoxShadow(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shadowColor: boxShadowTwo,
        margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
        child: Container(
          width: MediaQuery.of(context).size.width - 40,
          decoration: BoxDecoration(
            color: lightGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            child: SvgPicture.asset(
              "add_image".toSVG(),
              height: 130,
              fit: BoxFit.fill,
            ),
            onTap: () {
              pickImage();
            },
          ),
        ),
      ),
    );
  }

  Widget showImage() {
    return SizedBox(
      height: 130,
      child: Stack(
        children: <Widget>[
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            shadowColor: dividerColor,
            margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                    image: FileImage(
                      File(croppedImage ?? ""),
                    ),
                    fit: BoxFit.fill),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              padding: const EdgeInsets.only(right: 6, top: 6),
              alignment: Alignment.topRight,
              icon: Container(
                padding: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: iconBtnGrey,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  SlydoAppIcon.remove,
                  color: blackFont,
                  size: 15,
                ),
              ),
              onPressed: () {
                setState(() {
                  croppedImage = null;
                  setState(() {});
                });
              },
            ),
          )
        ],
      ),
    );
  }

  void pickImage() async {
    final imageSource = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: Text(AppLocalization.of(context)!.selectTheImageSource),
              actions: <Widget>[
                MaterialButton(
                  child: Text(AppLocalization.of(context)!.camera),
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                ),
                MaterialButton(
                  child: Text(AppLocalization.of(context)!.gallery),
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                )
              ],
            ));

    if (imageSource != null) {
      ImagePicker().pickImage(source: imageSource).then((value) async {
        if (value != null) {
          /// for cropping the image
          croppedImage = await ImageCrop().cropImage(value.path);
          if (croppedImage == null) {
            return;
          }

          // discountImages.add(PickedFile(croppedImage));
          // discountModel.poster = croppedImage;
          if (mounted) setState(() {});
        }
      });
    }
  }

  Widget _buildReviewTextField() {
    return TextField(
      controller: reviewController,
      maxLines: 5,
      decoration: InputDecoration(
        hintText:
            'Write a review to let other shoppers know what you think about this product.',
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: greyBorderColor, // Border color
            width: 1.0,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: greyBorderColor, // Border color
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: navyBlue, // Change the focus color here
            width: 1.0,
          ),
        ),
        filled: true,
        fillColor: white,
        // Background color
      ),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: darkGrey,
        fontFamily: "Inter",
      ),
    );
  }

  Widget getItemTileUi(int index) {
    if (items[index]["type"] == "product") {
      return OrderTileForProductNew(
        item: items[index],
      );
    }
    return OrderTileForService(
      items[index],
    );
  }

  Widget _buildRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How well does this item match its description ?',
          style: TextStyle(
            color: blackFont,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: "Inter",
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        getClickableRatingBar(
          starSize: 25.0,
          initialRating: 0,
          onRatingUpdate: (rate) {
            rating = rate.floor();
          },
        ),
      ],
    );
  }

  Widget floatingActionBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: CurvedButton(
        backgroundColor: navyBlue,
        textColor: Colors.white,
        text: "Submit Review",
        onPressed: () {
          // Navigator.of(context).pushNamed(
          //   '/send-payment',
          //   arguments: {
          //     'isFromProfile': false,
          //   },
          // );
        },
      ),
    );
  }
}
