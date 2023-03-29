import 'package:conduit/conduit.dart';
import 'catigories.dart';
import 'user.dart';

class NotesData extends ManagedObject<_NotesData> implements _NotesData {}

class _NotesData{
  @primaryKey
  int? id;
  @Column(indexed: true)
  String? notesName;
  @Column(indexed: true)
  String? content;
  @Column(indexed: true)
  DateTime? createDate;
  @Column(indexed: true)
  DateTime? editingDate;
  @Column(indexed: true)
  bool? isDeleted;

  @Serialize(input: true, output: false)
  int? idCategory;

  @Relate(#notesList, isRequired: true, onDelete: DeleteRule.cascade)
  User? user;
  @Relate(#notesList, isRequired: true, onDelete: DeleteRule.cascade)
  Categories? category;

}