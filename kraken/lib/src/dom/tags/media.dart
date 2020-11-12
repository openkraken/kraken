import 'dart:ffi';
import 'package:kraken/bridge.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/css.dart';
import 'package:kraken/launcher.dart';

final Pointer<NativeFunction<Native_PlayMedia>> nativePlay = Pointer.fromFunction(MediaElement._play);
final Pointer<NativeFunction<Native_PauseMedia>> nativePause = Pointer.fromFunction(MediaElement._pause);
final Pointer<NativeFunction<Native_FastSeek>> nativeFastSeek = Pointer.fromFunction(MediaElement._fastSeek);

abstract class MediaElement extends Element {
  static void _play(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget mediaElement = controller.view.getEventTargetById(targetId);

    if (mediaElement is MediaElement) {
      mediaElement.play();
    }
  }

  static void _pause(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget mediaElement = controller.view.getEventTargetById(targetId);

    if (mediaElement is MediaElement) {
      mediaElement.pause();
    }
  }

  static void _fastSeek(int contextId, int targetId, double duration) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget mediaElement = controller.view.getEventTargetById(targetId);

    if (mediaElement is MediaElement) {
      mediaElement.fastSeek(duration);
    }
  }

  final Pointer<NativeMediaElement> nativeMediaElementPtr;

  MediaElement(int targetId, this.nativeMediaElementPtr, ElementManager elementManager, String tagName,
      {Map<String, dynamic> defaultStyle})
      : super(targetId, nativeMediaElementPtr.ref.nativeElement, elementManager,
            isIntrinsicBox: true, tagName: tagName, repaintSelf: true, defaultStyle: defaultStyle);

  void play();

  void pause();

  void fastSeek(double duration);

}
