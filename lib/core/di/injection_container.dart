import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:quote/features/quotes/domain/usecases/add_quote_to_collection.dart';
import 'package:quote/features/quotes/domain/usecases/create_collection.dart';
import 'package:quote/features/quotes/domain/usecases/delete_collection.dart';
import 'package:quote/features/quotes/domain/usecases/get_authors.dart';
import 'package:quote/features/quotes/domain/usecases/get_categories.dart';
import 'package:quote/features/quotes/domain/usecases/get_collection_quotes.dart';
import 'package:quote/features/quotes/domain/usecases/get_collections.dart';
import 'package:quote/features/quotes/domain/usecases/get_quotes.dart';
import 'package:quote/features/quotes/domain/usecases/is_quote_in_collection.dart';
import 'package:quote/features/quotes/domain/usecases/like_quote.dart';
import 'package:quote/features/quotes/domain/usecases/remove_quote_from_collection.dart';
import 'package:quote/features/quotes/domain/usecases/search_quotes.dart';
import 'package:quote/features/quotes/domain/usecases/unlike_quote.dart';
import 'package:quote/features/quotes/domain/usecases/update_collection.dart';
import 'package:quote/features/quotes/presentation/bloc/browse_quotes_bloc.dart';
import 'package:quote/features/quotes/presentation/bloc/collections_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quote/core/network/dio_client.dart';
import 'package:quote/core/network/network_client.dart';
import 'package:quote/core/storage/local_storage.dart';
import 'package:quote/core/storage/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/quotes/data/datasources/quotes_remote_datasource.dart';
import '../../features/quotes/data/datasources/quotes_local_datasource.dart';
import '../../features/quotes/data/datasources/favorites_remote_datasource.dart';
import '../../features/quotes/data/datasources/collections_remote_datasource.dart';
import '../../features/quotes/data/datasources/likes_remote_datasource.dart';
import '../../features/quotes/data/repositories/quotes_repository_impl.dart';
import '../../features/quotes/domain/repositories/quotes_repository.dart';
import '../../features/quotes/domain/usecases/get_random_quote.dart';
import '../../features/quotes/domain/usecases/get_daily_quote.dart';
import '../../features/quotes/domain/usecases/save_favorite_quote.dart';
import '../../features/quotes/domain/usecases/get_favorite_quotes.dart';
import '../../features/quotes/domain/usecases/remove_favorite_quote.dart';
import '../services/notification_service.dart';
import '../services/widget_service.dart';
import '../../features/quotes/presentation/bloc/quotes_bloc.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_up.dart';
import '../../features/auth/domain/usecases/sign_in.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/reset_password.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/update_profile.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../config/supabase_config.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Supabase Client
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Network
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<DioClient>(() => DioClient(getIt()));
  getIt.registerLazySingleton<NetworkClient>(
    () => NetworkClientImpl(getIt<DioClient>()),
  );

  // Storage
  getIt.registerLazySingleton<StorageService>(
    () => StorageServiceImpl(getIt<SharedPreferences>()),
  );

  // Data sources
  getIt.registerLazySingleton<QuotesRemoteDataSource>(
    () => QuotesRemoteDataSourceImpl(
      getIt<SupabaseClient>(),
      getIt<NetworkClient>(),
    ),
  );
  getIt.registerLazySingleton<QuotesLocalDataSource>(
    () => QuotesLocalDataSourceImpl(getIt<StorageService>()),
  );
  getIt.registerLazySingleton<FavoritesRemoteDataSource>(
    () => FavoritesRemoteDataSourceImpl(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<CollectionsRemoteDataSource>(
    () => CollectionsRemoteDataSourceImpl(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<LikesRemoteDataSource>(
    () => LikesRemoteDataSourceImpl(getIt<SupabaseClient>()),
  );

  // Repository
  getIt.registerLazySingleton<QuotesRepository>(
    () => QuotesRepositoryImpl(
      remoteDataSource: getIt<QuotesRemoteDataSource>(),
      localDataSource: getIt<QuotesLocalDataSource>(),
      favoritesRemoteDataSource: getIt<FavoritesRemoteDataSource>(),
      collectionsRemoteDataSource: getIt<CollectionsRemoteDataSource>(),
      likesRemoteDataSource: getIt<LikesRemoteDataSource>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetRandomQuote(getIt<QuotesRepository>()));
  getIt.registerLazySingleton(() => GetDailyQuote(getIt<QuotesRepository>()));
  getIt.registerLazySingleton(
      () => SaveFavoriteQuote(getIt<QuotesRepository>()));
  getIt.registerLazySingleton(
      () => GetFavoriteQuotes(getIt<QuotesRepository>()));
  getIt.registerLazySingleton(
      () => RemoveFavoriteQuote(getIt<QuotesRepository>()));
  getIt.registerLazySingleton(() => GetQuotes(getIt<QuotesRepository>()));
  getIt.registerLazySingleton(() => GetCategories(getIt<QuotesRepository>()));
  getIt.registerLazySingleton(() => SearchQuotes(getIt<QuotesRepository>()));
  getIt.registerLazySingleton(() => GetAuthors(getIt<QuotesRepository>()));
  getIt.registerLazySingleton(() => GetCollections(getIt<QuotesRepository>()));
  getIt
      .registerLazySingleton(() => CreateCollection(getIt<QuotesRepository>()));
  getIt
      .registerLazySingleton(() => UpdateCollection(getIt<QuotesRepository>()));
  getIt
      .registerLazySingleton(() => DeleteCollection(getIt<QuotesRepository>()));
  getIt.registerLazySingleton(
      () => GetCollectionQuotes(getIt<QuotesRepository>()));
  getIt.registerLazySingleton(
      () => AddQuoteToCollection(getIt<QuotesRepository>()));
  getIt.registerLazySingleton(
      () => RemoveQuoteFromCollection(getIt<QuotesRepository>()));
  getIt.registerLazySingleton(
      () => IsQuoteInCollection(getIt<QuotesRepository>()));
  getIt.registerLazySingleton(() => LikeQuote(getIt<QuotesRepository>()));
  getIt.registerLazySingleton(() => UnlikeQuote(getIt<QuotesRepository>()));

  // BLoC
  getIt.registerFactory(
    () => QuotesBloc(
      getRandomQuote: getIt<GetRandomQuote>(),
      getDailyQuote: getIt<GetDailyQuote>(),
      saveFavoriteQuote: getIt<SaveFavoriteQuote>(),
      getFavoriteQuotes: getIt<GetFavoriteQuotes>(),
      removeFavoriteQuote: getIt<RemoveFavoriteQuote>(),
      likeQuote: getIt<LikeQuote>(),
      unlikeQuote: getIt<UnlikeQuote>(),
      repository: getIt<QuotesRepository>(),
    ),
  );
  getIt.registerFactory(
    () => BrowseQuotesBloc(
      getQuotes: getIt<GetQuotes>(),
      getCategories: getIt<GetCategories>(),
      searchQuotes: getIt<SearchQuotes>(),
      getAuthors: getIt<GetAuthors>(),
    ),
  );
  getIt.registerFactory(
    () => CollectionsBloc(
      getCollections: getIt<GetCollections>(),
      createCollection: getIt<CreateCollection>(),
      updateCollection: getIt<UpdateCollection>(),
      deleteCollection: getIt<DeleteCollection>(),
      getCollectionQuotes: getIt<GetCollectionQuotes>(),
      addQuoteToCollection: getIt<AddQuoteToCollection>(),
      removeQuoteFromCollection: getIt<RemoveQuoteFromCollection>(),
      isQuoteInCollection: getIt<IsQuoteInCollection>(),
    ),
  );

  // Auth Data Source
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<SupabaseClient>()),
  );

  // Auth Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );

  // Auth Use Cases
  getIt.registerLazySingleton(() => SignUp(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SignIn(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SignOut(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => ResetPassword(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => GetCurrentUser(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => UpdateProfile(getIt<AuthRepository>()));

  // Auth BLoC
  getIt.registerFactory(
    () => AuthBloc(
      signUp: getIt<SignUp>(),
      signIn: getIt<SignIn>(),
      signOut: getIt<SignOut>(),
      resetPassword: getIt<ResetPassword>(),
      getCurrentUser: getIt<GetCurrentUser>(),
      updateProfile: getIt<UpdateProfile>(),
    ),
  );

  // Services
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(storageService: getIt<StorageService>()),
  );
  getIt.registerLazySingleton<WidgetService>(
    () => WidgetService(
      quotesRepository: getIt<QuotesRepository>(),
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  // Settings
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(supabaseClient: getIt<SupabaseClient>()),
  );
  getIt.registerFactory<SettingsBloc>(
    () => SettingsBloc(
      repository: getIt<SettingsRepository>(),
      storageService: getIt<StorageService>(),
    ),
  );
}
