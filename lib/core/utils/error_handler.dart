import '../constants/app_strings.dart';
import '../errors/failures.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is Failure) {
      return _getFailureMessage(error);
    }

    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('socket')) {
      return AppStrings.errorNetwork;
    }

    // Authentication errors
    if (errorString.contains('invalid login') ||
        errorString.contains('invalid credentials') ||
        errorString.contains('wrong password')) {
      return AppStrings.errorInvalidCredentials;
    }

    if (errorString.contains('email already registered') ||
        errorString.contains('user already registered') ||
        errorString.contains('already exists')) {
      return AppStrings.errorEmailAlreadyExists;
    }

    if (errorString.contains('user not found') ||
        errorString.contains('no user found')) {
      return AppStrings.errorUserNotFound;
    }

    if (errorString.contains('password') && errorString.contains('weak')) {
      return AppStrings.errorWeakPassword;
    }

    if (errorString.contains('too many requests') ||
        errorString.contains('rate limit')) {
      return AppStrings.errorTooManyRequests;
    }

    // Server errors
    if (errorString.contains('server') ||
        errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503')) {
      return AppStrings.errorServer;
    }

    // Default error
    return AppStrings.errorGeneric;
  }

  static String _getFailureMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return AppStrings.errorNetwork;
    } else if (failure is ServerFailure) {
      final message = failure.message.toLowerCase();
      
      if (message.contains('invalid') || message.contains('wrong')) {
        return AppStrings.errorInvalidCredentials;
      }
      if (message.contains('already exists') || message.contains('registered')) {
        return AppStrings.errorEmailAlreadyExists;
      }
      if (message.contains('not found')) {
        return AppStrings.errorUserNotFound;
      }
      
      return AppStrings.errorServer;
    } else if (failure is CacheFailure) {
      return AppStrings.errorFailedToLoad;
    }

    return AppStrings.errorGeneric;
  }
}

