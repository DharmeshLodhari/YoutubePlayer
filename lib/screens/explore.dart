import 'dart:async';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';

final List<dynamic> services = [
  ["Book Taxi", Icons.local_taxi],
  ["Shopping", Icons.shopping_cart],
  ["Transportation", Icons.train],
  ["Hospitality", Icons.hotel],
  ["Charity", Icons.people],
  ["Public Service", Icons.public],
  ["Utilities", Icons.home],
  ["Mobile Top Up", Icons.phone_iphone],
  ["Investment", Icons.attach_money],
  ["Insurance", Icons.security],
  ["Restaurant", Icons.restaurant],
  ["Financial Service", Icons.account_balance],
  ["Property", Icons.account_balance],
  ["Entertainment", Icons.play_arrow],
  ["E-Books", Icons.book],
  ["News", Icons.info],
];

class ExploreList extends StatefulWidget {
  const ExploreList({super.key});

  @override
  State<ExploreList> createState() => _ExploreListState();
}

class _ExploreListState extends State<ExploreList> {
  bool isSearchBoxOpen = false;
  bool isValidSearch = false;
  TextEditingController? searchController;
  String searchedText = "";
  FocusNode? searchFocus;
  List<dynamic>? searchedResult;

  @override
  void initState() {
    searchController = TextEditingController();
    searchFocus = FocusNode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<ScaffoldState>();

    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        key: key,
        resizeToAvoidBottomInset: true,
        backgroundColor: whiteBackground,
        appBar: AppBar(
          backgroundColor: navyBlue,
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) =>
                ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: search(),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: searchResult,
            )
          ],
        ),
        body: Center(child: listBuilder()),
      ),
    );
  }

  Widget listBuilder() {
    return isValidSearch
        ? FutureBuilder<List?>(
            future: fetchSearchResult(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) => Container(
                    height: 50,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                );
              }
              return LoadingIndicator();
            })
        : ListView.builder(
            itemCount: services.length,
            itemBuilder: (BuildContext context, int index) =>
                getServiceList()[index]);
  }

  List<Widget> getServiceList() {
    final List<Widget> lst = [];
    services.sort((a, b) => a[0].compareTo(b[0]));
    for (final service in services) {
      final card = Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Card(
          margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
          child: ListTile(
            title: Text(service[0],
                style: TextStyle(
                    color: navyBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            leading: Icon(
              service[1],
              color: navyBlue,
            ),
            onTap: () {},
          ),
        ),
      );
      lst.add(card);
    }
    return lst;
  }

  Widget search() {
    if (!isSearchBoxOpen) {
      return Center(child: Text(AppLocalization.of(context)!.explore));
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.keyboard,
              size: 30,
            ),
            onPressed: () {
              if (searchFocus!.hasFocus) {
                FocusScope.of(context).unfocus();
              } else {
                FocusScope.of(context).requestFocus(searchFocus);
              }
            },
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: Center(
              child: TextFormField(
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(fontSize: 15),
                textInputAction: TextInputAction.search,
                focusNode: searchFocus,
                controller: searchController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  hintText: AppLocalization.of(context)!.search,
                  isDense: true,
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onFieldSubmitted: (val) {
                  searchResult();
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

  void searchResult() {
    if (isSearchBoxOpen && searchController!.text.length >= 3) {
      fetchSearchResult();
      FocusScope.of(context).unfocus();
      if (mounted) {
        setState(() {
          isValidSearch = true;
        });
      }
    }
    if (searchController!.text.length < 3) {
      if (mounted) {
        setState(() {
          isValidSearch = false;
        });
      }
    }
    if (isSearchBoxOpen && searchController!.text.isEmpty) {
      if (mounted) {
        setState(() {
          isSearchBoxOpen = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isSearchBoxOpen = true;
        });
      }
    }
  }

  Future<List?> fetchSearchResult() async {
    //TODO:call your searching API with passing searchedText variable and store your List in searchResult to be displayed
    // searchedResult = await _auth.listPaymentRequests("","");
    return searchedResult;
  }
}
