part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class UpdatePersonalInfo  extends ProfileEvent {
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final DateTime? DOB;
  final String? profilePic;
  final String? designation;

  UpdatePersonalInfo({ required this.name, required this.email, required this.phone, required this.address, required this.DOB, required this.profilePic, required this.designation});
}

class UpdateSocialMedia  extends ProfileEvent {

  final String linkedin;
  final String twitter;
  final String instagram;

  UpdateSocialMedia(this.linkedin, this.twitter, this.instagram);
}

class UpdateCompanyInfo extends ProfileEvent {
  final String companyName;
  final String website;
  final String about;
   UpdateCompanyInfo({
    required this.companyName,
    required this.website,
    required this.about,
  });
}

class UpdateProfilePic extends ProfileEvent {

  final String profilePic;

  UpdateProfilePic(this.profilePic);
}