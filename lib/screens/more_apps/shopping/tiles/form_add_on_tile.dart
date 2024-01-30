import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/common.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

class FormAddOnTile extends StatelessWidget {
  FormAddOnTile(
      {required this.productAddOnsList, required this.index, super.key});

  List<AddOns> productAddOnsList;
  int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      // margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        padding: EdgeInsets.symmetric(vertical: 7.0),
        child: ListTile(
          dense: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appendStringDot(productAddOnsList[index].name!, 20),
                maxLines: 1,
                style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w500,
                    fontSize: 14),
              ),
              SizedBox(height: 3.0),
              Text(
                '${productAddOnsList[index].options!.length} items',
                maxLines: 1,
                style: TextStyle(
                    color: darkGrey, fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
