import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_crop_bundle/image_crop_bundle_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelImageCropBundle platform = MethodChannelImageCropBundle();
  const MethodChannel channel = MethodChannel('image_crop_bundle');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
