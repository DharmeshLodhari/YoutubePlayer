import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';

class ConnectionListManager {
  DatabaseHelper _db = DatabaseHelper();

  ///Store Connections in to the db
  void saveConnectionsToDB({List<CustomerProfile> connections}) async {
    await _db.saveUserConnections(connections);
  }

  ///Clear stored connections From db
  void clearConnectionsFromDB() {}

  ///Get Connections From db
  Future<List<CustomerProfile>> getConnectionsFromDB() async {
    return await _db.getUserConnections();
  }

  ///Get Connections Count
  Future<int> getConnectionsCount() async {
    return await _db.getUserConnectionsCount();
  }

  ///Update LastMessage time in Db
  Future<int> updateLastMessageTime({String conversationId, int time}) async {
    return await _db.updateConnectionListLastMessageTime(
        conversationId: conversationId, time: time);
  }
}
