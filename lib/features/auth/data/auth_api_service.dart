

import 'dart:convert';

import 'package:android/core/constants/app_constants.dart';
import 'package:android/core/utils/utils.dart';
import 'package:dio/dio.dart';

import '../../../data/models/company/company_model.dart';
import '../../../data/models/employer/employer_model.dart';

class LoginApiService {

  final dio = Dio();

  Future<Map<String, dynamic>> login(String email, String password) async {
    String baseUrl=AppConstants.baseUrl;

    try{
      final response = await dio.post("$baseUrl/employer/login",

        data: {
        "email":email,
          "password":password
        },

      );
      if(response.statusCode==200){
        print("Full Response: ${jsonEncode(response.data)}");

        final employerData = response.data['user'] as Map<String, dynamic>;

        final companyData = response.data["companyDetails"] as Map<String,dynamic>;
        final tokens = response.data["tokens"] as Map<String,dynamic>;



        final employerResponse = Employer.fromJson(employerData);
        final companyResponse = CompanyDetails.fromJson(companyData);
        print("////employer $employerResponse");
        print("////companyDetails $companyResponse");
        Map<String,dynamic> data={
          "employer": employerData,
          "companyDetails": companyData,
          'accessToken':tokens['accessTokens'],
          'refreshToken':tokens['refreshToken'],
        };
        await HiveUtils.storeUserData(data);

        return {
          "employer": employerResponse,
          "companyDetails": companyResponse,
        };

      }else {

        throw Exception('Failed to login');
      }

    }catch(e){
      print("error $e");
      throw Exception('Network Error $e');

    }
  }


}