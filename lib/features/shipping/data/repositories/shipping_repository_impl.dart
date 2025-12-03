import '../../domain/entities/shipping_option.dart';
import '../../domain/repositories/shipping_repository.dart';
import '../shipping_service.dart';

class ShippingRepositoryImpl implements ShippingRepository {
  final ShippingService shippingService;

  ShippingRepositoryImpl(this.shippingService);

  @override
  Future<List<ShippingOption>> getAvailableShippingOptions({
    required String destinationPostalCode,
    required double totalWeight,
  }) async {
    return await shippingService.fetchShippingRates(
      postalCode: destinationPostalCode,
      totalWeight: totalWeight,
    );
  }
}
