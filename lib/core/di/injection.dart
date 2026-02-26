import 'package:get_it/get_it.dart';
import 'package:passion_tree_frontend/core/services/upload_service.dart';
import 'package:passion_tree_frontend/features/reflection_tree/data/datasources/album_data_source.dart';
import 'package:passion_tree_frontend/features/reflection_tree/data/repositories/album_repository.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/repositories/i_album_repository.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/usecases/album_usecases.dart';
import 'package:passion_tree_frontend/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:passion_tree_frontend/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:passion_tree_frontend/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/login_with_credentials_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/login_with_google_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/login_with_discord_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/register_user_usecase.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {

  // Auth Data Sources
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  // Auth Repository
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  // Auth Use Cases
  getIt.registerFactory<LoginWithCredentialsUseCase>(
    () => LoginWithCredentialsUseCase(getIt<IAuthRepository>()),
  );
  getIt.registerFactory<LoginWithGoogleUseCase>(
    () => LoginWithGoogleUseCase(getIt<IAuthRepository>()),
  );
  getIt.registerFactory<LoginWithDiscordUseCase>(
    () => LoginWithDiscordUseCase(getIt<IAuthRepository>()),
  );
  getIt.registerFactory<RegisterUserUseCase>(
    () => RegisterUserUseCase(getIt<IAuthRepository>()),
  );

  // Upload Service
  getIt.registerLazySingleton<UploadApiService>(
    () => UploadApiService(
      authLocalDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  // Album Data Source and Repository
  getIt.registerLazySingleton<AlbumDataSource>(
    () => AlbumDataSource(),
  );
  getIt.registerLazySingleton<IAlbumRepository>(
    () => AlbumRepository(
      dataSource: getIt<AlbumDataSource>(),
      authLocalDataSource: getIt<AuthLocalDataSource>(),
      uploadService: getIt<UploadApiService>(),
    ),
  );

  getIt.registerFactory<GetAlbumsByUserIdUseCase>(
    () => GetAlbumsByUserIdUseCase(getIt<IAlbumRepository>()),
  );

  getIt.registerFactory<GetAlbumByIdUseCase>(
    () => GetAlbumByIdUseCase(getIt<IAlbumRepository>()),
  );

  getIt.registerFactory<CreateAlbumUseCase>(
    () => CreateAlbumUseCase(getIt<IAlbumRepository>()),
  );

  getIt.registerFactory<UpdateAlbumUseCase>(
    () => UpdateAlbumUseCase(getIt<IAlbumRepository>()),
  );

  getIt.registerFactory<DeleteAlbumUseCase>(
    () => DeleteAlbumUseCase(getIt<IAlbumRepository>()),
  );
}

Future<void> resetDependencies() async {
  await getIt.reset();
}
