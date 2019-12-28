import 'package:flutter/material.dart';


// https://willowtreeapps.com/ideas/how-to-use-flutter-to-build-an-app-with-bottom-navigation
//https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html?source=post_page---------------------------


BottomNavigationBar bottomNavigationBar = BottomNavigationBar(
  currentIndex: 2, // new
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.home,
        color: Colors.grey[400],),
      title: Text('Home', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.group,
      color: Colors.grey[400]),
      title: Text('Accounts', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.shopping_cart,
        color: Colors.grey[400]
      ),
      title: Text('Transactions', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings,
        color: Colors.grey[400]
      ),
      title: Text('Settings', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
    ),
  ],
);
