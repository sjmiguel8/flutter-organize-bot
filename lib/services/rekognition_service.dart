import 'package:amplify_flutter/amplify_flutter.dart';
import 'dart:io';

class RekognitionService {
  Future<List<Map<String, dynamic>>> detectEmotions(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final request = {
        'Image': {
          'Bytes': bytes,
        },
        'Attributes': ['ALL']
      };

      final response = await Amplify.API.post('/rekognition/detect-faces',
          body: request).response;

      final faces = response.decodeBody() as Map<String, dynamic>;
      if (faces['FaceDetails'] != null && faces['FaceDetails'].isNotEmpty) {
        return (faces['FaceDetails'][0]['Emotions'] as List)
            .cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error detecting emotions: $e');
      return [];
    }
  }
} 