import 'package:passion_tree_frontend/core/error/exceptions.dart';

class CreateReflectionRequest {
  final String learningReflect;
  final String moodReflect;
  final int feelScore;
  final int progressScore;
  final int challengeScore;
  final String treeNodeId;

  CreateReflectionRequest({
    required this.learningReflect,
    required this.moodReflect,
    required this.feelScore,
    required this.progressScore,
    required this.challengeScore,
    required this.treeNodeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'learning_reflect': learningReflect,
      'mood_reflect': moodReflect,
      'feel_score': feelScore,
      'progress_score': progressScore,
      'challenge_score': challengeScore,
      'tree_node_id': treeNodeId,
    };
  }
}

class ReflectionApiModel {
  final String reflectId;
  final String summary;
  final String sentimentAnalysis;
  final String? primaryEmotion;
  final String strugglePoint;
  final String developmentPlan;
  final double aiConfidentScore;
  final double reflectionScore;
  final double weightedReflectionScore;
  final String? learnText;
  final String? feelText;
  final int? feelScore;
  final int? progressScore;
  final int? challengeScore;

  ReflectionApiModel({
    required this.reflectId,
    required this.summary,
    required this.sentimentAnalysis,
    this.primaryEmotion,
    required this.strugglePoint,
    required this.developmentPlan,
    required this.aiConfidentScore,
    required this.reflectionScore,
    required this.weightedReflectionScore,
    this.learnText,
    this.feelText,
    this.feelScore,
    this.progressScore,
    this.challengeScore,
  });

  factory ReflectionApiModel.fromJson(Map<String, dynamic> json) {
    try {
      final dynamic developmentPlanValue = json['development_plan'];
      final String developmentPlan = developmentPlanValue is List
          ? developmentPlanValue
                .whereType<String>()
                .where((item) => item.trim().isNotEmpty)
                .join('\n')
          : (developmentPlanValue as String?) ?? '';

      return ReflectionApiModel(
        reflectId: json['reflect_id'] ?? '',
        summary: json['summary'] ?? '',
        sentimentAnalysis: json['sentiment_analysis'] ?? '',
        primaryEmotion: json['primary_emotion'],
        strugglePoint: json['struggle_point'] ?? '',
        developmentPlan: developmentPlan,
        aiConfidentScore: (json['ai_confident_score'] ?? 0.0).toDouble(),
        reflectionScore: (json['reflection_score'] ?? 0.0).toDouble(),
        weightedReflectionScore: (json['weighted_reflection_score'] ?? 0.0).toDouble(),
        learnText: json['reflect_description'] as String?,
        feelText: json['reflect'] as String?,
        feelScore: _parseInt(json['reflect_score']),
        progressScore: _parseInt(json['progress_score']),
        challengeScore: _parseInt(json['challenge_score']),
      );
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse ReflectionApiModel',
        originalError: e,
      );
    }
  }

  static int? _parseInt(dynamic val) {
    if (val == null) return null;
    if (val is int) return val;
    if (val is double) return val.round();
    if (val is String) {
      return int.tryParse(val) ?? double.tryParse(val)?.round();
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'reflect_id': reflectId,
      'summary': summary,
      'sentiment_analysis': sentimentAnalysis,
      'primary_emotion': primaryEmotion,
      'struggle_point': strugglePoint,
      'development_plan': developmentPlan,
      'ai_confident_score': aiConfidentScore,
      'reflection_score': reflectionScore,
      'weighted_reflection_score': weightedReflectionScore,
    };
  }
}
