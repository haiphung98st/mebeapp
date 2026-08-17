import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import '../../../shared/services/firestore_service.dart';
import '../data/baby_food_database.dart';
import '../data/solid_food_entry.dart';
import '../data/solid_food_provider.dart';

class SolidFoodScreen extends ConsumerStatefulWidget {
  const SolidFoodScreen({super.key});

  @override
  ConsumerState<SolidFoodScreen> createState() => _SolidFoodScreenState();
}

class _SolidFoodScreenState extends ConsumerState<SolidFoodScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        title: const Text('Ăn dặm'),
        backgroundColor: AppColors.powder,
        elevation: 0,
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.blossom,
          unselectedLabelColor: AppColors.muted,
          indicatorColor: AppColors.blossom,
          tabs: const [
            Tab(text: 'Nhật ký'),
            Tab(text: 'Đã thử'),
            Tab(text: 'Thực đơn'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _JournalTab(),
          _FoodsTriedTab(),
          _MenuTab(),
        ],
      ),
    );
  }
}

// ─── Journal Tab ──────────────────────────────────────────────────────────────

class _JournalTab extends ConsumerWidget {
  const _JournalTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(solidFoodEntriesProvider).value ?? [];

    return Column(
      children: [
        _AddFoodEntry(),
        Expanded(
          child: entries.isEmpty
              ? const Center(
                  child: Text('Chưa có bữa ăn dặm nào',
                      style: TextStyle(color: AppColors.muted)))
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: entries.length,
                  itemBuilder: (context, i) =>
                      _JournalTile(entry: entries[i]),
                ),
        ),
      ],
    );
  }
}

class _AddFoodEntry extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddFoodEntry> createState() => _AddFoodEntryState();
}

class _AddFoodEntryState extends ConsumerState<_AddFoodEntry> {
  BabyFood? _selected;
  FoodReaction _reaction = FoodReaction.none;
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _expanded = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selected == null) return;
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    final fs = ref.read(firestoreServiceProvider);
    if (user == null || baby == null) return;

    await fs.addSolidFood(SolidFoodEntry(
      id: const Uuid().v4(),
      userId: user.uid,
      babyId: baby.id,
      foodId: _selected!.id,
      foodName: _selected!.name,
      givenAt: DateTime.now(),
      amountGrams: double.tryParse(_amountCtrl.text.trim()),
      reaction: _reaction,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    ));
    setState(() {
      _selected = null;
      _reaction = FoodReaction.none;
      _expanded = false;
      _amountCtrl.clear();
      _notesCtrl.clear();
    });
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Đã ghi nhận bữa ăn')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final baby = ref.watch(activeBabyProvider);
    final ageWeeks = baby == null
        ? 24
        : DateTime.now().difference(baby.dateOfBirth).inDays ~/ 7;
    final available = foodsForAge(ageWeeks);

    return Card(
      margin: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  const Icon(Icons.add_circle_outline,
                      color: AppColors.blossom),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Ghi nhận bữa ăn',
                      style: AppTextStyles.bodyMd),
                  const Spacer(),
                  Icon(
                    _expanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: AppColors.muted,
                  ),
                ],
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<BabyFood>(
                value: _selected,
                decoration: const InputDecoration(
                  labelText: 'Chọn thức ăn',
                  prefixIcon: Icon(Icons.restaurant_menu),
                ),
                items: available.map((f) {
                  return DropdownMenuItem<BabyFood>(
                    value: f,
                    child: Text('${f.emoji} ${f.name}'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selected = v),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Lượng (gram)',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DropdownButtonFormField<FoodReaction>(
                      value: _reaction,
                      isDense: true,
                      decoration: const InputDecoration(
                          labelText: 'Phản ứng'),
                      items: const [
                        DropdownMenuItem(
                            value: FoodReaction.none,
                            child: Text('Không có')),
                        DropdownMenuItem(
                            value: FoodReaction.mild,
                            child: Text('Nhẹ')),
                        DropdownMenuItem(
                            value: FoodReaction.severe,
                            child: Text('Nặng ⚠️')),
                      ],
                      onChanged: (v) =>
                          setState(() => _reaction = v ?? FoodReaction.none),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú (tuỳ chọn)',
                  isDense: true,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blossom),
                  onPressed: _selected == null ? null : _save,
                  child: const Text('Lưu'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _JournalTile extends ConsumerWidget {
  const _JournalTile({required this.entry});
  final SolidFoodEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = DateFormat('dd/MM HH:mm');
    final reactionColor = switch (entry.reaction) {
      FoodReaction.none => AppColors.mint,
      FoodReaction.mild => AppColors.warning,
      FoodReaction.severe => AppColors.error,
    };
    final reactionLabel = switch (entry.reaction) {
      FoodReaction.none => 'OK',
      FoodReaction.mild => 'Nhẹ',
      FoodReaction.severe => 'Nặng',
    };

    return Card(
      color: AppColors.white,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Text(
          _emojiFor(entry.foodId),
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(entry.foodName, style: AppTextStyles.bodyMd),
        subtitle: Text(
          '${fmt.format(entry.givenAt)}${entry.amountGrams != null ? ' · ${entry.amountGrams!.toInt()}g' : ''}${entry.notes != null ? ' · ${entry.notes}' : ''}',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: 2),
          decoration: BoxDecoration(
            color: reactionColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            border: Border.all(color: reactionColor),
          ),
          child: Text(reactionLabel,
              style: TextStyle(color: reactionColor, fontSize: 11)),
        ),
        onLongPress: () async {
          final user = ref.read(currentUserProvider);
          if (user == null) return;
          await ref
              .read(firestoreServiceProvider)
              .deleteSolidFood(user.uid, entry.babyId, entry.id);
        },
      ),
    );
  }

  String _emojiFor(String foodId) {
    return babyFoodDatabase
            .where((f) => f.id == foodId)
            .firstOrNull
            ?.emoji ??
        '🍽️';
  }
}

// ─── Foods Tried Tab ──────────────────────────────────────────────────────────

class _FoodsTriedTab extends ConsumerWidget {
  const _FoodsTriedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tried = ref.watch(triedFoodsProvider);
    final baby = ref.watch(activeBabyProvider);
    final ageWeeks = baby == null
        ? 24
        : DateTime.now().difference(baby.dateOfBirth).inDays ~/ 7;
    final available = foodsForAge(ageWeeks);
    final byCategory = <FoodCategory, List<BabyFood>>{};
    for (final f in available) {
      byCategory.putIfAbsent(f.category, () => []).add(f);
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Text(
            '${tried.length}/${available.length} loại thức ăn đã thử',
            style: AppTextStyles.bodyMd
                .copyWith(color: AppColors.mint, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...byCategory.entries.map((entry) {
          final cat = entry.key;
          final foods = entry.value;
          return _CategorySection(
            category: cat,
            foods: foods,
            tried: tried,
          );
        }),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.foods,
    required this.tried,
  });

  final FoodCategory category;
  final List<BabyFood> foods;
  final Set<String> tried;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Text(foods.first.categoryLabel,
              style: AppTextStyles.label),
        ),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: foods.map((food) {
            final isTried = tried.contains(food.id);
            return Chip(
              avatar: Text(food.emoji,
                  style: const TextStyle(fontSize: 14)),
              label: Text(food.name,
                  style: TextStyle(
                      fontSize: 11,
                      color: isTried ? AppColors.mint : AppColors.muted)),
              backgroundColor: isTried
                  ? AppColors.mintLight
                  : AppColors.powder,
              side: BorderSide(
                color: food.isCommonAllergen
                    ? AppColors.warning
                    : Colors.transparent,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

// ─── Menu Tab ─────────────────────────────────────────────────────────────────

class _MenuTab extends ConsumerWidget {
  const _MenuTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baby = ref.watch(activeBabyProvider);
    if (baby == null) {
      return const Center(child: Text('Cần có thông tin bé'));
    }

    final ageWeeks = DateTime.now().difference(baby.dateOfBirth).inDays ~/ 7;
    final tried = ref.watch(triedFoodsProvider);
    final plan = _generateMealPlan(ageWeeks, tried);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.blossom, AppColors.lavender],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thực đơn gợi ý tuần này',
                  style: AppTextStyles.headingSm
                      .copyWith(color: AppColors.white)),
              Text('Bé ${ageWeeks ~/ 4} tháng ${ageWeeks % 4} tuần',
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.white.withOpacity(0.8))),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...plan.entries.map((e) => _DayMealCard(day: e.key, meals: e.value)),
      ],
    );
  }

  Map<String, List<BabyFood>> _generateMealPlan(
      int ageWeeks, Set<String> tried) {
    final available = foodsForAge(ageWeeks);
    // Prefer foods not yet tried; mix categories per meal
    final notTried = available.where((f) => !tried.contains(f.id)).toList();
    final alreadyTried =
        available.where((f) => tried.contains(f.id)).toList();

    // Shuffle deterministically by week number (reproducible plan per week)
    final seed = ageWeeks;
    notTried.sort((a, b) => (a.id.hashCode + seed) - (b.id.hashCode + seed));
    alreadyTried.sort(
        (a, b) => (a.id.hashCode + seed) - (b.id.hashCode + seed));

    final pool = [...notTried, ...alreadyTried];

    // For <6 months (< 26 weeks): 1 meal/day; else 2 meals/day (7+mo: 3 meals)
    final mealsPerDay = ageWeeks < 26
        ? 1
        : ageWeeks < 32
            ? 2
            : 3;

    final days = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
    final plan = <String, List<BabyFood>>{};
    var idx = 0;

    for (final day in days) {
      final meals = <BabyFood>[];
      for (var m = 0; m < mealsPerDay; m++) {
        if (idx < pool.length) {
          meals.add(pool[idx % pool.length]);
          idx++;
        }
      }
      plan[day] = meals;
    }

    return plan;
  }
}

class _DayMealCard extends StatelessWidget {
  const _DayMealCard({required this.day, required this.meals});
  final String day;
  final List<BabyFood> meals;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Text(day,
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.blossom)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: meals.map((f) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text(f.emoji,
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(f.name,
                              style: AppTextStyles.bodyMd),
                        ),
                        if (f.prepNote != null)
                          Tooltip(
                            message: f.prepNote!,
                            child: const Icon(Icons.info_outline,
                                size: 14, color: AppColors.muted),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
