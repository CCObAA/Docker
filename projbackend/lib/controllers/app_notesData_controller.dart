import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:projbackend/model/NotesData.dart';

import '../model/response.dart';
import '../utils/app_response.dart';
import '../utils/app_utils.dart';

class AppNotesDataController extends ResourceController {
  AppNotesDataController(this.managedContext);

  final ManagedContext managedContext;

  @Operation.post()
  Future<Response> createNotesData(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.body() NotesData notesData
  ) async {
    try {
      // Получаем id пользователя из header
      final id = AppUtils.getIdFromHeader(header);

      // Создаем запрос для создания заметки передаем id пользователя контент берем из body
      final qCreateNotesData = Query<NotesData>(managedContext)
        ..values.notesName = notesData.notesName
        ..values.content = notesData.content
        ..values.createDate = DateTime.now()
        ..values.editingDate = DateTime.now()
        ..values.isDeleted = false
        //передаем в внешний ключ id пользователя
        ..values.user!.id = id
        ..values.category!.id = notesData.idCategory;

      await qCreateNotesData.insert();

      return AppResponse.ok(message: 'Успешное создание заметки');
    } catch (error) {
      return AppResponse.serverError(error, message: 'Ошибка создания заметки');
    }
  }

  @Operation.get()
  Future<Response> getFullNotesData(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
  ) async {
    try {
      // Получаем id пользователя из header
      final id = AppUtils.getIdFromHeader(header);

      final qCreateNotesData = Query<NotesData>(managedContext)
        ..where((x) => x.user!.id).equalTo(id)
        ..where((x) => x.isDeleted).equalTo(false);

      final List<NotesData> list = await qCreateNotesData.fetch();

      if (list.isEmpty)
      {
        return Response.notFound(body: ModelResponse(data: [], message: "Нет ни одной заметки"));
      }

      return Response.ok(list);
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }

  @Operation.get("id")
  Future<Response> getNotesDataFromID(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.path("id") int id,
  ) async {
    try {
      final currentUserId = AppUtils.getIdFromHeader(header);
      final notesData = await managedContext.fetchObjectWithID<NotesData>(id);
      if (notesData == null) {
        return AppResponse.ok(message: "Заметка не найдена");
      }
      if (notesData.user?.id != currentUserId) {
        return AppResponse.ok(message: "Нет доступа к заметке");
      }
      notesData.backing.removeProperty("user");
      return Response.ok(notesData);
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка получения заметки");
    }
  }

  @Operation.put('id')
  Future<Response> updateNotesData(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path("id") int id,
      @Bind.body() NotesData bodyNotesData
  ) async {
    try {
      final currentUserId = AppUtils.getIdFromHeader(header);
      final notesData = await managedContext.fetchObjectWithID<NotesData>(id);
      if (notesData == null) {
        return AppResponse.ok(message: "Заметка запись не найдена");
      }
      if (notesData.user?.id != currentUserId) {
        return AppResponse.ok(message: "Нет доступа к заметке");
      }

      final qUpdateNotesData = Query<NotesData>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.notesName = bodyNotesData.notesName
        ..values.content = bodyNotesData.content
        ..values.createDate = bodyNotesData.createDate
        ..values.editingDate = bodyNotesData.editingDate
        ..values.isDeleted = bodyNotesData.isDeleted
        //передаем в внешний ключ id пользователя
        ..values.user!.id = currentUserId
        ..values.category!.id = bodyNotesData.idCategory;

      await qUpdateNotesData.update();

      return AppResponse.ok(message: 'Заметка успешно обновлена');

    } catch (e) {
      return AppResponse.serverError(e);
    }
  }


  @Operation.delete("id")
  Future<Response> deleteNotesData(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.path("id") int id,
  ) async {
    try {
      final currentUserId = AppUtils.getIdFromHeader(header);
      final notesData = await managedContext.fetchObjectWithID<NotesData>(id);
      if (notesData == null) {
        return AppResponse.ok(message: "Заметка не найден");
      }
      if (notesData.user?.id != currentUserId) {
        return AppResponse.ok(message: "Нет доступа к заметке :(");
      }
      final qDeleteNotesData = Query<NotesData>(managedContext)
        ..where((x) => x.id).equalTo(id);
      await qDeleteNotesData.delete();
      return AppResponse.ok(message: "Успешное удаление заметки");
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка удаления заметки");
    }
  }
}

