import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'image_crop_bundle_method_channel.dart';

abstract class ImageCropBundlePlatform extends PlatformInterface {
  /// Constructs a ImageCropBundlePlatform.
  ImageCropBundlePlatform() : super(token: _token);

  static final Object _token = Object();

  static ImageCropBundlePlatform _instance = MethodChannelImageCropBundle();

  /// The default instance of [ImageCropBundlePlatform] to use.
  ///
  /// Defaults to [MethodChannelImageCropBundle].
  static ImageCropBundlePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ImageCropBundlePlatform] when
  /// they register themselves.
  static set instance(ImageCropBundlePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
