import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/medical_record_model.dart';
import '../controllers/medical_history_controller.dart';

class MedicalHistoryScreen extends StatelessWidget {
  const MedicalHistoryScreen({super.key});

  static const Map<RecordType, IconData> _typeIcons = {
    RecordType.condition: Icons.monitor_heart_outlined,
    RecordType.allergy: Icons.warning_amber_outlined,
    RecordType.medication: Icons.medication_outlined,
    RecordType.surgery: Icons.local_hospital_outlined,
  };

  static const Map<RecordType, Color> _typeColors = {
    RecordType.condition: AppColors.primary,
    RecordType.allergy: AppColors.error,
    RecordType.medication: AppColors.accent,
    RecordType.surgery: AppColors.warning,
  };

  void _showAddRecordSheet(BuildContext context, MedicalHistoryController controller) {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    final Rx<RecordType> selectedType = RecordType.condition.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Medical Record', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),

              Text('Type', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final type in RecordType.values)
                        ChoiceChip(
                          label: Text(type.label),
                          selected: selectedType.value == type,
                          onSelected: (_) => selectedType.value = type,
                        ),
                    ],
                  )),
              const SizedBox(height: 20),

              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Penicillin, Asthma, Appendectomy'),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes', hintText: 'Additional details...'),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      Get.snackbar('Title Required', 'Please enter a title.', snackPosition: SnackPosition.BOTTOM);
                      return;
                    }
                    controller.addRecord(
                      type: selectedType.value,
                      title: titleController.text.trim(),
                      notes: notesController.text.trim(),
                    );
                    Navigator.of(sheetContext).pop();
                  },
                  child: const Text('Save Record'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(MedicalHistoryController controller, MedicalRecord record) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Record'),
        content: Text('Delete "${record.title}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      controller.deleteRecord(record.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MedicalHistoryController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Record',
            onPressed: () => _showAddRecordSheet(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.records.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_shared_outlined, size: 64, color: subTextColor),
                  const SizedBox(height: 16),
                  Text('No medical records yet', style: TextStyle(color: subTextColor, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(
                    'Add conditions, allergies, medications, or past surgeries.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: subTextColor, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _showAddRecordSheet(context, controller),
                    child: const Text('Add a Record'),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.records.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final record = controller.records[index];
            final color = _typeColors[record.type] ?? AppColors.primary;
            final icon = _typeIcons[record.type] ?? Icons.description_outlined;

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(record.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                              child: Text(record.type.label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                        if (record.notes.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(record.notes, style: TextStyle(color: subTextColor, fontSize: 12)),
                        ],
                        const SizedBox(height: 6),
                        Text(DateFormat('MMM d, yyyy').format(record.dateRecorded), style: TextStyle(color: subTextColor, fontSize: 11)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                    onPressed: () => _confirmDelete(controller, record),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}