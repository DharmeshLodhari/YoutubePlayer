import 'package:Slydo/data/currency.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SearchProductChatTile extends StatefulWidget {
  Product product;

  SearchProductChatTile(this.product);

  @override
  _SearchProductChatTileState createState() => _SearchProductChatTileState();
}

class _SearchProductChatTileState extends State<SearchProductChatTile> {
  @override
  Widget build(BuildContext context) {
    return productCard(widget.product);
  }

  Widget productCard(Product product) {
    return Container(
      padding: EdgeInsets.only(
        bottom: 2,
      ),
      child: Column(
        children: <Widget>[
          ListTile(
            dense: true,
            leading: getLeading(product),
            title: getTitle(product),
            trailing: product.price.toString().length > 6
                ? null
                : getTrailingProduct(product),
            subtitle: getSubtitleProduct(product),
          ),
          SizedBox(
            height: 2,
          ),
          Divider(
            color: dividerColor,
            height: 0,
            thickness: 1,
          )
        ],
      ),
    );
  }

  Widget getLeading(Product product) {
    var imageUrl = "";
    try {
      imageUrl = product.cover ??
          "https://homepages.cae.wisc.edu/~ece533/images/peppers.png";
    } catch (e) {
      imageUrl = "";
    }
    if (imageUrl == "") {
      imageUrl = "https://homepages.cae.wisc.edu/~ece533/images/peppers.png";
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: 48,
        width: 48,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
        errorWidget: imageErrorWidget,
        placeholder: (context, url) =>
            imageUrl == "" ? Icon(Icons.person) : CircularLoadingIndicator(),
      ),
    );
  }

  Widget getTitle(Product product) {
    return Text(
      "${product.name}",
      maxLines: 1,
      style: TextStyle(
          color: blackFont, fontWeight: FontWeight.w600, fontSize: 14),
    );
  }

  Widget getTrailingProduct(Product product) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[product.currency],
          style: TextStyle(
              fontFamily: "Roboto",
              color: blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
        Text(
          product.price.toString(),
          style: TextStyle(
              color: blackFont, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget getSubtitleProduct(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 2,
        ),
        Text(
          "${product.shortDescription}",
          maxLines: 1,
          style: TextStyle(color: darkGrey, fontSize: 12),
        ),
        SizedBox(
          height: 2,
        ),
        product.price.toString().length > 6
            ? getTrailingProduct(product)
            : Container(),
        getSellerNameProduct(product)
      ],
    );
  }

  Widget getSellerNameProduct(Product product) {
    return Row(
      children: <Widget>[
        Text(
          product.seller,
          maxLines: 1,
          style: TextStyle(color: darkGrey, fontSize: 10),
        ),
      ],
    );
  }
}

// ignore: must_be_immutable
class SearchServiceChatTile extends StatefulWidget {
  Service service;

  SearchServiceChatTile(this.service);

  @override
  _SearchServiceChatTileState createState() => _SearchServiceChatTileState();
}

class _SearchServiceChatTileState extends State<SearchServiceChatTile> {
  @override
  Widget build(BuildContext context) {
    return getServiceCard(widget.service);
  }

  Widget getServiceCard(Service service) {
    return Container(
      padding: EdgeInsets.only(
        bottom: 2,
      ),
      child: Column(
        children: <Widget>[
          ListTile(
            dense: true,
            leading: getLeadingService(service),
            title: Text(
              service.name,
              maxLines: 1,
              style: TextStyle(
                  color: blackFont, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: getSubtitleService(service),
            trailing: service.price.toString().length > 6
                ? null
                : getTrailingService(service),
          ),
          SizedBox(
            height: 2,
          ),
          Divider(
            color: dividerColor,
            thickness: 1,
            height: 0,
          )
        ],
      ),
    );
  }

  Widget getLeadingService(Service service) {
    var imageUrl = "";
    try {
      imageUrl = service.cover ??
          "https://homepages.cae.wisc.edu/~ece533/images/peppers.png";
    } catch (e) {
      imageUrl = "";
    }
    if (imageUrl == "") {
      imageUrl = "https://homepages.cae.wisc.edu/~ece533/images/peppers.png";
    }
    return ClipOval(
      child: CachedNetworkImage(
          imageUrl: imageUrl,
          height: 48,
          width: 48,
          colorBlendMode: BlendMode.darken,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
          errorWidget: imageErrorWidget,
          placeholder: (context, url) =>
              imageUrl == "" ? Icon(Icons.person) : CircularLoadingIndicator()),
    );
  }

  Widget getSubtitleService(Service service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 2,
        ),
        Text(
          "${service.shortDescription}",
          maxLines: 1,
          style: TextStyle(color: darkGrey, fontSize: 12),
        ),
        SizedBox(
          height: 2,
        ),
        service.price.toString().length > 6
            ? getTrailingService(service)
            : Container(),
        getProviderNameService(service)
      ],
    );
  }

  Widget getProviderNameService(Service service) {
    return Row(
      children: <Widget>[
        Text(
          service.provider,
          maxLines: 1,
          style: TextStyle(color: darkGrey, fontSize: 10),
        ),
      ],
    );
  }

  Widget getTrailingService(Service service) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[service.currency],
          style: TextStyle(
              fontFamily: "Roboto",
              color: blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
        Text(
          service.price.toString(),
          style: TextStyle(
              color: blackFont, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
