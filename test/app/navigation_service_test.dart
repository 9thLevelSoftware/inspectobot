import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:inspectobot/app/navigation_service.dart';
import 'package:mocktail/mocktail.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group('GoRouterNavigationService', () {
    late MockGoRouter mockRouter;
    late GoRouterNavigationService service;

    setUp(() {
      mockRouter = MockGoRouter();
      service = GoRouterNavigationService(mockRouter);
    });

    test('go delegates to GoRouter.go', () {
      when(() => mockRouter.go('/dashboard', extra: null)).thenReturn(null);

      service.go('/dashboard');

      verify(() => mockRouter.go('/dashboard', extra: null)).called(1);
    });

    test('push delegates to GoRouter.push and returns Future<T?>', () async {
      when(() => mockRouter.push<String>('/inspections/new', extra: null))
          .thenAnswer((_) async => 'result');

      final result = await service.push<String>('/inspections/new');

      expect(result, 'result');
      verify(() => mockRouter.push<String>('/inspections/new', extra: null))
          .called(1);
    });

    test('pop delegates to GoRouter.pop', () {
      when(() => mockRouter.pop<String>('done')).thenReturn(null);

      service.pop<String>('done');

      verify(() => mockRouter.pop<String>('done')).called(1);
    });

    test('replace delegates to GoRouter.pushReplacement', () {
      when(
        () => mockRouter.pushReplacement('/auth/sign-in', extra: null),
      ).thenAnswer((_) async => null);

      service.replace('/auth/sign-in');

      verify(
        () => mockRouter.pushReplacement('/auth/sign-in', extra: null),
      ).called(1);
    });
  });
}
