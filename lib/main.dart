import 'package:PayBay/data/state_notifier.dart';
import 'package:PayBay/screens/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider<UserBloc>.value(
              value: UserBloc(),
            )
          ],
          child: MaterialApp(
              initialRoute: '/',
              onGenerateRoute: RouteGenerator.generateRoute)),
    );
