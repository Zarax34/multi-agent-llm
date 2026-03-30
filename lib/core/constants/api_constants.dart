class ApiConstants {
  // Ollama default port
  static const int ollamaDefaultPort = 11434;

  // Ollama API endpoints
  static const String ollamaApiBase = '/api';
  static const String ollamaTags = '/api/tags';
  static const String ollamaChat = '/api/chat';
  static const String ollamaPs = '/api/ps';
  static const String ollamaPull = '/api/pull';
  static const String ollamaShow = '/api/show';
  static const String ollamaGenerate = '/api/generate';
  static const String ollamaDelete = '/api/delete';
  static const String ollamaCopy = '/api/copy';
  static const String ollamaEmbeddings = '/api/embeddings';

  // OpenAI default endpoints
  static const String openaiChatCompletions = '/v1/chat/completions';
  static const String openaiModels = '/v1/models';

  // Connection timeout in seconds
  static const int connectTimeout = 10;
  static const int receiveTimeout = 30;
  static const int streamTimeout = 120;

  // Discovery
  static const int discoveryTimeout = 3; // seconds per IP
  static const int maxConcurrentScans = 20;
}
