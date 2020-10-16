import 'package:Slydo/screens/more_apps/news/news_tile.dart';
import 'package:flutter/material.dart';

class SubscriptionList extends StatefulWidget {
  @override
  _SubscriptionListState createState() => _SubscriptionListState();
}

class _SubscriptionListState extends State<SubscriptionList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: scaffoldBody());
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(20, (index) => SubscriptionTile()),
      ),
    );
  }
}
