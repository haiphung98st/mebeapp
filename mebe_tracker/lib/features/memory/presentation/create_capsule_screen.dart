import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/models/time_capsule.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import '../data/time_capsule_provider.dart';

class CreateCapsuleScreen extends ConsumerStatefulWidget {
  const CreateCapsuleScreen({super.key});

  @override
  ConsumerState<CreateCapsuleScreen> createState() =>
      _CreateCapsuleScreenState();
}

class _CreateCapsuleScreenState extends ConsumerState<CreateCapsuleScreen> {
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _items = <CapsuleItem>[];
  int _step = 0; // 0=title, 1=unlock, 2=items, 3=confirm
  int _selectedAgeMonths = 12;
  bool _saving = false;

  static const _ageOptions = [
    (12, '1 tuổi'),
    (24, '2 tuổi'),
    (36, '3 tuổi'),
    (60, '5 tuổi'),
    (84, '7 tuổi'),
    (120, '10 tuổi'),
    (216, '18 tuổi'),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  DateTime _unlockDate() {
    final baby = ref.read(activeBabyProvider);
    final dob = baby?.dateOfBirth ?? DateTime.now();
    return DateTime(
      dob.year + (_selectedAgeMonths ~/ 12),
      dob.month + (_selectedAgeMonths % 12),
      dob.day,
    );
  }

  String _ageLabel() {
    final opt = _ageOptions.firstWhere(
      (o) => o.$1 == _selectedAgeMonths,
      orElse: () => (_selectedAgeMonths, 'Tuổi tháng $_selectedAgeMonths'),
    );
    return 'Khi bé ${opt.$2}';
  }

  Future<void> _addNoteItem() async {
    final text = _noteCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _items.add(CapsuleItem(
        type: 'note',
        titleVi: 'Ghi chú từ mẹ 💕',
        contentVi: text,
        emoji: '📝',
      ));
      _noteCtrl.clear();
    });
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    setState(() => _saving = true);
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) {
      setState(() => _saving = false);
      return;
    }

    final capsule = TimeCapsule(
      id: const Uuid().v4(),
      babyId: baby.id,
      userId: user.uid,
      title: title,
      unlockDate: _unlockDate(),
      unlockAgeLabel: _ageLabel(),
      createdAt: DateTime.now(),
      items: _items,
    );

    await saveCapsule(user.uid, baby.id, capsule);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        backgroundColor: AppColors.blossom,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          ['Đặt tên hộp', 'Thời gian mở', 'Thêm kỷ niệm', 'Xác nhận'][_step],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_step + 1) / 4,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation(Colors.white),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildStep()),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  if (_step > 0)
                    OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      child: const Text('Quay lại'),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _step == 3
                        ? (_saving ? null : _save)
                        : () {
                            if (_step == 0 &&
                                _titleCtrl.text.trim().isEmpty) {
                              return;
                            }
                            setState(() => _step++);
                          },
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_step == 3 ? 'Tạo hộp 🎁' : 'Tiếp theo →'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => _Step0(titleCtrl: _titleCtrl),
      1 => _Step1(
          selectedAgeMonths: _selectedAgeMonths,
          ageOptions: _ageOptions,
          unlockDate: _unlockDate(),
          onSelect: (v) => setState(() => _selectedAgeMonths = v),
        ),
      2 => _Step2(
          noteCtrl: _noteCtrl,
          items: _items,
          onAdd: _addNoteItem,
          onRemove: (i) => setState(() => _items.removeAt(i)),
        ),
      _ => _Step3(
          title: _titleCtrl.text.trim(),
          ageLabel: _ageLabel(),
          unlockDate: _unlockDate(),
          items: _items,
        ),
    };
  }
}

class _Step0 extends StatelessWidget {
  const _Step0({required this.titleCtrl});

  final TextEditingController titleCtrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đặt tên cho hộp thời gian',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: titleCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Tên hộp',
              hintText: 'VD: Hộp tình yêu của mẹ 💕',
            ),
          ),
        ],
      ),
    );
  }
}

class _Step1 extends StatelessWidget {
  const _Step1({
    required this.selectedAgeMonths,
    required this.ageOptions,
    required this.unlockDate,
    required this.onSelect,
  });

  final int selectedAgeMonths;
  final List<(int, String)> ageOptions;
  final DateTime unlockDate;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const Text(
          'Hộp mở khi bé bao nhiêu tuổi?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Ngày mở: ${unlockDate.day}/${unlockDate.month}/${unlockDate.year}',
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...ageOptions.map((opt) {
          final selected = selectedAgeMonths == opt.$1;
          return GestureDetector(
            onTap: () => onSelect(opt.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: selected ? AppColors.blush : AppColors.white,
                border: Border.all(
                  color: selected ? AppColors.blossom : AppColors.divider,
                  width: selected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Text(
                    opt.$2,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected ? AppColors.blossom : AppColors.body,
                    ),
                  ),
                  const Spacer(),
                  if (selected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.blossom,
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _Step2 extends StatelessWidget {
  const _Step2({
    required this.noteCtrl,
    required this.items,
    required this.onAdd,
    required this.onRemove,
  });

  final TextEditingController noteCtrl;
  final List<CapsuleItem> items;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const Text(
          'Thêm kỷ niệm vào hộp',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  hintText: 'Viết ghi chú kỷ niệm...',
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text('Thêm'),
            ),
          ],
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          ...List.generate(items.length, (i) {
            final item = items[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(item.emoji ?? '📝',
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.contentVi,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.body,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.muted,
                    ),
                    onPressed: () => onRemove(i),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}

class _Step3 extends StatelessWidget {
  const _Step3({
    required this.title,
    required this.ageLabel,
    required this.unlockDate,
    required this.items,
  });

  final String title;
  final String ageLabel;
  final DateTime unlockDate;
  final List<CapsuleItem> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 56)),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$ageLabel · ${unlockDate.day}/${unlockDate.month}/${unlockDate.year}',
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            '${items.length} kỷ niệm trong hộp',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.body,
            ),
          ),
        ],
      ),
    );
  }
}
