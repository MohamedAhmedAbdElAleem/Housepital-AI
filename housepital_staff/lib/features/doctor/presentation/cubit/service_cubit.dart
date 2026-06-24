import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../../data/models/service_model.dart';

part 'service_state.dart';

class ServiceCubit extends Cubit<ServiceState> {
  final DoctorRepository repository;

  ServiceCubit({required this.repository}) : super(ServiceInitial());

  Future<void> fetchServices() async {
    try {
      emit(ServiceLoading());
      final services = await repository.getMyServices();
      emit(ServiceLoaded(services));
    } catch (e) {
      emit(ServiceError(e.toString()));
    }
  }

  Future<void> addService(ServiceModel service) async {
    try {
      emit(ServiceLoading());
      await repository.addService(service);
      await fetchServices();
    } catch (e) {
      emit(ServiceError(e.toString()));
    }
  }

  Future<void> updateService(ServiceModel service) async {
    try {
      emit(ServiceLoading());
      await repository.updateService(service);
      await fetchServices();
    } catch (e) {
      emit(ServiceError(e.toString()));
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      emit(ServiceLoading());
      await repository.deleteService(serviceId);
      await fetchServices();
    } catch (e) {
      emit(ServiceError(e.toString()));
    }
  }
}
