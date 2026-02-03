import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  static const String _apiKey = 'test_iehMorCLbOMZoCPBvrnDlXWNdNh';
  static const String _entitlementId = 'DearDay Pro';

  bool _isInitialized = false;

  /// Initialize the RevenueCat SDK
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await Purchases.configure(PurchasesConfiguration(_apiKey));
      _isInitialized = true;
      debugPrint('✅ RevenueCat initialized successfully');
    } catch (e) {
      debugPrint('❌ RevenueCat initialization failed: $e');
    }
  }

  /// Fetch available offerings from RevenueCat
  Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current == null) {
        debugPrint('⚠️ No current offering available');
        return null;
      }
      debugPrint('✅ Offerings fetched successfully');
      return offerings;
    } catch (e) {
      debugPrint('❌ Failed to fetch offerings: $e');
      return null;
    }
  }

  /// Purchase a specific package
  /// Returns true if purchase was successful
  Future<bool> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);

      // Check if the user has the entitlement
      final isPro =
          customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;

      if (isPro) {
        debugPrint('✅ Purchase successful!');
        return true;
      } else {
        debugPrint('⚠️ Purchase completed but entitlement not active');
        return false;
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      // User cancelled - not an error
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('ℹ️ User cancelled purchase');
        return false;
      }

      // Real error
      debugPrint('❌ Purchase failed: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected purchase error: $e');
      return false;
    }
  }

  /// Restore previous purchases
  /// Returns true if user has active pro entitlement
  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final isPro =
          customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;

      if (isPro) {
        debugPrint('✅ Purchases restored successfully');
        return true;
      } else {
        debugPrint('ℹ️ No active purchases to restore');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Failed to restore purchases: $e');
      return false;
    }
  }

  /// Check if user currently has pro access
  Future<bool> checkProStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
    } catch (e) {
      debugPrint('❌ Failed to check pro status: $e');
      return false;
    }
  }
}
