import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thoughts/app/database/database.dart';
import 'package:thoughts/app/database/db_constants.dart';
import 'package:thoughts/app/model/note/note_model.dart';
import 'package:thoughts/app/utils/snackbar.dart';

class NoteController extends GetxController {
  final Database _database = Get.find();
  RxList<NoteModel> notes = RxList([]);

  @override
  void onInit() {
    super.onInit();
    Future.delayed(Durations.short2, () async => await _fetchNotes());
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    final notesList = await _database.getCollection(DbConstants.noteCollection);
    notes.value = notesList.map((e) => NoteModel.fromMap(e)).toList();
  }

  Future<void> addNote({required String title, required String note}) async {
    try {
      await _database.create(DbConstants.noteCollection, {
        DbConstants.title: title,
        DbConstants.note: note,
      });

      showSnackbar(
        title: 'Success',
        message: 'Note has been saved!',
        type: SnackbarType.success,
      );
      _fetchNotes();
    } catch (e, s) {
      showSnackbar(
        title: 'Error',
        message: 'Unable to create note!',
        type: SnackbarType.error,
      );
      debugPrint(s.toString());
    }
  }

  Future<void> updateNote({
    required String id,
    required String title,
    required String note,
  }) async {
    try {
      await _database.update(DbConstants.noteCollection, id, {
        DbConstants.title: title,
        DbConstants.note: note,
      });

      showSnackbar(
        title: 'Success',
        message: 'Note has been updated!',
        type: SnackbarType.success,
      );
      _fetchNotes();
    } catch (e, s) {
      showSnackbar(
        title: 'Error',
        message: 'Unable to update note!',
        type: SnackbarType.error,
      );
      debugPrint(s.toString());
    }
  }

  Future<void> deleteNote({required String id}) async {
    try {
      await _database.delete(DbConstants.noteCollection, id);
      showSnackbar(
        title: 'Success',
        message: 'Note has been deleted!',
        type: SnackbarType.success,
      );
      _fetchNotes();
    } catch (e, s) {
      showSnackbar(
        title: 'Error',
        message: 'Unable to delete note!',
        type: SnackbarType.error,
      );
      debugPrint(s.toString());
    }
  }
}
