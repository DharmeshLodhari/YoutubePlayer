import 'package:Slydo/screens/ask/ask_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../../locale/app_localization.dart';
import '../../widget/curved_btn.dart';
import '../../utils/colors.dart';

class AskScreen extends StatefulWidget {
  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen> {

  @override
  void initState(){
    Future.microtask(() => context.read<AskViewModel>().initialiseVM());
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

                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          border: Border.all(color: Colors.blueAccent),
                      ),
                      height: 40,
                      width: e.length > 8 ? 110 : 90,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            e,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
                        maxHeight: 56,
                          maxWidth: MediaQuery.of(context)
                              .size
                              .width - 100),
                      child: CurvedButton(
                        textColor: Colors.white,
                        backgroundColor: navyBlue,
                        text: "${0} out of 3 selected",
                        onPressed: () async {

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