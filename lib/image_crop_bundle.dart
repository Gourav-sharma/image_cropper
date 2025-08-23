
import 'image_crop_bundle_platform_interface.dart';



export 'dart:typed_data';
export 'package:flutter/material.dart';
export 'package:image_picker/image_picker.dart';


export '../features/image_cropper.dart';

class ImageCropBundle {
  Future<String?> getPlatformVersion() {
    return ImageCropBundlePlatform.instance.getPlatformVersion();
  }
}
