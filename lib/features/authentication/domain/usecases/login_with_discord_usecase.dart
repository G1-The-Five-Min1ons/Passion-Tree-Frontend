import 'package:dartz/dartz.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:passion_tree_frontend/core/error/failures.dart';
import 'package:passion_tree_frontend/core/error/failure_mapper.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';

class LoginWithDiscordUseCase {
  final IAuthRepository _repository;
  
  static const String _clientId = 'YOUR_DISCORD_CLIENT_ID';
  static const String _redirectUri = 'passiontree://auth/callback';
  static const String _scope = 'identify email connections guild.join';

  LoginWithDiscordUseCase(this._repository);

  Future<Either<Failure, void>> initiateOAuth() async {
    try {
      final url = Uri.parse(
        'https://discord.com/api/oauth2/authorize'
        '?client_id=$_clientId'
        '&redirect_uri=$_redirectUri'
        '&response_type=code'
        '&scope=$_scope',
      );

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        return right(null);
      } else {
        return left(const ServerFailure(message: 'Could not launch Discord authorization URL'));
      }
    } catch (e) {
      return left(FailureMapper.fromException(e));
    }
  }

  Future<Either<Failure, void>> authenticateWithCode(String code) async {
    if (code.isEmpty) {
      return left(const ValidationFailure(message: 'Discord authorization code is empty'));
    }

    try {
      await _repository.nativeDiscordSignIn(code);
      return right(null);
    } catch (e) {
      return left(FailureMapper.fromException(e));
    }
  }
}
