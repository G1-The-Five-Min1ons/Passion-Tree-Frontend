class CreateNodeRequest {
  final String title;
  final String description;
  final String pathId;
  final String sequence;
  final List<CreateMaterialRequest>? materials;
  final List<CreateQuestionWithChoicesRequest>? questions;

  CreateNodeRequest({
    required this.title,
    this.description = '',
    required this.pathId,
    required this.sequence,
    this.materials,
    this.questions,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'path_id': pathId,
      'sequence': sequence,
    };
    
    if (materials != null && materials!.isNotEmpty) {
      data['material'] = materials!.map((v) => v.toJson()).toList();
    }

    if (questions != null && questions!.isNotEmpty) {
      data['Question'] = questions!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class CreateMaterialRequest {
  final String type;
  final String url;

  CreateMaterialRequest({required this.type, required this.url});

  Map<String, dynamic> toJson() => {'type': type, 'url': url};
}

class CreateQuestionWithChoicesRequest {
  final String questionText;
  final String type;
  final List<CreateChoiceRequest> choices;

  CreateQuestionWithChoicesRequest({
    required this.questionText,
    required this.type,
    required this.choices,
  });

  Map<String, dynamic> toJson() {
    return {
      'question_text': questionText,
      'type': type,
      'choice': choices.map((v) => v.toJson()).toList(),
    };
  }
}

class CreateChoiceRequest {
  final String choiceText;
  final bool isCorrect;
  final String reasoning;

  CreateChoiceRequest({
    required this.choiceText,
    required this.isCorrect,
    this.reasoning = '',
  });

  Map<String, dynamic> toJson() => {
    'choice_text': choiceText,
    'is_correct': isCorrect,
    'reasoning': reasoning,
  };
}
