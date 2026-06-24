import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/iap_service.dart';
import 'auth_provider.dart';
import 'baby_provider.dart';

class SubscriptionInfo {
  const SubscriptionInfo({
    required this.isPremium,
    this.productId,
    this.purchaseDate,
    this.expiryDate,
    this.platform,
  });

  final bool isPremium;
  final String? productId;
  final DateTime? purchaseDate;
  final DateTime? expiryDate;
  final String? platform;

  factory SubscriptionInfo.free() => const SubscriptionInfo(isPremium: false);

  factory SubscriptionInfo.fromMap(Map<String, dynamic>? data) {
    if (data == null) return SubscriptionInfo.free();
    final expiryDate = data['expiryDate'] != null ? DateTime.tryParse(data['expiryDate'] as String) : null;
    final rawIsPremium = data['isPremium'] as bool? ?? false;
    final isExpired = expiryDate != null && expiryDate.isBefore(DateTime.now());
    return SubscriptionInfo(
      isPremium: rawIsPremium && !isExpired,
      productId: data['productId'] as String?,
      purchaseDate:
          data['purchaseDate'] != null ? DateTime.tryParse(data['purchaseDate'] as String) : null,
      expiryDate: expiryDate,
      platform: data['platform'] as String?,
    );
  }
}

final iapServiceProvider = Provider<IapService>((ref) {
  final service = IapService(firestoreService: ref.watch(firestoreServiceProvider));
  ref.onDispose(service.dispose);
  return service;
});

final subscriptionProvider = StreamProvider<SubscriptionInfo>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(SubscriptionInfo.free());
  return ref
      .watch(firestoreServiceProvider)
      .watchSubscription(user.uid)
      .map(SubscriptionInfo.fromMap);
});

final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionProvider).value?.isPremium ?? false;
});

final purchaseFlowStatusProvider = StreamProvider<PurchaseFlowStatus>((ref) {
  return ref.watch(iapServiceProvider).statusStream;
});

const premiumFeatures = [
  'unlimited_history',
  'family_sharing',
  'ai_insights',
  'export_pdf',
  'advanced_milk_stash',
  'vaccine_schedule',
  'widget',
  'priority_support',
];
