import 'dart:io';

import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../Utils/Models/exam_model.dart';
import '../../Utils/Models/questions_generated_model.dart';
import '../../Utils/Models/subject_model.dart';

class ExamPdfUtil {
  // A function to detect Arabic text
  static bool _isArabic(String text) {
    if (text.isEmpty) return false;
    final arabicRegex = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]');
    return arabicRegex.hasMatch(text);
  }

  static String _sanitizeFileName(String value) {
    final sanitized =
        value.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_').trim();
    return sanitized.isEmpty ? 'exam' : sanitized;
  }

  static Future<Directory> _resolveOutputDirectory(String subjectName) async {
    final safeSubjectName =
        _sanitizeFileName(subjectName.isEmpty ? 'General' : subjectName);

    final directories = <Directory>[
      if (Platform.isAndroid)
        Directory(
            '/storage/emulated/0/Download/SmartTextThief/pdf/$safeSubjectName'),
      Directory(
        '${Directory.systemTemp.path}/SmartTextThief/pdf/$safeSubjectName',
      ),
    ];

    for (final directory in directories) {
      try {
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        return directory;
      } catch (_) {
        // Try next candidate directory.
      }
    }

    throw FileSystemException('Unable to create a writable PDF directory.');
  }

  static Future<void> createExamPdf({
    required ExamModel examData,
    required SubjectModel examInfo,
  }) async {
    try {
      // final fileName = _sanitizeFileName('Exam_${examData.specialIdLiveExam}');
      final fileName = examData.name;
      final outputDirectory = await _resolveOutputDirectory(
        examInfo.subjectName,
      );

      // Define the PDF file path
      final pdfFile = File('${outputDirectory.path}/$fileName.pdf');

      // Load fonts
      final fontData = await rootBundle.load("assets/Fonts/Roboto-Regular.ttf");
      final fontBold = await rootBundle.load("assets/Fonts/Roboto-Bold.ttf");

      final fontArabicData =
          await rootBundle.load("assets/Fonts/Cairo-Regular.ttf");
      final fontArabicBoldLoaded =
          await rootBundle.load("assets/Fonts/Cairo-Bold.ttf");

      final font = pw.Font.ttf(fontData);
      final fontBoldTtf = pw.Font.ttf(fontBold);
      final fontArabic = pw.Font.ttf(fontArabicData);
      final fontArabicBold = pw.Font.ttf(fontArabicBoldLoaded);

      final imageData = await rootBundle.load("assets/Image/logo.png");
      final logoImage = pw.MemoryImage(imageData.buffer.asUint8List());

      // Get exam questions
      final List<QuestionsGeneratedModel> questions = examData.questions;

      // Create PDF document
      final pdf = pw.Document();

      // First page - Exam Info
      pdf.addPage(
        pw.Page(
          pageTheme: _buildPageTheme(font, logoImage, isShow: false),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Image(logoImage, width: 200, height: 200),
              pw.Spacer(flex: 2),
              _buildExamHeader(
                font,
                fontBoldTtf,
                fontArabic,
                fontArabicBold,
                examInfo,
                examData,
              ),
              pw.Spacer(),
              pw.Spacer(),
            ],
          ),
        ),
      );

      // Questions pages
      pdf.addPage(
        pw.MultiPage(
          pageTheme: _buildPageTheme(font, logoImage),
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Exam Questions',
                style: pw.TextStyle(
                  font: fontBoldTtf,
                  fontSize: 20,
                  color: PdfColors.blue900,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            ...questions.asMap().entries.map((entry) {
              int index = entry.key;
              var question = entry.value;
              return _buildQuestion(
                question,
                index + 1,
                font,
                fontBoldTtf,
                fontArabic,
                fontArabicBold,
              );
            }),
          ],
        ),
      );

      // Answer Key page
      pdf.addPage(
        pw.MultiPage(
          pageTheme: _buildPageTheme(font, logoImage),
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Answer Key',
                style: pw.TextStyle(
                  font: fontBoldTtf,
                  fontSize: 20,
                  color: PdfColors.green900,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            ...questions.asMap().entries.map((entry) {
              int index = entry.key;
              var question = entry.value;
              return _buildAnswerKey(
                question,
                index + 1,
                font,
                fontBoldTtf,
                fontArabic,
                fontArabicBold,
              );
            }),
          ],
        ),
      );

      // Save and open the PDF file
      if (await pdfFile.exists()) {
        await pdfFile.delete();
      }
      await pdfFile.writeAsBytes(await pdf.save());
      await OpenFile.open(pdfFile.path);
    } catch (e) {
      rethrow;
    }
  }

  // Build page theme with watermark
  static pw.PageTheme _buildPageTheme(
    pw.Font font,
    pw.MemoryImage logoImage, {
    bool isShow = true,
  }) {
    return pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      theme: pw.ThemeData.withFont(base: font),
      buildBackground: (context) => pw.FullPage(
        ignoreMargins: true,
        child: pw.Stack(
          children: [
            pw.Container(
              margin: pw.EdgeInsets.all(10),
              color: PdfColor.fromInt(0xFFF5EDE2),
            ),
            isShow
                ? pw.Positioned(
                    top: 10,
                    right: 10,
                    child: pw.Opacity(
                      opacity: .98,
                      child: pw.Image(logoImage, width: 60, height: 60),
                    ),
                  )
                : pw.Container(),
          ],
        ),
      ),
    );
  }

  // Build exam header with info
  static pw.Widget _buildExamHeader(
    pw.Font font,
    pw.Font fontBold,
    pw.Font fontArabic,
    pw.Font fontArabicBold,
    SubjectModel subInfo,
    ExamModel examInfo,
  ) {
    return pw.Column(
      children: [
        pw.Container(
          width: 450,
          padding: pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.blue900, width: 2),
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'Exam Information',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 24,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 20),
              _buildCenteredInfoRow(
                'Subject:',
                subInfo.subjectName,
                font,
                fontBold,
                fontArabic,
                fontArabicBold,
              ),
              pw.SizedBox(height: 8),
              _buildCenteredInfoRow(
                'Exam Name:',
                examInfo.name,
                font,
                fontBold,
                fontArabic,
                fontArabicBold,
              ),
              pw.SizedBox(height: 8),
              _buildCenteredInfoRow(
                'Level:',
                examInfo.levelExam,
                font,
                fontBold,
                fontArabic,
                fontArabicBold,
              ),
              pw.SizedBox(height: 8),
              _buildCenteredInfoRow(
                'Number of Questions:',
                examInfo.questionCount.toString(),
                font,
                fontBold,
                fontArabic,
                fontArabicBold,
              ),
              pw.SizedBox(height: 8),
              _buildCenteredInfoRow(
                'Start Date:',
                examInfo.started,
                font,
                fontBold,
                fontArabic,
                fontArabicBold,
              ),
              pw.SizedBox(height: 8),
              _buildCenteredInfoRow(
                'End Date:',
                examInfo.ended,
                font,
                fontBold,
                fontArabic,
                fontArabicBold,
              ),
              pw.SizedBox(height: 8),
              _buildCenteredInfoRow(
                'Created At:',
                examInfo.created,
                font,
                fontBold,
                fontArabic,
                fontArabicBold,
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 200),
        pw.Container(
          width: 450,
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.SizedBox(height: 15),
                  pw.Container(
                    padding: pw.EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(
                          color: PdfColors.grey800,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: pw.Directionality(
                      textDirection:
                          _isArabic(subInfo.subjectTeacher.teacherName)
                              ? pw.TextDirection.rtl
                              : pw.TextDirection.ltr,
                      child: pw.Text(
                        "Dr.${subInfo.subjectTeacher.teacherName}",
                        style: pw.TextStyle(
                          font: _isArabic(subInfo.subjectTeacher.teacherName)
                              ? fontArabicBold
                              : fontBold,
                          fontSize: 16,
                          color: PdfColors.blue900,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(width: 30),
            ],
          ),
        ),
      ],
    );
  }

  // Build centered info row
  static pw.Widget _buildCenteredInfoRow(
    String label,
    String value,
    pw.Font font,
    pw.Font fontBold,
    pw.Font fontArabic,
    pw.Font fontArabicBold,
  ) {
    bool isValueArabic = _isArabic(value);

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 14,
            color: PdfColors.grey800,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Directionality(
          textDirection:
              isValueArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          child: pw.Text(
            value,
            style: pw.TextStyle(
              font: isValueArabic ? fontArabic : font,
              fontSize: 14,
              color: PdfColors.black,
            ),
          ),
        ),
      ],
    );
  }

  // Build question widget
  static pw.Widget _buildQuestion(
    QuestionsGeneratedModel question,
    int questionNumber,
    pw.Font font,
    pw.Font fontBold,
    pw.Font fontArabic,
    pw.Font fontArabicBold,
  ) {
    final String questionText = question.text;
    final String questionType = question.type;
    final List<String> options =
        question.options.map((option) => option.choice).toList(growable: false);
    bool isQuestionArabic = _isArabic(questionText);

    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: 20),
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.grey100,
      ),
      child: pw.Column(
        crossAxisAlignment: isQuestionArabic
            ? pw.CrossAxisAlignment.end
            : pw.CrossAxisAlignment.start,
        children: [
          // Question number and text
          pw.Directionality(
            textDirection:
                isQuestionArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
            child: pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: isQuestionArabic
                        ? ' .س$questionNumber'
                        : 'Q$questionNumber. ',
                    style: pw.TextStyle(
                      font: isQuestionArabic ? fontArabicBold : fontBold,
                      fontSize: 14,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.TextSpan(
                    text: questionText,
                    style: pw.TextStyle(
                      font: isQuestionArabic ? fontArabic : font,
                      fontSize: 14,
                      color: PdfColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          pw.SizedBox(height: 10),

          // Options
          if (options.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            ...options.asMap().entries.map((entry) {
              int index = entry.key;
              String option = entry.value;
              String optionLabel = String.fromCharCode(65 + index);
              bool isOptionArabic = _isArabic(option);

              return pw.Padding(
                padding: pw.EdgeInsets.only(
                  left: isOptionArabic ? 0 : 20,
                  right: isOptionArabic ? 20 : 0,
                  top: 5,
                ),
                child: pw.Directionality(
                  textDirection: isOptionArabic
                      ? pw.TextDirection.rtl
                      : pw.TextDirection.ltr,
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        isOptionArabic ? '($optionLabel ' : '$optionLabel) ',
                        style: pw.TextStyle(
                          font: isOptionArabic ? fontArabicBold : fontBold,
                          fontSize: 12,
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          option,
                          style: pw.TextStyle(
                            font: isOptionArabic ? fontArabic : font,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],

          // Answer space for short answer questions
          if (questionType == 'short_answer') ...[
            pw.SizedBox(height: 10),
            pw.Text(
              'Answer space',
              style: pw.TextStyle(
                font: font,
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Container(
              height: 80,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColors.grey400,
                  style: pw.BorderStyle.dashed,
                ),
                borderRadius: pw.BorderRadius.circular(4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Build answer key
  static pw.Widget _buildAnswerKey(
    QuestionsGeneratedModel question,
    int questionNumber,
    pw.Font font,
    pw.Font fontBold,
    pw.Font fontArabic,
    pw.Font fontArabicBold,
  ) {
    String correctAnswer = question.correctAnswer;
    bool isAnswerArabic = _isArabic(correctAnswer);

    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: 10),
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.green300),
        borderRadius: pw.BorderRadius.circular(6),
        color: PdfColors.green50,
      ),
      child: pw.Directionality(
        textDirection:
            isAnswerArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 60,
              child: pw.Text(
                isAnswerArabic ? ':س$questionNumber' : 'Q$questionNumber:',
                style: pw.TextStyle(
                  font: isAnswerArabic ? fontArabicBold : fontBold,
                  fontSize: 12,
                  color: PdfColors.green900,
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                correctAnswer,
                style: pw.TextStyle(
                  font: isAnswerArabic ? fontArabic : font,
                  fontSize: 12,
                  color: PdfColors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
