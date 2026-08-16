import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/bunny_avatar.dart';
import '../../../shared/models/baby_profile.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';

class CreateBabyScreen extends ConsumerStatefulWidget {
  const CreateBabyScreen({super.key});

  @override
  ConsumerState<CreateBabyScreen> createState() => _CreateBabyScreenState();
}

class _CreateBabyScreenState extends ConsumerState<CreateBabyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _dateOfBirth;
  DateTime? _edd;
  String _gender = 'female';
  File? _avatarFile;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (picked != null) {
      setState(() => _avatarFile = File(picked.path));
    }
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _pickEdd() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _edd ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      helpText: 'Ngày dự sinh',
    );
    if (picked != null) setState(() => _edd = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày sinh'), backgroundColor: AppColors.error),
      );
      return;
    }
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _saving = true);
    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final now = DateTime.now();
      final baby = BabyProfile(
        id: firestoreService.newId(),
        userId: user.uid,
        name: _nameController.text.trim(),
        dateOfBirth: _dateOfBirth!,
        gender: _gender,
        edd: _edd,
        createdAt: now,
        updatedAt: now,
      );
      await firestoreService.createBaby(baby);
      if (!mounted) return;
      context.go('/home');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.powder,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Tạo hồ sơ bé', style: AppTextStyles.displaySm, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.xxl),
                Center(
                  child: GestureDetector(
                    onTap: _pickAvatar,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        if (_avatarFile != null)
                          ClipOval(
                            child: Image.file(_avatarFile!, width: 120, height: 120, fit: BoxFit.cover),
                          )
                        else
                          const BunnyAvatar(size: 100, primaryColor: AppColors.white),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.blossom,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 16, color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Tên bé'),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Vui lòng nhập tên bé' : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                InkWell(
                  onTap: _pickDateOfBirth,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      hintText: 'Ngày sinh',
                      prefixIcon: Icon(Icons.cake_outlined),
                    ),
                    child: Text(
                      _dateOfBirth == null
                          ? ''
                          : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
                      style: AppTextStyles.bodyLg,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                InkWell(
                  onTap: _pickEdd,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      hintText: 'Ngày dự sinh (tùy chọn)',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      helperText: 'Dùng để tính Wonder Weeks chính xác hơn',
                    ),
                    child: Text(
                      _edd == null
                          ? ''
                          : '${_edd!.day}/${_edd!.month}/${_edd!.year}',
                      style: AppTextStyles.bodyLg,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Giới tính', style: AppTextStyles.label),
                const SizedBox(height: AppSpacing.sm),
                ToggleButtons(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  isSelected: [_gender == 'female', _gender == 'male'],
                  onPressed: (index) {
                    setState(() => _gender = index == 0 ? 'female' : 'male');
                  },
                  selectedColor: AppColors.white,
                  fillColor: AppColors.blossom,
                  color: AppColors.body,
                  constraints: const BoxConstraints(minHeight: 48, minWidth: 140),
                  children: const [
                    Text('Bé gái 🎀'),
                    Text('Bé trai 🧢'),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.blossom),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                          )
                        : const Text('Tiếp tục'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
