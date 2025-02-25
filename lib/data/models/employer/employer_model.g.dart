// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Employer _$EmployerFromJson(Map<String, dynamic> json) => Employer(
      id: json['_id'] as String? ?? '',
      personalInfo: json['personalInfo'] == null
          ? const PersonalInfo()
          : PersonalInfo.fromJson(json['personalInfo'] as Map<String, dynamic>),
      companyDetails: json['companyDetails'] == null
          ? const MinimalCompanyDetails()
          : MinimalCompanyDetails.fromJson(
              json['companyDetails'] as Map<String, dynamic>),
      postedJobs: (json['postedJobs'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      stories: json['stories'] == null
          ? const UserStories()
          : UserStories.fromJson(json['stories'] as Map<String, dynamic>),
      events: json['events'] == null
          ? const UserEvents()
          : UserEvents.fromJson(json['events'] as Map<String, dynamic>),
      auth: json['auth'] == null
          ? const Auth()
          : Auth.fromJson(json['auth'] as Map<String, dynamic>),
      about: json['about'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      fcmToken: json['fcmToken'] as String? ?? '',
    );

Map<String, dynamic> _$EmployerToJson(Employer instance) => <String, dynamic>{
      '_id': instance.id,
      'personalInfo': instance.personalInfo,
      'companyDetails': instance.companyDetails,
      'postedJobs': instance.postedJobs,
      'stories': instance.stories,
      'events': instance.events,
      'auth': instance.auth,
      'about': instance.about,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'fcmToken': instance.fcmToken,
    };

PersonalInfo _$PersonalInfoFromJson(Map<String, dynamic> json) => PersonalInfo(
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profilePic: json['profilePic'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      address: json['address'] as String? ?? '',
      dob: json['dob'] as String? ?? '',
      gender: json['gender'] as String? ?? 'Male',
    );

Map<String, dynamic> _$PersonalInfoToJson(PersonalInfo instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'email': instance.email,
      'profilePic': instance.profilePic,
      'phoneNumber': instance.phoneNumber,
      'address': instance.address,
      'dob': instance.dob,
      'gender': instance.gender,
    };

MinimalCompanyDetails _$MinimalCompanyDetailsFromJson(
        Map<String, dynamic> json) =>
    MinimalCompanyDetails(
      companyId: json['companyId'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
    );

Map<String, dynamic> _$MinimalCompanyDetailsToJson(
        MinimalCompanyDetails instance) =>
    <String, dynamic>{
      'companyId': instance.companyId,
      'designation': instance.designation,
    };

UserStories _$UserStoriesFromJson(Map<String, dynamic> json) => UserStories(
      myStoryIds: (json['myStories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      savedStoryIds: (json['savedStories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$UserStoriesToJson(UserStories instance) =>
    <String, dynamic>{
      'myStories': instance.myStoryIds,
      'savedStories': instance.savedStoryIds,
    };

UserEvents _$UserEventsFromJson(Map<String, dynamic> json) => UserEvents(
      myEvents: (json['myEvents'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      savedEvents: (json['savedEvents'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      registeredEvents: (json['registeredEvents'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$UserEventsToJson(UserEvents instance) =>
    <String, dynamic>{
      'myEvents': instance.myEvents,
      'savedEvents': instance.savedEvents,
      'registeredEvents': instance.registeredEvents,
    };

Auth _$AuthFromJson(Map<String, dynamic> json) => Auth(
      verified: json['verified'] as bool? ?? false,
      status: json['status'] as String? ?? '',
    );

Map<String, dynamic> _$AuthToJson(Auth instance) => <String, dynamic>{
      'verified': instance.verified,
      'status': instance.status,
    };
