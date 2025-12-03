// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:ecommerce/features/shipping/domain/entities/shipping_option.dart';
import 'package:ecommerce/features/shipping/domain/usecases/get_shipping_options_usecase.dart';
import 'package:equatable/equatable.dart'; 
import '../../../address/domain/entities/address.dart'; 


abstract class ShippingState extends Equatable {
  const ShippingState();

  @override
  List<Object?> get props => [];
}

class ShippingInitial extends ShippingState {}

class ShippingLoading extends ShippingState {}

class ShippingError extends ShippingState {
  final String message;
  const ShippingError(this.message);

  @override
  List<Object?> get props => [message];
}

class ShippingLoaded extends ShippingState {
  final List<ShippingOption> options; 
  final ShippingOption? selectedOption; 
  final Address? shippingAddress; 

  const ShippingLoaded({
    required this.options, 
    this.selectedOption,
    this.shippingAddress,
  });

  // copyWith sangat berguna untuk membuat State baru tanpa merubah semua field
  ShippingLoaded copyWith({
    List<ShippingOption>? options,
    ShippingOption? selectedOption,
    Address? shippingAddress,
  }) {
    return ShippingLoaded(
      options: options ?? this.options,
      selectedOption: selectedOption ?? this.selectedOption,
      shippingAddress: shippingAddress ?? this.shippingAddress,
    );
  }

  // Equatable akan membandingkan semua properti di bawah ini
  @override
  List<Object?> get props => [options, selectedOption, shippingAddress];
}


// --------------------------------------------------------------------------
// B. SHIPPING CUBIT
// --------------------------------------------------------------------------

class ShippingCubit extends Cubit<ShippingState> {
  final GetShippingOptionsUseCase getOptionsUseCase;

  ShippingCubit(this.getOptionsUseCase) : super(ShippingInitial());

  /// Memuat opsi pengiriman dari Use Case.
  Future<void> loadShippingOptions({
    required Address address,
    required double totalWeight,
  }) async {
    emit(ShippingLoading());

    final postalCode = address.postalCode;
    if (postalCode.isEmpty) {
      return emit(const ShippingError('Kode pos alamat tidak ditemukan.'));
    }

    try {
      final options = await getOptionsUseCase.call(
        destinationPostalCode: postalCode,
        totalWeight: totalWeight,
      );

      // Setelah berhasil, emit ShippingLoaded. Opsi pertama dipilih sebagai default.
      emit(ShippingLoaded(
        options: options, 
        selectedOption: options.isNotEmpty ? options.first : null,
        shippingAddress: address,
      ));

    } catch (e) {
      emit(ShippingError('Gagal memuat opsi pengiriman: ${e.toString()}'));
    }
  }

  /// Memperbarui opsi pengiriman yang dipilih oleh pengguna.
  void selectShippingOption(ShippingOption option) {
    if (state is ShippingLoaded) {
      final currentState = state as ShippingLoaded;
      
      // Menggunakan copyWith untuk emit State baru dengan hanya opsi yang berubah
      emit(currentState.copyWith(selectedOption: option));
    }
  }
}