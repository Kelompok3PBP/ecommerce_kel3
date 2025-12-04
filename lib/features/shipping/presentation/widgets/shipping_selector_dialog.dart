import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/shipping_cubit.dart';
import 'shipping_option_card.dart';

Future<void> showShippingSelectorDialog(BuildContext context) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return BlocProvider.value(
        value: BlocProvider.of<ShippingCubit>(context),
        child: const _ShippingSelectorContent(),
      );
    },
  );
}

class _ShippingSelectorContent extends StatelessWidget {
  const _ShippingSelectorContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Jasa Pengiriman',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Divider(),
          Expanded(
            child: BlocBuilder<ShippingCubit, ShippingState>(
              builder: (context, state) {
                if (state is ShippingLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ShippingError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (state is ShippingLoaded) {
                  final address = state.shippingAddress;
                  final selected = state.selectedOption;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (address != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Kirim ke: ${address.street}, ${address.city} (${address.postalCode})',
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),

                      Expanded(
                        child: ListView.builder(
                          itemCount: state.options.length,
                          itemBuilder: (context, index) {
                            final option = state.options[index];
                            return ShippingOptionCard(
                              option: option,
                              isSelected: option.id == selected?.id,
                              onTap: () {
                                context
                                    .read<ShippingCubit>()
                                    .selectShippingOption(option);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Tutup / Konfirmasi'),
                        ),
                      ),
                    ],
                  );
                }

                return const Center(
                  child: Text('Belum ada opsi pengiriman dimuat.'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
