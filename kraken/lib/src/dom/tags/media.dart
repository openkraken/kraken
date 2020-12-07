import 'dart:ffi';
import 'dart:collection';
import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';

final Pointer<NativeFunction<Native_PlayMedia>> nativePlay = Pointer.fromFunction(MediaElement._play);
final Pointer<NativeFunction<Native_PauseMedia>> nativePause = Pointer.fromFunction(MediaElement._pause);
final Pointer<NativeFunction<Native_FastSeek>> nativeFastSeek = Pointer.fromFunction(MediaElement._fastSeek);

abstract class MediaElement extends Element {
  static SplayTreeMap<int, MediaElement> _nativeMap = SplayTreeMap();

  static MediaElement getMediaElementOfNativePtr(Pointer<NativeMediaElement> nativeMediaElement) {
    MediaElement mediaElement = _nativeMap[nativeMediaElement.address];
    assert(mediaElement != null, 'Can not get mediaElement from nativeElement: $nativeMediaElement');
    return mediaElement;
  }

  static void _play(Pointer<NativeMediaElement> nativeMediaElement) {
    MediaElement mediaElement = getMediaElementOfNativePtr(nativeMediaElement);
    mediaElement.play();
  }

  static void _pause(Pointer<NativeMediaElement> nativeMediaElement) {
    MediaElement mediaElement = getMediaElementOfNativePtr(nativeMediaElement);
    mediaElement.pause();
  }

  static void _fastSeek(Pointer<NativeMediaElement> nativeMediaElement, double duration) {
    MediaElement mediaElement = getMediaElementOfNativePtr(nativeMediaElement);
    mediaElement.fastSeek(duration);
  }

  final Pointer<NativeMediaElement> nativeMediaElementPtr;

  MediaElement(int targetId, this.nativeMediaElementPtr, ElementManager elementManager, String tagName,
      {Map<String, dynamic> defaultStyle})
      : super(targetId, nativeMediaElementPtr.ref.nativeElement, elementManager,
            isIntrinsicBox: true, tagName: tagName, repaintSelf: true, defaultStyle: defaultStyle) {
    _nativeMap[nativeMediaElementPtr.address] = this;
    nativeMediaElementPtr.ref.play = nativePlay;
    nativeMediaElementPtr.ref.pause = nativePause;
    nativeMediaElementPtr.ref.fastSeek = nativeFastSeek;
  }

  @override
  void dispose() {
    super.dispose();
    _nativeMap.remove(nativeMediaElementPtr.address);
  }

  void play();

  void pause();

  void fastSeek(double duration);
}
