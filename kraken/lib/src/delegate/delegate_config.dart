import 'image/image_delegate.dart';
export 'image/image_delegate.dart';

class DelegateConfig {
  static ImageProviderDelegate _imageDelegate = DefaultImageProviderDelegate();

  static set imageProviderDelegate(
      ImageProviderDelegate imageProviderDelegate) {
    _imageDelegate = imageProviderDelegate;
  }

  static ImageProviderDelegate get imageProviderDelegate =>
      _imageDelegate ?? DefaultImageProviderDelegate();
}
