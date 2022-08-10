import 'package:Slydo/screens/ask/ask_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../../locale/app_localization.dart';
import '../../widget/curved_btn.dart';
import '../../utils/colors.dart';

class AskHomeScreen extends StatefulWidget {
  @override
  State<AskHomeScreen> createState() => _AskHomeScreenState();
}

class _AskHomeScreenState extends State<AskHomeScreen> {

  @override
  void initState(){
    //Future.microtask(() => context.read<AskViewModel>().initialiseVM());
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

                ],
              ),
            ),
          );
        }
    );
  }
}