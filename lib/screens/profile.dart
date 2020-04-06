import 'package:Slydo/screens/colors.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
        backgroundColor: darkBlue(),
      ),
      backgroundColor: lightBlue(),
      body: Column(
        children: <Widget>[
          TabBar(
            onTap: (index) {},
            controller: _tabController,
            tabs: <Widget>[
              Container(color: darkBlue(), child: Text("Info")),
              Container(color: darkBlue(), child: Text("Products / Services")),
            ],
          ),
          tabbarView()
        ],
      ),
    );
  }

  Widget tabbarView() {
    return TabBarView(controller: _tabController, children: [
      Container(
        color: Colors.red,
      ),
      Container(
        color: Colors.green,
      ),
    ]);
  }
}
