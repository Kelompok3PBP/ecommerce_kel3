import '../entities/shipping_option.dart';

abstract class ShippingRepository {
  Future<List<ShippingOption>> getAvailableShippingOptions({
    required String destinationPostalCode,
    required double totalWeight,
  });
}
