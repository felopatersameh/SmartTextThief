import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:smart_text_thief/Core/Utils/Enums/upload_option.dart';
import 'package:smart_text_thief/Features/Exams/shared/Models/information_file_model.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class FileTextExtractor {
  Future<String> extractFromPdf(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);

      final extractedText = StringBuffer();
      final extractor = PdfTextExtractor(document);

      for (var i = 0; i < document.pages.count; i++) {
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

  Future<List<String>> extractFromMultipleFiles(
    List<InformationFileModel> files,
  ) async {
    const separator = '----------------------------------';
    final extractedTexts = <String>[];

    for (var i = 0; i < files.length; i++) {
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

  String combineTexts(List<String> texts) {
    return texts.join('\n\n');
  }

  Future<String> extractAndCombine(List<InformationFileModel> files) async {
    final texts = await extractFromMultipleFiles(files);
    return combineTexts(texts);
  }

  bool isTextSufficient(String text, {int minWords = 50}) {
    final cleanText = text
        .replaceAll(RegExp(r'-+'), '')
        .replaceAll(RegExp(r'File \d+:.*'), '')
        .replaceAll(RegExp(r'Type:.*'), '')
        .replaceAll(RegExp(r'Size:.*'), '')
        .trim();

    final words = cleanText.split(RegExp(r'\s+'));
    final validWords = words.where((word) => word.length > 2).length;

    return validWords >= minWords;
  }

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
      'validWords': words.where((word) => word.length > 2).length,
      'sentences':
          sentences.where((sentence) => sentence.trim().isNotEmpty).length,
      'characters': characters,
      'averageWordLength': words.isEmpty
          ? 0
          : (words.map((word) => word.length).reduce((a, b) => a + b) /
                  words.length)
              .round(),
    };
  }
}
