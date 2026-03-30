import 'dart:async';
import 'package:multi_agent_llm/data/models/ollama_instance.dart';
import 'package:multi_agent_llm/core/network/ollama_discovery.dart';

class DiscoveryUseCase {
  /// Scan network for Ollama instances
  Stream<OllamaInstance> scanNetwork({String? subnet}) {
    return OllamaDiscovery.scanNetwork(subnet: subnet);
  }

  /// Test connection to a specific host
  Future<bool> testConnection(String ip, {int port = 11434}) {
    return OllamaDiscovery.testConnection(ip, port: port);
  }

  /// Get local subnet
  Future<String?> getLocalSubnet() {
    return OllamaDiscovery.getLocalSubnet();
  }
}
