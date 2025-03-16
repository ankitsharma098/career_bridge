
import 'package:android/core/constants/app_constants.dart';
import 'package:android/core/utils/hiveUtils.dart';
import 'package:android/features/Candidate%20Job/model/candidate_job_model.dart';
import 'package:dio/dio.dart';
class CandidateJobStatsApi {

  final dio = Dio();

  Future<Map<String,dynamic>> fetchJobStats() async {

    try{
      print("fetchJobStats api");

      String? accessToken = await HiveUtils.getAccessToken();

      if(accessToken==null || accessToken.isEmpty){
        throw Exception("AccessToken not found");
      }
      final response = await dio.get('${AppConstants.baseUrl}/candidate/jobs/stats',
        options:  Options(
            headers: {
              'Authorization':'Bearer $accessToken'
            }
        ),
      );

      if (response.statusCode == 200) {

        Map<String,dynamic> jobsStats=Map<String,dynamic>.from(response.data['stats']);


        print("job stats $jobsStats");
        return jobsStats;
      }else{
        throw Exception('Failed to Load Job stats ${response.statusMessage}');
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

  Future<List<CandidateJobModel>> fetchSavedJobs(int page) async{

    try{
      print("fetchSavedJobs api");

      String? accessToken = await HiveUtils.getAccessToken();

      if(accessToken==null || accessToken.isEmpty){
        throw Exception("AccessToken not found");
      }
      final response = await dio.get('${AppConstants.baseUrl}/candidate/jobs/saved?page=$page',
        options:  Options(
            headers: {
              'Authorization':'Bearer $accessToken'
            }
        ),
      );

      if (response.statusCode == 200) {

        final responseData = response.data as Map<String, dynamic>;
        final rawSavedJobs = List<Map<String, dynamic>>.from(responseData['jobs'] ?? []);

        print("Raw response jobs: $rawSavedJobs");

        final savedJobs = rawSavedJobs.map((json) => CandidateJobModel.fromJson(json)).toList();

        print("Parsed searched jobs: $savedJobs");

        final pagination = responseData['pagination'] as Map<String, dynamic>?;

        if (pagination != null) {
          print("Pagination info: Current Page: ${pagination['currentPage']}, Total Pages: ${pagination['totalPages']}");
        }

        return savedJobs;
      }else{
        print("Error->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${response}");
        throw Exception('Failed to fetch saved jobs ${response.statusMessage}');
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

  Future<List<CandidateJobModel>> fetchEnrolledJobs(int page) async{

    try{
      print("fetchEnrolledJobs api");

      String? accessToken = await HiveUtils.getAccessToken();

      if(accessToken==null || accessToken.isEmpty){
        throw Exception("AccessToken not found");
      }
      final response = await dio.get('${AppConstants.baseUrl}/candidate/jobs/enrolled-jobs?page=$page',
        options:  Options(
            headers: {
              'Authorization':'Bearer $accessToken'
            }
        ),
      );

      if (response.statusCode == 200) {

        final responseData = response.data as Map<String, dynamic>;
        final rawEnrolledJobs = List<Map<String, dynamic>>.from(responseData['jobs'] ?? []);

        print("Raw response jobs: $rawEnrolledJobs");

        final enrolledJobs = rawEnrolledJobs.map((json) => CandidateJobModel.fromJson(json)).toList();

        print("Parsed searched jobs: $enrolledJobs");

        final pagination = responseData['pagination'] as Map<String, dynamic>?;

        if (pagination != null) {
          print("Pagination info: Current Page: ${pagination['currentPage']}, Total Pages: ${pagination['totalPages']}");
        }

        return enrolledJobs;
      }else{
        print("Error->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${response}");
        throw Exception('Failed to fetch enrolled jobs ${response.statusMessage}');
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

  Future<bool> toggleSavedJob (String jobId) async{
    try{
      print("toggleSavedJob api");

      String? accessToken = await HiveUtils.getAccessToken();

      if(accessToken==null || accessToken.isEmpty){
        throw Exception("AccessToken not found");
      }
      final response = await dio.post('${AppConstants.baseUrl}/candidate/jobs/saved/$jobId',
        options:  Options(
            headers: {
              'Authorization':'Bearer $accessToken'
            }
        ),
      );

      if (response.statusCode == 200) {
        print("response ${response.data}");


        bool success = response.data['saved'] ?? false;


        print("success $success");
        return success;
      }else{
        print("Error->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${response}");
        throw Exception('Failed to Saved Job ${response.statusMessage}');
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