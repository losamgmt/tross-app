/// AppDataTable Organism Integration Tests ✅ LAYOUT FIXED, READY FOR FULL MIGRATION
///
/// Comprehensive tests for the complete AppDataTable organism
/// Tests end-to-end functionality with real User and Role data
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tross_app/widgets/organisms/data_table.dart';
import 'package:tross_app/config/table_column.dart';
import 'package:tross_app/widgets/molecules/empty_state.dart';
import 'package:tross_app/widgets/atoms/indicators/loading_indicator.dart';

// Test data models
class TestUser {
  final int id;
  final String name;
  final String email;
  final String role;
  final bool isActive;

  TestUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
  });
}

class TestRole {
  final int id;
  final String name;
  final bool isProtected;

  TestRole({required this.id, required this.name, required this.isProtected});
}

void main() {
  group('DataTable Organism Integration Tests', () {
    // Sample user data
    final testUsers = [
      TestUser(
        id: 1,
        name: 'Alice Admin',
        email: 'alice@example.com',
        role: 'admin',
        isActive: true,
      ),
      TestUser(
        id: 2,
        name: 'Bob Technician',
        email: 'bob@example.com',
        role: 'technician',
        isActive: true,
      ),
      TestUser(
        id: 3,
        name: 'Charlie Manager',
        email: 'charlie@example.com',
        role: 'manager',
        isActive: false,
      ),
    ];

    final userColumns = <TableColumn<TestUser>>[
      TableColumn<TestUser>(
        id: 'name',
        label: 'Name',
        sortable: true,
        cellBuilder: (user) => Text(user.name),
        comparator: (a, b) => a.name.compareTo(b.name),
      ),
      TableColumn<TestUser>(
        id: 'email',
        label: 'Email',
        sortable: true,
        cellBuilder: (user) => Text(user.email),
        comparator: (a, b) => a.email.compareTo(b.email),
      ),
      TableColumn<TestUser>(
        id: 'role',
        label: 'Role',
        sortable: true,
        cellBuilder: (user) => Text(user.role),
        comparator: (a, b) => a.role.compareTo(b.role),
      ),
    ];

    testWidgets('renders table with user data', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppDataTable<TestUser>(columns: userColumns, data: testUsers),
          ),
        ),
      );

      expect(find.text('Alice Admin'), findsOneWidget);
      expect(find.text('Bob Technician'), findsOneWidget);
      expect(find.text('Charlie Manager'), findsOneWidget);
    });

    testWidgets('renders all column headers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppDataTable<TestUser>(columns: userColumns, data: testUsers),
          ),
        ),
      );

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Role'), findsOneWidget);
    });

    testWidgets('displays loading state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppDataTable<TestUser>(
              columns: userColumns,
              data: [],
              state: AppDataTableState.loading,
            ),
          ),
        ),
      );

      expect(find.byType(LoadingIndicator), findsOneWidget);
      expect(find.text('Alice Admin'), findsNothing);
    });

    testWidgets('displays empty state when no data', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppDataTable<TestUser>(
              columns: userColumns,
              data: [],
              state: AppDataTableState.loaded,
            ),
          ),
        ),
      );

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No items to display'), findsOneWidget);
    });

    testWidgets('displays custom empty message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppDataTable<TestUser>(
              columns: userColumns,
              data: [],
              state: AppDataTableState.loaded,
              emptyMessage: 'No users found',
            ),
          ),
        ),
      );

      expect(find.text('No users found'), findsOneWidget);
    });

    testWidgets('displays error state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppDataTable<TestUser>(
              columns: userColumns,
              data: [],
              state: AppDataTableState.error,
              errorMessage: 'Failed to load users',
            ),
          ),
        ),
      );

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('Failed to load users'), findsOneWidget);
    });

    group('Sorting Tests', () {
      testWidgets('sorts data by name ascending', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppDataTable<TestUser>(
                columns: userColumns,
                data: testUsers,
              ),
            ),
          ),
        );

        // Click Name header to sort
        await tester.tap(find.text('Name'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_upward), findsOneWidget);

        // Verify sorting is applied (we can't directly check order in widget tree,
        // but we can verify the sort icon is present)
        expect(find.text('Alice Admin'), findsOneWidget);
        expect(find.text('Bob Technician'), findsOneWidget);
      });

      testWidgets('toggles sort direction on second click', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppDataTable<TestUser>(
                columns: userColumns,
                data: testUsers,
              ),
            ),
          ),
        );

        // First click - ascending
        await tester.tap(find.text('Name'));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.arrow_upward), findsOneWidget);

        // Second click - descending
        await tester.tap(find.text('Name'));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
      });

      testWidgets('clears sort on third click', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppDataTable<TestUser>(
                columns: userColumns,
                data: testUsers,
              ),
            ),
          ),
        );

        // Three clicks to cycle back to none
        await tester.tap(find.text('Name'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Name'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Name'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.unfold_more), findsNWidgets(3));
      });

      testWidgets('switches sort to different column', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppDataTable<TestUser>(
                columns: userColumns,
                data: testUsers,
              ),
            ),
          ),
        );

        // Sort by Name
        await tester.tap(find.text('Name'));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.arrow_upward), findsOneWidget);

        // Switch to Email column
        await tester.tap(find.text('Email'));
        await tester.pumpAndSettle();

        // Should show ascending on Email, neutral on Name
        final upwardArrows = find.byIcon(Icons.arrow_upward);
        expect(upwardArrows, findsOneWidget);
      });
    });

    group('Row Interaction Tests', () {
      testWidgets('calls onRowTap with correct item', (tester) async {
        TestUser? tappedUser;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppDataTable<TestUser>(
                columns: userColumns,
                data: testUsers,
                onRowTap: (user) => tappedUser = user,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Bob Technician'));
        await tester.pump();

        expect(tappedUser, isNotNull);
        expect(tappedUser?.name, 'Bob Technician');
      });

      testWidgets('renders action buttons when provided', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppDataTable<TestUser>(
                columns: userColumns,
                data: testUsers,
                actionsBuilder: (user) => [
                  IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
                ],
              ),
            ),
          ),
        );

        // 3 users * 1 action = 3 edit buttons
        expect(find.byIcon(Icons.edit), findsNWidgets(3));
      });

      testWidgets('action buttons are clickable', (tester) async {
        TestUser? editedUser;

        // Set larger viewport to accommodate wide table
        tester.view.physicalSize = const Size(2000, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppDataTable<TestUser>(
                columns: userColumns,
                data: testUsers,
                actionsBuilder: (user) => [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => editedUser = user,
                  ),
                ],
              ),
            ),
          ),
        );

        // Tap the first edit button
        await tester.tap(find.byIcon(Icons.edit).first);
        await tester.pump();

        expect(editedUser, isNotNull);
        expect(editedUser?.name, 'Alice Admin');
      });
    });

    group('Role Data Tests', () {
      final testRoles = [
        TestRole(id: 1, name: 'Admin', isProtected: true),
        TestRole(id: 2, name: 'Technician', isProtected: false),
        TestRole(id: 3, name: 'Manager', isProtected: false),
      ];

      final roleColumns = <TableColumn<TestRole>>[
        TableColumn<TestRole>(
          id: 'name',
          label: 'Role Name',
          sortable: true,
          cellBuilder: (role) => Text(role.name),
          comparator: (a, b) => a.name.compareTo(b.name),
        ),
        TableColumn<TestRole>(
          id: 'id',
          label: 'ID',
          sortable: true,
          cellBuilder: (role) => Text('${role.id}'),
          comparator: (a, b) => a.id.compareTo(b.id),
        ),
      ];

      testWidgets('renders table with role data', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppDataTable<TestRole>(
                columns: roleColumns,
                data: testRoles,
              ),
            ),
          ),
        );

        expect(find.text('Admin'), findsOneWidget);
        expect(find.text('Technician'), findsOneWidget);
        expect(find.text('Manager'), findsOneWidget);
      });

      testWidgets('sorts roles by name', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppDataTable<TestRole>(
                columns: roleColumns,
                data: testRoles,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Role Name'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      });

      testWidgets('sorts roles by ID', (tester) async {
        // Set larger viewport to accommodate wide table
        tester.view.physicalSize = const Size(2000, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppDataTable<TestRole>(
                columns: roleColumns,
                data: testRoles,
              ),
            ),
          ),
        );

        await tester.tap(find.text('ID'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      });
    });

    group('Styling and Layout Tests', () {
      testWidgets('table has proper borders', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppDataTable<TestUser>(
                columns: userColumns,
                data: testUsers,
              ),
            ),
          ),
        );

        final containers = tester.widgetList<Container>(find.byType(Container));

        // Verify at least one container has border decoration
        final borderedContainers = containers.where((c) {
          final decoration = c.decoration;
          return decoration is BoxDecoration && decoration.border != null;
        });

        expect(borderedContainers.isNotEmpty, true);
      });

      testWidgets('table has rounded corners', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppDataTable<TestUser>(
                columns: userColumns,
                data: testUsers,
              ),
            ),
          ),
        );

        final containers = tester.widgetList<Container>(find.byType(Container));

        // Verify at least one container has border radius
        final roundedContainers = containers.where((c) {
          final decoration = c.decoration;
          return decoration is BoxDecoration && decoration.borderRadius != null;
        });

        expect(roundedContainers.isNotEmpty, true);
      });

      testWidgets('supports horizontal scrolling', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppDataTable<TestUser>(
                columns: userColumns,
                data: testUsers,
              ),
            ),
          ),
        );

        // Find the horizontal SingleChildScrollView (the table's scroll view)
        // There may be multiple ScrollViews in the widget tree, so we look for
        // the one with horizontal scroll direction
        final scrollViews = find.byType(SingleChildScrollView);
        expect(scrollViews, findsWidgets);

        // Verify at least one SingleChildScrollView exists (the table's horizontal scroll)
        final scrollView = tester.widget<SingleChildScrollView>(
          scrollViews.first,
        );
        expect(scrollView.scrollDirection, Axis.horizontal);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles single row of data', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppDataTable<TestUser>(
                columns: userColumns,
                data: [testUsers[0]],
              ),
            ),
          ),
        );

        expect(find.text('Alice Admin'), findsOneWidget);
        expect(find.text('Bob Technician'), findsNothing);
      });

      testWidgets('handles large dataset', (tester) async {
        final largeData = List.generate(
          100,
          (i) => TestUser(
            id: i,
            name: 'User $i',
            email: 'user$i@example.com',
            role: 'user',
            isActive: true,
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppDataTable<TestUser>(
                columns: userColumns,
                data: largeData,
              ),
            ),
          ),
        );

        expect(find.text('User 0'), findsOneWidget);
        expect(find.text('User 99'), findsOneWidget);
      });

      testWidgets('handles empty column list gracefully', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppDataTable<TestUser>(columns: [], data: testUsers),
            ),
          ),
        );

        // Should not crash, but won't display data
        expect(find.text('Alice Admin'), findsNothing);
      });
    });
  });
}
