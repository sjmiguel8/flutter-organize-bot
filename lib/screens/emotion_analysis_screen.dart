import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/face_analysis_service.dart';
import 'dart:html' as html;

class EmotionAnalysisScreen extends StatefulWidget {
  @override
  _EmotionAnalysisScreenState createState() => _EmotionAnalysisScreenState();
}

class _EmotionAnalysisScreenState extends State<EmotionAnalysisScreen> {
  final FaceAnalysisService _faceService = FaceAnalysisService();
  final ImagePicker _picker = ImagePicker();
  String? _imageUrl;
  Map<String, dynamic>? _emotions;
  bool _isLoading = false;

  Future<void> _analyzeEmotions() async {
    try {
      setState(() => _isLoading = true);
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      
      if (image == null) {
        setState(() => _isLoading = false);
        return;
      }

      final bytes = await image.readAsBytes();
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      setState(() {
        _imageUrl = url;
      });

      final emotions = await _faceService.analyzeEmotion(image.path);
      setState(() {
        _emotions = emotions;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error analyzing image: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emotion Analysis'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (_imageUrl != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _imageUrl!,
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  if (_isLoading)
                    Center(child: CircularProgressIndicator())
                  else if (_emotions != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dominant Emotion: ${_emotions!['dominant_emotion']}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              SizedBox(height: 12),
                              ...(_emotions!['emotion'] as Map<String, dynamic>).entries.map((entry) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${entry.key}: ${(entry.value * 100).toStringAsFixed(1)}%',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    LinearProgressIndicator(
                                      value: entry.value,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _getEmotionColor(entry.key),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _analyzeEmotions,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Select Image for Analysis'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return Colors.yellow;
      case 'sad':
        return Colors.blue;
      case 'angry':
        return Colors.red;
      case 'fear':
        return Colors.purple;
      case 'disgust':
        return Colors.green;
      case 'surprise':
        return Colors.orange;
      case 'neutral':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
} 