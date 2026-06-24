// AUTO-GENERATED
class DomainEventBase {
  final String eventType;
  final String timestamp;
  final String aggregateId;

  const DomainEventBase({
    required this.eventType,
    required this.timestamp,
    required this.aggregateId,
  });

  factory DomainEventBase.fromJson(Map<String, dynamic> json) =>
    DomainEventBase(
      eventType: json['eventType']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
      aggregateId: json['aggregateId']?.toString() ?? '',
    );

  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'timestamp': timestamp,
    'aggregateId': aggregateId,
  };

  DomainEventBase copyWith({
    String? eventType,
    String? timestamp,
    String? aggregateId,
  }) => DomainEventBase(
    eventType: eventType ?? this.eventType,
    timestamp: timestamp ?? this.timestamp,
    aggregateId: aggregateId ?? this.aggregateId,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is DomainEventBase && other.eventType == eventType && other.timestamp == timestamp);
  @override
  int get hashCode => eventType.hashCode ^ timestamp.hashCode;
}
