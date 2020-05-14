import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  BasketBloc basketBloc;

  @override
  void initState() {
    setState(() {
      product = arguments['product'];
    });
    fetchProduct(product.id.toString());
    super.initState();
  }

  void fetchProduct(String productId) async {
    _auth.getProduct(productId).then((value) {
      if (mounted) {
        setState(() {
          product = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    basketBloc = Provider.of<BasketBloc>(context);
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
    return FloatingActionButton(
      backgroundColor: darkBlue(),
      child: Icon(
        Icons.add_shopping_cart,
        size: 30,
        color: Colors.white,
      ),
      onPressed: () async {
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
      },
    );
  }

  _buildProductDetailsPage(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return ListView(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(4.0),
          child: Card(
            elevation: 4.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildProductImagesWidgets(),
                _buildProductTitleWidget(),
                SizedBox(height: 12.0),
                _buildPriceWidgets(),
                SizedBox(height: 12.0),
                _buildDivider(screenSize),
                SizedBox(height: 12.0),
                _buildFurtherInfoWidget(),
                SizedBox(height: 12.0),
                _buildDivider(screenSize),
                SizedBox(height: 6.0),
                _buildSizeChartWidgets(),
                SizedBox(height: 6.0),
                _buildDivider(screenSize),
                _buildDetailsAndMaterialWidgets(),
                SizedBox(height: 12.0),
                _buildBuyButtonWidget(),
                SizedBox(height: 12.0),
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

  _buildProductImagesWidgets() {
    TabController imagesController =
        TabController(length: product.serverImages.length, vsync: this);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 250.0,
        child: Center(
          child: DefaultTabController(
            length: product.serverImages.length,
            child: Stack(
              children: <Widget>[
                TabBarView(
                  controller: imagesController,
                  children: productPhotos(product),
                ),
                Container(
                  alignment: FractionalOffset(0.5, 0.95),
                  child: TabPageSelector(
                    controller: imagesController,
                    selectedColor: Colors.grey,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildProductTitleWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Center(
        child: Text(
          //name,
          product.name,
          style: TextStyle(fontSize: 16.0, color: Colors.black),
        ),
      ),
    );
  }

  _buildPriceWidgets() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            worldCurrencies[product.currency] + product.price,
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
          SizedBox(
            width: 8.0,
          ),
          copyQrCode(),
        ],
      ),
    );
  }

  Widget copyQrCode() {
    return MaterialButton(
      child: Row(
        children: <Widget>[
          Image.asset(
            "assets/images/qr_code.png",
            height: 25,
            width: 25,
            filterQuality: FilterQuality.low,
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

  _buildFurtherInfoWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 12.0,
          ),
          Text(
            product.shortDescription,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  _buildSizeChartWidgets() {
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
                Icons.access_time,
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

  _buildDetailsAndMaterialWidgets() {
    TabController tabController = new TabController(length: 2, vsync: this);
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: TabBar(
              indicatorColor: darkBlue(),
              controller: tabController,
              tabs: <Widget>[
                Tab(
                  child: Text(
                    AppLocalization.of(context).details,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    AppLocalization.of(context).sellersOtherProduct,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            height: 200.0,
            child: TabBarView(
              controller: tabController,
              children: <Widget>[
                ListView(
                  children: <Widget>[
                    Text(
                      product.description,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                ListView(
                  children: <Widget>[
                    Text(
                      AppLocalization.of(context).comingSoon,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> productPhotos(Product product) {
    List<Widget> photos = [];
    for (var url in product.serverImages) {
      var img = Image.network(url);
      photos.add(img);
    }
    return photos;
  }

  _buildBuyButtonWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width / 1.4,
        color: Colors.green,
        child: Text(
          "Buy Now",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          getRecipient();
          navigateToSendPayment();
        },
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
