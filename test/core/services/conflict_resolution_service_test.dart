import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pti_mobile_app/core/services/conflict_resolution_service.dart';
import 'package:pti_mobile_app/data/datasources/database_service.dart';
import 'package:pti_mobile_app/data/models/sync_models.dart';
import 'package:pti_mobile_app/data/models/inspection_models.dart';

// Mock classes for testing
class MockDatabaseService extends Mock implements DatabaseService {}
void main() {
  group('ConflictResolutionService Tests', () {
    late ConflictResolutionService service;
    late MockApiService mockApiService;
    late MockDatabaseService mockDatabaseService;

    setUp(() {
      mockApiService = MockApiService();
      mockDatabaseService = MockDatabaseService();
      
      service = ConflictResolutionService(
        apiService: mockApiService,
        databaseService: mockDatabaseService,
      );
    });

    group('Conflict Detection', () {
      test('should detect conflict when local and server data differ', () {
        // Arrange
        final localData = {
          'id': '1',
          'status': 'in_progress',
          'updatedAt': '2024-01-01T10:00:00Z',
        };
        final serverData = {
          'id': '1',
          'status': 'completed',
          'updatedAt': '2024-01-01T11:00:00Z',
        };

        // Act
        final hasConflict = service.detectConflict(localData, serverData);

        // Assert
        expect(hasConflict, isTrue);
      });

      test('should not detect conflict when data is identical', () {
        // Arrange
        final localData = {
          'id': '1',
          'status': 'completed',
          'updatedAt': '2024-01-01T10:00:00Z',
        };
        final serverData = {
          'id': '1',
          'status': 'completed',
          'updatedAt': '2024-01-01T10:00:00Z',
        };

        // Act
        final hasConflict = service.detectConflict(localData, serverData);

        // Assert
        expect(hasConflict, isFalse);
      });

      test('should ignore timestamp differences within threshold', () {
        // Arrange
        final localData = {
          'id': '1',
          'status': 'completed',
          'updatedAt': '2024-01-01T10:00:00Z',
        };
        final serverData = {
          'id': '1',
          'status': 'completed',
          'updatedAt': '2024-01-01T10:00:01Z', // 1 second difference
        };

        // Act
        final hasConflict = service.detectConflict(localData, serverData);

        // Assert
        expect(hasConflict, isFalse);
      });

      test('should detect conflict for significant timestamp differences', () {
        // Arrange
        final localData = {
          'id': '1',
          'status': 'completed',
          'updatedAt': '2024-01-01T10:00:00Z',
        };
        final serverData = {
          'id': '1',
          'status': 'completed',
          'updatedAt': '2024-01-01T11:00:00Z', // 1 hour difference
        };

        // Act
        final hasConflict = service.detectConflict(localData, serverData);

        // Assert
        expect(hasConflict, isTrue);
      });
    });

    group('Auto Resolution', () {
      test('should auto-resolve when server data is newer', () {
        // Arrange
        final conflict = SyncConflict(
          id: 'conflict1',
          entityType: 'Inspection',
          entityId: '1',
          localData: {
            'status': 'in_progress',
            'updatedAt': '2024-01-01T10:00:00Z',
          },
          serverData: {
            'status': 'completed',
            'updatedAt': '2024-01-01T11:00:00Z',
          },
          detectedAt: DateTime.now(),
        );

        // Act
        final canAutoResolve = service.canAutoResolve(conflict);

        // Assert
        expect(canAutoResolve, isTrue);
      });

      test('should not auto-resolve when local data is newer', () {
        // Arrange
        final conflict = SyncConflict(
          id: 'conflict1',
          entityType: 'Inspection',
          entityId: '1',
          localData: {
            'status': 'completed',
            'updatedAt': '2024-01-01T11:00:00Z',
          },
          serverData: {
            'status': 'in_progress',
            'updatedAt': '2024-01-01T10:00:00Z',
          },
          detectedAt: DateTime.now(),
        );

        // Act
        final canAutoResolve = service.canAutoResolve(conflict);

        // Assert
        expect(canAutoResolve, isFalse);
      });

      test('should auto-resolve conflict successfully', () async {
        // Arrange
        final conflict = SyncConflict(
          id: 'conflict1',
          entityType: 'Inspection',
          entityId: '1',
          localData: {
            'status': 'in_progress',
            'updatedAt': '2024-01-01T10:00:00Z',
          },
          serverData: {
            'status': 'completed',
            'updatedAt': '2024-01-01T11:00:00Z',
          },
          detectedAt: DateTime.now(),
        );

        when(mockDatabaseService.updateEntity('Inspection', '1', conflict.serverData))
            .thenAnswer((_) async => {});

        // Act
        final resolution = await service.autoResolveConflict(conflict);

        // Assert
        expect(resolution, equals(ConflictResolution.useServer));
        verify(mockDatabaseService.updateEntity('Inspection', '1', conflict.serverData)).called(1);
      });
    });

    group('Manual Resolution', () {
      test('should resolve conflict using local data', () async {
        // Arrange
        final conflictId = 'conflict1';
        final conflict = SyncConflict(
          id: conflictId,
          entityType: 'Inspection',
          entityId: '1',
          localData: {'status': 'in_progress'},
          serverData: {'status': 'completed'},
          detectedAt: DateTime.now(),
        );

        when(mockDatabaseService.getConflictById(conflictId))
            .thenAnswer((_) async => conflict);
        when(mockApiService.put('/inspections/1', data: anyNamed('data')))
            .thenAnswer((_) async => {'success': true});
        when(mockDatabaseService.removeConflict(conflictId))
            .thenAnswer((_) async => {});

        // Act
        await service.resolveConflict(conflictId, ConflictResolution.useLocal);

        // Assert
        verify(mockApiService.put('/inspections/1', data: conflict.localData)).called(1);
        verify(mockDatabaseService.removeConflict(conflictId)).called(1);
      });

      test('should resolve conflict using server data', () async {
        // Arrange
        final conflictId = 'conflict1';
        final conflict = SyncConflict(
          id: conflictId,
          entityType: 'Inspection',
          entityId: '1',
          localData: {'status': 'in_progress'},
          serverData: {'status': 'completed'},
          detectedAt: DateTime.now(),
        );

        when(mockDatabaseService.getConflictById(conflictId))
            .thenAnswer((_) async => conflict);
        when(mockDatabaseService.updateEntity('Inspection', '1', conflict.serverData))
            .thenAnswer((_) async => {});
        when(mockDatabaseService.removeConflict(conflictId))
            .thenAnswer((_) async => {});

        // Act
        await service.resolveConflict(conflictId, ConflictResolution.useServer);

        // Assert
        verify(mockDatabaseService.updateEntity('Inspection', '1', conflict.serverData)).called(1);
        verify(mockDatabaseService.removeConflict(conflictId)).called(1);
      });

      test('should resolve conflict by merging data', () async {
        // Arrange
        final conflictId = 'conflict1';
        final conflict = SyncConflict(
          id: conflictId,
          entityType: 'Inspection',
          entityId: '1',
          localData: {'status': 'in_progress', 'notes': 'Local notes'},
          serverData: {'status': 'completed', 'completedAt': '2024-01-01T12:00:00Z'},
          detectedAt: DateTime.now(),
        );
        final mergedData = {
          'status': 'completed',
          'notes': 'Local notes',
          'completedAt': '2024-01-01T12:00:00Z',
        };

        when(mockDatabaseService.getConflictById(conflictId))
            .thenAnswer((_) async => conflict);
        when(mockDatabaseService.updateEntity('Inspection', '1', mergedData))
            .thenAnswer((_) async => {});
        when(mockApiService.put('/inspections/1', data: mergedData))
            .thenAnswer((_) async => {'success': true});
        when(mockDatabaseService.removeConflict(conflictId))
            .thenAnswer((_) async => {});

        // Act
        await service.resolveConflict(
          conflictId,
          ConflictResolution.merge,
          mergedData: mergedData,
        );

        // Assert
        verify(mockDatabaseService.updateEntity('Inspection', '1', mergedData)).called(1);
        verify(mockApiService.put('/inspections/1', data: mergedData)).called(1);
        verify(mockDatabaseService.removeConflict(conflictId)).called(1);
      });

      test('should resolve conflict by creating new entry', () async {
        // Arrange
        final conflictId = 'conflict1';
        final conflict = SyncConflict(
          id: conflictId,
          entityType: 'Inspection',
          entityId: '1',
          localData: {'status': 'in_progress'},
          serverData: {'status': 'completed'},
          detectedAt: DateTime.now(),
        );

        when(mockDatabaseService.getConflictById(conflictId))
            .thenAnswer((_) async => conflict);
        when(mockDatabaseService.createEntity('Inspection', any))
            .thenAnswer((_) async => 'new_id');
        when(mockApiService.post('/inspections', data: anyNamed('data')))
            .thenAnswer((_) async => {'data': {'id': 'new_id'}});
        when(mockDatabaseService.removeConflict(conflictId))
            .thenAnswer((_) async => {});

        // Act
        await service.resolveConflict(conflictId, ConflictResolution.createNew);

        // Assert
        verify(mockDatabaseService.createEntity('Inspection', any)).called(1);
        verify(mockApiService.post('/inspections', data: anyNamed('data'))).called(1);
        verify(mockDatabaseService.removeConflict(conflictId)).called(1);
      });
    });

    group('Conflict Summary', () {
      test('should generate conflict summary', () {
        // Arrange
        final conflict = SyncConflict(
          id: 'conflict1',
          entityType: 'Inspection',
          entityId: '1',
          localData: {
            'status': 'in_progress',
            'notes': 'Local notes',
            'updatedAt': '2024-01-01T10:00:00Z',
          },
          serverData: {
            'status': 'completed',
            'completedAt': '2024-01-01T11:00:00Z',
            'updatedAt': '2024-01-01T11:00:00Z',
          },
          detectedAt: DateTime.now(),
        );

        // Act
        final summary = service.generateConflictSummary(conflict);

        // Assert
        expect(summary.conflictId, equals('conflict1'));
        expect(summary.entityType, equals('Inspection'));
        expect(summary.entityId, equals('1'));
        expect(summary.conflictingFields, contains('status'));
        expect(summary.localOnlyFields, contains('notes'));
        expect(summary.serverOnlyFields, contains('completedAt'));
      });

      test('should identify conflicting fields correctly', () {
        // Arrange
        final conflict = SyncConflict(
          id: 'conflict1',
          entityType: 'Inspection',
          entityId: '1',
          localData: {
            'status': 'in_progress',
            'priority': 'high',
            'notes': 'Same notes',
          },
          serverData: {
            'status': 'completed',
            'priority': 'low',
            'notes': 'Same notes',
          },
          detectedAt: DateTime.now(),
        );

        // Act
        final summary = service.generateConflictSummary(conflict);

        // Assert
        expect(summary.conflictingFields, containsAll(['status', 'priority']));
        expect(summary.conflictingFields, isNot(contains('notes')));
      });
    });

    group('Data Comparison', () {
      test('should check for data differences correctly', () {
        // Arrange
        final data1 = {
          'id': '1',
          'status': 'completed',
          'notes': 'Test notes',
          'updatedAt': '2024-01-01T10:00:00Z',
        };
        final data2 = {
          'id': '1',
          'status': 'in_progress',
          'notes': 'Test notes',
          'completedAt': '2024-01-01T11:00:00Z',
        };

        // Act
        final hasDifferences = service.hasDataDifferences(data1, data2);

        // Assert
        expect(hasDifferences, isTrue);
      });

      test('should return false for identical data', () {
        // Arrange
        final data1 = {
          'id': '1',
          'status': 'completed',
          'notes': 'Test notes',
        };
        final data2 = {
          'id': '1',
          'status': 'completed',
          'notes': 'Test notes',
        };

        // Act
        final hasDifferences = service.hasDataDifferences(data1, data2);

        // Assert
        expect(hasDifferences, isFalse);
      });

      test('should handle null values correctly', () {
        // Arrange
        final data1 = {
          'id': '1',
          'status': 'completed',
          'notes': null,
        };
        final data2 = {
          'id': '1',
          'status': 'completed',
          'completedAt': '2024-01-01T10:00:00Z',
        };

        // Act
        final hasDifferences = service.hasDataDifferences(data1, data2);

        // Assert
        expect(hasDifferences, isTrue);
      });
    });

    group('Error Handling', () {
      test('should handle database errors during conflict resolution', () async {
        // Arrange
        final conflictId = 'conflict1';
        final conflict = SyncConflict(
          id: conflictId,
          entityType: 'Inspection',
          entityId: '1',
          localData: {'status': 'in_progress'},
          serverData: {'status': 'completed'},
          detectedAt: DateTime.now(),
        );

        when(mockDatabaseService.getConflictById(conflictId))
            .thenAnswer((_) async => conflict);
        when(mockDatabaseService.updateEntity('Inspection', '1', conflict.serverData))
            .thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => service.resolveConflict(conflictId, ConflictResolution.useServer),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle API errors during conflict resolution', () async {
        // Arrange
        final conflictId = 'conflict1';
        final conflict = SyncConflict(
          id: conflictId,
          entityType: 'Inspection',
          entityId: '1',
          localData: {'status': 'in_progress'},
          serverData: {'status': 'completed'},
          detectedAt: DateTime.now(),
        );

        when(mockDatabaseService.getConflictById(conflictId))
            .thenAnswer((_) async => conflict);
        when(mockApiService.put('/inspections/1', data: anyNamed('data')))
            .thenThrow(Exception('API error'));

        // Act & Assert
        expect(
          () => service.resolveConflict(conflictId, ConflictResolution.useLocal),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle missing conflict during resolution', () async {
        // Arrange
        final conflictId = 'nonexistent_conflict';

        when(mockDatabaseService.getConflictById(conflictId))
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => service.resolveConflict(conflictId, ConflictResolution.useLocal),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Batch Conflict Resolution', () {
      test('should resolve multiple conflicts in batch', () async {
        // Arrange
        final conflicts = [
          SyncConflict(
            id: 'conflict1',
            entityType: 'Inspection',
            entityId: '1',
            localData: {'status': 'in_progress'},
            serverData: {'status': 'completed'},
            detectedAt: DateTime.now(),
          ),
          SyncConflict(
            id: 'conflict2',
            entityType: 'Inspection',
            entityId: '2',
            localData: {'status': 'draft'},
            serverData: {'status': 'in_progress'},
            detectedAt: DateTime.now(),
          ),
        ];

        for (final conflict in conflicts) {
          when(mockDatabaseService.getConflictById(conflict.id))
              .thenAnswer((_) async => conflict);
          when(mockDatabaseService.updateEntity(conflict.entityType, conflict.entityId, conflict.serverData))
              .thenAnswer((_) async => {});
          when(mockDatabaseService.removeConflict(conflict.id))
              .thenAnswer((_) async => {});
        }

        // Act
        final results = await service.resolveConflictsBatch(
          conflicts.map((c) => c.id).toList(),
          ConflictResolution.useServer,
        );

        // Assert
        expect(results.length, equals(2));
        expect(results.every((r) => r.success), isTrue);
        
        for (final conflict in conflicts) {
          verify(mockDatabaseService.updateEntity(conflict.entityType, conflict.entityId, conflict.serverData)).called(1);
          verify(mockDatabaseService.removeConflict(conflict.id)).called(1);
        }
      });
    });
  });
}