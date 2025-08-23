
import 'dart:async';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:image_crop_bundle/image_crop_bundle.dart';

class ImageCropper {
  /// Open full-screen cropper and return cropped bytes
  static Future<Uint8List?> openCropper(
      BuildContext context,
      Uint8List bytes, {
        double? aspectRatio, // e.g. 1.0, 16/9, or null for freeform
      }) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CropPage(imageBytes: bytes, aspectRatio: aspectRatio),
      ),
    );
  }
}

/// -------------------------
/// CROP PAGE
/// -------------------------
class CropPage extends StatefulWidget {
  final Uint8List imageBytes;
  final double? aspectRatio;
  const CropPage({super.key, required this.imageBytes, this.aspectRatio});

  @override
  State<CropPage> createState() => _CropPageState();
}

class _CropPageState extends State<CropPage> {
  Rect _cropArea = const Rect.fromLTWH(50, 50, 200, 200);
  Size _widgetSize = Size.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crop Image"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _onConfirmCrop,
            tooltip: "Crop",
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _widgetSize = constraints.biggest;
          // Initialize a sensible default if it's too big for the current view
          if (_cropArea.width > _widgetSize.width || _cropArea.height > _widgetSize.height) {
            final side = (_widgetSize.shortestSide * 0.6).clamp(80.0, _widgetSize.shortestSide);
            final left = (_widgetSize.width - side) / 2;
            final top = (_widgetSize.height - side) / 2;
            _cropArea = Rect.fromLTWH(left, top, side, side);
          }

          return CropView(
            image: MemoryImage(widget.imageBytes),
            initialCropArea: _cropArea,
            aspectRatio: widget.aspectRatio,
            onAreaChanged: (rect) => _cropArea = rect,
          );
        },
      ),
    );
  }

  Future<void> _onConfirmCrop() async {
    // Decode to get original pixel size
    final codec = await ui.instantiateImageCodec(widget.imageBytes);
    final frame = await codec.getNextFrame();
    final uiImage = frame.image;
    final imgW = uiImage.width.toDouble();
    final imgH = uiImage.height.toDouble();

    // BoxFit.contain mapping
    final widgetAR = _widgetSize.width / _widgetSize.height;
    final imgAR = imgW / imgH;
    double scale;
    double offsetX = 0, offsetY = 0;
    if (imgAR > widgetAR) {
      // width-bound
      scale = _widgetSize.width / imgW;
      offsetY = (_widgetSize.height - imgH * scale) / 2;
    } else {
      // height-bound
      scale = _widgetSize.height / imgH;
      offsetX = (_widgetSize.width - imgW * scale) / 2;
    }

    // Intersect with displayed image rect (safety)
    final displayRect = Rect.fromLTWH(offsetX, offsetY, imgW * scale, imgH * scale);
    final inter = _cropArea.intersect(displayRect);
    if (inter.isEmpty) {
      Navigator.pop(context, null);
      return;
    }

    // Map UI -> image pixels
    int x = ((inter.left - offsetX) / scale).round().clamp(0, uiImage.width - 1);
    int y = ((inter.top - offsetY) / scale).round().clamp(0, uiImage.height - 1);
    int w = (inter.width / scale).round();
    int h = (inter.height / scale).round();
    w = w.clamp(1, uiImage.width - x);
    h = h.clamp(1, uiImage.height - y);

    // Crop with package:image
    final decoded = img.decodeImage(widget.imageBytes)!;
    final cropped = img.copyCrop(decoded, x: x, y: y, width: w, height: h);
    final out = Uint8List.fromList(img.encodeJpg(cropped, quality: 95));

    Navigator.pop(context, out);
  }
}

/// -------------------------
/// CROP VIEW (resizable + aspect ratio lock + mask)
/// -------------------------
class CropView extends StatefulWidget {
  final ImageProvider image;
  final Rect initialCropArea;
  final ValueChanged<Rect>? onAreaChanged;
  final double? aspectRatio;

  const CropView({
    super.key,
    required this.image,
    required this.initialCropArea,
    this.aspectRatio,
    this.onAreaChanged,
  });

  @override
  State<CropView> createState() => _CropViewState();
}

class _CropViewState extends State<CropView> {
  late Rect _cropArea;
  static const double _minSize = 60.0;
  static const double _handle = 22.0;

  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _cropArea = widget.initialCropArea;
  }

  void _notify(Rect r) {
    _cropArea = r;
    widget.onAreaChanged?.call(_cropArea);
    setState(() {});
  }

  Rect _clampTo(Size s, Rect r) {
    double left = r.left.clamp(0.0, s.width - _minSize);
    double top = r.top.clamp(0.0, s.height - _minSize);
    double width = r.width.clamp(_minSize, s.width - left);
    double height = r.height.clamp(_minSize, s.height - top);
    return Rect.fromLTWH(left, top, width, height);
  }

  Rect _applyAspect(Rect r, String corner) {
    if (widget.aspectRatio == null) return r;
    final ar = widget.aspectRatio!;
    // keep width, recompute height
    double w = r.width;
    double h = (w / ar).clamp(_minSize, double.infinity);

    switch (corner) {
      case 'tl':
        return Rect.fromLTWH(r.right - w, r.bottom - h, w, h);
      case 'tr':
        return Rect.fromLTWH(r.left, r.bottom - h, w, h);
      case 'bl':
        return Rect.fromLTWH(r.right - w, r.top, w, h);
      case 'br':
      default:
        return Rect.fromLTWH(r.left, r.top, w, h);
    }
  }

  void _resize(String corner, Offset delta) {
    Rect r;
    switch (corner) {
      case 'tl':
        r = Rect.fromLTRB(_cropArea.left + delta.dx, _cropArea.top + delta.dy, _cropArea.right, _cropArea.bottom);
        break;
      case 'tr':
        r = Rect.fromLTRB(_cropArea.left, _cropArea.top + delta.dy, _cropArea.right + delta.dx, _cropArea.bottom);
        break;
      case 'bl':
        r = Rect.fromLTRB(_cropArea.left + delta.dx, _cropArea.top, _cropArea.right, _cropArea.bottom + delta.dy);
        break;
      case 'br':
      default:
        r = Rect.fromLTRB(_cropArea.left, _cropArea.top, _cropArea.right + delta.dx, _cropArea.bottom + delta.dy);
        break;
    }

    // Enforce min size first
    if (r.width < _minSize) {
      if (corner.contains('l')) r = Rect.fromLTRB(_cropArea.right - _minSize, r.top, r.right, r.bottom);
      else r = Rect.fromLTRB(r.left, r.top, _cropArea.left + _minSize, r.bottom);
    }
    if (r.height < _minSize) {
      if (corner.contains('t')) r = Rect.fromLTRB(r.left, _cropArea.bottom - _minSize, r.right, r.bottom);
      else r = Rect.fromLTRB(r.left, r.top, r.right, _cropArea.top + _minSize);
    }

    r = _applyAspect(r, corner);
    r = _clampTo(_lastSize, r);
    _notify(r);
  }

  Widget _corner(String id, Offset posGetter(Rect r)) {
    final pos = posGetter(_cropArea);
    return Positioned(
      left: pos.dx - _handle / 2,
      top: pos.dy - _handle / 2,
      child: GestureDetector(
        onPanUpdate: (d) => _resize(id, d.delta),
        child: Container(
          width: _handle,
          height: _handle,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _lastSize = constraints.biggest;

      return GestureDetector(
        onPanUpdate: (d) => _notify(_clampTo(_lastSize, _cropArea.shift(d.delta))),
        child: Stack(
          children: [
            // Image (fit: contain)
            Positioned.fill(
              child: Image(image: widget.image, fit: BoxFit.contain),
            ),

            // Dimmed outside, clear inside + border
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _CropMaskPainter(_cropArea)),
              ),
            ),

            // Crop rectangle outline (hit area for moving is the parent GestureDetector)
            Positioned.fromRect(
              rect: _cropArea,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                ),
              ),
            ),

            // Corner handles
            _corner('tl', (r) => r.topLeft),
            _corner('tr', (r) => r.topRight),
            _corner('bl', (r) => r.bottomLeft),
            _corner('br', (r) => r.bottomRight),
          ],
        ),
      );
    });
  }
}

/// -------------------------
/// MASK PAINTER (outside dark, inside clear, white border)
/// -------------------------
class _CropMaskPainter extends CustomPainter {
  final Rect cropRect;
  _CropMaskPainter(this.cropRect);

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final inner = Path()..addRect(cropRect);
    final diff = Path.combine(PathOperation.difference, outer, inner);

    // Darken outside
    final overlay = Paint()..color = Colors.black.withOpacity(0.5);
    canvas.drawPath(diff, overlay);

    // White border
    final border = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(cropRect, border);
  }

  @override
  bool shouldRepaint(covariant _CropMaskPainter oldDelegate) =>
      oldDelegate.cropRect != cropRect;
}


