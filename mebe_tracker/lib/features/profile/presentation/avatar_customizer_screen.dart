import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/animated_bunny_avatar.dart';
import '../data/avatar_config.dart';
import '../data/avatar_provider.dart';

class AvatarCustomizerScreen extends ConsumerStatefulWidget {
  const AvatarCustomizerScreen({super.key});

  @override
  ConsumerState<AvatarCustomizerScreen> createState() =>
      _AvatarCustomizerScreenState();
}

class _AvatarCustomizerScreenState
    extends ConsumerState<AvatarCustomizerScreen> {
  // Null until the saved config finishes loading from SharedPreferences —
  // reading avatarConfigProvider's value synchronously in initState would
  // race the async load and silently reset the editor to defaults.
  AvatarConfig? _config;
  bool _dirty = false;

  void _update(AvatarConfig c) => setState(() {
        _config = c;
        _dirty = true;
      });

  Future<void> _save() async {
    final config = _config;
    if (config == null) return;
    await ref.read(avatarConfigProvider.notifier).save(config);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu avatar bé! 🐰')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final saved = ref.watch(avatarConfigProvider);
    _config ??= saved.value;
    final config = _config ?? const AvatarConfig();
    final stillLoading = saved.isLoading && _config == null;

    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        title: const Text('Tuỳ chỉnh avatar bé'),
        backgroundColor: AppColors.blossom,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_dirty)
            TextButton(
              onPressed: _save,
              child: const Text(
                'Lưu',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
      body: stillLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxxl,
              ),
              child: Column(
                children: [
                  // Live preview
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD6E4), Color(0xFFFFF0F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Center(
                      child: AnimatedBunnyAvatar(config: config, size: 120),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  _ColorSection(
                    title: '🐰 Màu lông',
                    colors: _skinColors,
                    selected: config.headColor,
                    onSelect: (c) => _update(config.copyWith(headColor: c)),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  _ColorSection(
                    title: '👂 Màu tai',
                    colors: _earColors,
                    selected: config.earColor,
                    onSelect: (c) => _update(config.copyWith(earColor: c)),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  _ColorSection(
                    title: '👁️ Màu mắt',
                    colors: _eyeColors,
                    selected: config.eyeColor,
                    onSelect: (c) => _update(config.copyWith(eyeColor: c)),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  _ColorSection(
                    title: '💗 Màu mũi & má',
                    colors: _blushColors,
                    selected: config.noseColor,
                    onSelect: (c) => _update(
                      config.copyWith(noseColor: c, cheekColor: c),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _update(const AvatarConfig()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.muted,
                        side: const BorderSide(color: AppColors.divider),
                      ),
                      child: const Text('Đặt lại mặc định'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _dirty ? _save : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blossom,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Lưu avatar'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

const _skinColors = [
  Color(0xFFFFF0F6), // default pink-white
  Color(0xFFFDE8C8), // warm peach
  Color(0xFFFFF8DC), // cream
  Color(0xFFE8D5C0), // light brown
  Color(0xFFD4A574), // medium brown
  Color(0xFF8D5524), // dark brown
];

const _earColors = [
  Color(0xFFFFB7CE), // default petal
  Color(0xFFC9A8F5), // lavender
  Color(0xFFFFD6B3), // peach
  Color(0xFFA8D8EA), // sky blue
  Color(0xFFB5E8B0), // mint green
  Color(0xFFFFF0B3), // pale yellow
];

const _eyeColors = [
  Color(0xFF3D1A35), // default dark
  Color(0xFF1A1A2E), // near black
  Color(0xFF5C4033), // warm brown
  Color(0xFF2E4A7A), // dark blue
  Color(0xFF2D7A4F), // deep green
  Color(0xFF6B3FA0), // violet
];

const _blushColors = [
  Color(0xFFF472A0), // default blossom
  Color(0xFFFF8080), // coral
  Color(0xFFF8A4C8), // soft pink
  Color(0xFFFFB347), // peach
  Color(0xFFA8D8EA), // sky blue
  Color(0xFFB5E8B0), // mint
];

class _ColorSection extends StatelessWidget {
  const _ColorSection({
    required this.title,
    required this.colors,
    required this.selected,
    required this.onSelect,
  });

  final String title;
  final List<Color> colors;
  final Color selected;
  final void Function(Color) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: colors.map((c) {
            final isSelected = c.value == selected.value;
            return GestureDetector(
              onTap: () => onSelect(c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.blossom : AppColors.divider,
                    width: isSelected ? 3 : 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.blossom.withOpacity(0.3),
                            blurRadius: 8,
                          )
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
