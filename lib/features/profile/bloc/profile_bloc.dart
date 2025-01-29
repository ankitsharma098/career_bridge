import 'package:android/data/models/company/company_model.dart';
import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

import '../../../core/utils/hiveUtils.dart';
import '../../../data/models/employer/employer_model.dart';
import '../data/profile_api_service.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  EmployerProfileService apiService= EmployerProfileService();
  
  ProfileBloc() : super(ProfileInitial()) {

    on<FetchProfileData>(_onFetchProfileData);
    on<UpdatePersonalInfoDialog>(_onUpdatePersonalInfo);
    on<UpdateSocialMediaDialog>(_onUpdateSocialMedia);
    on<UpdateCompanyInfoDialog>(_onUpdateCompanyInfo);
    on<UpdateAboutDialog>(_onUpdateAboutDialog);
  }

  Future<void> _onFetchProfileData(FetchProfileData event, Emitter<ProfileState> emit) async {
    emit(ProfileDataLoading());
    try {
      print("FetchProfileData");

      Map<String,dynamic> employerData=await HiveUtils.getEmployerData();
      Map<String,dynamic> companyData=await HiveUtils.getCompanyData();
      if (employerData.isEmpty && companyData.isEmpty) {
        emit(ProfileError('No data found'));
        return;
      }

      emit(ProfileDataLoaded(Employer.fromJson(employerData), CompanyDetails.fromJson(companyData)));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdatePersonalInfo(UpdatePersonalInfoDialog event, Emitter<ProfileState> emit) async {
    try {

      final personalInfo = event.personalInfo;

      print('//personalInfo $personalInfo');
      // Update implementation
      await apiService.updatePersonalInfo(
          fullName: personalInfo['fullName'],
          profilePic: '',
          email: personalInfo['email'],
          phoneNumber: personalInfo['phoneNumber'],
          address: personalInfo['address'],
          DOB: personalInfo['DOB'],
          designation: personalInfo['designation'],
          gender: personalInfo['gender']
      );
     emit(ProfileUpdateSuccess('Personal info updated successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
  Future<void> _onUpdateSocialMedia(UpdateSocialMediaDialog event, Emitter<ProfileState> emit) async {
    try {
      // Update implementation
      emit(ProfileUpdateSuccess('SocialMedia updated successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateCompanyInfo(UpdateCompanyInfoDialog event, Emitter<ProfileState> emit) async {
    try {
      // Update implementation
      emit(ProfileUpdateSuccess('CompanyInfo updated successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateAboutDialog (UpdateAboutDialog event, Emitter<ProfileState> emit) async{

    try{

      await apiService.updateAboutSection(event.about.toString());

      emit (ProfileUpdateSuccess("About section updated successfully"));
      add(FetchProfileData());

    }catch(e){

      emit(ProfileError(e.toString()));
    }

  }
}
