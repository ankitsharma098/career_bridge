

import 'package:android/core/constants/app_constants.dart';
import 'package:android/core/utils/hiveUtils.dart';
import 'package:android/data/models/Job/job_model.dart';
import 'package:dio/dio.dart';

class JobApiService {
  
  final dio= Dio();
  Future<Map<String,dynamic>> fetchJobStats() async{
    
    try{
      
      String? accessToken = await HiveUtils.getAccessToken();
      
      if(accessToken==null || accessToken.isEmpty){
        throw Exception("AccessToken not found");
      }
      final response = await dio.get('${AppConstants.baseUrl}/employer/job-stats',
      options:  Options(
        headers: {
          'Authorization':'Bearer $accessToken'
        }
      ),
      );

      if (response.statusCode == 200) {
        final rawStats = response.data['stats'];

        Map<String,dynamic> stats=Map<String,dynamic>.from(rawStats);

        print("JobStats $stats");
       return stats;
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
  
  Future<List<JobModel>> fetchPostedJobs(int page) async {
    
    try{
      print("calling");
      
      String? accessToken = await HiveUtils.getAccessToken();
      if(accessToken==null || accessToken.isEmpty){
        throw Exception("Access Token not found");
      }
      
      final response = await dio.get('${AppConstants.baseUrl}/employer/jobs-posted?page=$page',

          options: Options(
          headers: {
            'Authorization':'Bearer $accessToken'
          }
          )

      );
      if(response.statusCode == 200){

        List<Map<String, dynamic>> jobs = List<Map<String, dynamic>>.from(
            (response.data["jobs"] as List).where((job) => job != null)
        );

        List<JobModel> jobModel= jobs.map((job)=>JobModel.fromJson(job)).toList();
        return jobModel;
      }else {
        throw Exception('Failed to Load Stats');
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

  Future <JobModel> createJob(Map<String,dynamic> job) async {
    try{

      print("Creat job call");
      String? accessToken = await HiveUtils.getAccessToken();
      if(accessToken==null || accessToken.isEmpty){
        throw Exception("Access Token not found");
      }

      final response = await dio.post("${AppConstants.baseUrl}/job/create",
        options: Options(
          headers: {
            'Authorization':'Bearer $accessToken'
          },
        ),
        data: job
      );

      if(response.statusCode==201){


        Map<String,dynamic> createJob=Map<String,dynamic>.from(response.data['job']);

        JobModel job=JobModel.fromJson(createJob);

        return job;
      }else {
        throw Exception('Failed to Load Stats');
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

  Future<bool> updateJob(Map<String,dynamic> updatedJob, String jobId) async {

    try{

      print("Update job call");
      String? accessToken = await HiveUtils.getAccessToken();
      if(accessToken==null || accessToken.isEmpty){
        throw Exception("Access Token not found");
      }

      final response = await dio.put("${AppConstants.baseUrl}/employer/$jobId/update",
          options: Options(
            headers: {
              'Authorization':'Bearer $accessToken'
            },
          ),
          data: updatedJob
      );

      if(response.statusCode==200){


       // Map<String,dynamic> createJob=Map<String,dynamic>.from(response.data['job']);

        bool success = response.data['status'] ?? false;

        print("response.data ${response.data}");
        //JobModel job=JobModel.fromJson(updatedJob);
        print("success ------------------------------------------------------ $success");

        return success;
      }else {
        throw Exception('Failed to Update Job');
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