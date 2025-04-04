import 'package:flutter/material.dart';
import 'package:thoughts/app/config/theme/app_colors.dart';
import 'package:thoughts/app/model/note/note_model.dart';
import 'package:get/get.dart';
import 'package:thoughts/app/view/common/widgets/custom_button.dart';
import 'package:thoughts/app/view/common/widgets/custom_text_field.dart';

class AddEditNoteModal extends StatelessWidget {
  final NoteModel? note;
  final Function(String title, String content) onSave;

  AddEditNoteModal({super.key, this.note, required this.onSave});

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _isLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    final isEditMode = note != null;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    
    if (isEditMode) {
      _titleController.text = note!.title;
      _contentController.text = note!.note;
    }

    
    final modalWidth = isTablet ? size.width * 0.7 : size.width;

    return Center(
      child: Container(
        width: modalWidth,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditMode ? 'Edit Note' : 'Add Note',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Title',
                  hint: 'Enter note title',
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 600, minHeight: 300),
                  child: CustomTextField(
                    label: 'Content',
                    hint: 'Enter note content',
                    controller: _contentController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter some content';
                      }
                      return null;
                    },
                    maxLines: null,
                    minLines: null,
                    expands: true,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () => CustomButton(
                      text: isEditMode ? 'Update Note' : 'Save Note',
                      onPressed: _saveNote,
                      isLoading: _isLoading.value,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      _isLoading.value = true;

      
      Future.delayed(const Duration(milliseconds: 500), () {
        onSave(_titleController.text.trim(), _contentController.text.trim());
        _isLoading.value = false;
      });
    }
  }
}
