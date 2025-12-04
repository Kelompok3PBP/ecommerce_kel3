import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ecommerce/features/address/presentation/cubits/address_cubit.dart';
import 'package:ecommerce/features/address/presentation/pages/address_form_page.dart';

class AddressListPage extends StatefulWidget {
  const AddressListPage({Key? key}) : super(key: key);

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  @override
  void initState() {
    super.initState();
    context.read<AddressCubit>().fetchAll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<AddressCubit>().fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Alamat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/profile');
          },
        ),
      ),
      body: BlocBuilder<AddressCubit, AddressState>(
        builder: (context, state) {
          if (state is AddressLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AddressListLoaded) {
            final addresses = state.addresses;
            if (addresses.isEmpty) {
              return const Center(child: Text('Belum ada alamat.'));
            }

            return ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (context, i) {
                final address = addresses[i];
                return ListTile(
                  title: Text(address.label),
                  subtitle: Text(
                    '${address.street}, ${address.city}, ${address.postalCode}\n${address.phone}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<AddressCubit>(),
                                child: AddressFormPage(address: address),
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Hapus alamat'),
                              content: const Text(
                                'Yakin ingin menghapus alamat ini?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );
                          if (ok == true) {
                            context.read<AddressCubit>().delete(address.id);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }

          if (state is AddressError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<AddressCubit>(),
                child: const AddressFormPage(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Tambah Alamat',
      ),
    );
  }
}
