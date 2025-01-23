import 'package:json_annotation/json_annotation.dart';

part 'company_model.g.dart';

@JsonSerializable()
class CompanyDetails {
  @JsonKey(name: '_id')
  final String id;
  final String email;
  final String companyName;
  final String website;
  final String about;
  final String companyLogo;
  final String industryType;
  final String employerStrengths;
  final Location location;
  final String officialAddress;
  final BillingDetails billingDetails;
  final String companyProfile;
  final VerificationDocument verificationDocument;
  final SocialAccount socialAccount;

  CompanyDetails({
    required this.id,
    required this.email,
    required this.companyName,
    required this.website,
    required this.about,
    required this.companyLogo,
    required this.industryType,
    required this.employerStrengths,
    required this.location,
    required this.officialAddress,
    required this.billingDetails,
    required this.companyProfile,
    required this.verificationDocument,
    required this.socialAccount,
  });

  factory CompanyDetails.fromJson(Map<String, dynamic> json) =>
      _$CompanyDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyDetailsToJson(this);
}

@JsonSerializable()
class Location {
  final String country;
  final String state;
  final String city;
  final String pincode;

  Location({
    required this.country,
    required this.state,
    required this.city,
    required this.pincode,
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);
}

@JsonSerializable()
class BillingDetails {
  @JsonKey(name: 'GSTNo')
  final String gstNo;
  @JsonKey(name: 'PANNo')
  final String panNo;
  @JsonKey(name: 'MSME')
  final String msme;

  BillingDetails({
    required this.gstNo,
    required this.panNo,
    required this.msme,
  });

  factory BillingDetails.fromJson(Map<String, dynamic> json) =>
      _$BillingDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$BillingDetailsToJson(this);
}

@JsonSerializable()
class VerificationDocument {
  final String type;
  @JsonKey(name: 'URL')
  final String url;

  VerificationDocument({
    required this.type,
    required this.url,
  });

  factory VerificationDocument.fromJson(Map<String, dynamic> json) =>
      _$VerificationDocumentFromJson(json);

  Map<String, dynamic> toJson() => _$VerificationDocumentToJson(this);
}

@JsonSerializable()
class SocialAccount {
  final String linkedin;
  final String instagram;
  final String twitter;

  SocialAccount({
    required this.linkedin,
    required this.instagram,
    required this.twitter,
  });

  factory SocialAccount.fromJson(Map<String, dynamic> json) =>
      _$SocialAccountFromJson(json);

  Map<String, dynamic> toJson() => _$SocialAccountToJson(this);
}