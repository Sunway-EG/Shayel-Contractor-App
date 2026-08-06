part of 'profile_bloc.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoadSuccess extends ProfileState {
  const ProfileLoadSuccess({required this.userProfile});

  final UserProfile userProfile;
}

class ProfileLoadFailure extends ProfileState {
  const ProfileLoadFailure();
}
