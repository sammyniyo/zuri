import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

// ─── Auth State ───────────────────────────────────────────────────────────────
class AuthState {
  final ZuriUser? user;
  final bool isLoading;
  final String? error;
  final bool isGuest;
  final String? verificationId; // Holds Firebase phone verification ID

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isGuest = false,
    this.verificationId,
  });

  bool get isAuthenticated => user != null || isGuest;
  bool get isPro => user?.isProActive ?? false;

  AuthState copyWith({
    ZuriUser? user,
    bool? isLoading,
    String? error,
    bool? isGuest,
    String? verificationId,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isGuest: isGuest ?? this.isGuest,
      verificationId: verificationId ?? this.verificationId,
    );
  }
}

// ─── Auth Notifier ────────────────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  final _firestore = FirebaseFirestore.instance;

  AuthNotifier() : super(const AuthState()) {
    _listenToAuthChanges();
  }

  /// Keeps local state in sync with Firebase auth changes (login / logout / auto-login)
  void _listenToAuthChanges() {
    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null && !state.isGuest) {
        final doc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();
        ZuriUser user;
        if (doc.exists && doc.data() != null) {
          user = ZuriUser.fromMap(doc.data()!);
        } else {
          // First time — create Firestore user document
          user = ZuriUser(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'ZURI User',
            email: firebaseUser.email,
            phone: firebaseUser.phoneNumber,
            avatarUrl: firebaseUser.photoURL,
            isPro: false,
            loginMethod: firebaseUser.providerData.isNotEmpty
                ? firebaseUser.providerData.first.providerId
                : 'unknown',
          );
          await _firestore
              .collection('users')
              .doc(user.id)
              .set(user.toMap());
        }
        state = AuthState(user: user);
      }
    });
  }

  // ── Google Sign-In ─────────────────────────────────────────────────────────
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled
        state = state.copyWith(isLoading: false);
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      // _listenToAuthChanges() handles the state update
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Google sign-in failed. Please try again.',
      );
    }
  }

  // ── Phone Auth — Send OTP ──────────────────────────────────────────────────
  Future<bool> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    final completer = Completer<bool>();

    await _auth.verifyPhoneNumber(
      phoneNumber: '+250$phoneNumber',
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Android auto-verification (instant sign-in without OTP)
        try {
          await _auth.signInWithCredential(credential);
        } catch (_) {}
      },
      verificationFailed: (FirebaseAuthException e) {
        state = state.copyWith(
          isLoading: false,
          error: e.message ?? 'Verification failed. Check your number.',
        );
        if (!completer.isCompleted) completer.complete(false);
      },
      codeSent: (String verificationId, int? resendToken) {
        state = state.copyWith(
          isLoading: false,
          verificationId: verificationId,
        );
        if (!completer.isCompleted) completer.complete(true);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        state = state.copyWith(verificationId: verificationId);
      },
    );

    return completer.future;
  }

  // ── Phone Auth — Verify OTP ────────────────────────────────────────────────
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    if (state.verificationId == null) {
      state = state.copyWith(
        error: 'Session expired. Please request a new code.',
      );
      return false;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: state.verificationId!,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      // _listenToAuthChanges() handles the state update
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message ?? 'Invalid code. Please try again.',
      );
      return false;
    }
  }

  // ── Guest Mode ─────────────────────────────────────────────────────────────
  void continueAsGuest() {
    state = const AuthState(isGuest: true);
  }

  // ── Activate Pro after Flutterwave payment ─────────────────────────────────
  Future<void> activatePro() async {
    if (state.user == null) return;
    final upgraded = state.user!.copyWith(
      isPro: true,
      proExpiresAt: DateTime.now().add(const Duration(days: 30)),
    );
    state = state.copyWith(user: upgraded);
    try {
      await _firestore.collection('users').doc(upgraded.id).update({
        'isPro': true,
        'proExpiresAt': upgraded.proExpiresAt!.toIso8601String(),
      });
    } catch (_) {
      // Local state already updated — Firestore sync will retry on next launch
    }
  }

  // ── Increment review count ─────────────────────────────────────────────────
  Future<void> incrementReviewCount() async {
    if (state.user == null) return;
    final updated = state.user!.copyWith(
      reviewCount: state.user!.reviewCount + 1,
    );
    state = state.copyWith(user: updated);
    try {
      await _firestore
          .collection('users')
          .doc(updated.id)
          .update({'reviewCount': updated.reviewCount});
    } catch (_) {}
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    state = const AuthState();
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

final currentUserProvider = Provider<ZuriUser?>((ref) {
  return ref.watch(authProvider).user;
});

final isProProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isPro;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
