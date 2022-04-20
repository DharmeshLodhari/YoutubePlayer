import '../../../utils/colors.dart';
import 'models/provider_model.dart';
import 'package:Slydo/screens/more_apps/utility/utility_payment_screen.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../widget/LoadingIndicator.dart';

class UtilityProviderTile extends StatelessWidget {
  final ProviderModel providerModel;
  const UtilityProviderTile({Key? key, required this.providerModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        NavigationUtil.push(
          context,
          screen: UtilityPaymentScreen(
            providerModel: providerModel,
          ),
        );
      },
      child: Row(
        children: [
          Card(
            elevation: 7,
            margin: EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: CachedNetworkImage(
                width: 30,
                height: 30,
                imageUrl: providerModel.avatar,
                placeholder: (context, url) => Center(
                  child: CircularLoadingIndicator(),
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              getProviderName(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: blackFont),
            ),
          ),
        ],
      ),
    );
  }

  String getProviderName() {
    List<String> splitString = providerModel.name.split(' ');

    String providerName = "";

    try {
      providerName = "${splitString[0]} ${splitString[1]}";
    } catch (e) {
      providerName = "${splitString[0]}";
    }

    if (providerModel.name.toLowerCase().contains('electricity')) {
      if (!(providerName.toLowerCase().contains('electricity'))) {
        return "$providerName Electricity";
      }
    }

    return providerName;
  }
}
