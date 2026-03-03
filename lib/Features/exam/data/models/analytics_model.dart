  import 'package:equatable/equatable.dart';

class AnalyticsSubjectModel extends Equatable {
    const AnalyticsSubjectModel({
        required this.totalStudents,
        required this.totalExams,
        required this.totalSubmissions,
        required this.participation,
        required this.scores,
        required this.examsDifficulty,
        required this.questionsAnalysis,
        required this.generatedAt,
    });

    final List<TotalStudent> totalStudents;
    final num totalExams;
    final num totalSubmissions;
    final Participation? participation;
    final Scores? scores;
    final ExamsDifficulty? examsDifficulty;
    final QuestionsAnalysis? questionsAnalysis;
    final DateTime? generatedAt;

    AnalyticsSubjectModel copyWith({
        List<TotalStudent>? totalStudents,
        num? totalExams,
        num? totalSubmissions,
        Participation? participation,
        Scores? scores,
        ExamsDifficulty? examsDifficulty,
        QuestionsAnalysis? questionsAnalysis,
        DateTime? generatedAt,
    }) {
        return AnalyticsSubjectModel(
            totalStudents: totalStudents ?? this.totalStudents,
            totalExams: totalExams ?? this.totalExams,
            totalSubmissions: totalSubmissions ?? this.totalSubmissions,
            participation: participation ?? this.participation,
            scores: scores ?? this.scores,
            examsDifficulty: examsDifficulty ?? this.examsDifficulty,
            questionsAnalysis: questionsAnalysis ?? this.questionsAnalysis,
            generatedAt: generatedAt ?? this.generatedAt,
        );
    }

    factory AnalyticsSubjectModel.fromJson(Map<String, dynamic> json){ 
        return AnalyticsSubjectModel(
            totalStudents: json["totalStudents"] == null ? [] : List<TotalStudent>.from(json["totalStudents"]!.map((x) => TotalStudent.fromJson(x))),
            totalExams: json["totalExams"] ?? 0,
            totalSubmissions: json["totalSubmissions"] ?? 0,
            participation: json["participation"] == null ? null : Participation.fromJson(json["participation"]),
            scores: json["scores"] == null ? null : Scores.fromJson(json["scores"]),
            examsDifficulty: json["examsDifficulty"] == null ? null : ExamsDifficulty.fromJson(json["examsDifficulty"]),
            questionsAnalysis: json["questionsAnalysis"] == null ? null : QuestionsAnalysis.fromJson(json["questionsAnalysis"]),
            generatedAt: DateTime.tryParse(json["generatedAt"] ?? ""),
        );
    }

    Map<String, dynamic> toJson() => {
        "totalStudents": totalStudents.map((x) => x.toJson()).toList(),
        "totalExams": totalExams,
        "totalSubmissions": totalSubmissions,
        "participation": participation?.toJson(),
        "scores": scores?.toJson(),
        "examsDifficulty": examsDifficulty?.toJson(),
        "questionsAnalysis": questionsAnalysis?.toJson(),
        "generatedAt": generatedAt?.toIso8601String(),
    };

    @override
    List<Object?> get props => [
    totalStudents, totalExams, totalSubmissions, participation, scores, examsDifficulty, questionsAnalysis, generatedAt, ];
}

class ExamsDifficulty extends Equatable {
    const ExamsDifficulty({
        required this.hardest,
        required this.easiest,
    });

    final Est? hardest;
    final Est? easiest;

    ExamsDifficulty copyWith({
        Est? hardest,
        Est? easiest,
    }) {
        return ExamsDifficulty(
            hardest: hardest ?? this.hardest,
            easiest: easiest ?? this.easiest,
        );
    }

    factory ExamsDifficulty.fromJson(Map<String, dynamic> json){ 
        return ExamsDifficulty(
            hardest: json["hardest"] == null ? null : Est.fromJson(json["hardest"]),
            easiest: json["easiest"] == null ? null : Est.fromJson(json["easiest"]),
        );
    }

    Map<String, dynamic> toJson() => {
        "hardest": hardest?.toJson(),
        "easiest": easiest?.toJson(),
    };

    @override
    List<Object?> get props => [
    hardest, easiest, ];
}

class Est extends Equatable {
    const Est({
        required this.examId,
        required this.title,
        required this.averageScore,
    });

    final String examId;
    final String title;
    final num averageScore;

    Est copyWith({
        String? examId,
        String? title,
        num? averageScore,
    }) {
        return Est(
            examId: examId ?? this.examId,
            title: title ?? this.title,
            averageScore: averageScore ?? this.averageScore,
        );
    }

    factory Est.fromJson(Map<String, dynamic> json){ 
        return Est(
            examId: json["examId"] ?? "",
            title: json["title"] ?? "",
            averageScore: json["averageScore"] ?? 0,
        );
    }

    Map<String, dynamic> toJson() => {
        "examId": examId,
        "title": title,
        "averageScore": averageScore,
    };

    @override
    List<Object?> get props => [
    examId, title, averageScore, ];
}

class Participation extends Equatable {
    const Participation({
        required this.participated,
        required this.notParticipated,
        required this.rate,
    });

    final num participated;
    final num notParticipated;
    final num rate;

    Participation copyWith({
        num? participated,
        num? notParticipated,
        num? rate,
    }) {
        return Participation(
            participated: participated ?? this.participated,
            notParticipated: notParticipated ?? this.notParticipated,
            rate: rate ?? this.rate,
        );
    }

    factory Participation.fromJson(Map<String, dynamic> json){ 
        return Participation(
            participated: json["participated"] ?? 0,
            notParticipated: json["notParticipated"] ?? 0,
            rate: json["rate"] ?? 0,
        );
    }

    Map<String, dynamic> toJson() => {
        "participated": participated,
        "notParticipated": notParticipated,
        "rate": rate,
    };

    @override
    List<Object?> get props => [
    participated, notParticipated, rate, ];
}

class QuestionsAnalysis extends Equatable {
    const QuestionsAnalysis({
        required this.topWrong,
        required this.mostSkipped,
    });

    final List<TopWrong> topWrong;
    final List<MostSkipped> mostSkipped;

    QuestionsAnalysis copyWith({
        List<TopWrong>? topWrong,
        List<MostSkipped>? mostSkipped,
    }) {
        return QuestionsAnalysis(
            topWrong: topWrong ?? this.topWrong,
            mostSkipped: mostSkipped ?? this.mostSkipped,
        );
    }

    factory QuestionsAnalysis.fromJson(Map<String, dynamic> json){ 
        return QuestionsAnalysis(
            topWrong: json["topWrong"] == null ? [] : List<TopWrong>.from(json["topWrong"]!.map((x) => TopWrong.fromJson(x))),
            mostSkipped: json["mostSkipped"] == null ? [] : List<MostSkipped>.from(json["mostSkipped"]!.map((x) => MostSkipped.fromJson(x))),
        );
    }

    Map<String, dynamic> toJson() => {
        "topWrong": topWrong.map((x) => x.toJson()).toList(),
        "mostSkipped": mostSkipped.map((x) => x.toJson()).toList(),
    };

    @override
    List<Object?> get props => [
    topWrong, mostSkipped, ];
}

class MostSkipped extends Equatable {
    const MostSkipped({
        required this.questionId,
        required this.skipCount,
    });

    final String questionId;
    final num skipCount;

    MostSkipped copyWith({
        String? questionId,
        num? skipCount,
    }) {
        return MostSkipped(
            questionId: questionId ?? this.questionId,
            skipCount: skipCount ?? this.skipCount,
        );
    }

    factory MostSkipped.fromJson(Map<String, dynamic> json){ 
        return MostSkipped(
            questionId: json["questionId"] ?? "",
            skipCount: json["skipCount"] ?? 0,
        );
    }

    Map<String, dynamic> toJson() => {
        "questionId": questionId,
        "skipCount": skipCount,
    };

    @override
    List<Object?> get props => [
    questionId, skipCount, ];
}

class TopWrong extends Equatable {
    const TopWrong({
        required this.questionId,
        required this.wrongCount,
    });

    final String questionId;
    final num wrongCount;

    TopWrong copyWith({
        String? questionId,
        num? wrongCount,
    }) {
        return TopWrong(
            questionId: questionId ?? this.questionId,
            wrongCount: wrongCount ?? this.wrongCount,
        );
    }

    factory TopWrong.fromJson(Map<String, dynamic> json){ 
        return TopWrong(
            questionId: json["questionId"] ?? "",
            wrongCount: json["wrongCount"] ?? 0,
        );
    }

    Map<String, dynamic> toJson() => {
        "questionId": questionId,
        "wrongCount": wrongCount,
    };

    @override
    List<Object?> get props => [
    questionId, wrongCount, ];
}

class Scores extends Equatable {
    const Scores({
        required this.average,
        required this.highest,
        required this.lowest,
    });

    final num average;
    final num highest;
    final num lowest;

    Scores copyWith({
        num? average,
        num? highest,
        num? lowest,
    }) {
        return Scores(
            average: average ?? this.average,
            highest: highest ?? this.highest,
            lowest: lowest ?? this.lowest,
        );
    }

    factory Scores.fromJson(Map<String, dynamic> json){ 
        return Scores(
            average: json["average"] ?? 0,
            highest: json["highest"] ?? 0,
            lowest: json["lowest"] ?? 0,
        );
    }

    Map<String, dynamic> toJson() => {
        "average": average,
        "highest": highest,
        "lowest": lowest,
    };

    @override
    List<Object?> get props => [
    average, highest, lowest, ];
}

class TotalStudent extends Equatable {
    const TotalStudent({
        required this.name,
        required this.email,
        required this.status,
        required this.joinedAt,
    });

    final String name;
    final String email;
    final String status;
    final DateTime? joinedAt;

    TotalStudent copyWith({
        String? name,
        String? email,
        String? status,
        DateTime? joinedAt,
    }) {
        return TotalStudent(
            name: name ?? this.name,
            email: email ?? this.email,
            status: status ?? this.status,
            joinedAt: joinedAt ?? this.joinedAt,
        );
    }

    factory TotalStudent.fromJson(Map<String, dynamic> json){ 
        return TotalStudent(
            name: json["name"] ?? "",
            email: json["email"] ?? "",
            status: json["status"] ?? "",
            joinedAt: DateTime.tryParse(json["joinedAt"] ?? ""),
        );
    }

    Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "status": status,
        "joinedAt": joinedAt?.toIso8601String(),
    };

    @override
    List<Object?> get props => [
    name, email, status, joinedAt, ];
}
