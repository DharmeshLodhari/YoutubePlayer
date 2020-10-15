import 'package:Slydo/screens/more_apps/movies/movie_tile.dart';
import 'package:flutter/material.dart';

class MyMovieList extends StatefulWidget {
  @override
  _MyMovieListState createState() => _MyMovieListState();
}

class _MyMovieListState extends State<MyMovieList> {
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
