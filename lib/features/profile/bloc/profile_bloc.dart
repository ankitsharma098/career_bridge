import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../data/profile_api_service.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  EmployerProfileService apiService= EmployerProfileService();
  
  ProfileBloc() : super(ProfileInitial()) {
    on<UpdatePersonalInfo>(_onUpdatePersonalInfo);
    on<UpdateProfilePic>(_onUpdateProfilePic);
    on<UpdateSocialMedia>(_onUpdateSocialMedia);
    on<UpdateCompanyInfo>(_onUpdateCompanyInfo);
  }

 Future<void> _onUpdatePersonalInfo(UpdatePersonalInfo event,Emitter<ProfileState> emit) async{
   try {

     //Api caliing
     //  if (state is )
     await apiService.updatePersonalInfo(fullName: event.name, profilePic: '', email: event.email, phoneNumber: event.phone, address: event.address, DOB: event.DOB, designation: event.designation);
     emit(EmployerProfileUpdateSuccess("Personal Info Updated successfully"));


   }catch (e){

     emit(EmployerProfileError(e.toString()));
   }
}

  Future<void> _onUpdateSocialMedia(UpdateSocialMedia event,Emitter<ProfileState> emit) async{

    try {

      //Api caliing
    //  if (state is )
      emit(EmployerProfileUpdateSuccess('Social media updated successfully'));


    }catch (e){

      emit(EmployerProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateCompanyInfo(UpdateCompanyInfo event,Emitter<ProfileState> emit) async{
    try {

      //Api caliing
      //  if (state is )
      emit(EmployerProfileUpdateSuccess('Company info updated successfully'));


    }catch (e){

      emit(EmployerProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfilePic(UpdateProfilePic event,Emitter<ProfileState> emit) async{
    try {


      await apiService.updatePersonalInfo(fullName: null, profilePic: event.profilePic, email: null, phoneNumber: null, address: null, DOB: null, designation: null);
      emit(EmployerProfileUpdateSuccess('ProfilePic updated successfully'));


    }catch (e){

      emit(EmployerProfileError(e.toString()));
    }
  }
}
