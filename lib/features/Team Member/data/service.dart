import 'package:android/core/constants/app_constants.dart';
import 'package:dio/dio.dart';
import 'package:android/data/models/employer/employer_model.dart';

import '../../../core/utils/hiveUtils.dart';

class TeamMembersService {
  final Dio dio = Dio();
  Future<List<Employer>> fetchTeamMembers(String companyId) async{

    try{
      print("fetch aplication api");

      String? accessToken = await HiveUtils.getAccessToken();

      if(accessToken==null || accessToken.isEmpty){
        throw Exception("AccessToken not found");
      }
      final response = await dio.get('${AppConstants.baseUrl}/employer/team-members/$companyId',
        options:  Options(
            headers: {
              'Authorization':'Bearer $accessToken'
            }
        ),
      );


      if (response.statusCode == 200) {

        print(response.data);
        List<Map<String,dynamic>> rawResponse=List<Map<String,dynamic>>.from(response.data['data']);

        print("raw response $rawResponse");

        print("applications $rawResponse");
        return (rawResponse as List).map((json) => Employer.fromJson(json)).toList();
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

  Future<void> addTeamMember(String companyId, Map<String, dynamic> employerData) async {

    try{
      print("addTeamMember api");

      String? accessToken = await HiveUtils.getAccessToken();

      if(accessToken==null || accessToken.isEmpty){
        throw Exception("AccessToken not found");
      }
      final response = await dio.post('${AppConstants.baseUrl}/employer/register',
        options:  Options(
            headers: {
              'Authorization':'Bearer $accessToken'
            }
        ),
        data: {'companyId': companyId, 'employerData': employerData},
      );

      if (response.statusCode == 201) {

        return;
      }else{
        throw Exception('Failed to add member ${response.statusMessage}');
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

  Future<void> deleteTeamMember(String employerId) async {
    try{
      print("deleteTeamMember api");

      String? accessToken = await HiveUtils.getAccessToken();

      if(accessToken==null || accessToken.isEmpty){
        throw Exception("AccessToken not found");
      }
      final response = await dio.delete('${AppConstants.baseUrl}/employer/$employerId',
        options:  Options(
            headers: {
              'Authorization':'Bearer $accessToken'
            }
        ),
      );

      if (response.statusCode == 200) {

        return;
      }else{
        throw Exception('Failed to delete member ${response.statusMessage}');
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