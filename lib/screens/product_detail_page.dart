import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/item_display_card.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class ProductDetailPage extends StatefulWidget {
  var arguments;
  ProductDetailPage({@required this.arguments});
  @override
  _ProductDetailPageState createState() =>
      _ProductDetailPageState(arguments: arguments);
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with TickerProviderStateMixin {
  var arguments;
  _ProductDetailPageState({this.arguments});

  final _auth = AuthService();
  Product product;
  CustomerProfileBloc customerProfileBloc;
  UserBloc userBloc;
  BasketBloc basketBloc;
  static List<String> imgList = [];

  bool isValidCustomer;
  bool isOtherItemFetched = false;
  bool isOtherItemIsEmpty = true;
  ScrollController _scrollController = new ScrollController();

  List<dynamic> sellersOtherItems = List<dynamic>();

  int _current = 0;

  @override
  void initState() {
    setState(() {
      product = arguments['product'];
    });
    fetchProduct(product.id.toString());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!isOtherItemFetched) {
          getOtherItems();
        }
      }
    });
    super.initState();
  }

  void fetchProduct(String productId) async {
    _auth.getProduct(productId).then((value) {
      if (mounted) {
        setState(() {
          product = value;
          imgList = product.serverImages;
        });
      }
    });
  }

  void getOtherItems() {
    _auth
        .ownersOrderProductsAndServices(
            type: "products", userId: product.seller, exclude: product.id)
        .then((value) {
      debugPrint("value : $value");
      if (value.isNotEmpty) {
        setState(() {
          isOtherItemIsEmpty = false;
          sellersOtherItems = value;
        });
      } else {
        setState(() {
          isOtherItemIsEmpty = true;
        });
      }
    });
    isOtherItemFetched = true;
  }

  @override
  Widget build(BuildContext context) {
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    basketBloc = Provider.of<BasketBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
    isValidCustomer = userBloc.user.userName != product.seller;
    return Scaffold(
      backgroundColor: lightBlue(),
      appBar: AppBar(
        actions: <Widget>[messageSellerWidget(), goToBasket()],
        backgroundColor: darkBlue(),
        titleSpacing: 0,
        title: Row(
          children: <Widget>[
            getUserProfile(),
            Expanded(
              child: SizedBox(
                width: 14,
              ),
            ),
            Text(
              AppLocalization.of(context).productDetail,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            Expanded(
              child: SizedBox(
                width: 14,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: addToCart(),
      body: _buildProductDetailsPage(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget getUserProfile() {
    return GestureDetector(
      child: ClipOval(
        child: Container(
          height: 40,
          width: 40,
          child: CachedNetworkImage(
            imageUrl: product.sellerAvatar != null
                ? product.sellerAvatar
                : "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png",
            fit: BoxFit.fill,
          ),
        ),
      ),
      onTap: () async {
        _auth.fetchCustomerProfile(product.seller).then((user) {
          Navigator.pushNamed(context, '/profile',
              arguments: {"searchedUser": user});
        });
      },
    );
  }

  Widget messageSellerWidget() {
    return IconButton(
      icon: Icon(Icons.message),
      onPressed: () {
        Navigator.of(context).pushNamed('/compose_message', arguments: {
          'recipient': product.seller,
          'subject': product.name,
        });
      },
    );
  }

  Widget goToBasket() {
    return Badge(
      badgeColor: Colors.green,
      animationType: BadgeAnimationType.slide,
      badgeContent: getBadgeContent(),
      padding:
          basketBloc.items.length == 0 ? EdgeInsets.all(0) : EdgeInsets.all(4),
      position: BadgePosition(right: 6, top: 6),
      child: IconButton(
        icon: Icon(
          Icons.shopping_cart,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pushNamed(context, "/dashboard",
              arguments: {"dashboardIndex": 2});
        },
      ),
    );
  }

  Widget getBadgeContent() {
    if (basketBloc.items.length == 0) {
      return null;
    }
    return Text(
      getBadgeCount().toString(),
      style: TextStyle(
          fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  int getBadgeCount() {
    int totalItem = 0;
    basketBloc.items.forEach((element) {
      totalItem = totalItem + element['qty'];
    });
    return totalItem;
  }

  Widget addToCart() {
    return Card(
      elevation: 10,
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: EdgeInsets.all(8),
        height: 55,
        child: Row(
          children: <Widget>[
            _buildBuyButtonWidget(),
            SizedBox(
              width: 12,
            ),
            Expanded(
              child: MaterialButton(
                height: double.infinity,
                color: lightBlue(),
                child: Icon(
                  Icons.add_shopping_cart,
                  color: Colors.white,
                ),
                onPressed: () async {
                  if (isValidCustomer) {
                    String type = product is Product ? "product" : "service";
                    basketBloc.addItemToCart(item: product, type: type);
                    var mapData;
                    basketBloc.items.forEach((element) {
                      if (element["item"].id == product.id) {
                        mapData = element;
                        return;
                      }
                    });
                    Map data = {
                      "type": type,
                      "id": mapData["item"].id,
                      "qty": mapData["qty"],
                    };
                    debugPrint("Data From Product Page : $data");
                    await _auth.addItemToShoppingCart(data);
                  } else {
                    Toast.show("You can not Purchase this item !!", context,
                        textColor: Colors.white,
                        backgroundColor: darkBlue(),
                        duration: Toast.LENGTH_LONG);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildProductDetailsPage(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return ListView(
      controller: _scrollController,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(4.0),
          child: Card(
            elevation: 4.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildProductImagesWidgets(),
                _buildProductTitleAndPriceWidget(),
                SizedBox(height: 12.0),
                _buildShortInfoWidget(),
                SizedBox(height: 12.0),
                SizedBox(height: 12.0),
                _buildDivider(screenSize),
                SizedBox(height: 12.0),
                _buildAvailableFromAndShareWidgets(),
                SizedBox(height: 12.0),
                _buildDivider(screenSize),
                _buildDescriptionWidget(),
                SizedBox(height: 30.0),
                isOtherItemIsEmpty ? Container() : _buildSellersOtherProducts(),
                SizedBox(height: 80.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buildDivider(Size screenSize) {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.grey[600],
          width: screenSize.width,
          height: 0.25,
        ),
      ],
    );
  }

  final List<Widget> imageSliders = imgList
      .map((item) => Container(
            child: CachedNetworkImage(
              imageUrl: item,
              fit: BoxFit.fitWidth,
            ),
          ))
      .toList();

  _buildProductImagesWidgets() {
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            CarouselSlider(
              options: CarouselOptions(
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  autoPlay: false,
                  aspectRatio: 1.2,
                  onPageChanged: (index, _) {
                    setState(() {
                      _current = index;
                    });
                  }),
              items: imgList
                  .map((item) => Container(
                        child: Center(
                            child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4)),
                          child: CachedNetworkImage(
                            imageUrl: item,
                            fit: BoxFit.fill,
                            height: double.infinity,
                            width: double.infinity,
                          ),
                        )),
                      ))
                  .toList(),
            ),
            Positioned(
              bottom: 0,
              left:
                  MediaQuery.of(context).size.width / 2 - (5 * imgList.length),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: imgList.map((url) {
                  int index = imgList.indexOf(url);
                  return Container(
                    width: 5.0,
                    height: 5.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _current == index ? lightBlue() : Colors.white,
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ],
    );
  }

  _buildProductTitleAndPriceWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  //name,
                  product.name,
                  style: TextStyle(
                      fontSize: 13.0,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        worldCurrencies[product.currency],
                        style: TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 28.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        product.price,
                        style: TextStyle(
                            fontSize: 28.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        copyQrCode(),
      ],
    );
  }

  Widget copyQrCode() {
    return MaterialButton(
      child: Row(
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: product.qrCode,
            height: 50,
            width: 50,
            filterQuality: FilterQuality.high,
            fit: BoxFit.fill,
          ),
        ],
      ),
      onPressed: () {
        Clipboard.setData(new ClipboardData(text: product.qrCode));
        Toast.show(AppLocalization.of(context).copied, context,
            gravity: Toast.CENTER,
            duration: Toast.LENGTH_LONG,
            backgroundColor: darkBlue());
      },
    );
  }

  Widget _buildShortInfoWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Text(
              product.shortDescription,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildAvailableFromAndShareWidgets() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.date_range,
                color: Colors.black,
              ),
              SizedBox(
                width: 12.0,
              ),
              Text(
                "${product.availableFrom.day}/${product.availableFrom.month}/${product.availableFrom.year}",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(),
          ),
          MaterialButton(
            minWidth: 100,
            child: Row(
              children: <Widget>[
                Icon(Icons.share),
                SizedBox(width: 12),
                Text("Share")
              ],
            ),
            onPressed: () {
              var shareBody = "${product.name}\n" +
                  "http://slydo.co/products/" +
                  product.id.toString();
              Share.share(shareBody, subject: "${product.name}");
            },
          )
        ],
      ),
    );
  }

  Widget _buildDescriptionWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Text(
        product.description,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
          wordSpacing: 0.2,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildSellersOtherProducts() {
    return Container(
      height: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  AppLocalization.of(context).sellersOtherProduct,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
              ),
              GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Text(
                    "See all",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: lightBlue()),
                  ),
                ),
                onTap: () {
                  _auth.fetchCustomerProfile(product.seller).then((user) {
                    Navigator.pushNamed(context, '/profile',
                        arguments: {"searchedUser": user, "index": 1});
                  });
                },
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemCount: sellersOtherItems.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => displayProduct(
                context: context,
                product: sellersOtherItems[index],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildBuyButtonWidget() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: lightBlue(),
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: FlatButton(
          color: Colors.white,
          child: Text(
            "Buy Now",
            style: TextStyle(color: lightBlue()),
          ),
          onPressed: () {
            if (isValidCustomer) {
              getRecipient();
              navigateToSendPayment();
            } else {
              Toast.show("You can not Purchase this item !!", context,
                  textColor: Colors.white,
                  backgroundColor: darkBlue(),
                  duration: Toast.LENGTH_LONG);
            }
          },
        ),
      ),
    );
  }

  // Pull the user from the server
  void getRecipient() async {
    customerProfileBloc.customer =
        await _auth.fetchCustomerProfile(product.seller);
  }

  void navigateToSendPayment() {
    Navigator.of(context).pushNamed(
      '/send-payment',
      arguments: {
        'isFromProfile': false,
        'isRequest': false,
        'product': product
      },
    );
  }
}
