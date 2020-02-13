import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/screens/tiles/transaction.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:flutter/material.dart';

class ExploreList extends StatefulWidget {
  @override
  _ExploreListState createState() => _ExploreListState();
}

class _ExploreListState extends State<ExploreList> {
  bool isSearchBoxOpen = false;
  bool isValidSearch = false;
  TextEditingController searchController;
  String searchedText = "";
  final _auth = AuthService();
  List<dynamic> searchResult;

  @override
  void initState() {
    searchController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<ScaffoldState>();

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/dashboard');
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: lightBlue(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: darkBlue(),
          title: AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) => ScaleTransition(
              child: child,
              scale: animation,
            ),
            child: search(),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                if (isSearchBoxOpen && searchController.text.length > 3) {
                  fetchSearchResult();
                  setState(() {
                    isValidSearch = true;
                  });
                }
                if (searchController.text.length <= 3) {
                  setState(() {
                    isValidSearch = false;
                  });
                }
                if (isSearchBoxOpen && searchController.text.length == 0) {
                  setState(() {
                    isSearchBoxOpen = false;
                  });
                } else {
                  setState(() {
                    isSearchBoxOpen = true;
                  });
                }
              },
            )
          ],
        ),
        body: Center(child: listBuilder()),
      ),
    );
  }

  Widget listBuilder() {
    return isValidSearch
        ? FutureBuilder(
            future: fetchSearchResult(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) => TransactionTile(
                          transaction: snapshot.data[index],
                        ));
              }
              return LoadingIndicator();
            })
        : Center(
            child: Container(
            child: Text(
              "There is nothing to show !!",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ));
  }

  Widget search() {
    if (!isSearchBoxOpen) {
      return Center(child: Text("Explore"));
    } else {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Icon(
            Icons.explore,
            size: 30,
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Center(
              child: TextFormField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Seach here",
                  isDense: true,
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onFieldSubmitted: (val) {
                  fetchSearchResult();
                },
                onChanged: (value) {
                  searchedText = value;
                },
              ),
            ),
          ),
        ],
      );
    }
  }

  Future<List> fetchSearchResult() async {
    //call your searching API with passing searchedText variable and store your List in searchResult to be displayed
    searchResult = await _auth.getTransactions();
    return searchResult;
  }
}
