import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/repositories/auth/auth_repository.dart';
import '../data/repositories/auth/auth_repository_remote.dart';
import '../data/services/api_client.dart';
import '../data/services/token_storage_service.dart';
import 'env.dart';

/// Contenedor de dependencias: Services → Repositories. Los ViewModels se crean en cada pantalla.
List<SingleChildWidget> get providers => [
  Provider<TokenStorageService>(create: (_) => SecureTokenStorageService()),
  Provider<ApiClient>(
    create: (context) => ApiClient(baseUrl: Env.apiUrl, tokenProvider: context.read<TokenStorageService>().read),
  ),
  ChangeNotifierProvider<AuthRepository>(
    create: (context) =>
        AuthRepositoryRemote(apiClient: context.read(), tokenStorage: context.read())..restoreSession(),
  ),
];
