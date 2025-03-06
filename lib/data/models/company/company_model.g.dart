// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyDetails _$CompanyDetailsFromJson(Map<String, dynamic> json) =>
    CompanyDetails(
      id: json['_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      website: json['website'] as String? ?? '',
      about: json['about'] as String? ?? '',
      companyLogo: json['companyLogo'] == null
          ? const MediaItem()
          : MediaItem.fromJson(json['companyLogo'] as Map<String, dynamic>),
      industryType: json['industryType'] as String? ?? '',
      employerStrengths: json['employerStrengths'] as String? ?? '',
      location: json['location'] == null
          ? const Location()
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      officialAddress: json['officialAddress'] as String? ?? '',
      billingDetails: json['billingDetails'] == null
          ? const BillingDetails()
          : BillingDetails.fromJson(
              json['billingDetails'] as Map<String, dynamic>),
      companyProfile: json['companyProfile'] == null
          ? const MediaItem()
          : MediaItem.fromJson(json['companyProfile'] as Map<String, dynamic>),
      verificationDocument: json['verificationDocument'] == null
          ? const VerificationDocument()
          : VerificationDocument.fromJson(
              json['verificationDocument'] as Map<String, dynamic>),
      socialAccount: json['socialAccount'] == null
          ? const SocialAccount()
          : SocialAccount.fromJson(
              json['socialAccount'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CompanyDetailsToJson(CompanyDetails instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'email': instance.email,
      'companyName': instance.companyName,
      'website': instance.website,
      'about': instance.about,
      'companyLogo': instance.companyLogo,
      'industryType': instance.industryType,
      'employerStrengths': instance.employerStrengths,
      'location': instance.location,
      'officialAddress': instance.officialAddress,
      'billingDetails': instance.billingDetails,
      'companyProfile': instance.companyProfile,
      'verificationDocument': instance.verificationDocument,
      'socialAccount': instance.socialAccount,
    };

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
      country: json['country'] as String? ?? '',
      state: json['state'] as String? ?? '',
      city: json['city'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
    );

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'country': instance.country,
      'state': instance.state,
      'city': instance.city,
      'pincode': instance.pincode,
    };

BillingDetails _$BillingDetailsFromJson(Map<String, dynamic> json) =>
    BillingDetails(
      gstNo: json['GSTNo'] as String? ?? '',
      panNo: json['PANNo'] as String? ?? '',
      msme: json['MSME'] as String? ?? '',
    );

Map<String, dynamic> _$BillingDetailsToJson(BillingDetails instance) =>
    <String, dynamic>{
      'GSTNo': instance.gstNo,
      'PANNo': instance.panNo,
      'MSME': instance.msme,
    };

VerificationDocument _$VerificationDocumentFromJson(
        Map<String, dynamic> json) =>
    VerificationDocument(
      type: json['type'] as String? ?? '',
      url: json['url'] as String? ?? '',
      publicId: json['publicId'] as String? ?? '',
    );

Map<String, dynamic> _$VerificationDocumentToJson(
        VerificationDocument instance) =>
    <String, dynamic>{
      'type': instance.type,
      'url': instance.url,
      'publicId': instance.publicId,
    };

SocialAccount _$SocialAccountFromJson(Map<String, dynamic> json) =>
    SocialAccount(
      linkedin: json['linkedin'] as String? ?? 'linkedin',
      instagram: json['instagram'] as String? ?? 'instagram',
      twitter: json['twitter'] as String? ?? 'twitter',
    );

Map<String, dynamic> _$SocialAccountToJson(SocialAccount instance) =>
    <String, dynamic>{
      'linkedin': instance.linkedin,
      'instagram': instance.instagram,
      'twitter': instance.twitter,
    };

MediaItem _$MediaItemFromJson(Map<String, dynamic> json) => MediaItem(
      url: json['url'] as String? ?? '',
      publicId: json['publicId'] as String? ?? '',
    );

Map<String, dynamic> _$MediaItemToJson(MediaItem instance) => <String, dynamic>{
      'url': instance.url,
      'publicId': instance.publicId,
    };
