import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../../../utils/colors.dart';
import '../../../utils/navigation_util.dart';
import '../../../widget/curved_btn.dart';
import 'ask_home_screen.dart';
import 'ask_viewmodel.dart';

class AskStartScreen extends StatefulWidget {
  @override
  State<AskStartScreen> createState() => _AskStartScreenState();
}

class _AskStartScreenState extends State<AskStartScreen> {

  @override
  void initState(){
    Future.microtask(() => context.read<AskViewModel>().init());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AskViewModel>(
        builder: (context, model, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
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
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 26, ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 15,
                ),
                Text(
                  'What topic are you interested in?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  'Select 3 or more categories to continue. We’ll use this to recommend topics you may like.',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: 65,
                ),
                Wrap(
                  runSpacing: 30,
                  spacing: 26,
                  children: model.categoryList.map((e) => GestureDetector(
                    onTap: () {
                      model.onSelectCategory(c: e);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          border: Border.all(
                              color: model.selectedCategoryList.contains(e) ? Colors.blueAccent : Colors.blueAccent.withOpacity(0.3)
                          ),
                      ),
                      height: 40,
                      width: e.length > 8 ? 120 : 90,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            e,
                            style: TextStyle(
                                color: model.selectedCategoryList.contains(e) ? navyBlue : blackFont.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ).toList(),
                ),
              SizedBox(
                height: 85,
              ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context)
                              .size
                              .width - 60),
                      child: CurvedButton(
                        height: 50,
                        textColor: Colors.white,
                        backgroundColor: navyBlue,
                        text: "${model.selectedCategoryList.length} out of 3 selected",
                        onPressed: () async {
                          NavigationUtil.push(
                            context,
                            screen: AskHomeScreen(),
                          );
                        },
                      ),
                    ),
                  ],
                )
            ],),
          ),
        );
      }
    );
  }
}