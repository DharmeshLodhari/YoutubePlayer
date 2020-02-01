import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider<UserBloc>.value(
              value: UserBloc(),
            ),
            ChangeNotifierProvider<PayeeBloc>.value(
              value: PayeeBloc(),
            ),
            ChangeNotifierProvider<CustomerProfileBloc>.value(
              value: CustomerProfileBloc(),
            ),
          ],
          child: MaterialApp(
            initialRoute: '/',
            onGenerateRoute: RouteGenerator.generateRoute,
            debugShowCheckedModeBanner: false,
          )),
    );
