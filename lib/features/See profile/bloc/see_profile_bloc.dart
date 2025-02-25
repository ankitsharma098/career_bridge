import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../data/models/candidate/candidate_model.dart';
import '../../../data/models/company/company_model.dart';
import '../../../data/models/employer/employer_model.dart';
import '../data/api_service.dart';

part 'see_profile_event.dart';
part 'see_profile_state.dart';

class SeeProfileBloc extends Bloc<SeeProfileEvent, SeeProfileState> {
  final UserProfileApi _apiService = UserProfileApi();

  SeeProfileBloc() : super(SeeProfileInitial()) {
    on<FetchUserProfile>(_onFetchUserProfile);
  }
  Future<void> _onFetchUserProfile(FetchUserProfile event, Emitter<SeeProfileState> emit) async {
    emit(UserProfileLoading());
    try {
      final profileData = await _apiService.getUserProfile(event.userId, event.userType);
      if (event.userType == 'employer') {
        emit(UserProfileLoadedEmployer(
           profileData['employer'],
          profileData['companyDetails'],
        ));
      } else if (event.userType == 'candidate') {
        emit(UserProfileLoadedCandidate(profileData));
      }
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }
}
