import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../Features/Exams/create_exam/data/models/information_file_model.dart';
import '../../Utils/Enums/upload_option.dart';

class FileTextExtractor {
  /// Extract text from PDF file using Syncfusion
  Future<String> extractFromPdf(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);

      final extractedText = StringBuffer();
      final extractor = PdfTextExtractor(document);

      for (int i = 0; i < document.pages.count; i++) {
        final pageText = extractor.extractText(startPageIndex: i);
        extractedText.writeln(pageText);
        extractedText.writeln();
      }

      document.dispose();

      final result = extractedText.toString().trim();
      return result.isEmpty
          ? 'Unable to extract text from PDF. The file might be image-based or protected.'
          : result;
    } catch (e) {
      return 'Error reading PDF file: ${e.toString()}';
    }
  }

  /// Extract text from image using Google ML Kit OCR
  Future<String> extractFromImage(String filePath) async {
    try {
      final inputImage = InputImage.fromFilePath(filePath);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      if (recognizedText.text.trim().isEmpty) {
        return 'No text found in image.';
      }

      return recognizedText.text;
    } catch (e) {
      return 'Error reading image file: ${e.toString()}';
    }
  }

  /// Extract text from multiple files
  Future<List<String>> extractFromMultipleFiles(
    List<InformationFileModel> files,
  ) async {
    const separator = '----------------------------------';
    final extractedTexts = <String>[];

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      var text = '';

      try {
        if (file.type == FilesType.pdf) {
          text = await extractFromPdf(file.path);
        } else if (file.type == FilesType.image) {
          text = await extractFromImage(file.path);
        }

        final header = '\n$separator\n'
            'File ${i + 1}: ${file.name}\n'
            'Type: ${file.type.name.toUpperCase()}\n'
            'Size: ${file.sizeFormatted}\n'
            '$separator\n';

        extractedTexts.add(header + text);
      } catch (e) {
        extractedTexts.add(
          '\n$separator\n'
          'File ${i + 1}: ${file.name}\n'
          'Error: Could not process this file.\n'
          'Details: ${e.toString()}\n'
          '$separator\n',
        );
      }
    }

    return extractedTexts;
  }

  /// Combine all extracted texts into one string
  String combineTexts(List<String> texts) {
    return texts.join('\n\n');
  }

  /// Extract and combine in one step
  Future<String> extractAndCombine(List<InformationFileModel> files) async {
    final texts = await extractFromMultipleFiles(files);
    return combineTexts(texts);
  }

  /// Validate if extracted text is sufficient for exam generation
  bool isTextSufficient(String text, {int minWords = 50}) {
    final cleanText = text
        .replaceAll(RegExp(r'-+'), '')
        .replaceAll(RegExp(r'File \d+:.*'), '')
        .replaceAll(RegExp(r'Type:.*'), '')
        .replaceAll(RegExp(r'Size:.*'), '')
        .trim();

    final words = cleanText.split(RegExp(r'\s+'));
    final validWords = words.where((w) => w.length > 2).length;

    return validWords >= minWords;
  }

  /// Get statistics about extracted text
  Map<String, dynamic> getTextStatistics(String text) {
    final cleanText = text
        .replaceAll(RegExp(r'-+'), '')
        .replaceAll(RegExp(r'File \d+:.*'), '')
        .trim();

    final words = cleanText.split(RegExp(r'\s+'));
    final sentences = cleanText.split(RegExp(r'[.!?]+'));
    final characters = cleanText.length;

    return {
      'totalWords': words.length,
      'validWords': words.where((w) => w.length > 2).length,
      'sentences': sentences.where((s) => s.trim().isNotEmpty).length,
      'characters': characters,
      'averageWordLength': words.isEmpty
          ? 0
          : (words.map((w) => w.length).reduce((a, b) => a + b) / words.length)
              .round(),
    };
  }
}
