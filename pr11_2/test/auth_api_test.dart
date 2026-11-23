import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pr11_2/core/network/dio_client.dart';
import 'package:pr11_2/core/storage/secure_key_value_store.dart';
import 'package:pr11_2/core/storage/token_storage.dart';
import 'package:pr11_2/features/auth/data/auth_api.dart';
import 'package:pr11_2/features/auth/data/local_mock_auth_server.dart';
import 'package:pr11_2/features/auth/models/auth_tokens.dart';
import 'package:pr11_2/features/auth/providers/auth_controller.dart';

void main() {
  group('JWT authentication API', () {
    test('registers an account and returns a signed JWT pair', () async {
      final harness = _Harness();
      addTearDown(harness.dispose);

      final session = await harness.api.register(
        name: 'Test Student',
        email: 'test.student@example.com',
        password: 'Password123',
      );
      await harness.tokens.save(session.tokens, remember: true);
      final profile = await harness.api.getProfile();

      expect(session.tokens.accessToken.split('.'), hasLength(3));
      expect(session.tokens.refreshToken.split('.'), hasLength(3));
      expect(profile.name, 'Test Student');
      expect(profile.email, 'test.student@example.com');
    });

    test('rejects an incorrect login with a readable error', () async {
      final harness = _Harness();
      addTearDown(harness.dispose);

      await expectLater(
        harness.api.login('demo@pr11.local', 'incorrect'),
        throwsA(
          isA<DioException>().having(
            (error) => error.message,
            'message',
            contains('Неправильний email або пароль'),
          ),
        ),
      );
    });

    test(
      'refreshes a token after 401 and retries the protected request',
      () async {
        final harness = _Harness();
        addTearDown(harness.dispose);
        final session = await harness.api.login(
          'demo@pr11.local',
          'Flutter123',
        );
        await harness.tokens.save(session.tokens, remember: true);
        harness.server.rejectNextProfileRequest();

        final profile = await harness.api.getProfile();
        final refreshed = await harness.tokens.readTokens();

        expect(profile.email, 'demo@pr11.local');
        expect(harness.server.refreshCount, 1);
        expect(harness.server.profileRequestCount, 2);
        expect(refreshed, isA<AuthTokens>());
        expect(refreshed!.accessToken, isNot(session.tokens.accessToken));
        expect(refreshed.refreshToken, isNot(session.tokens.refreshToken));
      },
    );

    test('restores a remembered session from secure storage', () async {
      final harness = _Harness();
      addTearDown(harness.dispose);
      final session = await harness.api.login('demo@pr11.local', 'Flutter123');
      await harness.tokens.save(session.tokens, remember: true);

      final restoredStorage = TokenStorage(harness.secureStore);
      final restoredServer = LocalMockAuthServer(storage: harness.secureStore);
      final restoredApi = AuthApi(
        createAuthDio(
          tokenStorage: restoredStorage,
          mockServer: restoredServer,
          enableLogging: false,
        ),
        restoredServer,
      );
      final profile = await restoredApi.getProfile();

      expect(profile.name, 'Демо користувач');
      expect(restoredStorage.remembersSession, isTrue);
    });

    test(
      'updates profile and changes password through protected routes',
      () async {
        final harness = _Harness();
        addTearDown(harness.dispose);
        final session = await harness.api.login(
          'demo@pr11.local',
          'Flutter123',
        );
        await harness.tokens.save(session.tokens, remember: true);

        final profile = await harness.api.updateProfile(
          name: 'Updated Student',
          email: 'updated@example.com',
        );
        await harness.api.changePassword(
          currentPassword: 'Flutter123',
          newPassword: 'Changed123',
        );
        final nextSession = await harness.api.login(
          'updated@example.com',
          'Changed123',
        );

        expect(profile.name, 'Updated Student');
        expect(nextSession.user.email, 'updated@example.com');
      },
    );

    test(
      'maps 404 and 500 responses to readable DioException messages',
      () async {
        final harness = _Harness();
        addTearDown(harness.dispose);

        await expectLater(
          harness.api.dioForDiagnostics.get<dynamic>('debug/not-found'),
          throwsA(
            isA<DioException>().having(
              (error) => error.message,
              'message',
              contains('не знайдено'),
            ),
          ),
        );
        await expectLater(
          harness.api.dioForDiagnostics.get<dynamic>('debug/server-error'),
          throwsA(
            isA<DioException>().having(
              (error) => error.message,
              'message',
              contains('Демонстраційна помилка сервера'),
            ),
          ),
        );
      },
    );

    test('logs out after the configured idle period', () async {
      final harness = _Harness();
      final controller = AuthController(
        api: harness.api,
        tokenStorage: harness.tokens,
        inactivityLimit: const Duration(milliseconds: 60),
      );
      addTearDown(controller.dispose);
      addTearDown(harness.dispose);
      await controller.initialize();

      final signedIn = await controller.login(
        email: 'demo@pr11.local',
        password: 'Flutter123',
        rememberMe: true,
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(signedIn, isTrue);
      expect(controller.status, AuthStatus.signedOut);
      expect(await harness.tokens.readTokens(), isNull);
    });
  });
}

class _Harness {
  final SecureKeyValueStore secureStore = MemorySecureKeyValueStore();
  late final TokenStorage tokens = TokenStorage(secureStore);
  late final LocalMockAuthServer server = LocalMockAuthServer(
    storage: secureStore,
  );
  late final Dio dio = createAuthDio(
    tokenStorage: tokens,
    mockServer: server,
    enableLogging: false,
  );
  late final AuthApi api = AuthApi(dio, server);

  void dispose() => dio.close(force: true);
}
