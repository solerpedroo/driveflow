import 'package:supabase_flutter/supabase_flutter.dart';

import 'failure.dart';

/// Mapeia exceções de rede/dados para falhas seguras (sem vazar detalhes do servidor).
abstract final class RemoteDataSourceErrors {
  static Never rethrowPostgrest(PostgrestException error) {
    throw ServerFailure(cause: error);
  }

  static Never rethrowStorage(StorageException error) {
    throw ServerFailure(cause: error);
  }

  static Never rethrowFunction(FunctionException error) {
    throw ServerFailure(cause: error);
  }

  static Never rethrowUnknown(Object error) {
    throw ServerFailure(cause: error);
  }
}
