import 'dart:io';

import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../Utils/Models/exam_model.dart';
import '../../Utils/Models/exam_result_q_a.dart';
import '../../Utils/Models/subject_model.dart';

class ExamPdfUtil {
  static Future<void> createExamPdf({
    required ExamModel examData,
    required SubjectModel examInfo,
  }) async {
    try {
      String fileName =
          'Exam_${examData.examId}_${DateTime.now().millisecondsSinceEpoch}';
      Directory downloadsDirectory = Directory(
        '/storage/emulated/0/Download/Exams',
      );

      // Create directory if it doesn't exist
      if (!await downloadsDirectory.exists()) {
        await downloadsDirectory.create(recursive: true);
      }

      // Define the PDF file path
      File pdfFile = File('${downloadsDirectory.path}/$fileName.pdf');

      // Load font and image assets
      final fontData = await rootBundle.load("assets/Fonts/Roboto-Regular.ttf");
      final fontBold = await rootBundle.load("assets/Fonts/Roboto-Bold.ttf");
      final font = pw.Font.ttf(fontData);
      final fontBoldTtf = pw.Font.ttf(fontBold);
      final imageData = await rootBundle.load("assets/Image/logo.png");
      final logoImage = pw.MemoryImage(imageData.buffer.asUint8List());

      // Get exam questions
      List<ExamResultQA> questions = examData.examStatic.examResultQA;

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
              _buildExamHeader(font, fontBoldTtf, examInfo, examData),
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
              return _buildQuestion(question, index + 1, font, fontBoldTtf);
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
              return _buildAnswerKey(question, index + 1, font, fontBoldTtf);
            }),
          ],
        ),
      );

      // Save and open the PDF file
      await pdfFile.writeAsBytes(await pdf.save());
      await OpenFile.open(pdfFile.path);
    } catch (e) {
      // print('Error creating exam PDF: $e');
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
            // Watermark
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
              ),
              pw.SizedBox(height: 8),
              _buildCenteredInfoRow(
                'Exam Type:',
                examInfo.examStatic.typeExam,
                font,
                fontBold,
              ),
              pw.SizedBox(height: 8),
              _buildCenteredInfoRow(
                'Level:',
                examInfo.examStatic.levelExam.name,
                font,
                fontBold,
              ),
              pw.SizedBox(height: 8),
              _buildCenteredInfoRow(
                'Number of Questions:',
                examInfo.examStatic.numberOfQuestions.toString(),
                font,
                fontBold,
              ),
              pw.SizedBox(height: 8),
              _buildCenteredInfoRow(
                'Start Date:',
                examInfo.started ?? 'N/A',
                font,
                fontBold,
              ),
              pw.SizedBox(height: 8),
              _buildCenteredInfoRow(
                'End Date:',
                examInfo.ended ?? 'N/A',
                font,
                fontBold,
              ),
              pw.SizedBox(height: 8),
              _buildCenteredInfoRow(
                'Created At:',
                examInfo.created ?? 'N/A',
                font,
                fontBold,
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
                  // pw.Text(
                  //   'Teacher',
                  //   style: pw.TextStyle(
                  //     font: font,
                  //     fontSize: 12,
                  //     color: PdfColors.grey700,
                  //   ),
                  // ),
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
                    child: pw.Text(
                      "Dr.${subInfo.subjectTeacher.teacherName}",
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 16,
                        color: PdfColors.blue900,
                        fontStyle: pw.FontStyle.italic,
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
  ) {
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
        pw.Text(
          value,
          style: pw.TextStyle(font: font, fontSize: 14, color: PdfColors.black),
        ),
      ],
    );
  }

  // Build info row

  // Build question widget
  static pw.Widget _buildQuestion(
    ExamResultQA question,
    int questionNumber,
    pw.Font font,
    pw.Font fontBold,
  ) {
    String questionText = question.questionText;
    String questionType = question.questionType;
    List<dynamic> options = question.options;

    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: 20),
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.grey100,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Question number and text
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: 'Q$questionNumber. ',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 14,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.TextSpan(
                  text: questionText,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 14,
                    color: PdfColors.black,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),

          // Options (if available)
          if (options.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            ...options.asMap().entries.map((entry) {
              int index = entry.key;
              String option = entry.value.toString();
              String optionLabel = String.fromCharCode(
                65 + index,
              ); // A, B, C, D...
              return pw.Padding(
                padding: pw.EdgeInsets.only(left: 20, top: 5),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '$optionLabel) ',
                      style: pw.TextStyle(font: fontBold, fontSize: 12),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        option,
                        style: pw.TextStyle(font: font, fontSize: 12),
                      ),
                    ),
                  ],
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
    ExamResultQA question,
    int questionNumber,
    pw.Font font,
    pw.Font fontBold,
  ) {
    String correctAnswer = question.correctAnswer;

    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: 10),
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.green300),
        borderRadius: pw.BorderRadius.circular(6),
        color: PdfColors.green50,
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 60,
            child: pw.Text(
              'Q$questionNumber:',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 12,
                color: PdfColors.green900,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              correctAnswer,
              style: pw.TextStyle(
                font: font,
                fontSize: 12,
                color: PdfColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
