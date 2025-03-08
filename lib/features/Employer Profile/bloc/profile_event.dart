part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class FetchProfileData extends ProfileEvent {}

class UpdatePersonalInfoDialog extends ProfileEvent {
  final Map<String, dynamic> personalInfo;
  UpdatePersonalInfoDialog(this.personalInfo);
}

class UpdateAboutDialog extends ProfileEvent {
  final String about;
  UpdateAboutDialog(this.about);
}

class UpdateSocialMediaDialog extends ProfileEvent {
  final Map<String, String> socialMedia;
  UpdateSocialMediaDialog(this.socialMedia);
}

class UpdateCompanyInfoDialog extends ProfileEvent {
  final Map<String, String> companyInfo;
  UpdateCompanyInfoDialog(this.companyInfo);
}

class UpdateProfilePic extends ProfileEvent {

  final String profilePic;

  UpdateProfilePic(this.profilePic);
}