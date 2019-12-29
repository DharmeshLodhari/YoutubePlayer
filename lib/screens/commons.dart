import 'package:flutter/material.dart';


BottomNavigationBar bottomNavigationBar = BottomNavigationBar(
  currentIndex: 0,
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
