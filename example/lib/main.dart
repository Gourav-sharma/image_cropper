import 'dart:async';
import 'package:image_crop_bundle/image_crop_bundle.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const CropDemoPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// -------------------------
/// MAIN DEMO PAGE
/// -------------------------
class CropDemoPage extends StatefulWidget {
  const CropDemoPage({super.key});

  @override
  State<CropDemoPage> createState() => _CropDemoPageState();
}

class _CropDemoPageState extends State<CropDemoPage> {
  Uint8List? _croppedBytes;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();

      // ✅ free crop
     // final cropped = await ImageCropper.openCropper(context, bytes);

      // ✅ square crop
       final cropped = await ImageCropper.openCropper(context, bytes, aspectRatio: 1.0);

      // ✅ 16:9 crop
      // final cropped = await ImageCropper.openCropper(context, bytes, aspectRatio: 16 / 9);

      if (cropped != null) {
        setState(() => _croppedBytes = cropped);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image Crop Plugin Demo")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Pick & Crop Image"),
            ),
            const SizedBox(height: 20),
            if (_croppedBytes != null)
              Image.memory(_croppedBytes!, fit: BoxFit.cover),
          ],
        ),
      ),
    );
  }
}
