import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:multi_agent_llm/core/constants/api_constants.dart';
import 'package:multi_agent_llm/data/models/ollama_instance.dart';

class OllamaDiscovery {
  /// Scans a single IP for Ollama on port 11434
  static Future<OllamaInstance?> scanIp(String ip) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = Duration(seconds: ApiConstants.discoveryTimeout);
      final request = await client.getUrl(
        Uri.parse('http://$ip:${ApiConstants.ollamaDefaultPort}/api/tags'),
      );
      final response = await request.close();
      if (response.statusCode == 200) {
        client.close();
        return OllamaInstance(
          ip: ip,
          port: ApiConstants.ollamaDefaultPort,
          isOnline: true,
          lastSeen: DateTime.now(),
        );
      }
      client.close();
    } catch (_) {}
    return null;
  }

  /// Gets the local subnet (e.g., "192.168.1")
  static Future<String?> getLocalSubnet() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            final parts = addr.address.split('.');
            if (parts.length == 4) {
              return '${parts[0]}.${parts[1]}.${parts[2]}';
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Scans the local subnet for Ollama instances
  /// Returns a stream of discovered instances
  static Stream<OllamaInstance> scanNetwork({String? subnet}) async* {
    final targetSubnet = subnet ?? await getLocalSubnet();
    if (targetSubnet == null) return;

    final futures = <Future<OllamaInstance?>>[];
    for (int i = 1; i <= 254; i++) {
      final ip = '$targetSubnet.$i';
      futures.add(scanIp(ip));

      // Limit concurrency
      if (futures.length >= ApiConstants.maxConcurrentScans) {
        final results = await Future.wait(futures);
        for (final instance in results) {
          if (instance != null) yield instance;
        }
        futures.clear();
      }
    }

    // Wait for remaining
    if (futures.isNotEmpty) {
      final results = await Future.wait(futures);
      for (final instance in results) {
        if (instance != null) yield instance;
      }
    }
  }

  /// Fetches model list from an Ollama instance
  static Future<List<String>> fetchModels(String ip, {int port = 11434}) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = Duration(seconds: ApiConstants.discoveryTimeout);
      final request = await client.getUrl(
        Uri.parse('http://$ip:$port/api/tags'),
      );
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        client.close();
        return [];
      }
      client.close();
    } catch (_) {}
    return [];
  }

  /// Tests connection to an Ollama instance
  static Future<bool> testConnection(String ip, {int port = 11434}) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = Duration(seconds: ApiConstants.discoveryTimeout);
      final request = await client.getUrl(
        Uri.parse('http://$ip:$port/api/tags'),
      );
      final response = await request.close();
      client.close();
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
