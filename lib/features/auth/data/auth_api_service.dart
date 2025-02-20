

import 'dart:convert';

import 'package:android/core/constants/app_constants.dart';
import 'package:android/core/utils/hiveUtils.dart';
import 'package:dio/dio.dart';

import '../../../data/models/company/company_model.dart';
import '../../../data/models/employer/employer_model.dart';

class LoginApiService {

  final dio = Dio();
  String baseUrl="http://192.168.1.6:8000";

  Future<void> login(String email, String password) async {


    try{
      final response = await dio.post("$baseUrl/employer/login",

        data: {
        "email":email,
          "password":password
        },

      );
      if(response.statusCode==200){
        print("Full Response: ${jsonEncode(response.data)}");

        final employerData = Map<String, dynamic>.from(response.data['user']);

        final companyData = Map<String,dynamic>.from(response.data["companyDetails"]);
        final tokens = response.data["tokens"] as Map<String,dynamic>;



        // final employerResponse = Employer.fromJson(employerData);
        // final companyResponse = CompanyDetails.fromJson(companyData);

        print("////employer runtimeType ${companyData.runtimeType}");
        print("////companyDetails runtimeType ${employerData.runtimeType}");
        Map<String,dynamic> data={
          "employer": employerData,
          "companyDetails": companyData,
          'accessToken':tokens['accessTokens'],
          'refreshToken':tokens['refreshToken'],
        };
        await HiveUtils.storeUserData(data);

      }

    }on DioException catch (e) {
      if (e.response != null) {
        print("Error message ${e.response?.data["message"]}");
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      }
      else{
        print("Error sending request: ${e.message}");
        throw Exception('Network error occurred');
      }
    }
    catch(e){
      print("Error: $e");
      throw Exception('An unexpected error occurred');
    }
  }

  Future<void> saveToken(String fcmToken) async{
    try{
      print("tokens saved-------");
      String? accessToken = await HiveUtils.getAccessToken();

      if(accessToken==null || accessToken.isEmpty){
        throw Exception("AccessToken not found");
      }
      final response = await dio.post("$baseUrl/notification/save-token",
        options:  Options(
            headers: {
              'Authorization':'Bearer $accessToken'
            }
        ),
        data: {
          "fcmToken":fcmToken,
        },

      );
      if(response.statusCode==200) {
        print("tokens saved-------");
        bool isSavedFcmToken = response.data['status'] ?? false;
        print("isSavedToken $isSavedFcmToken");
      }

    }on DioException catch (e) {
      if (e.response != null) {
        print("Error message ${e.response?.data["message"]}");
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      }
      else{
        print("Error sending request: ${e.message}");
        throw Exception('Network error occurred');
      }
    }
    catch(e){
      print("Error: $e");
      throw Exception('An unexpected error occurred');
    }
  }



}