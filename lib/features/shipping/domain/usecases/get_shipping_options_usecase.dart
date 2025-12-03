import '../entities/shipping_option.dart';
import '../repositories/shipping_repository.dart';

class GetShippingOptionsUseCase {
  final ShippingRepository repository;

  GetShippingOptionsUseCase(this.repository);

  Future<List<ShippingOption>> call({
    required String destinationPostalCode,
    required double totalWeight,
  }) async {
    return await repository.getAvailableShippingOptions(
      destinationPostalCode: destinationPostalCode,
      totalWeight: totalWeight,
    );
  }
}