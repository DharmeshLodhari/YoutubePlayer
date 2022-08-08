import 'package:Slydo/screens/moments/moments_bloc.dart';
import 'package:Slydo/services/app_config_bloc.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void locatorSetup() {
  getIt.registerSingleton<MomentsBloc>(MomentsBloc());
  getIt.registerSingleton<AppConfigurationBloc>(AppConfigurationBloc());
}
