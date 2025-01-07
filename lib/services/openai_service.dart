import 'package:dart_openai/dart_openai.dart';
import '../config/.env';

class OpenAIService {
  static const String _model = 'gpt-3.5-turbo';

  OpenAIService() {
    OpenAI.apiKey = APIKeys.openAI;
  }

  Future<String> getResponse(String message) async {
    try {
      final chatCompletion = await OpenAI.instance.chat.create(
        model: _model,
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                message,
              ),
            ],
          ),
        ],
      );

      final text = chatCompletion.choices.first.message.content!.first.text;
      if (text == null) {
        throw Exception('Received null response from OpenAI');
      }
      return text;
    } catch (e) {
      throw Exception('Error: Unable to get response from AI: $e');
    }
  }
}
