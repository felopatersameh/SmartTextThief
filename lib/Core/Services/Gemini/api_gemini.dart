import 'package:google_generative_ai/google_generative_ai.dart';

/// Gemini API client
class ApiGemini {
  final String _keyApi = "AIzaSyCm2w5uUezoREJaS0PeqStryv_U7tHM5Bk";
  final String _nameModel = "gemini-2.5-flash";
  late final GenerativeModel _model;

  ApiGemini() {
    _model = GenerativeModel(
      model: _nameModel,
      apiKey: _keyApi,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );
  }

  Future<String> generateContent(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'No reply found. Please try again.';
    } catch (e) {
      // log('Gemini API error: $e');
      rethrow;
    }
  }
}
