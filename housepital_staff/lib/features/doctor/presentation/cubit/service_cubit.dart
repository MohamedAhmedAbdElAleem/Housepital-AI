import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../../data/models/service_model.dart';
import 'package:equatable/equatable.dart';

// States
abstract class ServiceState extends Equatable {
  const ServiceState();
  @override
  List<Object?> get props => [];
}

class ServiceInitial extends ServiceState {}

class ServiceLoading extends ServiceState {}

class ServiceLoaded extends ServiceState {
  final List<ServiceModel> services;
  const ServiceLoaded(this.services);
  @override
  List<Object?> get props => [services];
}

class ServiceOperationSuccess extends ServiceState {
  final String message;
  const ServiceOperationSuccess(this.message);
}

class ServiceError extends ServiceState {
  final String message;
  const ServiceError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class ServiceCubit extends Cubit<ServiceState> {
  final DoctorRepository repository;

  ServiceCubit({required this.repository}) : super(ServiceInitial());

  Future<void> fetchServices() async {
    emit(ServiceLoading());
    try {
      final services = await repository.getMyServices();
      emit(ServiceLoaded(services));
    } catch (e) {
      emit(ServiceError(e.toString()));
    }
  }

  Future<void> addService(ServiceModel service) async {
    emit(ServiceLoading());
    try {
      await repository.addService(service);
      emit(const ServiceOperationSuccess('Service added successfully'));
      await fetchServices();
    } catch (e) {
      emit(ServiceError(e.toString()));
    }
  }

  Future<void> updateService(ServiceModel service) async {
    emit(ServiceLoading());
    try {
      await repository.updateService(service);
      emit(const ServiceOperationSuccess('Service updated successfully'));
      await fetchServices();
    } catch (e) {
      emit(ServiceError(e.toString()));
    }
  }

  Future<void> deleteService(String serviceId) async {
    emit(ServiceLoading());
    try {
      await repository.deleteService(serviceId);
      emit(const ServiceOperationSuccess('Service deleted successfully'));
      await fetchServices();
    } catch (e) {
      emit(ServiceError(e.toString()));
    }
  }
}
