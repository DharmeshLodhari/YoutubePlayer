import 'package:Slydo/screens/more_apps/utility/utility_payment_screen.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'models/provider_model.dart';

class UtilityProviderTile extends StatelessWidget {
  final ProviderModel providerModel;
  const UtilityProviderTile({super.key, required this.providerModel})
     ;

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
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    imageUrl: providerModel.avatar,
                    placeholder: (context, url) => Center(
                      child: CircularLoadingIndicator(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  getProviderName(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: blackFont,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getProviderName() {
    if (providerModel.name.toLowerCase().startsWith('eedc')) {
      debugPrint(
          'PROVIDER NAME :: ${providerModel.name} '); // EEDC (Enugu Electric)
    }
    final List<String> splitString = providerModel.name.split(' ');

    String providerName = "";

    try {
      providerName = "${splitString[0]} ${splitString[1]}";
    } catch (e) {
      providerName = splitString[0];
    }

    if (providerModel.name.toLowerCase().contains('electricity')) {
      if (!(providerName.toLowerCase().contains('electricity'))) {
        return "$providerName Electricity";
      }
    }

    return providerName;
  }
}
