import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import '../../../shared/services/firestore_service.dart';
import '../data/health_models.dart';
import '../data/health_provider.dart';

class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen({super.key});

  @override
  ConsumerState<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen>
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
        title: const Text('Sức khoẻ bé'),
        backgroundColor: AppColors.powder,
        elevation: 0,
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.blossom,
          unselectedLabelColor: AppColors.muted,
          indicatorColor: AppColors.blossom,
          tabs: const [
            Tab(text: 'Nhiệt độ'),
            Tab(text: 'Thuốc'),
            Tab(text: 'Bệnh'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _TemperatureTab(),
          _MedicineTab(),
          _IllnessTab(),
        ],
      ),
    );
  }
}

// ─── Temperature ─────────────────────────────────────────────────────────────

class _TemperatureTab extends ConsumerWidget {
  const _TemperatureTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readings = ref.watch(temperaturesProvider).value ?? [];

    return Column(
      children: [
        _AddTempCard(),
        if (readings.isNotEmpty) ...[
          _TempMiniChart(readings: readings.take(7).toList()),
          const Divider(height: 1),
        ],
        Expanded(
          child: readings.isEmpty
              ? const _EmptyState(
                  icon: Icons.thermostat_outlined,
                  message: 'Chưa có bản ghi nhiệt độ',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: readings.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) =>
                      _TempTile(reading: readings[i]),
                ),
        ),
      ],
    );
  }
}

class _AddTempCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddTempCard> createState() => _AddTempCardState();
}

class _AddTempCardState extends ConsumerState<_AddTempCard> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final val = double.tryParse(_ctrl.text.trim());
    if (val == null || val < 35 || val > 42) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập nhiệt độ hợp lệ (35–42 °C)')),
      );
      return;
    }
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) return;
    final fs = ref.read(firestoreServiceProvider);
    await fs.addTemperature(TemperatureReading(
      id: fs.newId(),
      userId: user.uid,
      babyId: baby.id,
      recordedAt: DateTime.now(),
      tempCelsius: val,
    ));
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Nhiệt độ (°C) — vd: 37.5',
                prefixIcon: const Icon(Icons.thermostat_outlined),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blossom,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            onPressed: _save,
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}

class _TempMiniChart extends StatelessWidget {
  const _TempMiniChart({required this.readings});
  final List<TemperatureReading> readings;

  @override
  Widget build(BuildContext context) {
    final sorted = readings.reversed.toList();
    final minTemp = 36.0;
    final maxTemp = 40.0;

    return Container(
      height: 72,
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ...sorted.map((r) {
            final frac = ((r.tempCelsius - minTemp) / (maxTemp - minTemp))
                .clamp(0.0, 1.0);
            final barH = 8 + (frac * 40);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${r.tempCelsius.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 8,
                        color: r.isFever ? AppColors.error : AppColors.mint,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      height: barH,
                      decoration: BoxDecoration(
                        color: r.isFever ? AppColors.error : AppColors.mint,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (sorted.length < 7)
            ...List.generate(
              7 - sorted.length,
              (_) => const Expanded(child: SizedBox()),
            ),
        ],
      ),
    );
  }
}

class _TempTile extends ConsumerWidget {
  const _TempTile({required this.reading});
  final TemperatureReading reading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = DateFormat('dd/MM HH:mm');
    return ListTile(
      tileColor: AppColors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
      leading: CircleAvatar(
        backgroundColor:
            reading.isFever ? AppColors.error.withOpacity(0.1) : AppColors.mintLight,
        child: Text(
          '${reading.tempCelsius}°',
          style: TextStyle(
            fontSize: 12,
            color: reading.isFever ? AppColors.error : AppColors.mint,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: Text(
        reading.isFever ? 'Sốt ${reading.tempCelsius}°C' : '${reading.tempCelsius}°C',
        style: AppTextStyles.bodyMd,
      ),
      subtitle: Text(fmt.format(reading.recordedAt)),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: AppColors.muted),
        onPressed: () async {
          final user = ref.read(currentUserProvider);
          if (user == null) return;
          await ref.read(firestoreServiceProvider).deleteTemperature(
              user.uid, reading.babyId, reading.id);
        },
      ),
    );
  }
}

// ─── Medicine ─────────────────────────────────────────────────────────────────

class _MedicineTab extends ConsumerWidget {
  const _MedicineTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meds = ref.watch(medicinesProvider).value ?? [];
    final now = DateTime.now();
    final upcoming =
        meds.where((m) => m.nextDoseAt != null && m.nextDoseAt!.isAfter(now)).toList();

    return Column(
      children: [
        _AddMedicineCard(),
        if (upcoming.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
            child: Text('Sắp đến liều tiếp theo',
                style: AppTextStyles.label),
          ),
          ...upcoming.map((m) => _MedTile(med: m)),
          const Divider(height: AppSpacing.lg),
        ],
        Expanded(
          child: meds.isEmpty
              ? const _EmptyState(
                  icon: Icons.medication_outlined,
                  message: 'Chưa có bản ghi thuốc',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: meds.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) => _MedTile(med: meds[i]),
                ),
        ),
      ],
    );
  }
}

class _AddMedicineCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddMedicineCard> createState() => _AddMedicineCardState();
}

class _AddMedicineCardState extends ConsumerState<_AddMedicineCard> {
  final _nameCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  String _unit = 'mg';
  bool _nextDose = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nhập tên thuốc')));
      return;
    }
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) return;
    final fs = ref.read(firestoreServiceProvider);
    final dose = double.tryParse(_doseCtrl.text.trim());
    await fs.addMedicine(MedicineRecord(
      id: fs.newId(),
      userId: user.uid,
      babyId: baby.id,
      medicineName: _nameCtrl.text.trim(),
      givenAt: DateTime.now(),
      doseMg: dose,
      doseUnit: _unit,
      nextDoseAt: _nextDose
          ? DateTime.now().add(const Duration(hours: 6))
          : null,
    ));
    _nameCtrl.clear();
    _doseCtrl.clear();
    setState(() => _nextDose = false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                hintText: 'Tên thuốc — vd: Paracetamol',
                prefixIcon: Icon(Icons.medication_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _doseCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(hintText: 'Liều lượng'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                DropdownButton<String>(
                  value: _unit,
                  items: const [
                    DropdownMenuItem(value: 'mg', child: Text('mg')),
                    DropdownMenuItem(value: 'ml', child: Text('ml')),
                    DropdownMenuItem(value: 'viên', child: Text('viên')),
                  ],
                  onChanged: (v) => setState(() => _unit = v ?? 'mg'),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: _nextDose,
                  activeColor: AppColors.blossom,
                  onChanged: (v) => setState(() => _nextDose = v ?? false),
                ),
                const Text('Nhắc liều tiếp theo (sau 6h)'),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blossom),
                onPressed: _save,
                child: const Text('Ghi nhận'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedTile extends ConsumerWidget {
  const _MedTile({required this.med});
  final MedicineRecord med;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = DateFormat('dd/MM HH:mm');
    final hasNext = med.nextDoseAt != null;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 2),
      child: ListTile(
        tileColor: AppColors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        leading: const Icon(Icons.medication, color: AppColors.lavender),
        title: Text(med.medicineName, style: AppTextStyles.bodyMd),
        subtitle: Text(
          '${fmt.format(med.givenAt)}${med.doseMg != null ? ' · ${med.doseMg} ${med.doseUnit}' : ''}${hasNext ? '\nLiều tiếp: ${fmt.format(med.nextDoseAt!)}' : ''}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.muted),
          onPressed: () async {
            final user = ref.read(currentUserProvider);
            if (user == null) return;
            await ref.read(firestoreServiceProvider).deleteMedicine(
                user.uid, med.babyId, med.id);
          },
        ),
      ),
    );
  }
}

// ─── Illness ──────────────────────────────────────────────────────────────────

class _IllnessTab extends ConsumerWidget {
  const _IllnessTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodes = ref.watch(illnessesProvider).value ?? [];

    return Column(
      children: [
        _AddIllnessCard(),
        Expanded(
          child: episodes.isEmpty
              ? const _EmptyState(
                  icon: Icons.health_and_safety_outlined,
                  message: 'Chưa có đợt bệnh nào',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: episodes.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) =>
                      _IllnessTile(episode: episodes[i]),
                ),
        ),
      ],
    );
  }
}

class _AddIllnessCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddIllnessCard> createState() => _AddIllnessCardState();
}

class _AddIllnessCardState extends ConsumerState<_AddIllnessCard> {
  final _titleCtrl = TextEditingController();
  final _symptomsCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _symptomsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nhập tên bệnh/triệu chứng')));
      return;
    }
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) return;
    final fs = ref.read(firestoreServiceProvider);
    final symptoms = _symptomsCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    await fs.addIllness(IllnessEpisode(
      id: fs.newId(),
      userId: user.uid,
      babyId: baby.id,
      title: _titleCtrl.text.trim(),
      startedAt: DateTime.now(),
      symptoms: symptoms,
    ));
    _titleCtrl.clear();
    _symptomsCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                hintText: 'Tên bệnh — vd: Cúm, Tiêu chảy',
                prefixIcon: Icon(Icons.sick_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _symptomsCtrl,
              decoration: const InputDecoration(
                hintText: 'Triệu chứng (cách nhau bằng dấu phẩy)',
                prefixIcon: Icon(Icons.list_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blossom),
                onPressed: _save,
                child: const Text('Bắt đầu theo dõi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IllnessTile extends ConsumerWidget {
  const _IllnessTile({required this.episode});
  final IllnessEpisode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = DateFormat('dd/MM');
    final duration = episode.endedAt == null
        ? DateTime.now().difference(episode.startedAt).inDays
        : episode.endedAt!.difference(episode.startedAt).inDays;

    return ListTile(
      tileColor: AppColors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
      leading: CircleAvatar(
        backgroundColor: episode.isActive
            ? AppColors.error.withOpacity(0.1)
            : AppColors.mintLight,
        child: Icon(
          episode.isActive ? Icons.sick : Icons.check_circle,
          color: episode.isActive ? AppColors.error : AppColors.mint,
          size: 20,
        ),
      ),
      title: Text(episode.title, style: AppTextStyles.bodyMd),
      subtitle: Text(
        '${fmt.format(episode.startedAt)}${episode.endedAt != null ? ' → ${fmt.format(episode.endedAt!)}' : ' → nay'} · $duration ngày'
        '${episode.symptoms.isNotEmpty ? '\n${episode.symptoms.join(', ')}' : ''}',
      ),
      trailing: episode.isActive
          ? TextButton(
              onPressed: () async {
                final user = ref.read(currentUserProvider);
                if (user == null) return;
                final updated = IllnessEpisode(
                  id: episode.id,
                  userId: episode.userId,
                  babyId: episode.babyId,
                  title: episode.title,
                  startedAt: episode.startedAt,
                  endedAt: DateTime.now(),
                  symptoms: episode.symptoms,
                  notes: episode.notes,
                );
                await ref
                    .read(firestoreServiceProvider)
                    .updateIllness(updated);
              },
              child: const Text('Khỏi', style: TextStyle(color: AppColors.mint)),
            )
          : IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.muted),
              onPressed: () async {
                final user = ref.read(currentUserProvider);
                if (user == null) return;
                await ref
                    .read(firestoreServiceProvider)
                    .deleteIllness(user.uid, episode.babyId, episode.id);
              },
            ),
    );
  }
}

// ─── Shared ───────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.divider),
          const SizedBox(height: AppSpacing.md),
          Text(message,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.muted)),
        ],
      ),
    );
  }
}
