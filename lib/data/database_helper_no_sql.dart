import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';

class DatabaseHelperNoSql {
  // Singleton object of the database
  static final DatabaseHelperNoSql _singleton = DatabaseHelperNoSql._();

  // Singleton accessor
  static DatabaseHelperNoSql get instance => _singleton;

  // completer is used for transforming synchronous code into asynchronous code
  Completer<Database> _dbOpenCompleter;

  // A private constructor. allows us to create a instance of the database with
  // in the same class only
  DatabaseHelperNoSql._();

  // database object accessor
  Future<Database> get database {
    if (_dbOpenCompleter == null) {
      _dbOpenCompleter.complete();
      _openDatabase();
    }
  }

  Future _openDatabase() async {
    // get a platform-specific directory where persistence app data can be stored
    final appDocumentDirectory = await getApplicationDocumentsDirectory();

    // Path with the form: /platform-specific-directory/demo.db
    final dbPath = join(appDocumentDirectory.path, 'demo.db');
  }
}
