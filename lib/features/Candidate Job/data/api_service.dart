

import 'package:android/data/models/Job/job_model.dart';
import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/hiveUtils.dart';
import '../../../data/models/application/application_model.dart';
import '../model/candidate_job_model.dart';

class CandidateJobServices {
  final dio = Dio();
  Future<List<CandidateJobModel>> fetchRecommendedJobs(int page) async{

    try{
      print("fetchRecommendedJobs api");

      String? accessToken = await HiveUtils.getAccessToken();

      if(accessToken==null || accessToken.isEmpty){
        throw Exception("AccessToken not found");
      }
      final response = await dio.get('${AppConstants.baseUrl}/candidate/jobs-recommended?page=$page',
        options:  Options(
            headers: {
              'Authorization':'Bearer $accessToken'
            }
        ),
      );

      if (response.statusCode == 200) {

        List<Map<String,dynamic>> rawRecommendedJobs=List<Map<String,dynamic>>.from(response.data['jobs']);

        print("raw response $rawRecommendedJobs");
        List<CandidateJobModel> recommendedJobs = rawRecommendedJobs
            .map((json) => CandidateJobModel.fromJson(json))
            .toList();

        print("recommendedJobs $recommendedJobs");
        return recommendedJobs;
      }else{
        print("Error->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${response}");
        throw Exception('Failed to Load stories ${response.statusMessage}');
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

  Future<List<CandidateJobModel>> fetchSearchedJobs({
    required int page,
    int limit = 10,
    String? search,
  }) async {
    try {
      print("fetchSearchedJobs API called with page: $page");

      String? accessToken = await HiveUtils.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("Access token not found");
      }

      final queryParameters = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null) 'search': search,
      };

      final response = await dio.get(
        '${AppConstants.baseUrl}/candidate/jobs-search/all',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        // Type-safe extraction of jobs from response
        final responseData = response.data as Map<String, dynamic>;
        final rawSearchedJobs = List<Map<String, dynamic>>.from(responseData['jobs'] ?? []);

        print("Raw response jobs: $rawSearchedJobs");

        final searchedJobs = rawSearchedJobs.map((json) => CandidateJobModel.fromJson(json)).toList();

        print("Parsed searched jobs: $searchedJobs");

        final pagination = responseData['pagination'] as Map<String, dynamic>?;

        if (pagination != null) {
          print("Pagination info: Current Page: ${pagination['currentPage']}, Total Pages: ${pagination['totalPages']}");
        }

        return searchedJobs;
      } else {
        print("Error response: ${response.statusCode} - ${response.statusMessage}");
        throw Exception('Failed to load jobs: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'An error occurred';
        print("Dio error: $errorMessage");
        throw Exception(errorMessage);
      } else {
        print("Network error: ${e.message}");
        throw Exception('Network error occurred');
      }
    } catch (e) {
      print("Unexpected error: $e");
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> submitApplicationToBackend({
    required String jobId,
    required bool isFresher,
    required List<Map<String, String>> experiences,
    required Map<String, String> contactInfo,
    required String resumeUrl,
  }) async {

    try{
      print("_submitApplicationToBackend api");

      Map<String,dynamic> data ={
        "experiences":experiences,
        "isFresher":isFresher,
        "resume":resumeUrl,
        "contactInfo":contactInfo,
      };

      print("dfata $data");

      String? accessToken = await HiveUtils.getAccessToken();

      if(accessToken==null || accessToken.isEmpty){
        throw Exception("AccessToken not found");
      }
      final response = await dio.post('${AppConstants.baseUrl}/candidate/jobs/enrolled/$jobId',
        options:  Options(
            headers: {
              'Authorization':'Bearer $accessToken'
            }
        ),
        data: data
      );

      if (response.statusCode == 201) {
        Map<String,dynamic> application= Map<String,dynamic>.from(response.data["application"]);

        return application;
      }else{
        print("Error->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${response}");
        throw Exception('Failed to apply Job ${response.statusMessage}');
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


  Future<Application> fetchApplicationStatus({
    required String jobId,
  }) async {
    try {
      print("fetchApplicationStatus API ");

      String? accessToken = await HiveUtils.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("Access token not found");
      }


      final response = await dio.get(
        '${AppConstants.baseUrl}/candidate/applications/$jobId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Type-safe extraction of jobs from response
        final responseData = response.data as Map<String, dynamic>;
        final rawStatus = Map<String, dynamic>.from(responseData['status'] ?? {});

        print("Raw response jobs: $rawStatus");

        Map<String,dynamic> appStatus = {
          "_id":rawStatus["_id"] ?? "",
          "status":rawStatus["status"] ?? "",
          "resume":rawStatus["resume"] ?? "",
          "isFresher":rawStatus["isFresher"] ?? true,
          "experience":rawStatus["experience"] ?? [],
          "contactInfo":rawStatus["contactInfo"] ?? {},
          "appliedDate":rawStatus["appliedDate"] ?? {},
        };
        print("appStatus $appStatus");

        final   applicationStatus= Application.fromJson(appStatus);
        print("applicationStatus $applicationStatus");

        return applicationStatus;
      } else {
        print("Error response: ${response.statusCode} - ${response.statusMessage}");
        throw Exception('Failed to Fetch Application Status : ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'An error occurred';
        print("Dio error: $errorMessage");
        throw Exception(errorMessage);
      } else {
        print("Network error: ${e.message}");
        throw Exception('Network error occurred');
      }
    } catch (e) {
      print("Unexpected error: $e");
      throw Exception('An unexpected error occurred: $e');
    }
  }


  Future<bool> toggleSavedJob (String jobId) async{
    try{
      print("savedStory api");

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