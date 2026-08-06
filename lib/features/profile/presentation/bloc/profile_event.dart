part of 'profile_bloc.dart';

abstract class ProfileEvent {
  const ProfileEvent();
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileUpdateRequested extends ProfileEvent {
  const ProfileUpdateRequested({this.biometricFingerprint});

  final bool? biometricFingerprint;
}
