import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/zikr_model.dart';

class AddZikrDialog extends StatefulWidget {
  final String categoryName;
  final ZikrModel? existingZikr;
  final Function(ZikrModel) onAdd;
  final VoidCallback? onDelete;

  const AddZikrDialog({
    super.key,
    required this.categoryName,
    this.existingZikr,
    required this.onAdd,
    this.onDelete,
  });

  @override
  State<AddZikrDialog> createState() => _AddZikrDialogState();
}

class _AddZikrDialogState extends State<AddZikrDialog> {
  late TextEditingController _preTextController;
  late TextEditingController _contentController;
  late TextEditingController _descriptionController;
  late TextEditingController _countController;
  late TextEditingController _orderController;

  @override
  void initState() {
    super.initState();
    _preTextController =
        TextEditingController(text: widget.existingZikr?.preText ?? '');
    _contentController =
        TextEditingController(text: widget.existingZikr?.content ?? '');
    _descriptionController =
        TextEditingController(text: widget.existingZikr?.description ?? '');
    _countController = TextEditingController(
        text: widget.existingZikr?.initialCount.toString() ?? '1');
    _orderController = TextEditingController(
        text: widget.existingZikr?.order.toString() ?? '0');
  }

  @override
  void dispose() {
    _preTextController.dispose();
    _contentController.dispose();
    _descriptionController.dispose();
    _countController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _save() {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء كتابة الذكر')),
      );
      return;
    }

    final zikr = ZikrModel(
      id: widget.existingZikr?.id ??
          '${widget.categoryName}_${DateTime.now().millisecondsSinceEpoch}',
      category: widget.categoryName,
      initialCount: int.tryParse(_countController.text) ?? 1,
      currentCount: widget.existingZikr?.currentCount ??
          (int.tryParse(_countController.text) ?? 1),
      content: _contentController.text,
      description: _descriptionController.text,
      reference: '',
      preText: _preTextController.text.isEmpty ? null : _preTextController.text,
      order: int.tryParse(_orderController.text) ?? 0,
    );

    widget.onAdd(zikr);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBackground,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existingZikr == null ? 'إضافة ذكر' : 'تعديل ذكر',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _preTextController,
                label: 'ما قبل الذكر',
                hint: 'اكتب ما قبل الذكر',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _contentController,
                label: 'الذكر',
                hint: 'اكتب الذكر',
                maxLines: 5,
                required: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'ملاحظة',
                hint: 'اكتب الملاحظة',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _countController,
                      label: 'عدد الحبات',
                      hint: '1',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _orderController,
                      label: 'ترتيب الذكر',
                      hint: '0',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (widget.existingZikr != null && widget.onDelete != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onDelete!();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'حذف',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (widget.existingZikr != null && widget.onDelete != null)
                    const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.yellowAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'تأكيد',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label + (required ? ' *' : ''),
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          textAlign: TextAlign.right,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.greyText),
            filled: true,
            fillColor: AppColors.darkBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
