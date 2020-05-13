import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/services/auth.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import 'colors.dart';

// ignore: must_be_immutable
class ServiceDetailPage extends StatefulWidget {
  var arguments;
  ServiceDetailPage({@required this.arguments});
  @override
  _ServiceDetailPageState createState() =>
      _ServiceDetailPageState(arguments: arguments);
}

class _ServiceDetailPageState extends State<ServiceDetailPage>
    with TickerProviderStateMixin {
  var arguments;
  _ServiceDetailPageState({this.arguments});
  Service service;
  CustomerProfileBloc customerProfileBloc;
  BasketBloc basketBloc;

  final _auth = AuthService();

  @override
  void initState() {
    setState(() {
      service = arguments['service'];
    });
    debugPrint("provider avatar ${service.providerAvatar}");
    fetchService(service.id.toString());
    super.initState();
  }

  void fetchService(String serviceId) async {
    _auth.getService(serviceId).then((value) {
      setState(() {
        service = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    basketBloc = Provider.of<BasketBloc>(context);
    return Scaffold(
      backgroundColor: lightBlue(),
      appBar: AppBar(
        titleSpacing: 0,
        actions: <Widget>[messageSellerWidget(), goToBasket()],
        backgroundColor: darkBlue(),
        title: Row(
          children: <Widget>[
            getUserProfile(),
            Expanded(
              child: SizedBox(
                width: 14,
              ),
            ),
            Text(
              AppLocalization.of(context).serviceDetail,
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
      body: _buildServiceDetailsPage(context),
    );
  }

  Widget getUserProfile() {
    return GestureDetector(
      child: ClipOval(
        child: Container(
          height: 40,
          width: 40,
          child: CachedNetworkImage(
            imageUrl: service.providerAvatar != null
                ? service.providerAvatar
                : "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png",
            fit: BoxFit.fill,
          ),
        ),
      ),
      onTap: () async {
        _auth.fetchCustomerProfile(service.provider).then((user) {
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
          'recipient': service.provider,
          'subject': service.name,
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
          Navigator.pushNamed(context, "/shopping-cart");
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
        basketBloc.addItemToCart(item: service);
        var mapData;
        basketBloc.items.forEach((element) {
          if (element["item"].id == service.id) {
            mapData = element;
            return;
          }
        });
        Map data = {
          "type": "service",
          "id": mapData["item"].id,
          "qty": mapData["qty"],
        };
        await _auth.addItemToShoppingCart(data);
      },
    );
  }

  _buildServiceDetailsPage(BuildContext context) {
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
                _buildServiceImagesWidgets(),
                _buildServiceTitleWidget(),
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

  _buildServiceImagesWidgets() {
    TabController imagesController =
        TabController(length: service.serverImages.length, vsync: this);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 250.0,
        child: Center(
          child: DefaultTabController(
            length: service.serverImages.length,
            child: Stack(
              children: <Widget>[
                TabBarView(
                  controller: imagesController,
                  children: servicePhotos(service),
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

  _buildServiceTitleWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Center(
        child: Text(
          //name,
          service.name,
          style: TextStyle(fontSize: 16.0, color: Colors.black),
        ),
      ),
    );
  }

  _buildPriceWidgets() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            worldCurrencies[service.currency] + service.price,
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
          SizedBox(
            width: 8.0,
          ),
        ],
      ),
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
            service.shortDescription,
            style: TextStyle(
              color: Colors.grey[500],
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
                "${service.availableFrom.day}/${service.availableFrom.month}/${service.availableFrom.year}",
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
              Toast.show(
                "Coming Soon !!",
                context,
                gravity: Toast.BOTTOM,
                duration: Toast.LENGTH_LONG,
                backgroundColor: darkBlue(),
                textColor: Colors.white,
              );
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
          TabBar(
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
                  AppLocalization.of(context).sellersOtherServices,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            height: 200.0,
            child: TabBarView(
              controller: tabController,
              children: <Widget>[
                ListView(
                  children: [
                    Text(
                      service.description,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                ListView(
                  children: [
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

  List<Widget> servicePhotos(Service service) {
    List<Widget> photos = [];
    for (var url in service.serverImages) {
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
        await _auth.fetchCustomerProfile(service.provider);
  }

  void navigateToSendPayment() {
    Navigator.of(context).pushNamed(
      '/send-payment',
      arguments: {
        'isFromProfile': false,
        'isRequest': false,
//        'product': product
      },
    );
  }
}
