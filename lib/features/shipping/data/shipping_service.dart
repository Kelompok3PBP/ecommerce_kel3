import 'package:ecommerce/features/shipping/domain/entities/shipping_option.dart';

class ShippingService {
  Future<List<ShippingOption>> fetchShippingRates({
    required String postalCode,
    required double totalWeight,
  }) async {
    // Simulasikan penundaan seolah olah mengambil data
    await Future.delayed(const Duration(milliseconds: 100));

    // --- Logika Biaya Lokal ---
    // 1. Tentukan Biaya Dasar Berdasarkan Zona/Kode Pos
    double baseCost;
    if (postalCode.startsWith('1')) {
      baseCost = 15000.0; // Zona Jakarta
    } else if (postalCode.startsWith('6')) {
      baseCost = 22000.0; // Zona Jawa Timur
    } else {
      baseCost = 30000.0; // Biaya default / zona lain
    }

    // 2. Definisikan Opsi Pengiriman dan Hitung Biaya
    return [
      // Jasa Reguler (J&T Express)
      ShippingOption(
        id: 'JNT_REG',
        name: 'Reguler',
        serviceType: 'Reguler',
        // Biaya: Dasar + (Berat total * 500 per kg)
        cost: baseCost + (totalWeight * 500),
        courierName: 'J&T Express',
        estimate: '3-5 hari',
      ),
      // Jasa Express (Shopee Xpress)
      ShippingOption(
        id: 'SPX_XPS',
        name: 'Next Day',
        serviceType: 'Express',
        // Biaya: Dasar * 2.0
        cost: baseCost * 2.0,
        courierName: 'Shopee Xpress',
        estimate: '1-2 hari',
      ),
      // Jasa Ekonomi (POS Indonesia)
      ShippingOption(
        id: 'POS_EKO',
        name: 'Ekonomi',
        serviceType: 'Ekonomi',
        // Biaya: Dasar * 0.7
        cost: baseCost * 0.7,
        courierName: 'POS Indonesia',
        estimate: '5-7 hari',
      ),
    ];
  }
}
