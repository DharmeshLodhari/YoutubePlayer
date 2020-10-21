import 'package:Slydo/screens/more_apps/movies/movie_tile.dart';
import 'package:flutter/material.dart';

class MyTicketList extends StatefulWidget {
  @override
  _MyTicketListState createState() => _MyTicketListState();
}

class _MyTicketListState extends State<MyTicketList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: List.generate(
              50,
              (index) => Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: MovieTile()),
            ),
          ),
        ),
      ),
    );
  }
}
