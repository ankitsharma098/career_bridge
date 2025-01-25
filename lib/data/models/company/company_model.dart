import 'package:json_annotation/json_annotation.dart';

part 'company_model.g.dart';

@JsonSerializable()
class CompanyDetails {
  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  @JsonKey(defaultValue: '')
  final String email;

  @JsonKey(defaultValue: '')
  final String companyName;

  @JsonKey(defaultValue: '')
  final String website;

  @JsonKey(defaultValue: '')
  final String about;

  @JsonKey(defaultValue: '')
  final String companyLogo;

  @JsonKey(defaultValue: '')
  final String industryType;

  @JsonKey(defaultValue: '')
  final String employerStrengths;


  final Location location;

  @JsonKey(defaultValue: '')
  final String officialAddress;


  final BillingDetails billingDetails;

  @JsonKey(defaultValue: '')
  final String companyProfile;


  final VerificationDocument verificationDocument;


  final SocialAccount socialAccount;

  const CompanyDetails({
     this.id = '',
     this.email = 'email',
     this.companyName = 'companyName',
     this.website = '',
     this.about = '',
     this.companyLogo = '',
     this.industryType = '',
     this.employerStrengths = '',
     this.location =const Location(),
     this.officialAddress='',
     this.billingDetails=const BillingDetails(),
     this.companyProfile = '',
     this.verificationDocument=const VerificationDocument(),
     this.socialAccount=const SocialAccount(),
  });

  factory CompanyDetails.fromJson(Map<String, dynamic> json) =>
      _$CompanyDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyDetailsToJson(this);
}

@JsonSerializable()
class Location {

  @JsonKey(defaultValue: '')
  final String country;


  @JsonKey(defaultValue: '')
  final String state;


  @JsonKey(defaultValue: '')
  final String city;


  @JsonKey(defaultValue: '')
  final String pincode;

 const Location({
     this.country='',
     this.state='',
     this.city='',
     this.pincode='',
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);
}

@JsonSerializable()
class BillingDetails {
  @JsonKey(name: 'GSTNo',defaultValue: '')
  final String gstNo;
  @JsonKey(name: 'PANNo',defaultValue: '')
  final String panNo;
  @JsonKey(name: 'MSME',defaultValue: '')
  final String msme;

  const BillingDetails({
     this.gstNo='',
     this.panNo='',
     this.msme='',
  });

  factory BillingDetails.fromJson(Map<String, dynamic> json) =>
      _$BillingDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$BillingDetailsToJson(this);
}

@JsonSerializable()
class VerificationDocument {

  @JsonKey(defaultValue: '')
  final String type;

  @JsonKey(name: 'URL',defaultValue: '')
  final String url;

  const VerificationDocument({
     this.type='',
     this.url='',
  });

  factory VerificationDocument.fromJson(Map<String, dynamic> json) =>
      _$VerificationDocumentFromJson(json);

  Map<String, dynamic> toJson() => _$VerificationDocumentToJson(this);
}

@JsonSerializable()
class SocialAccount {

  @JsonKey(defaultValue: '')
  final String linkedin;


  @JsonKey(defaultValue: '')
  final String instagram;


  @JsonKey(defaultValue: '')
  final String twitter;

 const SocialAccount({
     this.linkedin='linkedin',
     this.instagram='instagram',
     this.twitter='twitter',
  });

  factory SocialAccount.fromJson(Map<String, dynamic> json) =>
      _$SocialAccountFromJson(json);

  Map<String, dynamic> toJson() => _$SocialAccountToJson(this);
}