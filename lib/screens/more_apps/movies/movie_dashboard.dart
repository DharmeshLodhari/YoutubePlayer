import 'package:Slydo/screens/more_apps/movies/movie_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/movies/movie_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MovieDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MovieDashboardBloc>.value(
          value: MovieDashboardBloc(),
        ),
      ],
      child: MovieDashboardScreen(),
    );
  }
}
