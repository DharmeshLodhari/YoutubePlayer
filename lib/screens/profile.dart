import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/user.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
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

  // this variable will responsible for is the user is owner of the products and add
  // edit button on the product if user is owner
  bool isOwner = false;
  UserBloc userBloc;

  @override
  void initState() {
    searchedUser = arguments['searchedUser'];

    _tabController = new TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    if (userBloc.user.userName == searchedUser.userName) {
      isOwner = true;
    }

    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (context, i) {
            return [
              SliverAppBar(
                backgroundColor: darkBlue(),
                pinned: true,
                expandedHeight: 220.0,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.call,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.message,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                ],
                bottom: tabBar(),
                title: Text(searchedUser.userName),
                titleSpacing: 0,
                flexibleSpace: FlexibleSpaceBar(
                    titlePadding: EdgeInsets.only(bottom: 37),
                    centerTitle: true,
                    title: Text(searchedUser.fullName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                        )),
                    background: Image.network(
                      searchedUser.avatar,
                      fit: BoxFit.cover,
                    )),
              ),
            ];
          },
          body: tabViews()),
    );
  }

  Widget tabBar() {
    return TabBar(
      indicatorColor: Colors.white,
      onTap: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      controller: _tabController,
      tabs: <Widget>[
        Material(
            color: Colors.transparent,
            child: Container(
                height: 35,
                child: Center(
                    child: Text(
                  "Productes",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )))),
        Material(
            color: Colors.transparent,
            child: Container(
                height: 35,
                child: Center(
                    child: Text(
                  "Services",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )))),
      ],
    );
  }

  Widget tabViews() {
    return IndexedStack(
      index: currentIndex,
      children: [
        productsList(),
        servicesList(),
      ],
    );
  }

  Widget productsList() {
    return Scaffold(
      body: Container(
        color: lightBlue(),
        padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
        child: StaggeredGridView.countBuilder(
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
                      child: Stack(children: <Widget>[
                        CachedNetworkImage(
                          width: double.infinity,
                          imageUrl:
                              "https://i.picsum.photos/id/${index * 10}/200/300.jpg",
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.high,
                        ),
                        isOwner
                            ? Positioned(
                                right: 0,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: darkBlue(),
                                  ),
                                  onPressed: () {},
                                ),
                              )
                            : Container()
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Leptop",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "MacBook Pro",
                                style: TextStyle(color: Colors.grey),
                              ),
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
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton(
              heroTag: "add-product",
              backgroundColor: darkBlue(),
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, '/add-product');
              },
            )
          : null,
    );
  }

  Widget servicesList() {
    return Scaffold(
      body: Container(
        color: lightBlue(),
        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: ListView.builder(
          itemBuilder: (context, index) => serviceTile(index),
          itemCount: 10,
        ),
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton(
              heroTag: "add-service",
              backgroundColor: darkBlue(),
              child: Icon(Icons.add),
              onPressed: () {},
            )
          : null,
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
        trailing: isOwner
            ? IconButton(
                icon: Icon(
                  Icons.edit,
                  color: darkBlue(),
                ),
                onPressed: () {},
              )
            : null,
      ),
    );
  }
}
