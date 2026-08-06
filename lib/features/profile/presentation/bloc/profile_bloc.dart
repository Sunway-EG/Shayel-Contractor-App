import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:contractor_app/core/entities/user_profile.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      // TODO: Implement actual profile loading.
      emit(const ProfileLoadSuccess(userProfile: UserProfile.empty));
    } catch (_) {
      emit(const ProfileLoadFailure());
    }
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    // TODO: Implement profile update payload handling.
    emit(state);
  }
}
