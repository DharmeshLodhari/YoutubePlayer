import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/movies/models/movie_item.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/shopping_cart_tile.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../music/models/music_album.dart';
import '../shopping_auth.dart';
import '../tiles/cart_tiles.dart';

class MixCartItem extends StatefulWidget {
  const MixCartItem({super.key});

  @override
  State<MixCartItem> createState() => _MixCartItemState();
}

class _MixCartItemState extends State<MixCartItem> {
  late BasketBloc basketBloc;
  late CustomerProfileBloc customerProfileBloc;
  late UserBloc userBloc;
  List<int?> orders = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _auth = PaymentAndBankingAuth();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Widget audioTile = Container();

  @override
  void initState() {
    super.initState();
  }

  void _onRefresh() async {
    //check network connectivity and if true then refresh the list
    if (await checkConnection(context)) {
      //clear old items
      basketBloc.items.clear();
      basketBloc.total = 0;
      //fetch items again
      initializeShoppingCart();
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  void initializeShoppingCart() async {
    debugPrint("initializeShoppingCart called");
    final List items = await ShoppingAuthService().getShoppingCart();
    for (var element in items) {
      final String type = element is Product ? "product" : "service";
      basketBloc.addItemToCart(
        item: element,
        type: type,
        currentUser: userBloc.user.convertToUser(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    userBloc = Provider.of<UserBloc>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: appBar() as PreferredSizeWidget?,
      body: SmartRefresher(
          enablePullDown: true,
          header: WaterDropHeader(
            complete: Container(),
            waterDropColor: navyBlue,
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: _buildBodyOfCart()),
      floatingActionButton:
          basketBloc.total == 0 ? Container() : checkoutWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
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
        AppLocalization.of(context)!.basket,
        style: TextStyle(
            color: blackFont, fontSize: 22, fontWeight: FontWeight.w700),
      ),
      actions: <Widget>[
        scanQRCodeBtn(),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget scanQRCodeBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.qr_code,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        Navigator.of(context)
            .pushNamed(Routes.SCAN_QR, arguments: {'isRequest': false});
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget _buildBodyOfCart() {
    return basketBloc.total == 0
        ? Center(
            child: NoItemInList(
                msg: AppLocalization.of(context)!.shoppingCartIsEmpty),
          )
        : SingleChildScrollView(
            child: Column(
              children: [
                Column(
                    children: basketBloc.items
                        .asMap()
                        .map((i, element) => MapEntry(i, getItemTile(i)))
                        .values
                        .toList()),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      getAlbumTile(),
                      const SizedBox(
                        height: 8,
                      ),
                      audioTile,
                      const SizedBox(
                        height: 8,
                      ),
                      getMovieTile(),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget getAlbumTile() {
    final MusicAlbum album = MusicAlbum.fromJson({
      "id": 1,
      "title": "Twice As Tall Album",
      "image":
          "https://trendybeatz.com/images/Burna-Boy-Twice-As-Tall-Album-Cover.jpg",
      "audio": [
        {
          "src":
              "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/f133a23f344e2e96b275800d505011f54a4dc20f/Burna-Boy-Monsters-You-Made-ft-Chris-Martin.mp3",
          "metas": {
            "id": "1",
            "title": "Monsters You Made",
            "artist": "Burna Boy",
            "album": "Twice As Tall Album",
            "image":
                "https://trendybeatz.com/images/Burna-Boy-Twice-As-Tall-Album-Cover.jpg"
          }
        },
        {
          "src":
              "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/673e733fe5e055fb5d3d1e35500e0f4991d4faad/Martin Garrix - Animals (Original Mix).mp3",
          "metas": {
            "id": "2",
            "title": "Animals (Original Mix)",
            "artist": "Martin Garrix",
            "album": "Animals",
            "image":
                "https://i.pinimg.com/originals/ce/de/a5/cedea5f757301128e39ebf13a36d3596.jpg"
          }
        },
        {
          "src":
              "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/ab04b116c1c257db491490aa8159fff960edeb55/Olamide-Wizkid-Kana.mp3",
          "metas": {
            "id": "3",
            "title": "Kana",
            "artist": "Olamide & Wizkid",
            "album": "Olamide & Wizkid",
            "image":
                "https://www.naijavibes.com/wp-content/uploads/2018/05/Olamide-Kana-Artwork.jpg"
          }
        },
        {
          "src":
              "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/7454987a918388eec9174581ef08c52fb18eb412/Tekno-Sudden.mp3",
          "metas": {
            "id": "4",
            "title": "Sudden",
            "artist": "Tekno",
            "album": "Singles",
            "image": "https://trendybeatz.com/images/tekno-sudden-artwork.jpg"
          }
        },
        {
          "src":
              "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/7454987a918388eec9174581ef08c52fb18eb412/Davido_ChrisBrown.mp3",
          "metas": {
            "id": "5",
            "title": "Blow My Mind",
            "artist": "Davido",
            "album": "Blow My Mind ft Chris Brown",
            "image": "https://trendybeatz.com/images/Davido_ChrisBrown.jpg"
          }
        }
      ]
    });

    final Audio audio = album.audio![1];
    audioTile = CartMusicTile(audio: audio);

    return CartAlbumTile(
      album: album,
    );
  }

  Widget getMovieTile() {
    final MovieItem movie = MovieItem.fromJson({
      "id": 1,
      "name": "The Cloud Of Northland",
      "poster": "https://m.media-amazon.com/images/I/A1o+mUmviOL._SS500_.jpg",
      "genre": "Action",
      "year": "2020",
      "price": "34.00",
      "currency": "NGN",
      "rating": "7.8"
    });
    return CartMovieTile(
      movie: movie,
    );
  }

  Widget checkoutWidget() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shadowColor: boxShadowTwo,
      elevation: 4,
      child: Container(
        decoration: decorateBox(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  "${AppLocalization.of(context)!.total} : ",
                  style: TextStyle(fontSize: 14, color: blackFont),
                ),
                Text(
                  worldCurrencies[userBloc.user.currency!]!,
                  style: const TextStyle(
                      fontFamily: "Inter",
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  basketBloc.total.toString(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Expanded(
                child: SizedBox(
              width: 10,
            )),
            Expanded(
              child: MaterialButton(
                height: 40,
                color: navyBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: const Text(
                  "Pay",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16),
                ),
                onPressed: () {
                  if (basketBloc.items.isNotEmpty) {
                    addNoteDialog();
                  } else {
                    showToast(
                      message:
                          AppLocalization.of(context)?.pleaseAddSomeItemsFirst,
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getItemTile(int index) {
    return getItemTileUI(index);
  }

  Widget getItemTileUI(int index) {
    if (basketBloc.items[index]["item"] is Product) {
      return ShoppingCartTileForProduct(
        basketItem: basketBloc.items[index],
        isSharedCart: false,
        onDecreaseQty: () {
          removeItem(index);
        },
        onIncreaseQty: () {
          addItem(index);
        },
      );
    }
    return ShoppingCartTileForService(
      basketBloc.items[index],
      index: index,
      onDecreaseQty: () {
        removeItem(index);
      },
      onIncreaseQty: () {
        addItem(index);
      },
    );
  }

  Widget addItemToBasket() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .pushNamed(Routes.SCAN_QR, arguments: {'isRequest': false});
        },
        child: Image.asset(
          'assets/images/qr_code.png',
          height: 24.0,
          width: 24.0,
          color: Colors.white,
        ),
      ),
    );
  }

  void addItem(int index) async {
    final String type =
        basketBloc.items[index]["item"] is Product ? "product" : "service";
    basketBloc.addItemToCart(
      item: basketBloc.items[index]["item"],
      type: type,
      currentUser: userBloc.user.convertToUser(),
    );
    late var mapData;
    for (var element in basketBloc.items) {
      if (element["item"].conversationID ==
          basketBloc.items[index]["item"].conversationID) {
        mapData = element;
        continue;
      }
    }
    final Map<String, dynamic> data = {
      "type": type,
      "id": mapData["item"].conversationID,
      "qty": mapData["qty"],
    };
    debugPrint("Data From increasing the  item : $data");
    await ShoppingAuthService().addOrUpdateItemToShoppingCart(data);
  }

  void removeItem(int index) async {
    final String type =
        basketBloc.items[index]["item"] is Product ? "product" : "service";

    late var mapData;
    for (var element in basketBloc.items) {
      if (element["item"].conversationID ==
          basketBloc.items[index]["item"].conversationID) {
        mapData = element;
        continue;
      }
    }
    final Map data = {
      "type": type,
      "id": mapData["item"].conversationID,
      "qty": mapData["qty"] - 1,
    };

    debugPrint("Data send From Remove Button : $data");
    basketBloc.removeItemFromCart(basketBloc.items[index]["item"]);
    await ShoppingAuthService().removeItemFromShoppingCart(data);
  }

  // void addVariantItem(int index, int variantIndex) async {
  //   String type = basketBloc.items[index]["item"] is Product ? "product" : "service";
  //
  //   basketBloc.increaseVariantQuantity(basketBloc.items[index]["item"], basketBloc.items[index]["variant"][variantIndex]);
  //   late var mapData;
  //   basketBloc.items.forEach((element) {
  //     if (element["item"].id == basketBloc.items[index]["item"].id) {
  //       mapData = element;
  //       return;
  //     }
  //   });
  //
  //   Map<String, dynamic> variants = {
  //     "id": mapData["id"], "quantity": mapData["qty"], "image": mapData["image"], "current_price": mapData["current_price"]
  //   };
  //
  //   Map data = {
  //     "type": type,
  //     "id": mapData["item"].id,
  //     "qty": mapData["qty"],
  //     "variant": variants,
  //   };
  //   // debugPrint("Data From Product Page : $data");
  //   await ShoppingAuthService().addItemToShoppingCart(data);
  // }
  //
  // void removeVariantItem(int index, int variantIndex) async {
  //   String type =
  //   basketBloc.items[index]["item"] is Product ? "product" : "service";
  //
  //   late var mapData;
  //   basketBloc.items.forEach((element) {
  //     if (element["item"].id == basketBloc.items[index]["item"].id) {
  //       mapData = element;
  //       return;
  //     }
  //   });
  //
  //   Map<String, dynamic> variants = {
  //     "id": mapData["id"], "quantity": mapData["qty"] - 1, "image": mapData["image"], "current_price": mapData["current_price"]
  //   };
  //
  //   Map data = {
  //     "type": type,
  //     "id": mapData["item"].id,
  //     "qty": mapData["qty"] - 1,
  //     "variant": variants,
  //   };
  //
  //   debugPrint("Data send From Remove Button : $data");
  //   basketBloc.removeOrReduceVariant(basketBloc.items[index]["item"], basketBloc.items[index]["variant"][variantIndex]);
  //   await ShoppingAuthService().removeItemFromShoppingCart(data);
  //   //close pop up if quantity to reduce is 1 currently
  //   if(mapData["qty"] == 1){
  //     Navigator.of(context).pop();
  //   }
  // }

  List<Widget> listActionSlideActions(int index) {
    final String caption1 = AppLocalization.of(context)!.remove;

    return [
      SlidableAction(
          label: caption1,
          backgroundColor: Colors.red,
          icon: Icons.remove,
          onPressed: (contex) {
            removeItem(index);
          }),
    ];
  }

  void navigateToSendPayment(Product product, int index) async {
    customerProfileBloc.customer =
        await UserAuth().fetchCustomerProfile(product.seller);
    Navigator.of(context).pushNamed(
      Routes.SEND_PAYMENT,
      arguments: {
        'isFromProfile': false,
        'product': product,
        'itemIndex': index
      },
    );
  }

  void addNoteDialog() {
    showMaterialDialog<String>(
      context: context,
      child: PopScope(
        onPopInvoked: (didPop) async {
          if (didPop) {
            Navigator.pop(context, 'cancel');
          }
        },
        child: AlertDialog(
          titlePadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(
            AppLocalization.of(context)!.confirmation,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: blackFont),
          ),
          content: Text(
            '${AppLocalization.of(context)!.areYouSureWantToPlaceThisOrderFor}(${worldCurrencies[userBloc.user.currency!]} ${basketBloc.total})?',
            style: TextStyle(
              fontSize: 16,
              color: blackFont,
              fontFamily: "Inter",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppLocalization.of(context)!.cancel,
                style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
              onPressed: () {
                Navigator.pop(context, 'cancel');
              },
            ),
            TextButton(
              child: Text(
                AppLocalization.of(context)!.place,
                style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
              onPressed: () {
                Navigator.pop(context, 'place');
              },
            ),
          ],
        ),
      ),
    );
  }

  void showMaterialDialog<T>({required BuildContext context, Widget? child}) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child!,
    ).then<void>((T? value) async {
      // The value passed to Navigator.pop() or null.
      if (value != null) {
        final data = {"note": value};
        if (value != "cancel") {
          BottomSheetPassCode(
              context: context,
              isValidCallback: () async {
                showDialog(
                  context: context,
                  builder: (context) => Center(
                    child: CircularLoadingIndicator(),
                  ),
                );

                // Create the orders
                final userOrder =
                    await ShoppingAuthService().placeOrderOfShoppingCart(data);

                if (userOrder != null) {
                  basketBloc.items.clear(); // Shopping cart
                  basketBloc.total = 0; // clearing the total amount

                  // Send the list of of orders for payment processing
                  for (int i = 0; i < userOrder.length; i++) {
                    orders.add(userOrder[i]["id"]);
                  }
                  final response =
                      await _auth.makePaymentForCartOrder({"orders": orders});
                  if (response.statusCode == 200 ||
                      response.statusCode == 201) {
                    Navigator.popAndPushNamed(
                      context,
                      Routes.ORDERS_LIST,
                    );
                  } else if (response.statusCode == 500) {
                    Navigator.pop(context);
                    showToast(
                        message: AppLocalization.of(context)?.serverError);
                  }
                  // else if (response.statusCode == 800) {
                  //   Navigator.pop(context);
                  //   Navigator.pushNamed(
                  //     context,
                  //     "/add-document",
                  //   );
                  // }
                  else {
                    debugPrint(
                      "MakePaymentForCartOrder Unsuccessful",
                    );
                  }
                } else {
                  debugPrint(
                    "Could Not Place The Order",
                  );
                }
              },
              cancelCallBack: () {
                Navigator.pop(context);
              });
        }
      }
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}

// ignore: must_be_immutable
class VerticalListItem extends StatelessWidget {
  Widget? child;
  var item;
  String? type;

  VerticalListItem(Widget child, var item, {super.key}) {
    this.child = child;
    type = item["type"];
    this.item = item["item"];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (type == "product") {
          final Product? product = item;
          Navigator.pushNamed(context, Routes.PRODUCT,
              arguments: {"product": product});
        }
        if (type == "service") {
          final Service? service = item;
          Navigator.pushNamed(context, Routes.SERVICE_DETAIL,
              arguments: {"service": service});
        }
      },
      child: child,
    );
  }
}
