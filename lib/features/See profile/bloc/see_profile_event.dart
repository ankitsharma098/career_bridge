part of 'see_profile_bloc.dart';

@immutable
sealed class SeeProfileEvent extends Equatable {

  const SeeProfileEvent();

  @override
  List<Object?> get props=>[];
}

class FetchUserProfile extends SeeProfileEvent{
  final String userId;
  final String userType;

  FetchUserProfile({required this.userId, required this.userType});

  @override
  // TODO: implement props
  List<Object?> get props => [userId,userType];

}
