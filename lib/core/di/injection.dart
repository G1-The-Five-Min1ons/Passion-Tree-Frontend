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

  // Upload Service
  getIt.registerLazySingleton<UploadApiService>(
    () => UploadApiService(),
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
