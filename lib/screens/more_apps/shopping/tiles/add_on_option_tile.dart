import 'package:Slydo/data/currency.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:flutter/material.dart';

class AddOnOptionTile extends StatelessWidget {
  const AddOnOptionTile({super.key, required this.addOnOption});

  final AddOnOption addOnOption;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: decorateBox(),
        child: ListTile(
          // dense: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                appendStringDot(addOnOption.name ?? "", 14),
                maxLines: 1,
                style: TextStyle(
                  color: blackFont,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  fontFamily: "Inter",
                ),
              ),
              const SizedBox(height: 3.0),
              Text(
                'Created: ${getProductDateTime(addOnOption.createdAt)}',
                maxLines: 1,
                style: TextStyle(
                  color: darkGrey,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  fontFamily: "Inter",
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                worldCurrencies[addOnOption.currency ?? 'NGN'] ?? '',
                style: TextStyle(
                  fontFamily: "Inter",
                  fontSize: 14.0,
                  color: darkGrey,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                moneyDisplayNormalizer(int.parse(addOnOption.price.toString())),
                style: TextStyle(
                  fontSize: 14.0,
                  color: darkGrey,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Inter",
                ),
              ),
            ],
          ),
          leading: GestureDetector(
            onTap: () {
              final String? url = addOnOption.picture;
              Navigator.of(context).pushNamed("/photo-viewer", arguments: url);
            },
            child: checkProductImage(addOnOption),
          ),
        ),
      ),
    );
  }

  DateTime getProductDateTime(String? date) {
    if (date != null) {
      final DateTime dateTime = DateTime.parse(date);
      return dateTime;
    }
    return DateTime.now();
  }

  Widget checkProductImage(AddOnOption addOnOption) {
    // Retrieve the first image from the 'pictures' list
    String? url = "";

    url = addOnOption.picture;

    final String? imageUrl = url?.replaceAll('https//', 'https://');
    if (url == "") {
      return CircleAvatar(
        backgroundColor: navyBlue,
        radius: 25,
        child: Text(
          getInitials(addOnOption.name!).toUpperCase(),
          style: TextStyle(
            color: white,
            fontWeight: FontWeight.w700,
            fontFamily: "Inter",
          ),
        ),
      );
    } else {
      return CustomBoxShadow(
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: imageUrl != null ? white : darkGrey.withOpacity(0.50),
            // image: DecorationImage(
            //     image: NetworkImage(
            //       imageUrl ?? "",
            //     ),
            //     fit: BoxFit.cover),
          ),
          child: imageUrl != null
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                )
              : Image.asset(
                  defaultProductAndServiceImage,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  colorBlendMode: BlendMode.darken,
                ),
        ),
      );
    }
  }
}
