part of 'job_bloc.dart';

@immutable
sealed class JobEvent {}

class FetchJobs extends JobEvent{}
class LoadMoreJobs extends JobEvent{}
