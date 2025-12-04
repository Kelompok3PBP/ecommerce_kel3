import 'package:ecommerce/features/shipping/domain/entities/shipping_option.dart';

class ShippingService {
  Future<List<ShippingOption>> fetchShippingRates({
    required String postalCode,
    required double totalWeight,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    double baseCost;
    if (postalCode.startsWith('1')) {
      baseCost = 15000.0;
    } else if (postalCode.startsWith('6')) {
      baseCost = 22000.0;
    } else {
      baseCost = 30000.0;
    }

    return [
      ShippingOption(
        id: 'JNT_REG',
        name: 'Reguler',
        serviceType: 'Reguler',
        cost: baseCost + (totalWeight * 500),
        courierName: 'J&T Express',
        estimate: '3-5 hari',
      ),
      ShippingOption(
        id: 'SPX_XPS',
        name: 'Next Day',
        serviceType: 'Express',
        cost: baseCost * 2.0,
        courierName: 'Shopee Xpress',
        estimate: '1-2 hari',
      ),
      ShippingOption(
        id: 'POS_EKO',
        name: 'Ekonomi',
        serviceType: 'Ekonomi',
        cost: baseCost * 0.7,
        courierName: 'POS Indonesia',
        estimate: '5-7 hari',
      ),
    ];
  }
}
