import 'package:Slydo/data/currency.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
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
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          dense: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "",
                maxLines: 1,
                style: TextStyle(
                    color: darkGrey, fontWeight: FontWeight.w400, fontSize: 12),
              ),
              Text(
                appendStringDot(addOnOption.name ?? "", 10),
                maxLines: 1,
                style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
              SizedBox(height: 5.0),
              Text(
                'Created: ${addOnOption.createdAt.toString()}',
                maxLines: 1,
                style: TextStyle(
                    color: darkGrey, fontWeight: FontWeight.w400, fontSize: 12),
              ),
              Text(
                "",
                maxLines: 1,
                style: TextStyle(
                    color: darkGrey, fontWeight: FontWeight.w400, fontSize: 12),
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
                    fontWeight: FontWeight.w700),
              ),
              Text(
                moneyDisplayNormalizer(int.parse(addOnOption.price.toString())),
                style: TextStyle(
                    fontSize: 14.0,
                    color: darkGrey,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          leading: GestureDetector(
            onTap: () {
              String? url = addOnOption.picture;
              Navigator.of(context).pushNamed("/photo-viewer", arguments: url);
            },
            child: checkProductImage(addOnOption),
          ),
        ),
      ),
    );
  }

  Widget checkProductImage(AddOnOption addOnOption) {
    // Retrieve the first image from the 'pictures' list
    String? url = "";

    url = addOnOption.picture;

    String imageUrl = url!.replaceAll('https//', 'https://');
    if (url == "") {
      return CircleAvatar(
        backgroundColor: navyBlue,
        radius: 25,
        child: Text(
          getInitials(addOnOption.name!).toUpperCase(),
          style: TextStyle(color: white, fontWeight: FontWeight.w700),
        ),
      );
    } else {
      return CustomBoxShadow(
        child: Container(
          width: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
                image: NetworkImage(
                  imageUrl,
                ),
                fit: BoxFit.cover),
          ),
        ),
      );
    }
  }
}
