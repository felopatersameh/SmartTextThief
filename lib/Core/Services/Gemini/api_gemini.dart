import 'package:google_generative_ai/google_generative_ai.dart';

/// Gemini API client
class ApiGemini {
  final String _keyApi;
  final String _nameModel = "gemini-2.5-flash";
  late final GenerativeModel _model;

  ApiGemini({required String apiKey}) : _keyApi = apiKey {
    _model = GenerativeModel(
      model: _nameModel,
      apiKey: _keyApi,
      generationConfig: GenerationConfig(
        temperature: 0.2,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 4096,
        responseMimeType: 'application/json',
      ),
    );
  }

  Future<GenerateContentResponse> generateContent(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      return await _model.generateContent(content);
    } catch (e) {
      // log('Gemini API error: $e');
      rethrow;
    }
  }
}
