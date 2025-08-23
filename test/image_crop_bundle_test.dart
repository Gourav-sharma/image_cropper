import 'package:flutter_test/flutter_test.dart';
import 'package:image_crop_bundle/image_crop_bundle.dart';
import 'package:image_crop_bundle/image_crop_bundle_platform_interface.dart';
import 'package:image_crop_bundle/image_crop_bundle_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockImageCropBundlePlatform
    with MockPlatformInterfaceMixin
    implements ImageCropBundlePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ImageCropBundlePlatform initialPlatform = ImageCropBundlePlatform.instance;

  test('$MethodChannelImageCropBundle is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelImageCropBundle>());
  });

  test('getPlatformVersion', () async {
    ImageCropBundle imageCropBundlePlugin = ImageCropBundle();
    MockImageCropBundlePlatform fakePlatform = MockImageCropBundlePlatform();
    ImageCropBundlePlatform.instance = fakePlatform;

    expect(await imageCropBundlePlugin.getPlatformVersion(), '42');
  });
}
