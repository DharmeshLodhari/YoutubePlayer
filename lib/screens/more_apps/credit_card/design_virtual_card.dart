import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/credit_card/tiles/color_selector.dart';
import 'package:Slydo/screens/more_apps/credit_card/utils/utils.dart';
import 'package:Slydo/utils/cache_manager.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class DesignVirtualCard extends StatefulWidget {
  final dynamic arguments;

  const DesignVirtualCard({this.arguments, super.key});

  @override
  DesignVirtualCardState createState() => DesignVirtualCardState();
}

class DesignVirtualCardState extends State<DesignVirtualCard> {
  final _formKey = GlobalKey<FormState>();
  UserBloc? userBloc;

  final ScrollController _scrollController = ScrollController();
  String cardLabel = "";
  String nairaAmount = "";
  String usdAmount = "";
  String cardBrand = "";
  String cardType = "";
  List<String> cardList = ['MasterCard', 'Visa'];
  List<String> cardTypeList = ['Dollar', 'Naira'];
  bool isLoading = false;
  bool isAPILoading = false;
  List<Color> cardColors = [navyBlue, richPink, black, orange];
  int currentColorIndex = 0;
  final CarouselController _carouselController = CarouselController();

  @override
  void deactivate() {
    CacheManager().deleteCache();
    super.deactivate();
  }

  @override
  void initState() {
    // debugPrint('Fola payload :::: ${widget.arguments["data"]}');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: lightGrey,
        resizeToAvoidBottomInset: true,
        appBar: appBar() as PreferredSizeWidget?,
        body: scaffoldBody(),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
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
        "Debit Card",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    final bool isScreenIsSmall = MediaQuery.of(context).size.height < 600;

    return isLoading
        ? Center(
            child: CircularLoadingIndicator(),
          )
        : SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 16, vertical: isScreenIsSmall ? 8 : 16),
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Customise your card",
                        maxLines: 1,
                        style: TextStyle(
                          color: blackFont,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                      Text(
                        "2/3",
                        maxLines: 1,
                        style: TextStyle(
                          color: blackFont,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  creditCardCarousel(),
                  const SizedBox(height: 15),
                  Card(
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: iconBtnGrey,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: iconBtnGrey, width: 1)),
                      child: Form(
                        key: _formKey,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: isScreenIsSmall ? 8 : 16),
                          child: Column(
                            children: <Widget>[
                              const SizedBox(height: 20),
                              getCardBrandField(),
                              const SizedBox(height: 20),
                              getCardTypeField(),
                              const SizedBox(height: 10),
                              addCardLabelField(),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      getSubmitButton(),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }

  Widget creditCardCarousel() {
    return Column(
      children: [
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            viewportFraction: 0.9,
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) {
              setState(() {
                currentColorIndex = index;
              });
            },
          ),
          items: cardColors.map((color) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: creditCard(color),
                );
              },
            );
          }).toList(),
        ),
        ColorSelector(
          colors: cardColors,
          currentIndex: currentColorIndex,
          onTap: onColorSelected,
        ),
      ],
    );
  }

  void onColorSelected(int index) {
    setState(() {
      currentColorIndex = index;
    });
    _carouselController.animateToPage(index);
  }

  Widget creditCard(Color color) {
    return SizedBox(
      height: 200,
      child: Card(
        elevation: 0,
        color: color,
        // color: navyBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/arrow_card.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: mainCreditCardContent(),
        ),
      ),
    );
  }

  Widget mainCreditCardContent() {
    return Row(
      children: [
        // Left side with text
        Container(
          padding: const EdgeInsets.only(left: 16),
          child: Stack(
            children: [
              Positioned(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30.0),
                    Text(
                      cardLabel.isNotEmpty ? cardLabel : '*****',
                      style: TextStyle(
                        color: white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      children: [
                        Text(
                          cardType == 'Dollar' &&
                                  cardBrand.isNotEmpty &&
                                  cardLabel.isNotEmpty
                              ? formatAsDollar(0.0)
                              : '****',
                          style: TextStyle(
                            color: white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      insertSpacesInCardNumber('****************'),
                      style: TextStyle(
                        color: white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      children: [
                        Text(
                          '******************',
                          style: TextStyle(
                            color: white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Text(
                          "****",
                          style: TextStyle(
                            color: white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Text(
                          '***',
                          style: TextStyle(
                            color: white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Right side with background image and text
        Expanded(
          child: Stack(
            children: [
              Positioned(
                top: 20,
                right: 20,
                child: Row(
                  children: [
                    Text(
                      'Slydo',
                      style: TextStyle(
                        color: white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 5.0),
                    SvgPicture.asset(
                      "slydo".toSVG(),
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
              Positioned(
                  bottom: 20,
                  right: 20,
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        "mastercard".toSVG(),
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 5.0),
                      Column(
                        children: [
                          Text(
                            'Mastercard',
                            style: TextStyle(
                              color: white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 5.0),
                        ],
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget addCardLabelField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.cardLabel,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.pleaseEnterProductName;
      },
      onChanged: (val) {
        cardLabel = val;
      },
    );
  }

  Widget getCardBrandField() {
    return CustomizedDropDownField(
      title: AppLocalization.of(context)!.cardBrand,
      child: ListTile(
        dense: true,
        title: Text(
          cardBrand.isNotEmpty ? cardBrand : "",
          style: TextStyle(
            color: blackFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
          maxLines: 1,
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          cardBrandAndroidSheet();
        },
      ),
    );
  }

  Widget getCardTypeField() {
    return CustomizedDropDownField(
      title: AppLocalization.of(context)!.cardType,
      child: ListTile(
        dense: true,
        title: Text(
          cardType.isNotEmpty ? cardType : "",
          style: TextStyle(
            color: blackFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
          maxLines: 1,
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          cardTypeAndroidSheet();
        },
      ),
    );
  }

  void cardTypeAndroidSheet() {
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: cardTypeList.length,
                    itemBuilder: (context, index) {
                      final String category = cardTypeList[index];
                      return ListTile(
                        title: Text(
                          category,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        dense: true,
                        onTap: () {
                          cardType = category;
                          Navigator.pop(context);
                          if (mounted) {
                            setState(() {});
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void cardBrandAndroidSheet() {
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: cardList.length,
                    itemBuilder: (context, index) {
                      final String category = cardList[index];
                      return ListTile(
                        title: Text(
                          category,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        dense: true,
                        onTap: () {
                          cardBrand = category;
                          Navigator.pop(context);
                          if (mounted) {
                            setState(() {});
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: isAPILoading
          ? () {}
          : () async {
              FocusScope.of(context).unfocus();

              await goToGeneratePage();
            },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Generate Debit Card",
      isLoading: isAPILoading,
    );
  }

  Future<void> goToGeneratePage() async {
    if (_formKey.currentState!.validate()) {
      if (validateDropdown()) {
        String color = "";
        if (currentColorIndex == 0) {
          color = 'Slydo Blue';
        } else if (currentColorIndex == 1) {
          color = 'Pink';
        } else if (currentColorIndex == 2) {
          color = 'Black';
        } else if (currentColorIndex == 3) {
          color = 'Orange';
        }

        final Map<String, dynamic> result = {
          "first_name": widget.arguments["data"]['first_name'],
          "last_name": widget.arguments["data"]['last_name'],
          "address1": widget.arguments["data"]['address1'],
          "address2": widget.arguments["data"]['address2'],
          "city": widget.arguments["data"]['city'],
          "state": widget.arguments["data"]['state'],
          "zipcode": widget.arguments["data"]['zipcode'],
          "id_number": widget.arguments["data"]['id_number'],
          "id_type": widget.arguments["data"]['id_type'],
          "customer_bvn": widget.arguments["data"]['customer_bvn'],
          "card_brand": cardBrand,
          "label": cardLabel,
          "color": color,
        };

        final data = await Navigator.of(context)
            .pushNamed(Routes.GENERATE_VIRTUAL_CARD, arguments: {
          'data': result,
        });

        // Handle the result (map) received from GENERATE_VIRTUAL_CARD
        if (data != null && data == true) {
          //send callback
          Navigator.pop(context, data);
          if (mounted) setState(() {});
        }
      }
    }
  }

  bool validateDropdown() {
    if (cardBrand.isNotEmpty || cardType.isNotEmpty) {
      return true;
    } else {
      showToast(message: AppLocalization.of(context)!.pleaseSelectCardBrand);
      return false;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
