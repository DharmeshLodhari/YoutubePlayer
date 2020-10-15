import 'package:Slydo/screens/more_apps/movies/movie_tile.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

class SpecificCategoryMovieList extends StatefulWidget {
  @override
  _SpecificCategoryMovieListState createState() =>
      _SpecificCategoryMovieListState();
}

class _SpecificCategoryMovieListState extends State<SpecificCategoryMovieList> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar(),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: List.generate(
                50,
                (index) => Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: MovieTileGeneral()),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Most recent discovery",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 1,
      ),
    );
  }
}
