// lib/features/auth/presentation/viewmodels/auth_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_impl.dart';

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(ref.read(authRepositoryProvider));
});

class AuthState {
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthViewModel(this._repository) : super(AuthState());

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.signInWithGoogle();
      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signInWithFacebook() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.signInWithFacebook();
      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.signInWithEmail(email, password);
      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.signUpWithEmail(email, password);
      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.signOut();
      state = state.copyWith(isLoading: false, isAuthenticated: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}