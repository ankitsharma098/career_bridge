import 'package:android/features/Candidate%20Job/model/candidate_job_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../core/constants/colors.dart'; // Adjust import path
import '../../../core/utils/snackBarUtils.dart'; // Adjust import path
import '../Job Bloc/candidate_job_bloc.dart';


class CandidateTabJobs extends StatelessWidget {
  const CandidateTabJobs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Jobs'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Search Jobs'),
              Tab(text: 'Recommended Jobs'),
            ],
          ),
        ),
        body: TabBarView(
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

// Shared Widgets
Widget _buildJobCard(CandidateJobModel job, Size screenSize, BuildContext context) {
  return Card(
    elevation: 2,
    margin: const EdgeInsets.only(bottom: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: EdgeInsets.all(screenSize.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: screenSize.height * 0.005),
                    Text(
                      job.companyDetails.companyName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(context,"openn", screenSize),
            ],
          ),
          SizedBox(height: screenSize.height * 0.015),
          Row(
            children: [
              _buildInfoPill(
                context,
                Icons.location_on,
                '${job.location.city}, ${job.location.country}',
              ),
              SizedBox(width: screenSize.width * 0.02),
              _buildInfoPill(context, Icons.work, job.employmentType),
            ],
          ),
          SizedBox(height: screenSize.height * 0.015),
          Text(
            '${job.salary.currency} ${job.salary.min} - ${job.salary.max}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: screenSize.height * 0.015),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: job.skills
                .take(3)
                .map(
                  (skill) => Chip(
                label: Text(skill),
                backgroundColor: AppColors.lightDeepPurple.withOpacity(0.1),
                labelStyle: Theme.of(context).textTheme.bodySmall,
              ),
            )
                .toList(),
          ),
          SizedBox(height: screenSize.height * 0.015),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => JobDetailsScreen(job: JobModel()),
                    //   ),
                    // );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightPrimary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        ],
      ),
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

Widget _buildStatusChip(BuildContext context,String status, Size screenSize) {
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

  return Chip(
    label: Text(status),
    backgroundColor: chipColor.withOpacity(0.1),
    labelStyle: Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: chipColor, fontSize: screenSize.width * 0.035),
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