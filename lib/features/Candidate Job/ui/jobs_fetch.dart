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
            .add(FetchJobs(isRecommended: widget.isRecommended,search: value));
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
          return  Center(child:LoadingAnimationWidget.hexagonDots(color: AppColors.lightPrimary, size: 20));
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
        if(state is JobSuccess){
          SnackBarUtils.showGreenSnackBar(state.message, context);
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
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section with company logo and save button
        Stack(
          children: [
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenSize.width * 0.025,
                  horizontal: screenSize.width * 0.03,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Company Logo
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: job.companyDetails.logo.url.isNotEmpty
                            ? Image.network(
                          job.companyDetails.logo.url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Center(child: Icon(Icons.business, size: 30)),
                        )
                            : Center(child: Icon(Icons.business, size: 30)),
                      ),
                    ),
                    SizedBox(width: 12),
                    // Job title and company name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6),
                          Text(
                            job.companyDetails.companyName.isNotEmpty
                                ? job.companyDetails.companyName
                                : job.overview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                              fontSize: screenSize.width * 0.035,
                            ),
                          ),
                          SizedBox(height: 6),
                          // Status chip
                          _buildStatusChip(context, job.status, screenSize),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Save/Unsave button
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    job.isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: job.isSaved ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                  onPressed: () {

                    context.read<CandidateJobBloc>().add(
                      ToggleSavedJobsEvent( jobId: job.id,),
                    );

                  },
                ),
              ),
            ),
          ],
        ),

        // Job details section
        Padding(
          padding: EdgeInsets.all(screenSize.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job info pills in a scrollable row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildInfoPill(
                      context,
                      Icons.location_on,
                      '${job.location.city}, ${job.location.state}',
                    ),
                    SizedBox(width: 8),
                    _buildInfoPill(
                      context,
                      Icons.work,
                      job.employmentType,
                    ),
                    SizedBox(width: 8),
                    _buildInfoPill(
                      context,
                      Icons.trending_up,
                      job.experienceLevel,
                    ),
                    if (job.companyDetails.industryType.isNotEmpty) ...[
                      SizedBox(width: 8),
                      _buildInfoPill(
                        context,
                        Icons.category,
                        job.companyDetails.industryType,
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: screenSize.height * 0.02),

              // Salary and deadline info
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.currency_rupee,
                              size: 18,
                              color: Theme.of(context).primaryColor,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Salary',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: screenSize.width * 0.035,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${job.salary.currency} ${job.salary.min}-${job.salary.max}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.timer,
                              size: 18,
                              color: Colors.red[300],
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Deadline',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: screenSize.width * 0.035,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          _formatDate(job.deadline),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.red[300],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
                    .take(2)
                    .map((resp) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 14,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          resp,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: screenSize.width * 0.035,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
                    .toList(),
              ),

              SizedBox(height: screenSize.height * 0.02),

              // Required Skills
              Text(
                'Required Skills:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: job.skills
                    .take(3)
                    .map((skill) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: screenSize.width * 0.035,
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CandidateJobDetails(job: job, isAlreadyApplied: false,),
                          ),
                        );
                      },
                      icon: Icon(Icons.description_outlined),
                      label: Text('View Details',style: Theme.of(context).textTheme.bodyMedium?.copyWith(color :
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white:Colors.black),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkPrimary.withOpacity(0.1)
                            : AppColors.lightDisabled,
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
                      icon: Icon(Icons.people, color: AppColors.lightDivider),
                      label: Text('Apply Now'),
                      style: ElevatedButton.styleFrom(
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

// Updated info pill with improved styling
Widget _buildInfoPill(BuildContext context, IconData icon, String text) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Theme.of(context).primaryColor.withOpacity(0.2),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).primaryColor),
        SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Theme.of(context).primaryColor.withOpacity(0.8),
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}

// Updated status chip with improved styling
Widget _buildStatusChip(BuildContext context, String status, Size screenSize) {
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

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: chipColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: chipColor.withOpacity(0.3)),
    ),
    child: Text(
      status,
      style: TextStyle(
        color: chipColor,
        fontWeight: FontWeight.w500,
        fontSize: screenSize.width * 0.035,
      ),
    ),
  );
}


String _formatDate(String dateString) {
  final date = DateTime.parse(dateString);
  return '${date.day}/${date.month}/${date.year}';
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