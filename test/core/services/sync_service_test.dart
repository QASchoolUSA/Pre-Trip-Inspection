import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pti_mobile_app/core/services/sync_service.dart';
import 'package:pti_mobile_app/core/services/api_service.dart';
import 'package:pti_mobile_app/core/services/auth_service.dart';
import 'package:pti_mobile_app/data/datasources/database_service.dart';
import 'package:pti_mobile_app/data/models/sync_models.dart';
import 'package:pti_mobile_app/data/models/inspection_models.dart';

// Mock classes for testing
class MockApiService extends Mock implements ApiService {}
class MockAuthService extends Mock implements AuthService {}
class MockDatabaseService extends Mock implements DatabaseService {}
void main() {
  group('SyncService Tests', () {
    late SyncService syncService;
    late MockApiService mockApiService;
    late MockDatabaseService mockDatabaseService;
    late MockConflictResolutionService mockConflictResolutionService;

    setUp(() {
      mockApiService = MockApiService();
      mockDatabaseService = MockDatabaseService();
      mockConflictResolutionService = MockConflictResolutionService();
      
      syncService = SyncService(
        apiService: mockApiService,
        databaseService: mockDatabaseService,
        conflictResolutionService: mockConflictResolutionService,
      );
    });

    group('Initialization', () {
      test('should initialize with correct dependencies', () {
        expect(syncService.apiService, equals(mockApiService));
        expect(syncService.databaseService, equals(mockDatabaseService));
        expect(syncService.conflictResolutionService, equals(mockConflictResolutionService));
      });

      test('should start with idle sync status', () {
        expect(syncService.syncStatus.status, equals(SyncStatus.idle));
        expect(syncService.syncStatus.progress, equals(0.0));
        expect(syncService.syncStatus.currentOperation, isNull);
      });
    });

    group('Full Sync', () {
      test('should perform full sync successfully', () async {
        // Arrange
        final mockInspections = [
          Inspection(
            id: '1',
            vehicleId: 'v1',
            inspectorId: 'u1',
            status: InspectionStatus.completed,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        final mockVehicles = [
          Vehicle(
            id: 'v1',
            vin: 'TEST123456789',
            make: 'Test',
            model: 'Vehicle',
            year: 2023,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        final mockUsers = [
          User(
            id: 'u1',
            email: 'test@example.com',
            firstName: 'Test',
            lastName: 'User',
            role: UserRole.inspector,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        when(mockApiService.get('/sync/inspections'))
            .thenAnswer((_) async => {'data': mockInspections.map((i) => i.toJson()).toList()});
        when(mockApiService.get('/sync/vehicles'))
            .thenAnswer((_) async => {'data': mockVehicles.map((v) => v.toJson()).toList()});
        when(mockApiService.get('/sync/users'))
            .thenAnswer((_) async => {'data': mockUsers.map((u) => u.toJson()).toList()});

        when(mockDatabaseService.getUnsyncedInspections())
            .thenAnswer((_) async => []);
        when(mockDatabaseService.getUnsyncedVehicles())
            .thenAnswer((_) async => []);
        when(mockDatabaseService.getUnsyncedUsers())
            .thenAnswer((_) async => []);

        // Act
        final result = await syncService.performFullSync();

        // Assert
        expect(result.success, isTrue);
        expect(result.syncedEntities, greaterThan(0));
        verify(mockApiService.get('/sync/inspections')).called(1);
        verify(mockApiService.get('/sync/vehicles')).called(1);
        verify(mockApiService.get('/sync/users')).called(1);
      });

      test('should handle sync errors gracefully', () async {
        // Arrange
        when(mockApiService.get('/sync/inspections'))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await syncService.performFullSync();

        // Assert
        expect(result.success, isFalse);
        expect(result.errors, isNotEmpty);
        expect(result.errors.first.type, equals(SyncErrorType.networkError));
      });

      test('should update sync status during sync', () async {
        // Arrange
        final statusUpdates = <SyncStatusData>[];
        syncService.syncStatusStream.listen(statusUpdates.add);

        when(mockApiService.get('/sync/inspections'))
            .thenAnswer((_) async => {'data': []});
        when(mockApiService.get('/sync/vehicles'))
            .thenAnswer((_) async => {'data': []});
        when(mockApiService.get('/sync/users'))
            .thenAnswer((_) async => {'data': []});

        when(mockDatabaseService.getUnsyncedInspections())
            .thenAnswer((_) async => []);
        when(mockDatabaseService.getUnsyncedVehicles())
            .thenAnswer((_) async => []);
        when(mockDatabaseService.getUnsyncedUsers())
            .thenAnswer((_) async => []);

        // Act
        await syncService.performFullSync();

        // Assert
        expect(statusUpdates.length, greaterThan(1));
        expect(statusUpdates.first.status, equals(SyncStatus.syncing));
        expect(statusUpdates.last.status, equals(SyncStatus.idle));
      });
    });

    group('Incremental Sync', () {
      test('should sync only changed entities', () async {
        // Arrange
        final lastSyncTime = DateTime.now().subtract(const Duration(hours: 1));
        final mockInspections = [
          Inspection(
            id: '1',
            vehicleId: 'v1',
            inspectorId: 'u1',
            status: InspectionStatus.completed,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        when(mockDatabaseService.getLastSyncTime())
            .thenAnswer((_) async => lastSyncTime);
        when(mockApiService.get('/sync/inspections', queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => {'data': mockInspections.map((i) => i.toJson()).toList()});
        when(mockApiService.get('/sync/vehicles', queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => {'data': []});
        when(mockApiService.get('/sync/users', queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => {'data': []});

        when(mockDatabaseService.getUnsyncedInspections())
            .thenAnswer((_) async => []);
        when(mockDatabaseService.getUnsyncedVehicles())
            .thenAnswer((_) async => []);
        when(mockDatabaseService.getUnsyncedUsers())
            .thenAnswer((_) async => []);

        // Act
        final result = await syncService.performIncrementalSync();

        // Assert
        expect(result.success, isTrue);
        verify(mockApiService.get('/sync/inspections', 
            queryParameters: argThat(contains('since'), named: 'queryParameters'))).called(1);
      });
    });

    group('Conflict Detection and Resolution', () {
      test('should detect conflicts during sync', () async {
        // Arrange
        final localInspection = Inspection(
          id: '1',
          vehicleId: 'v1',
          inspectorId: 'u1',
          status: InspectionStatus.inProgress,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        );

        final serverInspection = Inspection(
          id: '1',
          vehicleId: 'v1',
          inspectorId: 'u1',
          status: InspectionStatus.completed,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
        );

        when(mockApiService.get('/sync/inspections'))
            .thenAnswer((_) async => {'data': [serverInspection.toJson()]});
        when(mockDatabaseService.getInspectionById('1'))
            .thenAnswer((_) async => localInspection);
        when(mockConflictResolutionService.detectConflict(any, any))
            .thenReturn(true);

        when(mockDatabaseService.getUnsyncedInspections())
            .thenAnswer((_) async => []);
        when(mockDatabaseService.getUnsyncedVehicles())
            .thenAnswer((_) async => []);
        when(mockDatabaseService.getUnsyncedUsers())
            .thenAnswer((_) async => []);

        // Act
        final result = await syncService.performFullSync();

        // Assert
        expect(result.conflicts, isNotEmpty);
        verify(mockConflictResolutionService.detectConflict(any, any)).called(1);
      });

      test('should resolve conflicts automatically when possible', () async {
        // Arrange
        final conflict = SyncConflict(
          id: 'conflict1',
          entityType: 'Inspection',
          entityId: '1',
          localData: {'status': 'in_progress'},
          serverData: {'status': 'completed'},
          detectedAt: DateTime.now(),
        );

        when(mockConflictResolutionService.canAutoResolve(conflict))
            .thenReturn(true);
        when(mockConflictResolutionService.autoResolveConflict(conflict))
            .thenAnswer((_) async => ConflictResolution.useServer);

        // Act
        final resolved = await syncService.resolveConflict(conflict);

        // Assert
        expect(resolved, isTrue);
        verify(mockConflictResolutionService.autoResolveConflict(conflict)).called(1);
      });
    });

    group('Batch Operations', () {
      test('should process sync operations in batches', () async {
        // Arrange
        final largeInspectionList = List.generate(150, (index) => Inspection(
          id: 'inspection_$index',
          vehicleId: 'v1',
          inspectorId: 'u1',
          status: InspectionStatus.completed,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        when(mockApiService.get('/sync/inspections'))
            .thenAnswer((_) async => {'data': largeInspectionList.map((i) => i.toJson()).toList()});
        when(mockApiService.get('/sync/vehicles'))
            .thenAnswer((_) async => {'data': []});
        when(mockApiService.get('/sync/users'))
            .thenAnswer((_) async => {'data': []});

        when(mockDatabaseService.getUnsyncedInspections())
            .thenAnswer((_) async => []);
        when(mockDatabaseService.getUnsyncedVehicles())
            .thenAnswer((_) async => []);
        when(mockDatabaseService.getUnsyncedUsers())
            .thenAnswer((_) async => []);

        // Act
        final result = await syncService.performFullSync();

        // Assert
        expect(result.success, isTrue);
        expect(result.syncedEntities, equals(150));
        // Verify that batch processing occurred (should be multiple database operations)
        verify(mockDatabaseService.insertInspections(any)).called(greaterThan(1));
      });
    });

    group('Error Handling', () {
      test('should handle network errors', () async {
        // Arrange
        when(mockApiService.get('/sync/inspections'))
            .thenThrow(Exception('Network timeout'));

        // Act
        final result = await syncService.performFullSync();

        // Assert
        expect(result.success, isFalse);
        expect(result.errors.first.type, equals(SyncErrorType.networkError));
        expect(result.errors.first.message, contains('Network timeout'));
      });

      test('should handle authentication errors', () async {
        // Arrange
        when(mockApiService.get('/sync/inspections'))
            .thenThrow(Exception('Unauthorized'));

        // Act
        final result = await syncService.performFullSync();

        // Assert
        expect(result.success, isFalse);
        expect(result.errors.first.type, equals(SyncErrorType.authenticationError));
      });

      test('should handle validation errors', () async {
        // Arrange
        final invalidInspection = {
          'id': '1',
          'vehicleId': null, // Invalid - required field
          'inspectorId': 'u1',
          'status': 'invalid_status',
        };

        when(mockApiService.get('/sync/inspections'))
            .thenAnswer((_) async => {'data': [invalidInspection]});

        // Act
        final result = await syncService.performFullSync();

        // Assert
        expect(result.success, isFalse);
        expect(result.errors.first.type, equals(SyncErrorType.validationError));
      });
    });

    group('Periodic Sync', () {
      test('should start periodic sync', () async {
        // Arrange
        when(mockDatabaseService.getLastSyncTime())
            .thenAnswer((_) async => DateTime.now().subtract(const Duration(minutes: 30)));

        // Act
        syncService.startPeriodicSync(const Duration(seconds: 1));

        // Wait for at least one sync cycle
        await Future.delayed(const Duration(milliseconds: 1100));

        // Assert
        verify(mockDatabaseService.getLastSyncTime()).called(greaterThan(0));
        
        // Cleanup
        syncService.stopPeriodicSync();
      });

      test('should stop periodic sync', () async {
        // Arrange
        syncService.startPeriodicSync(const Duration(seconds: 1));
        await Future.delayed(const Duration(milliseconds: 100));

        // Act
        syncService.stopPeriodicSync();
        final initialCallCount = verify(mockDatabaseService.getLastSyncTime()).callCount;
        
        // Wait to ensure no more calls are made
        await Future.delayed(const Duration(milliseconds: 1100));
        
        // Assert
        final finalCallCount = verify(mockDatabaseService.getLastSyncTime()).callCount;
        expect(finalCallCount, equals(initialCallCount));
      });
    });

    group('Sync Statistics', () {
      test('should track sync statistics', () async {
        // Arrange
        final mockInspections = List.generate(5, (index) => Inspection(
          id: 'inspection_$index',
          vehicleId: 'v1',
          inspectorId: 'u1',
          status: InspectionStatus.completed,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        when(mockApiService.get('/sync/inspections'))
            .thenAnswer((_) async => {'data': mockInspections.map((i) => i.toJson()).toList()});
        when(mockApiService.get('/sync/vehicles'))
            .thenAnswer((_) async => {'data': []});
        when(mockApiService.get('/sync/users'))
            .thenAnswer((_) async => {'data': []});

        when(mockDatabaseService.getUnsyncedInspections())
            .thenAnswer((_) async => []);
        when(mockDatabaseService.getUnsyncedVehicles())
            .thenAnswer((_) async => []);
        when(mockDatabaseService.getUnsyncedUsers())
            .thenAnswer((_) async => []);

        // Act
        final result = await syncService.performFullSync();

        // Assert
        expect(result.syncedEntities, equals(5));
        expect(result.duration, greaterThan(Duration.zero));
        expect(result.timestamp, isNotNull);
      });
    });

    group('Data Integrity', () {
      test('should maintain data integrity during sync', () async {
        // Arrange
        final inspection = Inspection(
          id: '1',
          vehicleId: 'v1',
          inspectorId: 'u1',
          status: InspectionStatus.completed,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockApiService.get('/sync/inspections'))
            .thenAnswer((_) async => {'data': [inspection.toJson()]});
        when(mockApiService.get('/sync/vehicles'))
            .thenAnswer((_) async => {'data': []});
        when(mockApiService.get('/sync/users'))
            .thenAnswer((_) async => {'data': []});

        when(mockDatabaseService.getUnsyncedInspections())
            .thenAnswer((_) async => []);
        when(mockDatabaseService.getUnsyncedVehicles())
            .thenAnswer((_) async => []);
        when(mockDatabaseService.getUnsyncedUsers())
            .thenAnswer((_) async => []);

        // Act
        final result = await syncService.performFullSync();

        // Assert
        expect(result.success, isTrue);
        verify(mockDatabaseService.insertInspections(argThat(
          predicate<List<Inspection>>((inspections) => 
            inspections.first.id == '1' && 
            inspections.first.status == InspectionStatus.completed)
        ))).called(1);
      });
    });
  });
}