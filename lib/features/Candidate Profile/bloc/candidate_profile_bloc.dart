import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../core/utils/hiveUtils.dart';
import '../../../data/models/candidate/candidate_model.dart';
import '../../../data/models/employer/employer_model.dart';

part 'candidate_profile_event.dart';
part 'candidate_profile_state.dart';

class CandidateProfileBloc extends Bloc<CandidateProfileEvent, CandidateProfileState> {
  CandidateProfileBloc() : super(CandidateProfileInitial()) {
    on<FetchProfileData>(_onFetchProfileData);
  }
  Future<void> _onFetchProfileData(FetchProfileData event, Emitter<CandidateProfileState> emit) async {
    emit(ProfileDataLoading());
    try {
      print("FetchProfileData");

      Map<String,dynamic> candidateData=await HiveUtils.getCandidateData();

      if (candidateData.isEmpty) {
        emit(ProfileError('No data found'));
        return;
      }
      print("before candidate Profile data loaded");
      Candidate candidate = Candidate.fromJson(candidateData);
      print("candidate $candidate");

      emit(ProfileDataLoaded(candidate));
      print("after candidate Profile data loaded");
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
