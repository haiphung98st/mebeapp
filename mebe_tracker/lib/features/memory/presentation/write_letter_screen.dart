import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/models/future_letter.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import '../data/letter_provider.dart';

class WriteLetterScreen extends ConsumerStatefulWidget {
  const WriteLetterScreen({super.key});

  @override
  ConsumerState<WriteLetterScreen> createState() => _WriteLetterScreenState();
}

class _WriteLetterScreenState extends ConsumerState<WriteLetterScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  int _step = 0;
  int _selectedAgeMonths = 12;
  bool _saving = false;

  static const _ageOptions = [
    (1, '1 tháng tuổi'),
    (3, '3 tháng tuổi'),
    (6, '6 tháng tuổi'),
    (12, '1 tuổi'),
    (24, '2 tuổi'),
    (36, '3 tuổi'),
    (60, '5 tuổi'),
    (84, '7 tuổi'),
    (120, '10 tuổi'),
    (216, '18 tuổi'),
  ];

  static const _templates = [
    'Bé yêu ơi, hôm nay mẹ muốn kể cho bé nghe về ngày đặc biệt này...',
    'Khi bé đọc được thư này, bé đã lớn rồi. Mẹ muốn bé biết rằng...',
    'Có những điều mẹ muốn nói với bé khi bé trưởng thành...',
    'Ngày hôm nay, bé còn bé xíu. Nhưng mẹ biết sau này bé sẽ...',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
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

  String _unlockLabel() {
    final opt = _ageOptions.firstWhere(
      (o) => o.$1 == _selectedAgeMonths,
      orElse: () => (_selectedAgeMonths, 'Tuổi $_selectedAgeMonths tháng'),
    );
    return 'Khi bé ${opt.$2}';
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty || content.isEmpty) return;

    setState(() => _saving = true);
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) {
      setState(() => _saving = false);
      return;
    }

    final letter = FutureLetter(
      id: const Uuid().v4(),
      babyId: baby.id,
      userId: user.uid,
      title: title,
      content: content,
      unlockDate: _unlockDate(),
      createdAt: DateTime.now(),
      unlockAgeLabel: _unlockLabel(),
    );

    await saveLetter(user.uid, baby.id, letter);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final baby = ref.watch(activeBabyProvider);

    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        backgroundColor: const Color(0xFFA67CD8),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _step == 0 ? 'Chọn thời điểm' : 'Viết thư 💌',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (_step == 1)
            TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Lưu',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
        ],
      ),
      body: _step == 0
          ? _StepOne(
              baby: baby,
              selectedAgeMonths: _selectedAgeMonths,
              ageOptions: _ageOptions,
              unlockDate: _unlockDate(),
              onSelect: (v) => setState(() => _selectedAgeMonths = v),
              onNext: () => setState(() => _step = 1),
            )
          : _StepTwo(
              titleCtrl: _titleCtrl,
              contentCtrl: _contentCtrl,
              unlockLabel: _unlockLabel(),
              templates: _templates,
            ),
    );
  }
}

class _StepOne extends StatelessWidget {
  const _StepOne({
    required this.baby,
    required this.selectedAgeMonths,
    required this.ageOptions,
    required this.unlockDate,
    required this.onSelect,
    required this.onNext,
  });

  final dynamic baby;
  final int selectedAgeMonths;
  final List<(int, String)> ageOptions;
  final DateTime unlockDate;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const Text(
                'Thư sẽ mở khoá khi nào?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Bé sẽ đọc được thư này vào ngày ${unlockDate.day}/${unlockDate.month}/${unlockDate.year}',
                style: const TextStyle(color: AppColors.body, fontSize: 13),
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
                      color: selected
                          ? AppColors.lilac
                          : AppColors.white,
                      border: Border.all(
                        color: selected
                            ? AppColors.lavender
                            : AppColors.divider,
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
                            color: selected
                                ? AppColors.lavender
                                : AppColors.body,
                          ),
                        ),
                        const Spacer(),
                        if (selected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.lavender,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA67CD8),
                ),
                child: const Text('Tiếp theo →'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepTwo extends StatelessWidget {
  const _StepTwo({
    required this.titleCtrl,
    required this.contentCtrl,
    required this.unlockLabel,
    required this.templates,
  });

  final TextEditingController titleCtrl;
  final TextEditingController contentCtrl;
  final String unlockLabel;
  final List<String> templates;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.lilac,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '🔒 $unlockLabel',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.lavender,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: titleCtrl,
          decoration: const InputDecoration(
            labelText: 'Tiêu đề thư',
            hintText: 'VD: Thư gửi con lúc 1 tuổi',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: contentCtrl,
          minLines: 8,
          maxLines: 20,
          decoration: const InputDecoration(
            labelText: 'Nội dung thư',
            hintText: 'Viết thư cho bé...',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'Gợi ý mở đầu 💡',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.body,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...templates.map((t) => GestureDetector(
              onTap: () {
                if (contentCtrl.text.isEmpty) {
                  contentCtrl.text = t;
                  contentCtrl.selection = TextSelection.fromPosition(
                    TextPosition(offset: contentCtrl.text.length),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  t,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.body,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )),
      ],
    );
  }
}
