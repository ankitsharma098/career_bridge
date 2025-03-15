import 'package:android/features/Candidate%20Job/Apply%20Job%20Bloc/apply_job_bloc.dart';
import 'package:android/features/Candidate%20Job/model/candidate_job_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../core/constants/colors.dart'; // Adjust import path
import '../../../core/utils/snackBarUtils.dart'; // Adjust import path
import '../Job Bloc/candidate_job_bloc.dart';
import 'apply_job.dart';
import 'full_job_detail.dart';


class CandidateTabJobs extends StatelessWidget {
  const CandidateTabJobs({super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [

          TabBar(
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            labelStyle:  TextStyle(fontWeight: FontWeight.bold),

            tabs:  [
              Tab(
                child: SizedBox(
                  width: screenSize.width*0.35,

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.analytics_outlined),
                      SizedBox(width: 8),
                      Text('Search Jobs',overflow: TextOverflow.ellipsis,),
                    ],
                  ),
                ),
              ),
              Tab(
                child: SizedBox(

                  width: screenSize.width*0.46,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.work_outline),
                      SizedBox(width: 8),
                      Text('Recommended Jobs',overflow: TextOverflow.ellipsis,),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Expanded(
            child: TabBarView(
              physics: const BouncingScrollPhysics(),
              children: [
                BlocProvider(
                  create: (context) => CandidateJobBloc(),
                  child: SearchOrAllJobs(isRecommended: false),
                ),
                BlocProvider(
                  create: (context) => CandidateJobBloc(),
                  child: RecommendationJobs(isRecommended: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SearchOrAllJobs extends StatefulWidget {
  final bool isRecommended;

  const SearchOrAllJobs({super.key, required this.isRecommended});

  @override
  State<SearchOrAllJobs> createState() => _SearchOrAllJobsState();
}

class _SearchOrAllJobsState extends State<SearchOrAllJobs> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<CandidateJobBloc>(context)
        .add(FetchJobs(isRecommended: widget.isRecommended));
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = context.read<CandidateJobBloc>().state;
    if (_isBottom && state is JobLoaded && !state.hasReachedMax) {
      BlocProvider.of<CandidateJobBloc>(context).add(LoadMoreJobs(isRecommended: widget.isRecommended));
    }
  }

  bool get _isBottom {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    return currentScroll >= (maxScroll * 0.8);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.all(screenSize.width * 0.04),
      child: Column(
        children: [
          _buildSearchBar(context, screenSize),
          SizedBox(height: screenSize.height * 0.02),
          Expanded(child: _buildJobsList(context, screenSize)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, Size screenSize) {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: 'Search jobs by title, skills, or location',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
      ),
      onSubmitted: (value) {

        BlocProvider.of<CandidateJobBloc>(context)
            .add(FetchJobs(isRecommended: widget.isRecommended));
      },
    );
  }

  Widget _buildJobsList(BuildContext context, Size screenSize) {
    return BlocConsumer<CandidateJobBloc, CandidateJobState>(
      listener: (context, state) {
        if (state is JobError) {
          SnackBarUtils.showRedSnackBar(state.error, context);
        }
      },
      builder: (context, state) {
        if (state is JobLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is JobLoaded) {
          if (state.jobs.isEmpty) {
            return _buildEmptyState(context,screenSize, 'No jobs found');
          }

          return RefreshIndicator(
            onRefresh: () async {
              BlocProvider.of<CandidateJobBloc>(context).add(FetchJobs(isRecommended: widget.isRecommended));
            },
            child: ListView.builder(
              controller: scrollController,
              itemCount: state.jobs.length + (state.hasReachedMax ? 0 : 1),
              itemBuilder: (context, index) {
                if (index >= state.jobs.length) {
                  return _buildLoadingIndicator(context);
                }
                final job = state.jobs[index];
                return _buildJobCard(job, screenSize, context);
              },
            ),
          );
        }

        return _buildErrorState(context,screenSize);
      },
    );
  }
}

class RecommendationJobs extends StatefulWidget {
  final bool isRecommended;

  const RecommendationJobs({super.key, required this.isRecommended});

  @override
  State<RecommendationJobs> createState() => _RecommendationJobsState();
}

class _RecommendationJobsState extends State<RecommendationJobs> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<CandidateJobBloc>(context)
        .add(FetchJobs(isRecommended: widget.isRecommended));
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = context.read<CandidateJobBloc>().state;
    if (_isBottom && state is JobLoaded && !state.hasReachedMax) {
      BlocProvider.of<CandidateJobBloc>(context)
          .add(LoadMoreJobs(isRecommended: widget.isRecommended));
    }
  }

  bool get _isBottom {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    return currentScroll >= (maxScroll * 0.8);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.all(screenSize.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended Jobs',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenSize.height * 0.02),
          Expanded(child: _buildJobsList(context, screenSize)),
        ],
      ),
    );
  }

  Widget _buildJobsList(BuildContext context, Size screenSize) {
    return BlocConsumer<CandidateJobBloc, CandidateJobState>(
      listener: (context, state) {
        if (state is JobError) {
          SnackBarUtils.showRedSnackBar(state.error, context);
        }
      },
      builder: (context, state) {
        if (state is JobLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is JobLoaded) {
          if (state.jobs.isEmpty) {
            return _buildEmptyState(context,screenSize, 'No recommended jobs yet');
          }

          return RefreshIndicator(
            onRefresh: () async {
              BlocProvider.of<CandidateJobBloc>(context)
                  .add(FetchJobs(isRecommended: widget.isRecommended));
            },
            child: ListView.builder(
              controller: scrollController,
              itemCount: state.jobs.length + (state.hasReachedMax ? 0 : 1),
              itemBuilder: (context, index) {
                if (index >= state.jobs.length) {
                  return _buildLoadingIndicator(context);
                }
                final job = state.jobs[index];
                return _buildJobCard(job, screenSize, context);
              },
            ),
          );
        }

        return _buildErrorState(context,screenSize);
      },
    );
  }
}


Widget _buildJobCard(CandidateJobModel job, Size screenSize, BuildContext context) {
  return Card(
    elevation: 2,
    margin: const EdgeInsets.only(bottom: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          margin: EdgeInsets.all(0),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.only( topLeft: Radius.circular(16),
            topRight: Radius.circular(16),)),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical :screenSize.width * 0.025,horizontal: screenSize.width*0.015),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        job.overview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                            fontSize: screenSize.width*0.04
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(context,job.status,screenSize),
              ],
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(vertical :screenSize.width * 0.04,horizontal: screenSize.width*0.015),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Key Information Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoPill(
                      context,
                      Icons.location_on,
                      '${job.location.city}, ${job.location.state}', // Updated location access
                    ),
                    SizedBox(width: 5,),
                    _buildInfoPill(
                      context,
                      Icons.work,
                      job.employmentType, // Changed from jobType
                    ),
                    SizedBox(width: 5,),
                    _buildInfoPill(
                      context,
                      Icons.trending_up,
                      job.experienceLevel,
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenSize.height * 0.02),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${job.salary.currency}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${job.salary.min}-${job.salary.max}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deadline:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.red[200],
                            fontSize: screenSize.width*0.04
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${_formatDate(job.deadline)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                            fontSize: screenSize.width*0.04
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: screenSize.height * 0.02),

              // Key Responsibilities
              Text(
                'Key Responsibilities:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenSize.height * 0.01),
              Column(
                children: job.responsibilities
                    .take(2) // Show only first 2 responsibilities
                    .map((resp) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Icon(Icons.check_circle,
                        size: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        resp,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: screenSize.width*0.035
                        ),
                      ),
                    ),
                  ],
                ))
                    .toList(),
              ),

              SizedBox(height: screenSize.height * 0.02),

              // Required Skills
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: job.skills
                    .take(3) // Show only first 3 skills
                    .map((skill) => Card(
                  margin: EdgeInsets.all(0),
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSecondary.withOpacity(0.1):AppColors.lightDeepPurple.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                  child: Padding(
                    padding:   EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                        skill,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: screenSize.width*0.035,
                        )
                    ),
                  ),
                ))
                    .toList(),
              ),

              SizedBox(height: screenSize.height * 0.02),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CandidateJobDetails(job: job ,)));
                      },
                      icon: Icon(Icons.description_outlined),
                      label: Text('View Full Details',style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        // color: Theme.of(context).brightness == Brightness.dark
                      ),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).brightness == Brightness.dark ?AppColors.darkPrimary.withOpacity(0.1):AppColors.lightDisabled,
                        // foregroundColor: AppColors.lightPrimary,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => ApplyJobBloc(),
                              child: ApplyJobScreen(jobId: job.id),
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.people,color: AppColors.lightDivider,),
                      label: Text('Apply here'),
                      style: ElevatedButton.styleFrom(
                        //backgroundColor: AppColors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildInfoPill(BuildContext context, IconData icon, String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.lightDeepPurple.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.lightPrimary),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.lightPrimary,
          ),
        ),
      ],
    ),
  );
}

String _formatDate(String dateString) {
  final date = DateTime.parse(dateString);
  return '${date.day}/${date.month}/${date.year}';
}

Widget _buildStatusChip(BuildContext context,String status,Size screenSize) {
  Color chipColor;
  switch (status.toLowerCase()) {
    case 'open':
      chipColor = Colors.green;
      break;
    case 'closed':
      chipColor = Colors.red;
      break;
    default:
      chipColor = Colors.grey;
  }

  return Card(
    elevation: 0,
    margin: EdgeInsets.all(0),
    color: chipColor.withOpacity(0.1),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
          status,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: chipColor,
              fontSize: screenSize.width*0.04
          )
      ),
    ),
  );
}

Widget _buildEmptyState(BuildContext context,Size screenSize, String message) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.work_off_outlined,
          size: screenSize.width * 0.15,
          color: Colors.grey,
        ),
        SizedBox(height: screenSize.height * 0.02),
        Text(
          message,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget _buildErrorState(BuildContext context,Size screenSize) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: screenSize.width * 0.15,
          color: Colors.grey,
        ),
        SizedBox(height: screenSize.height * 0.02),
        Text(
          'Something went wrong',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),
        Text(
          'Please try again later',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[500],
          ),
        ),
      ],
    ),
  );
}

Widget _buildLoadingIndicator(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Center(
      child: LoadingAnimationWidget.progressiveDots(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkPrimary
            : AppColors.lightPrimary,
        size: 20,
      ),
    ),
  );
}