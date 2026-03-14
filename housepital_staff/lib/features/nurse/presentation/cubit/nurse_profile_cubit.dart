import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/nurse_profile_model.dart';
import '../../data/repositories/nurse_repository.dart';
import '../../../../core/error/exceptions.dart';

// States
abstract class NurseProfileState {}

class NurseProfileInitial extends NurseProfileState {}

class NurseProfileLoading extends NurseProfileState {}

class NurseProfileLoaded extends NurseProfileState {
  final NurseProfile profile;
  final int completionPercentage;

  NurseProfileLoaded({
    required this.profile,
    required this.completionPercentage,
  });
}

class NurseProfileStatusLoaded extends NurseProfileState {
  final ProfileStatus status;

  NurseProfileStatusLoaded(this.status);
}

class NurseProfileUpdating extends NurseProfileState {}

class NurseProfileUpdated extends NurseProfileState {
  final NurseProfile profile;

  NurseProfileUpdated(this.profile);
}

class NurseProfileSubmitted extends NurseProfileState {
  final NurseProfile profile;

  NurseProfileSubmitted(this.profile);
}

class DocumentUploading extends NurseProfileState {
  final String documentType;

  DocumentUploading(this.documentType);
}

class DocumentUploaded extends NurseProfileState {
  final String documentType;
  final String url;

  DocumentUploaded(this.documentType, this.url);
}

class NurseProfileError extends NurseProfileState {
  final String message;

  NurseProfileError(this.message);
}

// Cubit
class NurseProfileCubit extends Cubit<NurseProfileState> {
  final NurseRepository repository;
  NurseProfile? _currentProfile;

  NurseProfileCubit({required this.repository}) : super(NurseProfileInitial());

  NurseProfile? get currentProfile => _currentProfile;

  Future<void> loadProfile() async {
    emit(NurseProfileLoading());
    try {
      print('🔄 Loading nurse profile...');
      final profile = await repository.getProfile();
      _currentProfile = profile;

      final completionPercentage = _calculateCompletionPercentage(profile);
      print(
        '✅ Profile loaded: ${profile.profileStatus} ($completionPercentage%)',
      );

      emit(
        NurseProfileLoaded(
          profile: profile,
          completionPercentage: completionPercentage,
        ),
      );
    } on AppException catch (e) {
      print('❌ Error loading profile: ${e.message}');
      emit(NurseProfileError(e.message));
    } catch (e) {
      print('❌ Unexpected error: $e');
      emit(NurseProfileError('Failed to load profile'));
    }
  }

  Future<void> loadProfileStatus() async {
    try {
      print('🔄 Loading profile status...');
      final status = await repository.getProfileStatus();
      print('✅ Status loaded: ${status.profileStatus}');
      emit(NurseProfileStatusLoaded(status));
    } on AppException catch (e) {
      print('❌ Error loading status: ${e.message}');
      emit(NurseProfileError(e.message));
    } catch (e) {
      print('❌ Unexpected error: $e');
      emit(NurseProfileError('Failed to load status'));
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    emit(NurseProfileUpdating());
    try {
      print('🔄 Updating profile with data: $data');
      final profile = await repository.updateProfile(data);
      _currentProfile = profile;
      print('✅ Profile updated successfully');
      emit(NurseProfileUpdated(profile));

      // Reload to get updated completion percentage
      await loadProfile();
    } on AppException catch (e) {
      print('❌ Error updating profile: ${e.message}');
      emit(NurseProfileError(e.message));
    } catch (e) {
      print('❌ Unexpected error: $e');
      emit(NurseProfileError('Failed to update profile'));
    }
  }

  Future<void> uploadDocument(String filePath, String documentType) async {
    emit(DocumentUploading(documentType));
    try {
      print('🔄 Uploading $documentType...');
      final url = await repository.uploadDocument(filePath, documentType);
      print('✅ Document uploaded: $url');
      emit(DocumentUploaded(documentType, url));

      // Update profile with document URL
      final fieldName = _getDocumentFieldName(documentType);
      await updateProfile({fieldName: url});
    } on AppException catch (e) {
      print('❌ Error uploading document: ${e.message}');
      emit(NurseProfileError(e.message));
    } catch (e) {
      print('❌ Unexpected error: $e');
      emit(NurseProfileError('Failed to upload document'));
    }
  }

  Future<void> submitForReview() async {
    emit(NurseProfileUpdating());
    try {
      print('🔄 Submitting profile for review...');
      final profile = await repository.submitForReview();
      _currentProfile = profile;
      print('✅ Profile submitted for review');
      emit(NurseProfileSubmitted(profile));
    } on AppException catch (e) {
      print('❌ Error submitting profile: ${e.message}');
      emit(NurseProfileError(e.message));
    } catch (e) {
      print('❌ Unexpected error: $e');
      emit(NurseProfileError('Failed to submit profile'));
    }
  }

  Future<void> toggleOnlineStatus(bool isOnline) async {
    if (false) {
      // Disabled for testing
      emit(NurseProfileError('Profile must be approved to go online'));
      // Restore previous state
      if (_currentProfile != null) {
        emit(
          NurseProfileLoaded(
            profile: _currentProfile!,
            completionPercentage: _calculateCompletionPercentage(
              _currentProfile!,
            ),
          ),
        );
      }
      return;
    }

    emit(NurseProfileUpdating());
    try {
      print('🔄 Toggling online status to: $isOnline');
      final profile = await repository.updateProfile({'isOnline': isOnline});
      _currentProfile = profile;
      print('✅ Online status updated: $isOnline');
      emit(NurseProfileUpdated(profile));

      // Reload to ensure full state consistency
      await loadProfile();
    } on AppException catch (e) {
      print('❌ Error toggling status: ${e.message}');
      emit(NurseProfileError(e.message));
    } catch (e) {
      print('❌ Unexpected error: $e');
      emit(NurseProfileError('Failed to update availability'));
    }
  }

  int _calculateCompletionPercentage(NurseProfile profile) {
    int completed = 0;
    const int total = 9; // Total required fields

    if (profile.licenseNumber != null && profile.licenseNumber!.isNotEmpty)
      completed++;
    if (profile.specialization != null && profile.specialization!.isNotEmpty)
      completed++;
    if (profile.yearsOfExperience != null) completed++;
    if (profile.gender != null && profile.gender!.isNotEmpty) completed++;
    if (profile.bio != null && profile.bio!.isNotEmpty) completed++;
    if (profile.nationalIdUrl != null && profile.nationalIdUrl!.isNotEmpty)
      completed++;
    if (profile.degreeUrl != null && profile.degreeUrl!.isNotEmpty) completed++;
    if (profile.licenseUrl != null && profile.licenseUrl!.isNotEmpty)
      completed++;

    // Payout method (either bank or ewallet)
    final hasPayoutMethod =
        (profile.bankAccount?.accountNumber != null &&
            profile.bankAccount!.accountNumber!.isNotEmpty) ||
        (profile.eWallet?.number != null &&
            profile.eWallet!.number!.isNotEmpty);
    if (hasPayoutMethod) completed++;

    return ((completed / total) * 100).round();
  }

  String _getDocumentFieldName(String documentType) {
    switch (documentType) {
      case 'national_id':
        return 'nationalIdUrl';
      case 'degree':
        return 'degreeUrl';
      case 'license':
        return 'licenseUrl';
      default:
        return documentType;
    }
  }
}
