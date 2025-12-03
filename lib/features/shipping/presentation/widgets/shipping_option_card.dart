// lib/features/shipping/presentation/widgets/shipping_option_card.dart

import 'package:flutter/material.dart';
import '../../domain/entities/shipping_option.dart';
// ignore: unused_import
import '../cubits/shipping_cubit.dart'; // Import Cubit

class ShippingOptionCard extends StatelessWidget {
  final ShippingOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const ShippingOptionCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      // Ubah warna border jika opsi ini terpilih
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nama Kurir dan Service Type
                  Text(
                    '${option.courierName} (${option.serviceType})',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: isSelected ? Colors.blue.shade800 : Colors.black87,
                    ),
                  ),
                  // Biaya Pengiriman
                  Text(
                    'Rp ${option.cost.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: isSelected
                          ? Colors.green.shade700
                          : Colors.green.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              // Estimasi Waktu Tiba
              Text(
                'Estimasi tiba: ${option.estimate}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
