import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';

class ApiGemini {
  final String _keyApi;
  final int maxOutputTokens;
  final double temperature;

  late final List<String> _models;

  ApiGemini({
    required String apiKey,
    String modelName = AppConstants.defaultGeminiModel,
    required this.maxOutputTokens,
    required this.temperature,
  }) : _keyApi = apiKey {
    // final primary =
    //     modelName.trim().isEmpty ? AppConstants.defaultGeminiModel : modelName.trim();

    _models = {
      "gemini-2.5-pro",
      "gemini-2.5-flash",
      "gemini-2.0-pro",
      "gemini-2.0-flash",
      "gemini-1.5-pro",
      "gemini-1.5-flash",
    }.toList();
  }

  Future<GenerateContentResponse> generateContent(String prompt) async {
    Exception? lastError;

    for (final modelName in _models) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: _keyApi,
          generationConfig: GenerationConfig(
            temperature: temperature,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: maxOutputTokens,
            responseMimeType: 'application/json',
          ),
        );

        final content = [Content.text(prompt)];
        return await model.generateContent(content);
      } catch (e) {
        lastError = e as Exception;

        final errorText = e.toString();

        /// fallback فقط لو quota أو rate limit
        if (errorText.contains("Quota") ||
            errorText.contains("429") ||
            errorText.contains("rate limit")) {
          continue; // جرب اللي بعده
        } else {
          rethrow; // مش مشكلة موديل → اطلع الخطأ
        }
      }
    }

    throw lastError ?? Exception("All Gemini models failed.Try Again Tomorrow");
  }
}
