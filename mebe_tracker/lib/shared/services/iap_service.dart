import 'dart:async';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';

import 'firestore_service.dart';

/// Product IDs configured in Google Play Console / App Store Connect.
class IapProductIds {
  IapProductIds._();
  static const monthly = 'com.mebe.premium.monthly';
  static const yearly = 'com.mebe.premium.yearly';
  static const all = {monthly, yearly};
}

enum PurchaseFlowStatus { idle, pending, success, failed, restoreNotFound }

class IapService {
  IapService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  final InAppPurchase _iap = InAppPurchase.instance;
  final FirestoreService _firestoreService;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  final _statusController = StreamController<PurchaseFlowStatus>.broadcast();
  Stream<PurchaseFlowStatus> get statusStream => _statusController.stream;

  Future<bool> initConnection(String userId) async {
    final available = await _iap.isAvailable();
    if (!available) return false;
    _purchaseSubscription ??= _iap.purchaseStream.listen(
      (purchases) => _onPurchaseUpdate(userId, purchases),
      onDone: () => _purchaseSubscription?.cancel(),
    );
    return true;
  }

  Future<List<ProductDetails>> getProducts() async {
    final response = await _iap.queryProductDetails(IapProductIds.all);
    return response.productDetails;
  }

  Future<void> buyProduct(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() => _iap.restorePurchases();

  bool verifyPurchase(PurchaseDetails purchaseDetails) {
    return purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored;
  }

  Future<void> _onPurchaseUpdate(String userId, List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _statusController.add(PurchaseFlowStatus.pending);
          break;
        case PurchaseStatus.error:
          _statusController.add(PurchaseFlowStatus.failed);
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (verifyPurchase(purchase)) {
            await _persistSubscription(userId, purchase);
            _statusController.add(PurchaseFlowStatus.success);
          } else {
            _statusController.add(PurchaseFlowStatus.failed);
          }
          break;
        case PurchaseStatus.canceled:
          _statusController.add(PurchaseFlowStatus.idle);
          break;
      }
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _persistSubscription(String userId, PurchaseDetails purchase) async {
    final now = DateTime.now();
    final isYearly = purchase.productID == IapProductIds.yearly;
    final expiryDate = now.add(Duration(days: isYearly ? 365 : 30));
    await _firestoreService.updateSubscription(userId, {
      'isPremium': true,
      'productId': purchase.productID,
      'purchaseDate': now.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'platform': Platform.isIOS ? 'ios' : 'android',
    });
  }

  void dispose() {
    _purchaseSubscription?.cancel();
    _statusController.close();
  }
}
