class ImageAnalysisScreen extends StatefulWidget {
  @override
  _ImageAnalysisScreenState createState() => _ImageAnalysisScreenState();
}

class _ImageAnalysisScreenState extends State<ImageAnalysisScreen> {
  final RekognitionService _rekognitionService = RekognitionService();
  final ImagePicker _picker = ImagePicker();
  List<Label> _labels = [];

  Future<void> _analyzeImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final labels = await _rekognitionService.detectLabels(image.path);
      setState(() {
        _labels = labels;
      });
    } catch (e) {
      print('Error analyzing image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Analysis')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _analyzeImage,
            child: Text('Select and Analyze Image'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _labels.length,
              itemBuilder: (context, index) {
                final label = _labels[index];
                return ListTile(
                  title: Text(label.name ?? ''),
                  subtitle: Text('Confidence: ${label.confidence?.toStringAsFixed(2)}%'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 