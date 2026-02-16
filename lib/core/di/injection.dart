import 'package:get_it/get_it.dart';
import 'package:passion_tree_frontend/features/reflection_tree/data/datasources/album_data_source.dart';
import 'package:passion_tree_frontend/features/reflection_tree/data/repositories/album_repository.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/repositories/i_album_repository.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/usecases/album_usecases.dart';
import 'package:passion_tree_frontend/features/authentication/data/services/token_storage_service.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  
  getIt.registerLazySingleton<TokenStorageService>(
    () => TokenStorageService(),
  );


  getIt.registerLazySingleton<AlbumDataSource>(
    () => AlbumDataSource(),
  );
  getIt.registerLazySingleton<IAlbumRepository>(
    () => AlbumRepository(
      dataSource: getIt<AlbumDataSource>(),
      tokenStorage: getIt<TokenStorageService>(),
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
