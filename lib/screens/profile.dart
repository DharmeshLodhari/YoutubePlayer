import 'package:Slydo/models/user.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Profile extends StatefulWidget {
  var arguments;
  Profile({@required this.arguments});
  @override
  _ProfileState createState() => _ProfileState(arguments: arguments);
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  var arguments;
  _ProfileState({this.arguments});
  TabController _tabController;
  int currentIndex = 0;
  CustomerProfile searchedUser;
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    searchedUser = arguments['searchedUser'];
    _tabController = new TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: darkBlue(),
        title: Text('Profile'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          userDetails(),
          Divider(),
          tabBar(),
          tabViews(),
        ],
      ),
    );
  }

  Widget userDetails() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Center(
            child: IconButton(
              icon: Icon(
                Icons.call,
                color: darkBlue(),
              ),
              onPressed: () {},
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: searchedUser.avatar,
                      height: 100,
                      width: 100,
                      colorBlendMode: BlendMode.darken,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      placeholder: (context, url) => searchedUser.avatar == ""
                          ? Icon(Icons.person)
                          : CircularProgressIndicator(
                              backgroundColor: Colors.white,
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  searchedUser.fullName,
                  style: TextStyle(
                    color: darkBlue(),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  searchedUser.userName,
                  style: TextStyle(
                    color: darkBlue(),
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: IconButton(
              icon: Icon(
                Icons.message,
                color: darkBlue(),
              ),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }

  Widget tabBar() {
    return Container(
      color: lightBlue(),
      child: TabBar(
        indicatorColor: darkBlue(),
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        controller: _tabController,
        tabs: <Widget>[
          Material(
              color: lightBlue(),
              child: Container(
                  height: 35,
                  child: Center(
                      child: Text(
                    "Productes",
                    style: TextStyle(
                      color: darkBlue(),
                      fontWeight: FontWeight.bold,
                    ),
                  )))),
          Material(
              color: lightBlue(),
              child: Container(
                  height: 35,
                  child: Center(
                      child: Text(
                    "Services",
                    style: TextStyle(
                      color: darkBlue(),
                      fontWeight: FontWeight.bold,
                    ),
                  )))),
        ],
      ),
    );
  }

  Widget tabViews() {
    return Expanded(
      child: IndexedStack(
        index: _tabController.index,
        children: [
          productsList(),
          servicesList(),
        ],
      ),
    );
  }

  Widget productsList() {
    return Container(
      color: lightBlue(),
      padding: EdgeInsets.fromLTRB(4, 8, 4, 0),
      child: StaggeredGridView.countBuilder(
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        crossAxisCount: 4,
        itemCount: 200,
        itemBuilder: (BuildContext context, int index) => new Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: CachedNetworkImage(
                      width: double.infinity,
                      imageUrl:
                          "https://i.picsum.photos/id/${index * 10}/200/300.jpg",
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Leptop"),
                            Text("MacBook Pro"),
                          ],
                        ),
                        Text(r"$" + "$index" + ".00")
                      ],
                    ),
                  )
                ],
              ),
            )),
        staggeredTileBuilder: (int index) =>
            new StaggeredTile.count(2, index.isEven ? 2 : 1.5),
        mainAxisSpacing: 2.0,
        crossAxisSpacing: 2.0,
      ),
    );
  }

  Widget servicesList() {
    return Container(
      color: lightBlue(),
      padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: ListView.builder(
        itemBuilder: (context, index) => serviceTile(index),
        itemCount: 10,
      ),
    );
  }

  Widget serviceTile(int index) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: Colors.white,
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
        leading: ClipOval(
          child: CachedNetworkImage(
            imageUrl: "https://i.picsum.photos/id/${index * 20}/200/300.jpg",
            height: 50,
            width: 50,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            placeholder: (context, url) => searchedUser.avatar == ""
                ? Icon(Icons.person)
                : CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
          ),
        ),
        title: Text(
          "Service $index",
          style: TextStyle(color: darkBlue(), fontWeight: FontWeight.bold),
        ),
        subtitle: Text("tap to get details"),
      ),
    );
  }
}
