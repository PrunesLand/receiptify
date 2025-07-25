import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:receipt_app/core/index.dart';
import 'package:receipt_app/features/Onboarding/index.dart';
import 'package:receipt_app/features/PocketGroup/application/index.dart';

import '../features/Document/Index.dart';

final getIt = GetIt.instance;

final Completer<void> _firebaseReadyCompleter = Completer<void>();
Future<void> get firebaseReadyFuture => _firebaseReadyCompleter.future;

void signalFirebaseReady() {
  if (!_firebaseReadyCompleter.isCompleted) {
    _firebaseReadyCompleter.complete();
    print('ServiceLocator: Firebase signaled as ready.');
  }
}

void signalFirebaseFailed(Object error) {
  if (!_firebaseReadyCompleter.isCompleted) {
    _firebaseReadyCompleter.completeError(error);
    print('ServiceLocator: Firebase signaled as FAILED.');
  }
}

void setupServiceLocator() {
  getIt.registerSingleton<Future<void>>(firebaseReadyFuture, instanceName: 'firebaseReady');
  getIt.registerLazySingleton(() => DocumentBloc());

  getIt.registerLazySingleton(() => TokenStorageService());

  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio();

    dio.interceptors.add(AuthInterceptor(getIt<TokenStorageService>()));
    return dio;
  });

  getIt.registerLazySingleton(() => UserRepositoryService(getIt<Dio>()));

  getIt.registerLazySingleton(
    () => UserRepository(
      getIt<UserRepositoryService>(),
      getIt<TokenStorageService>(),
    ),
  );

  getIt.registerLazySingleton(() => DocumentRepositoryService(getIt<Dio>()));

  getIt.registerLazySingleton(
    () => DocumentRepository(getIt<DocumentRepositoryService>()),
  );

  getIt.registerLazySingleton(() => PocketBloc());
}
