class ModelUtils {
  /// Formats model size in bytes to human-readable string
  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Formats a model size string like "3.8GB" or "466MB"
  static String formatModelSize(String sizeStr) {
    return sizeStr;
  }

  /// Extracts model name from file path
  static String modelNameFromPath(String path) {
    final parts = path.split('/');
    final fileName = parts.last;
    return fileName.replaceAll('.gguf', '').replaceAll('.GGUF', '');
  }

  /// Returns model family from name
  static String modelFamily(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('llama')) return 'Llama';
    if (lower.contains('mistral')) return 'Mistral';
    if (lower.contains('gemma')) return 'Gemma';
    if (lower.contains('phi')) return 'Phi';
    if (lower.contains('qwen')) return 'Qwen';
    if (lower.contains('codellama')) return 'Code Llama';
    if (lower.contains('deepseek')) return 'DeepSeek';
    return 'Other';
  }

  /// Validates a URL
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }

  /// Builds Ollama base URL
  static String buildOllamaUrl(String host, {int port = 11434}) {
    if (host.startsWith('http')) {
      return '$host:$port';
    }
    return 'http://$host:$port';
  }

  /// Estimates tokens from text
  static int estimateTokens(String text) {
    return (text.length / 4).ceil();
  }
}
