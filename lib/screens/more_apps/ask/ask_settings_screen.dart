import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/colors.dart';
import 'ask_viewmodel.dart';

class AskSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AskViewModel>(
        builder: (context, model, child) {
        return Scaffold(
          backgroundColor: white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              'Categories',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: blackFont,
              ),
            ),
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_left,
                color: navyBlue,
                size: 26,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                ...List.generate(
                  model.categoryList.length, (i) {
                  return Column(
                    children: [
                      buildCategoryList(
                        e: model.categoryList[i],
                        model: model,
                        onAddCategory: (){

                        }
                      ),
                      Divider(color: blackFont.withOpacity(0.08), thickness: 1,),
                    ],
                  );
                },
                ),
              ],),
            ),
          ),
        );
      }
    );
  }

  Widget buildCategoryList({String? e, Function? onAddCategory, AskViewModel? model}) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            e!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: blackFont,
            ),
          ),
          Expanded(child: SizedBox(width: 10,)),
          Container(
            decoration: BoxDecoration(
              color: blackFont.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                model!.selectedCategoryList.contains(e) ? 'Remove' : 'Add',
                style: TextStyle(
                  color: blackFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 60,)
      ],),
    );
  }

}