import 'package:Slydo/data/currency.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SearchProductTile extends StatefulWidget {
  Product product;

  SearchProductTile({@required this.product});

  @override
  _SearchProductTileState createState() => _SearchProductTileState();
}

class _SearchProductTileState extends State<SearchProductTile> {
  String itemCover = "";

  @override
  void initState() {
    try {
      itemCover = widget.product.cover ??
          "https://homepages.cae.wisc.edu/~ece533/images/peppers.png";
    } catch (e) {
      itemCover = "";
    }
    if (itemCover == "") {
      itemCover = "https://homepages.cae.wisc.edu/~ece533/images/peppers.png";
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: CustomBoxShadow(
        child: Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.zero,
            shadowColor: boxShadowTwo,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 200,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: CachedNetworkImage(
                        width: double.infinity,
                        imageUrl: itemCover,
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    ListTile(
                        dense: true,
                        title: Text(
                          widget.product.name,
                          maxLines: 1,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: blackFont),
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                        subtitle: Text(
                          widget.product.shortDescription,
                          maxLines: 1,
                          style: TextStyle(fontSize: 14, color: darkGrey),
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                        trailing: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: worldCurrencies[widget.product.currency],
                                style: TextStyle(
                                    fontFamily: "Roboto",
                                    color: navyBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            TextSpan(
                                // text: widget.product.price.toString(),
                                text: widget.product.price.toString(),
                                style: TextStyle(
                                  color: navyBlue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ))
                          ]),
                        )),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}

// ignore: must_be_immutable
class SearchServiceTile extends StatefulWidget {
  Service service;

  SearchServiceTile({@required this.service});

  @override
  _SearchServiceTileState createState() => _SearchServiceTileState();
}

class _SearchServiceTileState extends State<SearchServiceTile> {
  String itemCover = "";

  @override
  void initState() {
    try {
      itemCover = widget.service.cover ??
          "https://homepages.cae.wisc.edu/~ece533/images/peppers.png";
    } catch (e) {
      itemCover = "";
    }
    if (itemCover == "") {
      itemCover = "https://homepages.cae.wisc.edu/~ece533/images/peppers.png";
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: CustomBoxShadow(
        child: Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.zero,
            shadowColor: boxShadowTwo,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 200,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: CachedNetworkImage(
                        width: double.infinity,
                        imageUrl: itemCover,
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    ListTile(
                        dense: true,
                        title: Text(
                          widget.service.name,
                          maxLines: 1,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: blackFont),
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                        subtitle: Text(
                          widget.service.shortDescription,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 14,
                              color: darkGrey,
                              fontWeight: FontWeight.w400),
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                        trailing: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: worldCurrencies[widget.service.currency],
                                style: TextStyle(
                                    fontFamily: "Roboto",
                                    color: navyBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            TextSpan(
                                text: widget.service.price.toString(),
                                style: TextStyle(
                                  color: navyBlue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ))
                          ]),
                        )),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
