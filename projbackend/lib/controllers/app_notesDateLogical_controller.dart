import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:projbackend/model/NotesData.dart';

import '../model/response.dart';
import '../utils/app_response.dart';
import '../utils/app_utils.dart';

class AppNotesDataLogicalController extends ResourceController {
  AppNotesDataLogicalController(this.managedContext);

  final ManagedContext managedContext;

  @Operation.put('id')
  Future<Response> deleteLogicalNotesData(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.path("id") int id,
    @Bind.query('isDeleted') String isDeleted,
  ) async {
    try {
      final currentUserId = AppUtils.getIdFromHeader(header);
      final notesData = await managedContext.fetchObjectWithID<NotesData>(id);
      if (notesData == null) {
        return AppResponse.ok(message: "Заметка не найдена");
      }
      if (notesData.user?.id != currentUserId) {
        return AppResponse.ok(message: "Нет доступа к заметке :(");
      }
      bool delorback = true;
      if(isDeleted == "true")
      {
        delorback = true;
      }
      else if(isDeleted == "false")
      {
        delorback = false;
      }
      else
      {
        return AppResponse.ok(message: "Введено неверное значение");
      }
      final qDeleteLogicalNotesData = Query<NotesData>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.isDeleted = delorback;
      await qDeleteLogicalNotesData.update();
      return AppResponse.ok(message: "Успешное логическое удаление или восстановление");
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка логического удаления или восстановления");
    }
  }
}

