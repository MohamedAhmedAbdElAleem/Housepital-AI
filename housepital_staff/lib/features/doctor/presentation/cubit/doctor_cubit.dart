import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/doctor_model.dart';
import '../../domain/repositories/doctor_repository.dart';

import '../../../../core/error/exceptions.dart';

part 'doctor_state.dart';

class DoctorCubit extends Cubit<DoctorState> {
  final DoctorRepository repository;

  DoctorCubit({required this.repository}) : super(DoctorInitial());

  // Profile Management
  Future<void> fetchProfile() async {
    emit(DoctorLoading());
    try {
      final profile = await repository.getProfile();
      emit(DoctorProfileLoaded(profile));
    } on NotFoundException {
      // Profile not found is expected for new doctors
      emit(DoctorInitial());
    } catch (e) {
      emit(DoctorError(e.toString()));
    }
  }

  Future<void> createProfile(DoctorModel doctor) async {
    emit(DoctorLoading());
    try {
      final profile = await repository.createProfile(doctor);
      emit(DoctorProfileLoaded(profile));
    } catch (e) {
      emit(DoctorError(e.toString()));
    }
  }

  Future<void> updateProfile(DoctorModel doctor) async {
    emit(DoctorLoading());
    try {
      final profile = await repository.updateProfile(doctor);
      emit(DoctorProfileLoaded(profile));
    } catch (e) {
      emit(DoctorError(e.toString()));
    }
  }

  Future<String> uploadImage(File file) async {
    try {
      return await repository.uploadImage(file);
    } catch (e) {
      throw e;
    }
  }
}
