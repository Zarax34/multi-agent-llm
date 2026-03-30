import 'package:equatable/equatable.dart';

class OllamaInstance extends Equatable {
  final String ip;
  final int port;
  final bool isOnline;
  final DateTime? lastSeen;
  final String? name;
  final List<String> models;

  const OllamaInstance({
    required this.ip,
    this.port = 11434,
    this.isOnline = false,
    this.lastSeen,
    this.name,
    this.models = const [],
  });

  String get baseUrl => 'http://$ip:$port';

  OllamaInstance copyWith({
    String? ip,
    int? port,
    bool? isOnline,
    DateTime? lastSeen,
    String? name,
    List<String>? models,
  }) {
    return OllamaInstance(
      ip: ip ?? this.ip,
      port: port ?? this.port,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      name: name ?? this.name,
      models: models ?? this.models,
    );
  }

  Map<String, dynamic> toJson() => {
    'ip': ip,
    'port': port,
    'isOnline': isOnline,
    'lastSeen': lastSeen?.toIso8601String(),
    'name': name,
    'models': models,
  };

  factory OllamaInstance.fromJson(Map<String, dynamic> json) => OllamaInstance(
    ip: json['ip'],
    port: json['port'] ?? 11434,
    isOnline: json['isOnline'] ?? false,
    lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
    name: json['name'],
    models: List<String>.from(json['models'] ?? []),
  );

  @override
  List<Object?> get props => [ip, port, isOnline];
}
