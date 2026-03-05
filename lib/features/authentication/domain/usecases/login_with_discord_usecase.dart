import 'package:dartz/dartz.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:passion_tree_frontend/core/config/api_config.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';

/// Discord OAuth Configuration
/// Client ID is loaded from config.json or environment
class DiscordOAuthConfig {
  /// Discord Client ID (public - stored in app)
  static const String clientId = '1478856105281982544';

  /// Callback URL scheme - must match Android manifest and iOS Info.plist
  /// flutter_web_auth_2 listens for redirects with this scheme
  static const String callbackUrlScheme = 'passiontree';

  /// The redirect URI registered with Discord.
  /// Discord does NOT allow custom URL schemes (e.g. passiontree://),
  /// so we redirect to a backend endpoint which then redirects to the app.
  static String get redirectUri =>
      '${ApiConfig.backendBaseUrl}${ApiConfig.apiVersion}/auth/discord/native/callback';

  /// OAuth scopes requested from Discord
  static const String scopes = 'identify email';

  /// Generate Discord OAuth URL
  static String get authorizationUrl =>
      Uri.https('discord.com', '/oauth2/authorize', {
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'response_type': 'code',
        'scope': scopes,
      }).toString();
}

/// Use case for Discord OAuth login using flutter_web_auth_2
class LoginWithDiscordUseCase {
  final IAuthRepository _repository;

  LoginWithDiscordUseCase(this._repository);

  /// Initiates Discord OAuth flow by opening browser
  /// Returns the authorization code on success
  Future<Either<Failure, void>> initiateOAuth() async {
    try {
      // Open Discord OAuth page in browser and wait for callback
      final result = await FlutterWebAuth2.authenticate(
        url: DiscordOAuthConfig.authorizationUrl,
        callbackUrlScheme: DiscordOAuthConfig.callbackUrlScheme,
        options: const FlutterWebAuth2Options(
          preferEphemeral: true, // Use private/incognito browser session
          timeout: 120, // 2 minute timeout
        ),
      );

      // Extract authorization code from callback URL
      final uri = Uri.parse(result);
      final code = uri.queryParameters['code'];

      if (code == null || code.isEmpty) {
        final error = uri.queryParameters['error'];
        if (error == 'access_denied') {
          return const Left(
            CancellationFailure(message: 'User cancelled Discord login'),
          );
        }
        return const Left(
          AuthFailure(message: 'No authorization code received'),
        );
      }

      // Exchange code for token via backend
      return await authenticateWithCode(code);
    } catch (e) {
      final errorString = e.toString().toLowerCase();
      final originalErrorString = e.toString();

      if (errorString.contains('canceled') ||
          errorString.contains('cancelled') ||
          errorString.contains('user_cancelled')) {
        return const Left(
          CancellationFailure(message: 'User cancelled Discord login'),
        );
      } else if (errorString.contains('timeout')) {
        return const Left(AuthFailure(message: 'Discord login timed out'));
      }

      // Check for specific backend errors and clean them up for the UI
      if (errorString.contains('account with this email already exists')) {
        return const Left(
          AuthFailure(
            message:
                'An account with this email already exists. Please use web login to link accounts.',
          ),
        );
      }

      // Clean up generic AuthException prefix if present
      String cleanMessage = originalErrorString;
      if (cleanMessage.startsWith('AuthException')) {
        // Find the actual message after the colon
        final colonIndex = cleanMessage.indexOf(':');
        if (colonIndex != -1 && colonIndex < cleanMessage.length - 1) {
          cleanMessage = cleanMessage.substring(colonIndex + 1).trim();
        }
      }

      return Left(AuthFailure(message: 'Discord login failed: $cleanMessage'));
    }
  }

  /// Authenticates with Discord using authorization code
  /// Sends code to backend for token exchange
  Future<Either<Failure, void>> authenticateWithCode(String code) async {
    try {
      await _repository.signInWithDiscord(code);
      return const Right(null);
    } catch (e) {
      return Left(
        AuthFailure(message: 'Discord authentication failed: ${e.toString()}'),
      );
    }
  }

  /// Legacy method for deep link callback handling
  /// Kept for backward compatibility
  Future<Either<Failure, void>> call(String code) => authenticateWithCode(code);
}
