import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/address.dart';
import '../../data/address_service.dart';

abstract class AddressState {}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressListLoaded extends AddressState {
  final List<Address> addresses;
  AddressListLoaded(this.addresses);
}

class AddressLoaded extends AddressState {
  final Address address;
  AddressLoaded(this.address);
}

class AddressSuccess extends AddressState {}

class AddressError extends AddressState {
  final String message;
  AddressError(this.message);
}

class AddressCubit extends Cubit<AddressState> {
  final AddressService service;
  AddressCubit(this.service) : super(AddressInitial());

  Future<void> fetchAll() async {
    emit(AddressLoading());
    try {
      final list = await service.fetchAll();
      emit(AddressListLoaded(list));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> fetchById(int id) async {
    emit(AddressLoading());
    try {
      final address = await service.fetchById(id);
      emit(AddressLoaded(address));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> create(Address address) async {
    emit(AddressLoading());
    try {
      await service.create(address);
      emit(AddressSuccess());
      await fetchAll();
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> update(Address address) async {
    emit(AddressLoading());
    try {
      await service.update(address);
      emit(AddressSuccess());
      await fetchAll();
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> delete(int id) async {
    emit(AddressLoading());
    try {
      await service.delete(id);
      emit(AddressSuccess());
      await fetchAll();
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }
}
