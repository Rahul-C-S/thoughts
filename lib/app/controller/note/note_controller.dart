import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thoughts/app/config/theme/app_colors.dart';
import 'package:thoughts/app/database/database.dart';
import 'package:thoughts/app/database/db_constants.dart';
import 'package:thoughts/app/model/note/note_model.dart';

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

      Get.snackbar(
        'Success',
        'Note has been created!',
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
      _fetchNotes();
    } catch (e, s) {
      Get.snackbar(
        'Error',
        'Unable to create note!',
        backgroundColor: AppColors.error,
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
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

      Get.snackbar(
        'Success',
        'Note has been updated!',
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
      _fetchNotes();
    } catch (e, s) {
      Get.snackbar(
        'Error',
        'Unable to update note!',
        backgroundColor: AppColors.error,
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
      debugPrint(s.toString());
    }
  }

  Future<void> deleteNote({required String id}) async {
    try {
      await _database.delete(DbConstants.noteCollection, id);
      Get.snackbar(
        'Success',
        'Note has been deleted!',
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
      _fetchNotes();
    } catch (e, s) {
      Get.snackbar(
        'Error',
        'Unable to delete note!',
        backgroundColor: AppColors.error,
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
      debugPrint(s.toString());
    }
  }
}
