/// Database Health Data Model
///
/// Models for database health monitoring data from /api/health/databases
library;

import '../widgets/atoms/indicators/connection_status_badge.dart';

/// Individual database health information
class DatabaseHealth {
  /// Database name
  final String name;

  /// Current health status
  final HealthStatus status;

  /// Response time in milliseconds
  final int responseTime;

  /// Current number of active connections
  final int connectionCount;

  /// Maximum allowed connections
  final int maxConnections;

  /// When the health check was last performed (ISO 8601)
  final String lastChecked;

  /// Error message if status is degraded or critical
  final String? errorMessage;

  const DatabaseHealth({
    required this.name,
    required this.status,
    required this.responseTime,
    required this.connectionCount,
    required this.maxConnections,
    required this.lastChecked,
    this.errorMessage,
  });

  /// Create from JSON
  factory DatabaseHealth.fromJson(Map<String, dynamic> json) {
    return DatabaseHealth(
      name: json['name'] as String,
      status: _parseStatus(json['status'] as String),
      responseTime: json['responseTime'] as int,
      connectionCount: json['connectionCount'] as int,
      maxConnections: json['maxConnections'] as int,
      lastChecked: json['lastChecked'] as String,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'status': _statusToString(status),
      'responseTime': responseTime,
      'connectionCount': connectionCount,
      'maxConnections': maxConnections,
      'lastChecked': lastChecked,
      'errorMessage': errorMessage,
    };
  }

  /// Parse status string to HealthStatus enum
  static HealthStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return HealthStatus.healthy;
      case 'degraded':
        return HealthStatus.degraded;
      case 'critical':
        return HealthStatus.critical;
      default:
        return HealthStatus.unknown;
    }
  }

  /// Convert HealthStatus enum to string
  static String _statusToString(HealthStatus status) {
    switch (status) {
      case HealthStatus.healthy:
        return 'healthy';
      case HealthStatus.degraded:
        return 'degraded';
      case HealthStatus.critical:
        return 'critical';
      case HealthStatus.unknown:
        return 'unknown';
    }
  }

  /// Get DateTime from ISO 8601 string
  DateTime get lastCheckedDateTime => DateTime.parse(lastChecked);

  /// Get Duration from milliseconds
  Duration get responseTimeDuration => Duration(milliseconds: responseTime);

  /// Calculate connection usage percentage (0.0 to 1.0)
  double get connectionUsage {
    if (maxConnections == 0) return 0.0;
    return connectionCount / maxConnections;
  }

  @override
  String toString() {
    return 'DatabaseHealth(name: $name, status: $status, responseTime: ${responseTime}ms)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DatabaseHealth &&
        other.name == name &&
        other.status == status &&
        other.responseTime == responseTime &&
        other.connectionCount == connectionCount &&
        other.maxConnections == maxConnections &&
        other.lastChecked == lastChecked &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      status,
      responseTime,
      connectionCount,
      maxConnections,
      lastChecked,
      errorMessage,
    );
  }
}

/// Response from /api/health/databases endpoint
class DatabasesHealthResponse {
  /// List of database health information
  final List<DatabaseHealth> databases;

  /// Timestamp when health check was performed (ISO 8601)
  final String timestamp;

  const DatabasesHealthResponse({
    required this.databases,
    required this.timestamp,
  });

  /// Create from JSON
  factory DatabasesHealthResponse.fromJson(Map<String, dynamic> json) {
    return DatabasesHealthResponse(
      databases: (json['databases'] as List)
          .map((db) => DatabaseHealth.fromJson(db as Map<String, dynamic>))
          .toList(),
      timestamp: json['timestamp'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'databases': databases.map((db) => db.toJson()).toList(),
      'timestamp': timestamp,
    };
  }

  /// Get DateTime from ISO 8601 string
  DateTime get timestampDateTime => DateTime.parse(timestamp);

  /// Get overall system status (worst status among all databases)
  HealthStatus get overallStatus {
    if (databases.isEmpty) return HealthStatus.unknown;

    // Critical takes precedence
    if (databases.any((db) => db.status == HealthStatus.critical)) {
      return HealthStatus.critical;
    }

    // Then degraded
    if (databases.any((db) => db.status == HealthStatus.degraded)) {
      return HealthStatus.degraded;
    }

    // Then unknown
    if (databases.any((db) => db.status == HealthStatus.unknown)) {
      return HealthStatus.unknown;
    }

    // All healthy
    return HealthStatus.healthy;
  }

  @override
  String toString() {
    return 'DatabasesHealthResponse(databases: ${databases.length}, overall: $overallStatus)';
  }
}
