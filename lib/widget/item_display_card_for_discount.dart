import 'package:Slydo/data/currency.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../data/state_notifier.dart';
import '../locale/app_localization.dart';
import '../routes/route_constants.dart';
import '../screens/more_apps/shopping/shopping_auth.dart';
import '../screens/more_apps/user_profile/models/user.dart';
import '../screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import '../screens/more_apps/user_profile/user_auth.dart';
import '../screens/more_apps/yarn/models/share_as_yarn_model.dart';
import '../screens/more_apps/yarn/share_as_a_yarn_screen.dart';
import '../screens/more_apps/yarn/utils/utils.dart';
import '../screens/more_apps/yarn/utils/yarn_enum.dart';
import '../screens/more_apps/yarn/yarn_auth.dart';
import '../screens/more_apps/yarn/yarn_dashboard_bloc.dart';
import '../utils/navigation_util.dart';
import '../utils/slydo_app_icon_icons.dart';
import '../utils/slydo_app_icon_new_icons.dart';
import 'bottom_sheet_item.dart';

class DisplayProductForDiscount extends StatelessWidget {
  final Product product;
  final bool isSelected;
  final void Function(bool) onChange;

  const DisplayProductForDiscount({
    required this.product,
    required this.onChange,
    required this.isSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("${DateTime.now().toString()}");
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product',
            arguments: {"product": product});
      },
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: Colors.white,
        // margin: EdgeInsets.only(right: 0.0, bottom: 2),
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shadowColor: Colors.grey,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: <Widget>[
              Checkbox(
                activeColor: navyBlue,
                value: isSelected,
                onChanged: (value) {
                  onChange(value!);
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
              Container(
                height: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: CachedNetworkImage(
                    imageUrl: product.cover!,
                    fit: BoxFit.cover,
                    width: 80,
                    errorWidget: productAndServiceBigErrorWidget,
                  ),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      truncateString(
                        str: product.name!,
                        lengthToTruncateAt: 16,
                        showEllipsis: false,
                      ),
                      style: TextStyle(
                        color: blackFont,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      truncateString(
                        str: product.shortDescription!,
                        lengthToTruncateAt: 60,
                        showEllipsis: true,
                      ),
                      style: TextStyle(
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        color: yarnBlack,
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    getRating(numberOfRating: product.rating?.toInt()),
                  ],
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Text(
                  worldCurrencies[product.currency!]!,
                  style: TextStyle(
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.bold,
                    fontSize: 14.8,
                    color: navyBlue,
                  ),
                ),
                Text(
                  moneyDisplayNormalizer(int.parse(product.price!)),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: navyBlue,
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
