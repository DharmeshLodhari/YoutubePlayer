import 'dart:convert';

import 'package:Slydo/models/store.dart';
import 'package:Slydo/services/auth.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart' as slydoUser;

class AutoCompleteDemo extends StatefulWidget {
  AutoCompleteDemo() : super();

  final String title = "AutoComplete Demo";

  @override
  _AutoCompleteDemoState createState() => _AutoCompleteDemoState();
}

class _AutoCompleteDemoState extends State<AutoCompleteDemo> {
  AutoCompleteTextField searchTextField;
  GlobalKey<AutoCompleteTextFieldState<User>> key = new GlobalKey();
  static List<dynamic> results = new List<dynamic>();
  bool loading = false;
  var filterValue = "Users";
  final _auth = AuthService();

  void getSearchResults() async {
    try {
      final response =
          await http.get("https://jsonplaceholder.typicode.com/users");
      debugPrint("Status COde : " + response.statusCode.toString());
      if (response.statusCode == 200) {
        results = loadResults(response.body);
        print('Users: ${results.length}');
        setState(() {
          loading = false;
        });
      } else {
        print("Error getting users.");
      }
    } catch (e) {
      print("Error getting users.");
    }
  }

  List<Widget> loadResults(String jsonString) {
    var results = [];
    final parsed = json.decode(jsonString).cast < Map<String, dynamic>();
    switch (filterValue) {
      case "Products":
        for (var item in parsed) {
          var product = _auth.createProduct(item);
          results.add(getProductTile(product));
        }
        break;
      case "Users":
//        for (var item in parsed) {
//          slydoUser.User _user = _auth.createUserInstance(item);
//          results.add(getUserTile(_user));
        results
            .addAll(parsed.map<User>((json) => User.fromJson(json)).toList());
//        }
        break;

      case "Services":
        for (var item in parsed) {
          var service = _auth.createService(item);
          results.add(getServiceTile(service));
        }
        break;
      default:
        for (var item in parsed) {
          slydoUser.User _user = _auth.createUserInstance(item);
          results.add(getUserTile(_user));
        }
    }

    return results;
  }

  @override
  void initState() {
    getSearchResults();
    super.initState();
  }

  Widget row(User user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Text(
            user.name,
            style: TextStyle(fontSize: 16.0),
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
        Text(
          user.email,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: loading
            ? CircularProgressIndicator(
                backgroundColor: Colors.white,
              )
            : searchTextField = AutoCompleteTextField<dynamic>(
                key: key,
                clearOnSubmit: false,
                suggestions: results,
                style: TextStyle(color: Colors.black, fontSize: 16.0),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 20.0),
                  hintText: "Search Name",
                  hintStyle: TextStyle(color: Colors.black),
                ),
                itemFilter: (item, query) {
                  return item.name
                      .toLowerCase()
                      .startsWith(query.toLowerCase());
                },
                itemSorter: (a, b) {
                  return a.name.compareTo(b.name);
                },
                itemSubmitted: (item) {
                  setState(() {
                    searchTextField.textField.controller.text = item.name;
                  });
                },
                itemBuilder: (context, item) {
                  // ui for the autocompelete row
                  return displayTile(item);
                },
              ),
        actions: <Widget>[_threeItemPopup()],
      ),
    );
  }

  Widget _threeItemPopup() => PopupMenuButton(
        padding: EdgeInsets.all(0),
        captureInheritedThemes: true,
        itemBuilder: (context) {
          var list = List<PopupMenuEntry<Object>>();
          list.add(
            PopupMenuItem(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Filter"),
                  Icon(
                    Icons.sort,
                    color: Colors.black,
                  )
                ],
              ),
              value: 1,
            ),
          );
          list.add(
            PopupMenuDivider(
              height: 10,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                "Users",
                style: TextStyle(color: Colors.black),
              ),
              value: "Users",
              checked: filterValue == "Users" ? true : false,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                "Products",
                style: TextStyle(color: Colors.black),
              ),
              value: "Products",
              checked: filterValue == "Products" ? true : false,
            ),
          );

          list.add(
            CheckedPopupMenuItem(
              child: Text(
                "Services",
                style: TextStyle(color: Colors.black),
              ),
              value: "Services",
              checked: filterValue == "Services" ? true : false,
            ),
          );

          return list;
        },
        onSelected: (Object object) {
          setState(() {
            if (object != 1) {
              filterValue = object;
            }
          });
        },
      );

  Widget displayTile(dynamic object) {
    if (filterValue == "Users") {
      return getUserTile(object);
    } else if (filterValue == "Products") {
      return getProductTile(object);
    } else if (filterValue == "Services") {
      return getServiceTile(object);
    } else
      return Card(
        child: ListTile(),
      );
  }

  Widget getUserTile(slydoUser.User object) {
    return ListTile();
  }

  Widget getProductTile(Product object) {
    return ListTile();
  }

  Widget getServiceTile(Service object) {
    return ListTile();
  }
}

class User {
  int id;
  String name;
  String email;

  User({this.id, this.name, this.email});

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return User(
      id: parsedJson["id"],
      name: parsedJson["name"] as String,
      email: parsedJson["email"] as String,
    );
  }
}
