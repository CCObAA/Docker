import 'dart:io';
import 'package:conduit/conduit.dart';
import 'package:projbackend/controllers/app_auth_controller.dart';
import 'package:projbackend/controllers/app_token_controller.dart';
import 'package:projbackend/controllers/app_user_controller.dart';
import 'package:projbackend/controllers/app_notesData_controller.dart';
import 'package:projbackend/controllers/app_notesDataPagination.dart';
import 'package:projbackend/controllers/app_notesDateLogical_controller.dart';

class AppService extends ApplicationChannel {
  late final ManagedContext managedContext;

  @override
  Future prepare() {
    final persistentStore = _initDatabase();

    managedContext = ManagedContext(
      ManagedDataModel.fromCurrentMirrorSystem(), persistentStore);
    return super.prepare();
  }

  @override
  Controller get entryPoint => Router()
    ..route('token/[:refresh]').link(
      () => AppAuthContoler(managedContext),
    )
    ..route('user')
        .link(AppTokenContoller.new)!
        .link(() => AppUserConttolelr(managedContext))
    ..route('notes/[:id]')
        .link(AppTokenContoller.new)!
        .link(() => AppNotesDataController(managedContext))
    ..route('notes/logical/[:id]')
      .link(AppTokenContoller.new)!
      .link(() => AppNotesDataLogicalController(managedContext))
    ..route('notes/pagination/[:pageNumber]')
      .link(AppTokenContoller.new)!
      .link(() => AppNotesDataPaginationController(managedContext));

  PersistentStore _initDatabase() {
    final username = Platform.environment['DB_USERNAME'] ?? 'postgres';
    final password = Platform.environment['DB_PASSWORD'] ?? '1';
    final host = Platform.environment['DB_HOST'] ?? '127.0.0.1';
    final port = int.parse(Platform.environment['DB_PORT'] ?? '5432');
    final databaseName = Platform.environment['DB_NAME'] ?? 'postgres';
    return PostgreSQLPersistentStore(
      username, password, host, port, databaseName);
  }
}