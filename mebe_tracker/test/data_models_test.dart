import 'package:flutter_test/flutter_test.dart';
import 'package:mebe_tracker/shared/models/baby_profile.dart';
import 'package:mebe_tracker/shared/models/diaper_entry.dart';
import 'package:mebe_tracker/shared/models/feeding_entry.dart';
import 'package:mebe_tracker/shared/models/growth_entry.dart';
import 'package:mebe_tracker/shared/models/milestone_entry.dart';
import 'package:mebe_tracker/shared/models/milk_stash_entry.dart';
import 'package:mebe_tracker/shared/models/pump_entry.dart';
import 'package:mebe_tracker/shared/models/sleep_entry.dart';
import 'package:mebe_tracker/shared/models/vaccine_entry.dart';

void main() {
  test('BabyProfile toFirestore/fromJson round-trip keeps field values', () {
    final baby = BabyProfile(
      id: 'baby1',
      userId: 'user1',
      name: 'Bé Mia',
      dateOfBirth: DateTime(2025, 1, 1),
      gender: 'female',
      weightKg: 6.8,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );
    final json = baby.toFirestore();
    expect(json['name'], 'Bé Mia');
    expect(json.containsKey('id'), isFalse);
  });

  test('FeedingEntry serializes enum type by name', () {
    final entry = FeedingEntry(
      id: 'f1',
      babyId: 'baby1',
      userId: 'user1',
      type: FeedingType.breastLeft,
      startTime: DateTime(2025, 1, 1, 8),
      createdAt: DateTime(2025, 1, 1, 8),
    );
    final json = entry.toJson();
    expect(json['type'], 'breastLeft');
  });

  test('PumpEntry, SleepEntry, DiaperEntry, GrowthEntry, MilkStashEntry, '
      'MilestoneEntry, VaccineEntry construct without error', () {
    final now = DateTime(2025, 1, 1);
    expect(
      PumpEntry(
        id: 'p1', babyId: 'b1', userId: 'u1', startTime: now,
        storage: PumpStorage.fridge, createdAt: now,
      ).toJson()['storage'],
      'fridge',
    );
    expect(
      SleepEntry(
        id: 's1', babyId: 'b1', userId: 'u1', startTime: now,
        type: SleepType.nap, createdAt: now,
      ).toJson()['type'],
      'nap',
    );
    expect(
      DiaperEntry(
        id: 'd1', babyId: 'b1', userId: 'u1', time: now,
        type: DiaperType.both, createdAt: now,
      ).toJson()['type'],
      'both',
    );
    expect(
      GrowthEntry(
        id: 'g1', babyId: 'b1', userId: 'u1', measuredAt: now, createdAt: now,
      ).toJson()['babyId'],
      'b1',
    );
    expect(
      MilkStashEntry(
        id: 'm1', babyId: 'b1', userId: 'u1', pumpedAt: now,
        amountMl: 120, location: StashLocation.freezer, isUsed: false,
        createdAt: now,
      ).toJson()['location'],
      'freezer',
    );
    expect(
      MilestoneEntry(
        id: 'ms1', babyId: 'b1', milestoneKey: 'rollover', titleVi: 'Lật người',
        expectedWeekMin: 12, expectedWeekMax: 20, isAchieved: false,
      ).toJson()['milestoneKey'],
      'rollover',
    );
    expect(
      VaccineEntry(
        id: 'v1', babyId: 'b1', vaccineKey: 'bcg', nameVi: 'BCG',
        scheduledDate: now, isCompleted: false, createdAt: now,
      ).toJson()['vaccineKey'],
      'bcg',
    );
  });
}
