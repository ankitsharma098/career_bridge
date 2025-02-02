

import 'package:android/core/constants/app_constants.dart';
import 'package:android/core/utils/hiveUtils.dart';
import 'package:android/data/models/Job/job_model.dart';
import 'package:android/data/models/application/application_model.dart';
import 'package:dio/dio.dart';

class ApplicationApiService {

  final dio= Dio();
  Future<JobApplicationResponse> fetchApplication(String jobId) async{

    try{
      print("fetch aplication api");

      String? accessToken = await HiveUtils.getAccessToken();

      if(accessToken==null || accessToken.isEmpty){
        throw Exception("AccessToken not found");
      }
      final response = await dio.get('${AppConstants.baseUrl}/employer/applications/$jobId',
        options:  Options(
            headers: {
              'Authorization':'Bearer $accessToken'
            }
        ),
      );

      if (response.statusCode == 200) {

    Map<String,dynamic> rawResponse=Map<String,dynamic>.from(response.data);

        print("raw response $rawResponse");
        print("experience ${rawResponse['applications'][0]["experience"]}");
        JobApplicationResponse applications = JobApplicationResponse.fromJson(rawResponse);

        print("applications $applications");
        return applications;
      }else{
        throw Exception('Failed to Load Stats ${response.statusMessage}');
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