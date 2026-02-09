import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';

/// Gemini API client
class ApiGemini {
  final String _keyApi;
  final String _nameModel;
  late final GenerativeModel _model;

  ApiGemini({
    required String apiKey,
    String modelName = AppConstants.defaultGeminiModel,
  })  : _keyApi = apiKey,
        _nameModel = modelName.trim().isEmpty
            ? AppConstants.defaultGeminiModel
            : modelName.trim() {
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
