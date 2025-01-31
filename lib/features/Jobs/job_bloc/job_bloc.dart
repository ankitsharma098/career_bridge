import 'package:android/features/Jobs/data_services/jobs_api_service.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/models/Job/job_model.dart';

part 'job_event.dart';
part 'job_state.dart';

class JobBloc extends Bloc<JobEvent, JobState> {

  JobApiService apiService = JobApiService();
  JobBloc() : super(JobInitial()) {
    on<FetchJobs>(_onFetchJobs);
    on<LoadMoreJobs>(_onLoadMoreJobs);
  }

  Future<void> _onFetchJobs(FetchJobs event,Emitter<JobState> emit) async{


    try{

      emit(JobLoading());
      List<JobModel> jobs = await apiService.fetchPostedJobs(1);
     // print("total Jobs ${jobs.length}");
     //  Map<String,dynamic> rawJob={
     //    "_id": "65f4a2b7c9a8d5f12e3b4a6d",
     //    "companyId": "65f4a2b7c9a8d5f12e3b4a1c",
     //    "employerId": "65f4a2b7c9a8d5f12e3b4a2d",
     //    "employerEmail": "hr@techcorp.com",
     //    "title": "Software Engineer",
     //    "overview": "We are looking for a skilled software engineer to develop and maintain applications.",
     //    "employmentType": "Full-time",
     //    "experienceLevel": "Intermediate",
     //    "responsibilities": [
     //      "Develop and maintain web applications",
     //      "Collaborate with cross-functional teams",
     //      "Write clean and efficient code",
     //      "Troubleshoot and debug applications"
     //    ],
     //    "qualifications": [
     //      "Bachelor’s degree in Computer Science or related field",
     //      "Proficiency in Flutter and Dart",
     //      "Experience with RESTful APIs"
     //    ],
     //    "benefits": [
     //      "Health insurance",
     //      "Flexible work hours",
     //      "Remote work options"
     //    ],
     //    "workspaceAccommodations": "Ergonomic seating, wheelchair access",
     //    "interviewAccommodations": "Sign language interpreter available upon request",
     //    "skills": ["Flutter", "Dart", "Node.js", "MongoDB"],
     //    "location": {
     //      "type": "On-site",
     //      "address": "123 Tech Park, Silicon Valley",
     //      "city": "San Francisco",
     //      "state": "California",
     //      "country": "USA",
     //      "facilityAccessibility": ["Wheelchair Accessible", "Assistive Technology"]
     //    },
     //    "salary": {
     //      "currency": "USD",
     //      "min": 60000,
     //      "max": 100000
     //    },
     //    "disabilityTypes": {
     //      "supportedDisabilities": ["Hearing Impairments", "Visual Impairments"]
     //    },
     //    "deadline": "2025-03-15",
     //    "status": "Open",
     //    "applicants": ["65f4b1a7c9a8d5f12e3b4b6e", "65f4c2b7c9a8d5f12e3b4c7d"],
     //    "views": 120
     //  };

      //List<JobModel> rawJobs = [JobModel.fromJson(rawJob)];

      emit(JobLoaded(jobs: jobs, hasReachedMax: false, currentPage: 1));


    }catch(e){
      emit(JobError(e.toString()));
    }


  }

  Future<void> _onLoadMoreJobs(LoadMoreJobs event,Emitter<JobState> emit) async {

    final currentState=state;
    if(currentState is JobLoaded){

      if(!currentState.hasReachedMax) {
        try{
          final nextPage = currentState.currentPage+1;
          List<JobModel> newJobs= await apiService.fetchPostedJobs(nextPage);
          if (newJobs.isEmpty) {
            emit(JobLoaded(
              jobs: currentState.jobs,
              hasReachedMax: true,
              currentPage: currentState.currentPage,
            ));

        }else {
            emit(JobLoaded(
              jobs: [...currentState.jobs, ...newJobs],
              hasReachedMax: false, currentPage: nextPage,
            ));
          }
        }catch(e){
          emit(JobError(e.toString()));
        }
      }
    }


  }
}
