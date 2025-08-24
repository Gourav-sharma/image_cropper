# image_crop_bundle

# 📸 Flutter Image Cropper Plugin

A lightweight Flutter plugin that allows you to **pick images from gallery/camera (via `image_picker`)** and **crop them** with a customizable crop box.

This plugin is written in **Dart** (crop logic/UI) and uses **`image_picker`** for selecting images.

---

## ✨ Features

- Pick images from **Gallery** or **Camera** using `image_picker`.
- Interactive crop UI with draggable & resizable crop box.
- Cropped image returned as `Uint8List`.
- Pure Dart cropping logic (using `package:image`).
- Lightweight alternative to `image_cropper`.

---

## Installation
Add this to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  image_crop_bundle: ^0.0.1
```

## Usage

### Step 1: Import the Plugin
```dart
import 'package:image_crop_bundle/image_crop_bundle.dart';


