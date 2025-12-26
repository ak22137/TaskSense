// API Configuration
class ApiConfig {
  // Change this to your deployed backend URL
  static const String baseUrl = 'http://localhost:3000/api';
  
  // For production, use your Render.com URL:
  // static const String baseUrl = 'https://tasksense-api.onrender.com/api';
  
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
