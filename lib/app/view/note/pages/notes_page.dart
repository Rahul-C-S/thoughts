import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:thoughts/app/config/theme/app_colors.dart';
import 'package:thoughts/app/controller/note/note_controller.dart';
import 'package:thoughts/app/model/note/note_model.dart';
import 'package:thoughts/app/view/common/widgets/custom_button.dart';
import 'package:thoughts/app/view/note/widgets/add_edit_note_modal.dart';

class NotesPage extends GetView<NoteController> {
  const NotesPage({super.key});

  void _showAddEditNoteModal({NoteModel? note}) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => AddEditNoteModal(
            note: note,
            onSave: (title, content) {
              if (note == null) {
                controller.addNote(title: title, note: content);
              } else {
                controller.updateNote(id: note.id, title: title, note: content);
              }
              Navigator.pop(context);
            },
          ),
    );
  }

  void _showDeleteConfirmation(String noteId) {
    showDialog(
      context: Get.context!,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Delete Note',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Text(
              'Are you sure you want to delete this note? This action cannot be undone.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                onPressed: () {
                  controller.deleteNote(id: noteId);
                  Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1200;

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.notes.isEmpty) {
                  return _buildEmptyState();
                }

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? size.width * 0.1 : 16,
                    vertical: 16,
                  ),
                  child:
                      isTablet || isDesktop
                          ? _buildGridView(isDesktop ? 3 : 2)
                          : _buildListView(),
                );
              }),
            ),
          ],
        ),

        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () => _showAddEditNoteModal(),
            child: Icon(Icons.add, color: AppColors.buttonText),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_alt_outlined, size: 80, color: AppColors.textLight),
          const SizedBox(height: 16),
          Text(
            'No notes yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first note',
            style: TextStyle(color: AppColors.textLight),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Create Note',
            onPressed: () => _showAddEditNoteModal(),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: controller.notes.length,
      itemBuilder: (context, index) {
        final note = controller.notes[index];
        return _buildSwipeableNoteCard(note);
      },
    );
  }

  Widget _buildGridView(int crossAxisCount) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: controller.notes.length,
      itemBuilder: (context, index) {
        final note = controller.notes[index];

        return _buildNoteCard(note);
      },
    );
  }

  Widget _buildSwipeableNoteCard(NoteModel note) {
    return Dismissible(
      key: Key(note.id),

      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),

      secondaryBackground: Container(
        color: AppColors.primary,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.edit, color: Colors.white),
      ),

      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          _showAddEditNoteModal(note: note);
          return false;
        } else if (direction == DismissDirection.startToEnd) {
          _showDeleteConfirmation(note.id);
          return false;
        }
        return false;
      },
      child: _buildNoteCard(note),
    );
  }

  Widget _buildNoteCard(NoteModel note) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final formattedDate = dateFormat.format(note.createdAt);
    final bool isEdited = note.updatedAt.isAfter(note.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showAddEditNoteModal(note: note),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                const Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: AppColors.error),
                                const SizedBox(width: 8),
                                const Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showAddEditNoteModal(note: note);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(note.id);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 80),
                child: Text(
                  note.note,
                  style: TextStyle(color: AppColors.textSecondary),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 12, color: AppColors.textLight),
                  ),
                  if (isEdited) ...[
                    const SizedBox(width: 8),
                    Text(
                      '(edited)',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
