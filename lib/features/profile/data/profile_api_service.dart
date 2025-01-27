

import 'package:android/core/constants/app_constants.dart';
import 'package:android/core/utils/hiveUtils.dart';
import 'package:dio/dio.dart';

class EmployerProfileService{


  final dio = Dio();

  Future<void> updatePersonalInfo({required String? fullName, required String? profilePic , required String? email, required String? phoneNumber,required String? address, required DateTime? DOB,required String? designation}) async {

    try{
      String? accessToken= await HiveUtils.getAccessToken();
      if(accessToken!.isEmpty){
        throw Exception("AccessToken not found");
      }

      final Map<String, dynamic> data = {};
      if (fullName != null && fullName.isNotEmpty) data['fullName'] = fullName;
      if (profilePic != null && profilePic.isNotEmpty) data['profilePic'] = profilePic;
      if (email != null && email.isNotEmpty) data['email'] = email;
      if (phoneNumber != null && phoneNumber.isNotEmpty) data['phoneNumber'] = phoneNumber;
      if (address != null && address.isNotEmpty) data['address'] = address;
      if (DOB != null) data['DOB'] = DOB.toIso8601String();
      if (designation != null && designation.isNotEmpty) data['designation'] = designation;

      // Check if there is any data to update
      if (data.isEmpty) {
        throw Exception("No valid fields to update");
      }
      final response = await dio.put("${AppConstants.baseUrl}/employer/update/personalInfo",
          options: Options(
              headers: {
                'Authorization':'Bearer $accessToken'
              }
          ),
        data: data,
      );

      if(response.statusCode==200){
        final updatedUser = response.data['updatedUser'];

        await HiveUtils.updateEmployerData(updatedUser);


        return updatedUser;
      }else {
        throw Exception('Failed to update personal information. Status Code: ${response.statusCode}');
      }


    }catch(e){

      print("Error $e");
      throw Exception('Network Error $e');

    }


  }

}