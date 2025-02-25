import 'package:dio/dio.dart';
import '../../../core/utils/hiveUtils.dart';
import '../../../data/models/candidate/candidate_model.dart';
import '../../../data/models/company/company_model.dart';
import '../../../data/models/employer/employer_model.dart';


class UserProfileApi {
  final Dio dio = Dio();
  final String baseUrl = "http://192.168.1.6:8000"; // Adjust to your API base URL

  Future<dynamic> getUserProfile(String userId, String userType) async {
    try {
      print("$userId $userType");
      final token = await HiveUtils.getAccessToken();

      final response = await dio.get(
        '$baseUrl/user/profile/$userType/$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print(response.data);
      if (userType == 'employer') {

        Map<String,dynamic> rawEmployer = Map<String,dynamic>.from(response.data['user']);
        print("raw emplyer $rawEmployer");
        Map<String,dynamic> rawCompanyDetails = Map<String,dynamic>.from(response.data['companyDetails']);

        print("raw company $rawCompanyDetails");

        return {
          'employer': Employer.fromJson(rawEmployer),
          'companyDetails': CompanyDetails.fromJson(rawCompanyDetails),
        };
      } else if (userType == 'candidate') {
        Map<String,dynamic> rawCandidate = Map<String,dynamic>.from(response.data['user']);
        return Candidate.fromJson(rawCandidate);
      }
      throw Exception('Unknown user type: $userType');
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