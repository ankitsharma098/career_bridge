import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/models/Job/job_model.dart';

part 'job_event.dart';
part 'job_state.dart';

class JobBloc extends Bloc<JobEvent, JobState> {
  JobBloc() : super(JobInitial()) {
    on<FetchJobs>(_onFetchJobs);
    on<LoadMoreJobs>(_onLoadMoreJobs);
  }

  Future<void> _onFetchJobs(FetchJobs event,Emitter<JobState> emit) async{


    try{

      emit(JobLoading());
      Map<String,dynamic> jobsData =
      {
        "jobs": [
          {
            "_id": "676983b4c954d6e29f1e25c0",
            "companyId": "674ed8709a77dd90938c97be",
            "employerId": "6758890472959274d2256fbd",
            "employerEmail": "ankit@gmail.com",
            "title": "Digital Marketing expert",
            "description": {
              "roleOverview": "Craft user-centered designs for digital platforms.",
              "responsibilities": [
                "Create wireframes, prototypes, and user flows",
                "Conduct user research and usability testing",
                "Collaborate with developers to ensure design implementation"
              ],
              "qualifications": {
                "education": "Bachelor's degree in Design, HCI, or related field",
                "experience": "2+ years in UI/UX design",
                "skills": [
                  "Figma",
                  "Adobe XD",
                  "User Research",
                  "Prototyping"
                ],
                "certifications": [
                  "Certified Usability Analyst",
                  "Google UX Design Certificate"
                ],
                "_id": "676983b4c954d6e29f1e25c2"
              },
              "benefits": [
                "Flexible work hours",
                "Learning and development programs",
                "Generous paid leave policy"
              ],
              "workEnvironment": {
                "location": "Hybrid (Remote and On-site)",
                "schedule": "Flexible with mandatory design sprints",
                "_id": "676983b4c954d6e29f1e25c3"
              },
              "companyOverview": "A global leader in creating impactful digital experiences.",
              "growthOpportunities": "Expand into product design or lead design teams",
              "salary": {
                "currency": "USD",
                "min": 45000,
                "max": 65000,
                "_id": "676983b4c954d6e29f1e25c4"
              },
              "applicationInstructions": "Submit your portfolio showcasing past UI/UX design projects.",
              "content": "Join a creative team redefining user experiences.",
              "_id": "676983b4c954d6e29f1e25c1"
            },
            "requirements": [
              "Strong design portfolio",
              "Knowledge of design systems and accessibility standards"
            ],
            "jobType": "Full-time",
            "jobLocation": "Remote",
            "jobLocationDetails": {
              "address": "101 Market Street",
              "city": "San Francisco",
              "state": "California",
              "country": "USA"
            },
            "employmentType": "Permanent",
            "experienceLevel": "Intermediate",
            "applicationProcess": {
              "steps": [
                "Submit portfolio and resume",
                "Participate in a design challenge",
                "Attend team interviews"
              ],
              "contactEmail": "designcareers@globalexperiences.com"
            },
            "deadline": "2024-12-31T23:59:59.000Z",
            "status": "Open",
            "applicants": [],
            "views": 0,
            "accessibilityFeatures": {
              "workplaceAccommodations": [
                "Wheelchair Accessible"
              ],
              "communicationSupport": "Text-based Communication",
              "disabilityFriendliness": "Fully Accessible"
            },
            "inclusivityStatement": "We value diversity and encourage applicants from all backgrounds.",
            "specialNeeds": {
              "personalAssistanceAvailable": true,
              "specialEquipmentProvided": false,
              "additionalSupportDetails": ""
            },
            "disabilityTypes": {
              "supportedDisabilities": [
                "Hearing Impairments",
                "Mental Health Conditions"
              ]
            },
            "inclusiveHiringPractices": {
              "blindRecruitment": false,
              "alternativeInterviewFormats": [
                "Written Interviews",
                "Alternative Communication Methods"
              ]
            },
            "createdAt": "2024-12-23T15:37:24.957Z",
            "updatedAt": "2024-12-23T15:37:24.957Z",
            "__v": 0
          },
          {
            "_id": "6769811bc954d6e29f1e24f6",
            "companyId": "674ed8709a77dd90938c97be",
            "employerId": "6758890472959274d2256fbd",
            "employerEmail": "ankit@gmail.com",
            "title": "Digital Market expert",
            "description": {
              "roleOverview": "Craft user-centered designs for digital platforms.",
              "responsibilities": [
                "Create wireframes, prototypes, and user flows",
                "Conduct user research and usability testing",
                "Collaborate with developers to ensure design implementation"
              ],
              "qualifications": {
                "education": "Bachelor's degree in Design, HCI, or related field",
                "experience": "2+ years in UI/UX design",
                "skills": [
                  "Figma",
                  "Adobe XD",
                  "User Research",
                  "Prototyping"
                ],
                "certifications": [
                  "Certified Usability Analyst",
                  "Google UX Design Certificate"
                ],
                "_id": "6769811bc954d6e29f1e24f8"
              },
              "benefits": [
                "Flexible work hours",
                "Learning and development programs",
                "Generous paid leave policy"
              ],
              "workEnvironment": {
                "location": "Hybrid (Remote and On-site)",
                "schedule": "Flexible with mandatory design sprints",
                "_id": "6769811bc954d6e29f1e24f9"
              },
              "companyOverview": "A global leader in creating impactful digital experiences.",
              "growthOpportunities": "Expand into product design or lead design teams",
              "salary": {
                "currency": "USD",
                "min": 45000,
                "max": 65000,
                "_id": "6769811bc954d6e29f1e24fa"
              },
              "applicationInstructions": "Submit your portfolio showcasing past UI/UX design projects.",
              "content": "Join a creative team redefining user experiences.",
              "_id": "6769811bc954d6e29f1e24f7"
            },
            "requirements": [
              "Strong design portfolio",
              "Knowledge of design systems and accessibility standards"
            ],
            "jobType": "Full-time",
            "jobLocation": "Remote",
            "jobLocationDetails": {
              "address": "101 Market Street",
              "city": "San Francisco",
              "state": "California",
              "country": "USA"
            },
            "employmentType": "Permanent",
            "experienceLevel": "Intermediate",
            "applicationProcess": {
              "steps": [
                "Submit portfolio and resume",
                "Participate in a design challenge",
                "Attend team interviews"
              ],
              "contactEmail": "designcareers@globalexperiences.com"
            },
            "deadline": "2024-12-31T23:59:59.000Z",
            "status": "Open",
            "applicants": [],
            "views": 0,
            "accessibilityFeatures": {
              "workplaceAccommodations": [
                "Wheelchair Accessible"
              ],
              "communicationSupport": "Text-based Communication",
              "disabilityFriendliness": "Fully Accessible"
            },
            "inclusivityStatement": "We value diversity and encourage applicants from all backgrounds.",
            "specialNeeds": {
              "personalAssistanceAvailable": true,
              "specialEquipmentProvided": false,
              "additionalSupportDetails": ""
            },
            "disabilityTypes": {
              "supportedDisabilities": [
                "Hearing Impairments",
                "Mental Health Conditions"
              ]
            },
            "inclusiveHiringPractices": {
              "blindRecruitment": false,
              "alternativeInterviewFormats": [
                "Written Interviews",
                "Alternative Communication Methods"
              ]
            },
            "createdAt": "2024-12-23T15:26:19.723Z",
            "updatedAt": "2024-12-23T15:26:19.723Z",
            "__v": 0
          },
        ],
        "totalJobs": 20,
        "currentPage": 1,
        "totalPages": 2
      };


      List jobs=jobsData['jobs'];
      List<JobModel> jobModel= jobs.map((job)=>JobModel.fromJson(job)).toList();

      emit(JobLoaded(jobModel, false, 1));


    }catch(e){
      emit(JobError(e.toString()));
    }


  }

  Future<void> _onLoadMoreJobs(LoadMoreJobs event,Emitter<JobState> emit) async {

    final currentState=state;
    if(currentState is JobLoaded){
      try{
        final nextPage = currentState.currentPage+1;
        //API caling new jobs
        Map<String,dynamic> jobs =
          {
            "jobs": [
              {
                "_id": "676983b4c954d6e29f1e25c0",
                "companyId": "674ed8709a77dd90938c97be",
                "employerId": "6758890472959274d2256fbd",
                "employerEmail": "ankit@gmail.com",
                "title": "Digital Marketing expert",
                "description": {
                  "roleOverview": "Craft user-centered designs for digital platforms.",
                  "responsibilities": [
                    "Create wireframes, prototypes, and user flows",
                    "Conduct user research and usability testing",
                    "Collaborate with developers to ensure design implementation"
                  ],
                  "qualifications": {
                    "education": "Bachelor's degree in Design, HCI, or related field",
                    "experience": "2+ years in UI/UX design",
                    "skills": [
                      "Figma",
                      "Adobe XD",
                      "User Research",
                      "Prototyping"
                    ],
                    "certifications": [
                      "Certified Usability Analyst",
                      "Google UX Design Certificate"
                    ],
                    "_id": "676983b4c954d6e29f1e25c2"
                  },
                  "benefits": [
                    "Flexible work hours",
                    "Learning and development programs",
                    "Generous paid leave policy"
                  ],
                  "workEnvironment": {
                    "location": "Hybrid (Remote and On-site)",
                    "schedule": "Flexible with mandatory design sprints",
                    "_id": "676983b4c954d6e29f1e25c3"
                  },
                  "companyOverview": "A global leader in creating impactful digital experiences.",
                  "growthOpportunities": "Expand into product design or lead design teams",
                  "salary": {
                    "currency": "USD",
                    "min": 45000,
                    "max": 65000,
                    "_id": "676983b4c954d6e29f1e25c4"
                  },
                  "applicationInstructions": "Submit your portfolio showcasing past UI/UX design projects.",
                  "content": "Join a creative team redefining user experiences.",
                  "_id": "676983b4c954d6e29f1e25c1"
                },
                "requirements": [
                  "Strong design portfolio",
                  "Knowledge of design systems and accessibility standards"
                ],
                "jobType": "Full-time",
                "jobLocation": "Remote",
                "jobLocationDetails": {
                  "address": "101 Market Street",
                  "city": "San Francisco",
                  "state": "California",
                  "country": "USA"
                },
                "employmentType": "Permanent",
                "experienceLevel": "Intermediate",
                "applicationProcess": {
                  "steps": [
                    "Submit portfolio and resume",
                    "Participate in a design challenge",
                    "Attend team interviews"
                  ],
                  "contactEmail": "designcareers@globalexperiences.com"
                },
                "deadline": "2024-12-31T23:59:59.000Z",
                "status": "Open",
                "applicants": [],
                "views": 0,
                "accessibilityFeatures": {
                  "workplaceAccommodations": [
                    "Wheelchair Accessible"
                  ],
                  "communicationSupport": "Text-based Communication",
                  "disabilityFriendliness": "Fully Accessible"
                },
                "inclusivityStatement": "We value diversity and encourage applicants from all backgrounds.",
                "specialNeeds": {
                  "personalAssistanceAvailable": true,
                  "specialEquipmentProvided": false,
                  "additionalSupportDetails": ""
                },
                "disabilityTypes": {
                  "supportedDisabilities": [
                    "Hearing Impairments",
                    "Mental Health Conditions"
                  ]
                },
                "inclusiveHiringPractices": {
                  "blindRecruitment": false,
                  "alternativeInterviewFormats": [
                    "Written Interviews",
                    "Alternative Communication Methods"
                  ]
                },
                "createdAt": "2024-12-23T15:37:24.957Z",
                "updatedAt": "2024-12-23T15:37:24.957Z",
                "__v": 0
              },
              {
                "_id": "6769811bc954d6e29f1e24f6",
                "companyId": "674ed8709a77dd90938c97be",
                "employerId": "6758890472959274d2256fbd",
                "employerEmail": "ankit@gmail.com",
                "title": "Digital Market expert",
                "description": {
                  "roleOverview": "Craft user-centered designs for digital platforms.",
                  "responsibilities": [
                    "Create wireframes, prototypes, and user flows",
                    "Conduct user research and usability testing",
                    "Collaborate with developers to ensure design implementation"
                  ],
                  "qualifications": {
                    "education": "Bachelor's degree in Design, HCI, or related field",
                    "experience": "2+ years in UI/UX design",
                    "skills": [
                      "Figma",
                      "Adobe XD",
                      "User Research",
                      "Prototyping"
                    ],
                    "certifications": [
                      "Certified Usability Analyst",
                      "Google UX Design Certificate"
                    ],
                    "_id": "6769811bc954d6e29f1e24f8"
                  },
                  "benefits": [
                    "Flexible work hours",
                    "Learning and development programs",
                    "Generous paid leave policy"
                  ],
                  "workEnvironment": {
                    "location": "Hybrid (Remote and On-site)",
                    "schedule": "Flexible with mandatory design sprints",
                    "_id": "6769811bc954d6e29f1e24f9"
                  },
                  "companyOverview": "A global leader in creating impactful digital experiences.",
                  "growthOpportunities": "Expand into product design or lead design teams",
                  "salary": {
                    "currency": "USD",
                    "min": 45000,
                    "max": 65000,
                    "_id": "6769811bc954d6e29f1e24fa"
                  },
                  "applicationInstructions": "Submit your portfolio showcasing past UI/UX design projects.",
                  "content": "Join a creative team redefining user experiences.",
                  "_id": "6769811bc954d6e29f1e24f7"
                },
                "requirements": [
                  "Strong design portfolio",
                  "Knowledge of design systems and accessibility standards"
                ],
                "jobType": "Full-time",
                "jobLocation": "Remote",
                "jobLocationDetails": {
                  "address": "101 Market Street",
                  "city": "San Francisco",
                  "state": "California",
                  "country": "USA"
                },
                "employmentType": "Permanent",
                "experienceLevel": "Intermediate",
                "applicationProcess": {
                  "steps": [
                    "Submit portfolio and resume",
                    "Participate in a design challenge",
                    "Attend team interviews"
                  ],
                  "contactEmail": "designcareers@globalexperiences.com"
                },
                "deadline": "2024-12-31T23:59:59.000Z",
                "status": "Open",
                "applicants": [],
                "views": 0,
                "accessibilityFeatures": {
                  "workplaceAccommodations": [
                    "Wheelchair Accessible"
                  ],
                  "communicationSupport": "Text-based Communication",
                  "disabilityFriendliness": "Fully Accessible"
                },
                "inclusivityStatement": "We value diversity and encourage applicants from all backgrounds.",
                "specialNeeds": {
                  "personalAssistanceAvailable": true,
                  "specialEquipmentProvided": false,
                  "additionalSupportDetails": ""
                },
                "disabilityTypes": {
                  "supportedDisabilities": [
                    "Hearing Impairments",
                    "Mental Health Conditions"
                  ]
                },
                "inclusiveHiringPractices": {
                  "blindRecruitment": false,
                  "alternativeInterviewFormats": [
                    "Written Interviews",
                    "Alternative Communication Methods"
                  ]
                },
                "createdAt": "2024-12-23T15:26:19.723Z",
                "updatedAt": "2024-12-23T15:26:19.723Z",
                "__v": 0
              },
            ],
            "totalJobs": 20,
            "currentPage": 1,
            "totalPages": 2
          };

        emit(JobLoaded(jobs['jobs'], true, nextPage));


      }catch(e){
        emit(JobError(e.toString()));

      }
    }


  }
}
