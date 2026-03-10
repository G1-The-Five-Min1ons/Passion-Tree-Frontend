import 'package:get_it/get_it.dart';
import 'package:passion_tree_frontend/core/network/api_handler.dart';
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
import 'package:passion_tree_frontend/features/authentication/domain/usecases/verify_email_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/get_profile_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/select_role_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/get_user_role_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/forgot_password_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/mark_role_selected_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/save_user_role_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/reset_password_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/update_account_settings_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/domain/usecases/change_password_usecase.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/bloc/user_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/data/datasources/comment_remote_data_source.dart';
import 'package:passion_tree_frontend/features/learning_path/data/repositories/comment_repository_impl.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/repositories/comment_repository.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/comment/get_node_comments.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/comment/get_path_comments.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/comment/create_comment.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/comment/create_path_comment.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/comment/update_comment.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/comment/delete_comment.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/comment/add_comment_reaction.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/comment/comment_bloc.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // Core Network
  getIt.registerLazySingleton<ApiHandler>(() => ApiHandler());

  // Auth Data Sources
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiHandler: getIt<ApiHandler>()),
  );

  // Auth Repository
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
      apiHandler: getIt<ApiHandler>(),
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
  getIt.registerFactory<VerifyEmailUseCase>(
    () => VerifyEmailUseCase(getIt<IAuthRepository>()),
  );
  getIt.registerFactory<GetProfileUseCase>(
    () => GetProfileUseCase(getIt<IAuthRepository>()),
  );
  getIt.registerFactory<SelectRoleUseCase>(
    () => SelectRoleUseCase(getIt<IAuthRepository>()),
  );
  getIt.registerFactory<GetUserRoleUseCase>(
    () => GetUserRoleUseCase(getIt<IAuthRepository>()),
  );
  getIt.registerFactory<ForgotPasswordUseCase>(
    () => ForgotPasswordUseCase(getIt<IAuthRepository>()),
  );
  getIt.registerFactory<MarkRoleSelectedUseCase>(
    () => MarkRoleSelectedUseCase(getIt<IAuthRepository>()),
  );
  getIt.registerFactory<SaveUserRoleUseCase>(
    () => SaveUserRoleUseCase(getIt<IAuthRepository>()),
  );
  getIt.registerFactory<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(getIt<IAuthRepository>()),
  );
  getIt.registerFactory<UpdateAccountSettingsUseCase>(
    () => UpdateAccountSettingsUseCase(getIt<IAuthRepository>()),
  );
  getIt.registerFactory<ChangePasswordUseCase>(
    () => ChangePasswordUseCase(getIt<IAuthRepository>()),
  );

  // Auth Blocs
  getIt.registerFactory<UserBloc>(
    () => UserBloc(authRepository: getIt<IAuthRepository>()),
  );

  // Upload Service
  getIt.registerLazySingleton<UploadApiService>(
    () => UploadApiService(authLocalDataSource: getIt<AuthLocalDataSource>()),
  );

  // Album Data Source and Repository
  getIt.registerLazySingleton<AlbumDataSource>(() => AlbumDataSource());
  getIt.registerLazySingleton<IAlbumRepository>(
    () => AlbumRepository(
      dataSource: getIt<AlbumDataSource>(),
      authLocalDataSource: getIt<AuthLocalDataSource>(),
      uploadService: getIt<UploadApiService>(),
    ),
  );

  getIt.registerFactory<GetAlbumsByUserIdUseCase>(
    () => GetAlbumsByUserIdUseCase(
      getIt<IAlbumRepository>(),
      getIt<AuthLocalDataSource>(),
    ),
  );

  getIt.registerFactory<GetAlbumByIdUseCase>(
    () => GetAlbumByIdUseCase(getIt<IAlbumRepository>()),
  );

  getIt.registerFactory<CreateAlbumUseCase>(
    () => CreateAlbumUseCase(
      getIt<IAlbumRepository>(),
      getIt<AuthLocalDataSource>(),
    ),
  );

  getIt.registerFactory<UpdateAlbumUseCase>(
    () => UpdateAlbumUseCase(getIt<IAlbumRepository>()),
  );

  getIt.registerFactory<DeleteAlbumUseCase>(
    () => DeleteAlbumUseCase(getIt<IAlbumRepository>()),
  );

  getIt.registerFactory<CreateTreeUseCase>(
    () => CreateTreeUseCase(getIt<IAlbumRepository>()),
  );

  getIt.registerFactory<UpdateTreeUseCase>(
    () => UpdateTreeUseCase(getIt<IAlbumRepository>()),
  );

  getIt.registerFactory<DeleteTreeUseCase>(
    () => DeleteTreeUseCase(getIt<IAlbumRepository>()),
  );
  // Comment Feature
  getIt.registerLazySingleton<CommentRemoteDataSource>(
    () => CommentRemoteDataSource(),
  );

  getIt.registerLazySingleton<CommentRepository>(
    () => CommentRepositoryImpl(
      remoteDataSource: getIt<CommentRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<GetNodeComments>(
    () => GetNodeComments(getIt<CommentRepository>()),
  );
  getIt.registerFactory<GetPathComments>(
    () => GetPathComments(getIt<CommentRepository>()),
  );
  getIt.registerFactory<CreateComment>(
    () => CreateComment(getIt<CommentRepository>()),
  );
  getIt.registerFactory<CreatePathComment>(
    () => CreatePathComment(getIt<CommentRepository>()),
  );
  getIt.registerFactory<UpdateComment>(
    () => UpdateComment(getIt<CommentRepository>()),
  );
  getIt.registerFactory<DeleteComment>(
    () => DeleteComment(getIt<CommentRepository>()),
  );
  getIt.registerFactory<AddCommentReaction>(
    () => AddCommentReaction(getIt<CommentRepository>()),
  );

  getIt.registerFactory<CommentBloc>(
    () => CommentBloc(
      getNodeComments: getIt<GetNodeComments>(),
      getPathComments: getIt<GetPathComments>(),
      createComment: getIt<CreateComment>(),
      createPathComment: getIt<CreatePathComment>(),
      updateComment: getIt<UpdateComment>(),
      deleteComment: getIt<DeleteComment>(),
      addCommentReaction: getIt<AddCommentReaction>(),
    ),
  );
}

Future<void> resetDependencies() async {
  await getIt.reset();
}
