import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:quote/core/network/dio_client.dart';
import 'package:quote/core/network/network_client.dart';
import 'package:quote/core/storage/local_storage.dart';
import 'package:quote/core/storage/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/quotes/data/datasources/quotes_remote_datasource.dart';
import '../../features/quotes/data/datasources/quotes_local_datasource.dart';
import '../../features/quotes/data/repositories/quotes_repository_impl.dart';
import '../../features/quotes/domain/repositories/quotes_repository.dart';
import '../../features/quotes/domain/usecases/get_random_quote.dart';
import '../../features/quotes/domain/usecases/save_favorite_quote.dart';
import '../../features/quotes/domain/usecases/get_favorite_quotes.dart';
import '../../features/quotes/domain/usecases/remove_favorite_quote.dart';
import '../../features/quotes/presentation/bloc/quotes_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

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
    () => QuotesRemoteDataSourceImpl(getIt<NetworkClient>()),
  );
  getIt.registerLazySingleton<QuotesLocalDataSource>(
    () => QuotesLocalDataSourceImpl(getIt<StorageService>()),
  );

  // Repository
  getIt.registerLazySingleton<QuotesRepository>(
    () => QuotesRepositoryImpl(
      remoteDataSource: getIt<QuotesRemoteDataSource>(),
      localDataSource: getIt<QuotesLocalDataSource>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetRandomQuote(getIt<QuotesRepository>()));
  getIt.registerLazySingleton(() => SaveFavoriteQuote(getIt<QuotesRepository>()));
  getIt.registerLazySingleton(() => GetFavoriteQuotes(getIt<QuotesRepository>()));
  getIt.registerLazySingleton(() => RemoveFavoriteQuote(getIt<QuotesRepository>()));

  // BLoC
  getIt.registerFactory(
    () => QuotesBloc(
      getRandomQuote: getIt<GetRandomQuote>(),
      saveFavoriteQuote: getIt<SaveFavoriteQuote>(),
      getFavoriteQuotes: getIt<GetFavoriteQuotes>(),
      removeFavoriteQuote: getIt<RemoveFavoriteQuote>(),
    ),
  );
}

