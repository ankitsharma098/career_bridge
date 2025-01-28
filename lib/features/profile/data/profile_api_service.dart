

import 'package:android/core/constants/app_constants.dart';
import 'package:android/core/utils/hiveUtils.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class EmployerProfileService{


  final dio = Dio();

  Future<void> updatePersonalInfo({ required String? fullName,
    required String? profilePic,
    required String? email,
    required String? phoneNumber,
    required String? address,
    required String? DOB,
    required String? designation,
    required String? gender}) async {
    try {
      print("updatePersonalInfo");

      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken!.isEmpty) {
        throw Exception("AccessToken not found");
      }

      print("accessToken");
      final Map<String, dynamic> data = {};

      void addIfValid(String key, String? value) {
        if (value != null && value.isNotEmpty) {
          data[key] = value;
        }
      }

      addIfValid('fullName', fullName);
      addIfValid('profilePic', profilePic);
      addIfValid('email', email);
      addIfValid('phoneNumber', phoneNumber);
      addIfValid('address', address);
      addIfValid('DOB', DOB);
      addIfValid('designation', designation);
      addIfValid('gender', gender);

      // Check if there is any data to update
      if (data.isEmpty) {
        throw Exception("No valid fields to update");
      }
      print("APi hit data $data");
      final response = await dio.put(
        "${AppConstants.baseUrl}/employer/update/personalInfo",
        options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken'
            }
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        final updatedUser = response.data['updatedUser'];

        print("Response $updatedUser");
        await HiveUtils.updateEmployerData(updatedUser);


        return updatedUser;
      }
    } on DioException catch (e) {
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
