import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../providers/category_provider.dart';
import '../providers/note_editor_provider.dart';
import '../models/note_model.dart';
import '../widgets/dialog/create_label_dialog.dart';
import '../widgets/dialog/attachment_bottom_sheet.dart';
import '../widgets/dialog/more_options_bottom_sheet.dart';
import '../widgets/image_tile.dart';

class NoteEditorScreen extends StatelessWidget {
  final NoteModel? note; // Pass a note to edit, or null to create a new one
  final bool isChecklist;

  const NoteEditorScreen({super.key, this.note, this.isChecklist = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
      NoteEditorProvider()..init(note, isChecklistMode: isChecklist),
      child: const _NoteEditorContent(),
    );
  }
}

class _NoteEditorContent extends StatelessWidget {
  const _NoteEditorContent();

  Future<void> _saveAndExit(
      BuildContext context, NoteEditorProvider provider) async {
    final success = await provider.saveNote();
    if (context.mounted) {
      if (provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (success || provider.errorMessage == null) {
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteEditorProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || provider.isSaving) return;
        await _saveAndExit(context, provider);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
            onPressed: provider.isSaving
                ? null
                : () => _saveAndExit(context, provider),
          ),
          actions: [
            // Pin Button
            IconButton(
              icon: Icon(
                provider.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              ),
              onPressed: provider.isSaving ? null : () => provider.togglePin(),
            ),
            // Archive / Save Button
            IconButton(
              icon: provider.isSaving
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.archive_outlined, color: Colors.black54),
              onPressed: provider.isSaving
                  ? null
                  : () async {
                final success = await provider.saveNote();
                if (context.mounted) {
                  if (provider.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(provider.errorMessage!),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  if (success) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              // Multi-Image Gallery Header
              if (provider.remoteImageUrls.isNotEmpty ||
                  provider.localImages.isNotEmpty)
                Container(
                  height: 180,
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Remote saved images from Supabase
                      ...provider.remoteImageUrls.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final url = entry.value;
                        return ImageTile(
                          image: Image.network(
                            url,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: Colors.grey.shade100,
                                child: const Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.grey,
                                  ),
                                ),
                          ),
                          onRemove: () => provider.removeRemoteImage(idx),
                        );
                      }),
                      // Local pending images before upload
                      ...provider.localImages.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final file = entry.value;
                        return ImageTile(
                          image: kIsWeb
                              ? Image.network(file.path, fit: BoxFit.cover)
                              : Image.file(
                            File(file.path),
                            fit: BoxFit.cover,
                          ),
                          onRemove: () => provider.removeLocalImage(idx),
                        );
                      }),
                    ],
                  ),
                ),

              // Title Input
              TextField(
                controller: provider.titleController,
                style:
                const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                decoration: const InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(color: Colors.black38),
                  filled: false,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
              ),

              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 8),

              // Checklist Progress & Quick Actions Bar
              if (provider.isChecklistMode)
                _ChecklistHeaderBar(provider: provider),

              // Dynamic Content Area (Text or Checklist)
              Expanded(
                child: provider.isChecklistMode
                    ? _ChecklistContent(provider: provider)
                    : TextField(
                  controller: provider.contentController,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Note',
                    hintStyle: TextStyle(color: Colors.black38),
                    filled: false,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                ),
              ),

              // Labels Section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                width: double.infinity,
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (categoryProvider.isLoading)
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      ...categoryProvider.categories.map((category) {
                        final isSelected = provider.categoryId == category.id;

                        return FilterChip(
                          avatar: isSelected
                              ? null
                              : const Icon(
                            Icons.label_outline,
                            size: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                          label: Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.onSurface,
                            ),
                          ),
                          selected: isSelected,
                          showCheckmark: false,
                          backgroundColor: Colors.grey.shade100,
                          selectedColor: AppColors.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.secondary
                                  : Colors.grey.shade300,
                            ),
                          ),
                          onSelected: (bool selected) {
                            provider.setCategory(selected ? category.id : null);
                          },
                        );
                      }),
                    ActionChip(
                      avatar: const Icon(Icons.add,
                          size: 14, color: AppColors.primary),
                      label: const Text(
                        'Add label',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      onPressed: () {
                        _showAddLabelDialog(
                            context, categoryProvider, provider);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Bottom Action Bar
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          elevation: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Add attachment',
                    icon: const Icon(Icons.add_box_outlined,
                        color: Colors.black54),
                    onPressed: () =>
                        AttachmentBottomSheet.show(context, provider),
                  ),
                  IconButton(
                    tooltip: provider.isChecklistMode
                        ? 'Convert to plain note'
                        : 'Toggle checklist',
                    icon: Icon(
                      provider.isChecklistMode
                          ? Icons.check_box
                          : Icons.check_box_outlined,
                      color: provider.isChecklistMode
                          ? AppColors.primary
                          : Colors.black54,
                    ),
                    onPressed: () => provider.toggleChecklistMode(),
                  ),
                  IconButton(
                    tooltip: 'Color',
                    icon: const Icon(Icons.palette_outlined,
                        color: Colors.black54),
                    onPressed: () {},
                  ),
                  IconButton(
                    tooltip: 'Add label',
                    icon: const Icon(Icons.label_outline,
                        color: Colors.black54),
                    onPressed: () =>
                        _showAddLabelDialog(context, categoryProvider, provider),
                  ),
                ],
              ),
              IconButton(
                tooltip: 'More options',
                icon: const Icon(Icons.more_vert, color: Colors.black54),
                onPressed: () => MoreOptionsBottomSheet.show(context, provider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddLabelDialog(
      BuildContext context,
      CategoryProvider categoryProvider,
      NoteEditorProvider provider,
      ) {
    CreateLabelDialog.show(
      context,
      categoryProvider: categoryProvider,
      onCategoryCreated: (newCategory) {
        provider.setCategory(newCategory.id);
      },
    );
  }
}

class _ChecklistHeaderBar extends StatelessWidget {
  final NoteEditorProvider provider;

  const _ChecklistHeaderBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${provider.completedCount} / ${provider.totalCount} completed',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: provider.checklistProgress,
                    minHeight: 4,
                    backgroundColor: Colors.grey.shade200,
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            tooltip: 'Checklist options',
            icon: Icon(Icons.tune, size: 20, color: Colors.grey.shade700),
            onSelected: (value) {
              switch (value) {
                case 'toggle_all':
                  provider.toggleAllChecklistItems();
                  break;
                case 'delete_checked':
                  provider.deleteCheckedItems();
                  break;
                case 'plain_text':
                  provider.toggleChecklistMode();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_all',
                child: Row(
                  children: [
                    Icon(
                      provider.allItemsChecked
                          ? Icons.check_box_outline_blank
                          : Icons.done_all,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(provider.allItemsChecked
                        ? 'Uncheck all items'
                        : 'Check all items'),
                  ],
                ),
              ),
              if (provider.completedCount > 0)
                const PopupMenuItem(
                  value: 'delete_checked',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep_outlined,
                          size: 18, color: Colors.redAccent),
                      SizedBox(width: 10),
                      Text(
                        'Delete checked items',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'plain_text',
                child: Row(
                  children: [
                    Icon(Icons.notes_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Hide checkboxes'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChecklistContent extends StatelessWidget {
  final NoteEditorProvider provider;

  const _ChecklistContent({required this.provider});

  @override
  Widget build(BuildContext context) {
    final unchecked = provider.uncheckedItems;
    final checked = provider.checkedItems;

    return CustomScrollView(
      slivers: [
        // Reorderable Unchecked Items
        SliverReorderableList(
          itemCount: unchecked.length,
          onReorderItem: (oldIndex, newIndex) =>
              provider.reorderUncheckedItem(oldIndex, newIndex),
          proxyDecorator: (child, index, animation) {
            return Material(
              elevation: 3,
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              child: child,
            );
          },
          itemBuilder: (context, index) {
            final item = unchecked[index];
            final realIndex = provider.checklistItems.indexOf(item);
            return _ChecklistRow(
              key: ObjectKey(item),
              item: item,
              realIndex: realIndex,
              reorderIndex: index,
              provider: provider,
              canReorder: true,
            );
          },
        ),

        // "+ List item" Button
        SliverToBoxAdapter(
          child: InkWell(
            onTap: () => provider.addChecklistItem(),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const SizedBox(width: 24),
                  const SizedBox(
                    width: 40,
                    height: 36,
                    child: Icon(Icons.add, color: Colors.grey, size: 22),
                  ),
                  Text(
                    'List item',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Collapsible Checked Items Section
        if (checked.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
              child: Column(
                children: [
                  Divider(height: 1, color: Colors.grey.shade300),
                  InkWell(
                    onTap: () => provider.toggleShowCheckedItems(),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            provider.showCheckedItems
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_right,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${checked.length} checked ${checked.length == 1 ? 'item' : 'items'}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => provider.deleteCheckedItems(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Clear',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (provider.showCheckedItems)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final item = checked[index];
                  final realIndex = provider.checklistItems.indexOf(item);
                  return _ChecklistRow(
                    key: ObjectKey(item),
                    item: item,
                    realIndex: realIndex,
                    provider: provider,
                    canReorder: false,
                  );
                },
                childCount: checked.length,
              ),
            ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  final ChecklistItem item;
  final int realIndex;
  final int? reorderIndex;
  final NoteEditorProvider provider;
  final bool canReorder;

  const _ChecklistRow({
    super.key,
    required this.item,
    required this.realIndex,
    required this.provider,
    required this.canReorder,
    this.reorderIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Handle hardware/web backspace at offset 0 to delete or merge line
    item.focusNode.onKeyEvent = (node, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.backspace) {
        final selection = item.controller.selection;
        final isComposing = item.controller.value.composing.isValid &&
            !item.controller.value.composing.isCollapsed;
        if (!isComposing &&
            selection.isCollapsed &&
            selection.baseOffset == 0) {
          provider.handleBackspaceAtStart(realIndex);
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    };

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle for unchecked items
          if (canReorder && reorderIndex != null)
            ReorderableDragStartListener(
              index: reorderIndex!,
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0, right: 2.0),
                child: Icon(
                  Icons.drag_indicator,
                  size: 18,
                  color: Colors.grey.shade400,
                ),
              ),
            )
          else
            const SizedBox(width: 20),

          // Checkbox
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Checkbox(
              value: item.isChecked,
              onChanged: (val) => provider.toggleChecklistItem(realIndex, val),
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              visualDensity: VisualDensity.compact,
            ),
          ),

          // Editable Content Line
          Expanded(
            child: TextField(
              controller: item.controller,
              focusNode: item.focusNode,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                decoration:
                item.isChecked ? TextDecoration.lineThrough : null,
                decorationColor: Colors.grey,
                color: item.isChecked ? Colors.grey : Colors.black87,
              ),
              decoration: const InputDecoration(
                hintText: 'List item',
                hintStyle: TextStyle(color: Colors.black26),
                filled: false,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onEditingComplete: () {
                provider.handleItemSubmitted(realIndex);
              },
              onChanged: (val) {
                if (val.contains('\n')) {
                  provider.handlePasteOrMultiline(realIndex, val);
                }
              },
            ),
          ),

          // Delete Item Button
          IconButton(
            tooltip: 'Delete item',
            icon: Icon(Icons.close, color: Colors.grey.shade500, size: 19),
            splashRadius: 18,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.only(top: 10),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => provider.removeChecklistItemWithFocus(realIndex),
          ),
        ],
      ),
    );
  }
}