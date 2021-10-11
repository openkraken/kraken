/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:typed_data';
import 'dart:ui';
import 'dart:ffi';
import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';
import 'package:meta/meta.dart';
import 'package:ffi/ffi.dart';

import 'element_native_methods.dart';

final RegExp _splitRegExp = RegExp(r'\s+');

const String _STYLE_PROPERTY = 'style';
const String _CLASS_NAME = 'class';

/// Defined by W3C Standard,
/// Most element's default width is 300 in pixel,
/// height is 150 in pixel.
const String ELEMENT_DEFAULT_WIDTH = '300px';
const String ELEMENT_DEFAULT_HEIGHT = '150px';

typedef TestElement = bool Function(Element element);

enum StickyPositionType {
  relative,
  fixed,
}

enum BoxSizeType {
  // Element which have intrinsic before layout. Such as <img /> and <video />
  intrinsic,

  // Element which have width or min-width properties defined.
  specified,

  // Element which neither have intrinsic or predefined size.
  automatic,
}

mixin ElementBase on Node {
  RenderLayoutBox? _renderLayoutBox;
  RenderIntrinsic? _renderIntrinsic;

  RenderBoxModel? get renderBoxModel => _renderLayoutBox ?? _renderIntrinsic;
  set renderBoxModel(RenderBoxModel? value) {
    if (value == null) {
      _renderIntrinsic = null;
      _renderLayoutBox = null;
    } else if (value is RenderIntrinsic) {
      _renderIntrinsic = value;
    } else if (value is RenderLayoutBox) {
      _renderLayoutBox = value;
    } else {
      if (!kReleaseMode) throw FlutterError('Unknown RenderBoxModel value.');
    }
  }

  late RenderStyle renderStyle;
}

typedef BeforeRendererAttach = RenderObject Function();
typedef GetTargetId = int Function();
typedef GetRootElementFontSize = double Function();
typedef GetChildNodes = List<Node> Function();
/// Get the viewport size of current element.
typedef GetViewportSize = Size Function();
/// Get the render box model of current element.
typedef GetRenderBoxModel = RenderBoxModel? Function();

/// Delegate methods passed to renderBoxModel for actions involved with element
/// (eg. convert renderBoxModel to repaint boundary then attach to element).
class ElementDelegate {

  /// Toggle the renderer of element between repaint boundary and non repaint boundary.
  VoidCallback toggleRendererRepaintBoundary;

  /// Detach the renderer from its owner element.
  VoidCallback detachRenderer;

  /// Return the targetId of current element.
  GetTargetId getTargetId;

  /// Get the font size of root element
  GetRootElementFontSize getRootElementFontSize;
  GetViewportSize getViewportSize;
  GetRenderBoxModel getRenderBoxModel;
  GetChildNodes getChildNodes;

  // Handle scrolling.
  ScrollListener handleScroll;

  /// Focus the input element.
  VoidCallback focusInput;

  /// Blur the input element.
  VoidCallback blurInput;

  /// Scroll the input element to the caret.
  VoidCallback scrollInputToCaret;

  ElementDelegate({
    required this.toggleRendererRepaintBoundary,
    required this.detachRenderer,
    required this.getTargetId,
    required this.getRootElementFontSize,
    required this.handleScroll,
    required this.focusInput,
    required this.blurInput,
    required this.scrollInputToCaret,
    required this.getViewportSize,
    required this.getRenderBoxModel,
    required this.getChildNodes,
  });
}

class Element extends Node
    with
        ElementBase,
        ElementNativeMethods,
        ElementEventMixin,
        ElementOverflowMixin {
  static final SplayTreeMap<int, Element> _nativeMap = SplayTreeMap();

  static Element getElementOfNativePtr(Pointer<NativeElement> nativeElement) {
    Element? element = _nativeMap[nativeElement.address];
    if (element == null) throw FlutterError('Can not get element from nativeElement: $nativeElement');
    return element;
  }

  final Map<String, dynamic> properties = <String, dynamic>{};

  /// Should create repaintBoundary for this element to repaint separately from parent.
  bool repaintSelf;

  final String tagName;

  /// Is element an intrinsic box.
  final bool _isIntrinsicBox;

  final Pointer<NativeElement> nativeElementPtr;

  /// The style of the element, not inline style.
  late CSSStyleDeclaration style;

  /// The default user-agent style.
  final Map<String, dynamic> _defaultStyle;

  /// The inline style is a map of style property name to style property value.
  final Map<String, dynamic> inlineStyle = {};

  late ElementDelegate _elementDelegate;

  Size get viewportSize => elementManager.viewport.viewportSize;

  /// Whether should create repaintBoundary for this element when style changed
  bool get shouldConvertToRepaintBoundary {
    // Following cases should always convert to repaint boundary for performance consideration
    // Intrinsic element such as Canvas
    bool isSetRepaintSelf = repaintSelf;
    // Scrolling box
    bool isScrollingBox = scrollingContentLayoutBox != null;
    // Transform element
    bool hasTransform = renderBoxModel?.renderStyle.transform != null;
    // Fixed element
    bool isPositionedFixed = renderBoxModel?.renderStyle.position == CSSPositionType.fixed;

    return isScrollingBox || isSetRepaintSelf || hasTransform || isPositionedFixed;
  }

  Element(int targetId, this.nativeElementPtr, ElementManager elementManager,
      {required this.tagName,
        Map<String, dynamic> defaultStyle = const {},
        // Whether element allows children.
        bool isIntrinsicBox = false,
        this.repaintSelf = false,
        // @HACK: overflow scroll needs to create an shadow element to create an scrolling renderBox for better scrolling performance.
        // we needs to prevent this shadow element override real element in nativeMap.
        bool isHiddenElement = false})
      : _defaultStyle = defaultStyle,
        _isIntrinsicBox = isIntrinsicBox,
        super(NodeType.ELEMENT_NODE, targetId, nativeElementPtr.ref.nativeNode, elementManager, tagName) {

      // Init element delegate for proxy element internal method.
      _elementDelegate = ElementDelegate(
        toggleRendererRepaintBoundary: _toggleRendererRepaintBoundary,
        detachRenderer: detach,
        getTargetId: _getTargetId,
        getRootElementFontSize: elementManager.getRootFontSize,
        handleScroll: _handleScroll,
        focusInput: _focusInput,
        blurInput: _blurInput,
        scrollInputToCaret: _scrollInputToCaret,
        getViewportSize: _getViewportSize,
        getRenderBoxModel: _getRenderBoxModel,
        getChildNodes: _getChildNodes,
      );

    // Init style and add change listener.
    style = CSSStyleDeclaration.computedStyle(this, _defaultStyle, _onStyleChanged);

    // Init render style.
    renderStyle = RenderStyle(style: style, elementDelegate: _elementDelegate);

    if (!isHiddenElement) {
      _nativeMap[nativeElementPtr.address] = this;
    }

    bindNativeMethods(nativeElementPtr);
  }

  Size _getViewportSize() {
    return elementManager.viewport.viewportSize;
  }

  RenderBoxModel? _getRenderBoxModel() {
    return renderBoxModel;
  }

  void _toggleRendererRepaintBoundary() {
    if (shouldConvertToRepaintBoundary) {
      convertToRepaintBoundary();
    } else {
      convertToNonRepaintBoundary();
    }
  }

  int _getTargetId() {
    return targetId;
  }

  List<Node> _getChildNodes() {
    return childNodes;
  }

  void _focusInput() {
    InputElement input = this as InputElement;
    InputElement.setFocus(input);
  }

  void _blurInput() {
    InputElement.clearFocus();
  }

  void _scrollInputToCaret() {
    InputElement inputElement = this as InputElement;
    inputElement.scrollToCaret();
  }

  @override
  RenderObject? get renderer => renderBoxModel?.renderPositionHolder ?? renderBoxModel;

  @override
  RenderObject createRenderer() {
    if (renderer != null) {
      return renderer!;
    }
    updateRenderBoxModel();
    return renderer!;
  }

  void updateRenderBoxModel({ bool? shouldRepaintSelf }) {
    // Content children layout, BoxModel content.
    if (_isIntrinsicBox) {
      _renderIntrinsic = _createRenderIntrinsic(repaintSelf: shouldRepaintSelf ?? repaintSelf, prevRenderIntrinsic: _renderIntrinsic);
    } else {
      _renderLayoutBox = _createRenderLayout(repaintSelf: shouldRepaintSelf ?? repaintSelf, prevRenderLayoutBox: _renderLayoutBox);
    }
    // Ensure that the event responder is bound.
    _ensureEventResponderBound();
  }

  @override
  void willAttachRenderer() {
    // Init render box model.
    createRenderer();
  }

  @override
  void didAttachRenderer() {
    // Ensure that the child is attached.
    ensureChildAttached();
    // Flush pending style.
    style.flushPendingProperties();
  }

  @override
  void willDetachRenderer() {
    // Cancel running transition.
    style.cancelRunningTransiton();
    // Remove all intersection change listeners.
    renderBoxModel!.clearIntersectionChangeListeners();

    // Remove placeholder of positioned element.
    RenderPositionHolder? renderPositionHolder = renderBoxModel!.renderPositionHolder;
    if (renderPositionHolder != null) {
      RenderLayoutBox? parent = renderPositionHolder.parent as RenderLayoutBox?;
      if (parent != null) {
        parent.remove(renderPositionHolder);
      }
    }

    // Remove fixed children from root when dispose.
    _removeFixedChild(renderBoxModel!);

    // Remove self.
    RenderObject? parent = renderBoxModel!.parent as RenderObject?;
    if (parent is ContainerRenderObjectMixin) {
      parent.remove(renderBoxModel!);
    } else if (parent is RenderProxyBox) {
      parent.child = null;
    }

  }

  @override
  void didDetachRenderer() {
    style.reset();
  }

  bool _shouldConsumeScrollTicker = false;
  void _consumeScrollTicker(_) {
    if (_shouldConsumeScrollTicker && eventHandlers.containsKey(EVENT_SCROLL)) {
      _dispatchScrollEvent();
      _shouldConsumeScrollTicker = false;
    }
  }

  void _handleScroll(double scrollOffset, AxisDirection axisDirection) {
    applyStickyChildrenOffset();
    paintFixedChildren(scrollOffset, axisDirection);

    if (!_shouldConsumeScrollTicker) {
      // Make sure scroll listener trigger most to 1 time each frame.
      SchedulerBinding.instance!.addPostFrameCallback(_consumeScrollTicker);
      SchedulerBinding.instance!.scheduleFrame();
    }
    _shouldConsumeScrollTicker = true;
  }

  /// https://drafts.csswg.org/cssom-view/#scrolling-events
  void _dispatchScrollEvent() {
    dispatchEvent(Event(EVENT_SCROLL));
  }

  /// Normally element in scroll box will not repaint on scroll because of repaint boundary optimization
  /// So it needs to manually mark element needs paint and add scroll offset in paint stage
  void paintFixedChildren(double scrollOffset, AxisDirection axisDirection) {
    RenderLayoutBox? _scrollingContentLayoutBox = scrollingContentLayoutBox;
    // Only root element has fixed children
    if (tagName == 'HTML' && _scrollingContentLayoutBox != null) {
      for (RenderBoxModel child in _scrollingContentLayoutBox.fixedChildren) {
        // Save scrolling offset for paint
        if (axisDirection == AxisDirection.down) {
          child.scrollingOffsetY = scrollOffset;
        } else if (axisDirection == AxisDirection.right) {
          child.scrollingOffsetX = scrollOffset;
        }
      }
    }
  }

  // Calculate sticky status according to scroll offset and scroll direction
  void applyStickyChildrenOffset() {
    RenderLayoutBox? scrollContainer = (renderBoxModel as RenderLayoutBox?)!;
    for (RenderBoxModel stickyChild in scrollContainer.stickyChildren) {
      CSSPositionedLayout.applyStickyChildOffset(scrollContainer, stickyChild);
    }
  }

  /// Convert renderBoxModel to non repaint boundary
  void convertToNonRepaintBoundary() {
    RenderBoxModel? _renderBoxModel = renderBoxModel;
    if (_renderBoxModel != null && _renderBoxModel.isRepaintBoundary) {
      _toggleRepaintSelf(repaintSelf: false);
    }
  }

  /// Convert renderBoxModel to repaint boundary
  void convertToRepaintBoundary() {
    RenderBoxModel? _renderBoxModel = renderBoxModel;
    if (_renderBoxModel != null && !_renderBoxModel.isRepaintBoundary) {
      _toggleRepaintSelf(repaintSelf: true);
    }
  }

  /// Toggle renderBoxModel between repaint boundary and non repaint boundary.
  void _toggleRepaintSelf({ required bool repaintSelf }) {
    RenderBoxModel _renderBoxModel = renderBoxModel!;
    Element _parentElement = parentElement!;

    RenderObject? parentRenderObject = _renderBoxModel.parent as RenderObject?;
    RenderBox? previousSibling;
    // Remove old renderObject
    if (parentRenderObject is ContainerRenderObjectMixin) {
      ContainerParentDataMixin<RenderBox>? _parentData = _renderBoxModel.parentData as ContainerParentDataMixin<RenderBox>?;
      if (_parentData != null) {
        previousSibling = _parentData.previousSibling;
        // Get the renderBox before the RenderPositionHolder to find the renderBox to insert after
        // cause renderPositionHolder of sticky element lays before the renderBox.
        if (previousSibling is RenderPositionHolder) {
          ContainerParentDataMixin<RenderBox>? _parentData = previousSibling.parentData as ContainerParentDataMixin<RenderBox>?;
          if (_parentData != null) {
            previousSibling = _parentData.previousSibling;
          }
        }
        parentRenderObject.remove(_renderBoxModel);
      }
    }

    updateRenderBoxModel(shouldRepaintSelf: repaintSelf);

    if (parentRenderObject is ContainerRenderObjectMixin) {
      _parentElement.addChildRenderObject(this, after: previousSibling);
    } else if (parentRenderObject is RenderObjectWithChildMixin) {
      parentRenderObject.child = renderBoxModel;
    }
  }

  void _updateRenderBoxModelWithPosition(CSSPositionType currentPosition) {
    RenderBoxModel _renderBoxModel = renderBoxModel!;
    Element _parentElement = parentElement!;

    // Remove fixed children before convert to non repaint boundary renderObject
    if (currentPosition != CSSPositionType.fixed) {
      _removeFixedChild(_renderBoxModel);
    }

    // Move element according to position when it's already attached to render tree.
    if (isRendererAttached) {
      RenderObject _renderer = renderer!;

      RenderBox? prev = (_renderer.parentData as ContainerParentDataMixin<RenderBox>).previousSibling;
      // It needs to find the previous sibling of the previous sibling if the placeholder of
      // positioned element exists and follows renderObject at the same time, eg.
      // <div style="position: relative"><div style="position: absolute" /></div>
      if (prev == _renderBoxModel) {
        prev = (_renderBoxModel.parentData as ContainerParentDataMixin<RenderBox>).previousSibling;
      }

      // Remove placeholder of positioned element.
      RenderPositionHolder? renderPositionHolder = _renderBoxModel.renderPositionHolder;
      if (renderPositionHolder != null) {
        ContainerRenderObjectMixin<RenderBox, ContainerParentDataMixin<RenderBox>>? parent = renderPositionHolder.parent as ContainerRenderObjectMixin<RenderBox, ContainerParentDataMixin<RenderBox>>?;
        if (parent != null) {
          parent.remove(renderPositionHolder);
          _renderBoxModel.renderPositionHolder = null;
        }
      }
      // Remove renderBoxModel from original parent and append to its containing block
      RenderObject? parentRenderBoxModel = _renderBoxModel.parent as RenderBox?;
      if (parentRenderBoxModel is ContainerRenderObjectMixin) {
        parentRenderBoxModel.remove(_renderBoxModel);
      } else if (parentRenderBoxModel is RenderProxyBox) {
        parentRenderBoxModel.child = null;
      }
      _parentElement.addChildRenderObject(this, after: prev);
    }

    if (shouldConvertToRepaintBoundary) {
      convertToRepaintBoundary();
    } else {
      convertToNonRepaintBoundary();
    }

    // Add fixed children after convert to repaint boundary renderObject
    if (currentPosition == CSSPositionType.fixed) {
      _addFixedChild(renderBoxModel!);
    }
  }

  Element? getElementById(Element parentElement, int targetId) {
    Element? result;
    List childNodes = parentElement.childNodes;

    for (int i = 0; i < childNodes.length; i++) {
      Element element = childNodes[i];
      if (element.targetId == targetId) {
        result = element;
        break;
      }
    }
    return result;
  }

  void addChild(RenderBox child) {
    if (_renderLayoutBox != null) {
      if (scrollingContentLayoutBox != null) {
        scrollingContentLayoutBox!.add(child);
      } else {
        _renderLayoutBox!.add(child);
      }
    } else if (_renderIntrinsic != null) {
      _renderIntrinsic!.child = child;
    }
  }

  @override
  void dispose() {
    super.dispose();

    if (isRendererAttached) {
      detach();
    }

    RenderBoxModel? _renderBoxModel = renderBoxModel;
    Element? _parentElement = parentElement;

    // Call dispose method of renderBoxModel when GC auto dispose element
    if (_renderBoxModel != null) {
      _renderBoxModel.dispose();
    }

    if (_parentElement != null) {
      _parentElement.removeChild(this);
    }

    style.dispose();
    properties.clear();

    // Remove native reference.
    _nativeMap.remove(nativeElementPtr.address);
  }

  // Used for force update layout.
  void flushLayout() {
    if (isRendererAttached) {
      renderer!.owner!.flushLayout();
    }
  }

  void addChildRenderObject(Element child, {RenderBox? after}) {
    CSSPositionType positionType = child.renderBoxModel!.renderStyle.position;
    RenderLayoutBox? _scrollingContentLayoutBox = scrollingContentLayoutBox;
    switch (positionType) {
      case CSSPositionType.absolute:
      case CSSPositionType.fixed:
        _addPositionedChild(child, positionType);
        break;
      case CSSPositionType.sticky:
      case CSSPositionType.relative:
      case CSSPositionType.static:
        RenderLayoutBox? parentRenderLayoutBox = _scrollingContentLayoutBox ?? _renderLayoutBox;

        if (parentRenderLayoutBox != null) {
          parentRenderLayoutBox.insert(child.renderBoxModel!, after: after);

          if (positionType == CSSPositionType.sticky) {
            _addPositionHolder(parentRenderLayoutBox, child, positionType);
          }
        }
        break;
    }
  }

  // Attach renderObject of current node to parent
  @override
  void attachTo(Node parent, {RenderBox? after}) {

    _applyStyle();

    if (renderStyle.display != CSSDisplay.none) {
      willAttachRenderer();
      if (parent is Element) {
        parent.addChildRenderObject(this, after: after);
      } else if (parent is Document) {
        parent.appendChild(this);
      }

      didAttachRenderer();
    }
  }

  // Detach renderObject of current node from parent
  @override
  void detach() {
    if (renderBoxModel == null) return;

    willDetachRenderer();

    for (Node child in childNodes) {
      child.detach();
    }

    didDetachRenderer();

    // Call dispose method of renderBoxModel when it is detached from tree
    renderBoxModel!.dispose();
    renderBoxModel = null;
  }

  @override
  void ensureChildAttached() {
    if (isRendererAttached) {
      for (Node child in childNodes) {
        if (_renderLayoutBox != null && !child.isRendererAttached) {
          RenderBox? after;
          if (scrollingContentLayoutBox != null) {
            after = scrollingContentLayoutBox!.lastChild;
          } else {
            after = _renderLayoutBox!.lastChild;
          }

          child.attachTo(this, after: after);
          child.ensureChildAttached();
        }
      }
    }
  }

  @override
  @mustCallSuper
  Node appendChild(Node child) {
    super.appendChild(child);
    // Update renderStyle tree.
    if (child is Element) {
      child.renderStyle.parent = renderStyle;
    }
    if (isRendererAttached) {
      // Only append child renderer when which is not attached.
      if (!child.isRendererAttached) {
        if (scrollingContentLayoutBox != null) {
          child.attachTo(this, after: scrollingContentLayoutBox!.lastChild);
        } else {
          child.attachTo(this, after: _renderLayoutBox!.lastChild);
        }
      }
    }

    return child;
  }

  @override
  @mustCallSuper
  Node removeChild(Node child) {
    // Not remove node type which is not present in RenderObject tree such as Comment
    // Only append node types which is visible in RenderObject tree
    // Only remove childNode when it has parent
    if (child.isRendererAttached) {
      child.detach();
    }
    // Update renderStyle tree.
    if (child is Element) {
      child.renderStyle.parent = null;
    }

    super.removeChild(child);
    return child;
  }

  @override
  @mustCallSuper
  Node insertBefore(Node child, Node referenceNode) {
    // Node.insertBefore will change element tree structure,
    // so get the referenceIndex before calling it.
    int referenceIndex = childNodes.indexOf(referenceNode);
    Node node = super.insertBefore(child, referenceNode);
    // Update renderStyle tree.
    if (child is Element) {
      child.renderStyle.parent = renderStyle;
    }

    if (isRendererAttached) {
      // Only append child renderer when which is not attached.
      if (!child.isRendererAttached) {
        RenderBox? afterRenderObject;
        // `referenceNode` should not be null, or `referenceIndex` can only be -1.
        if (referenceIndex != -1 && referenceNode.isRendererAttached) {
          afterRenderObject = (referenceNode.renderer!.parentData as ContainerParentDataMixin<RenderBox>).previousSibling;
        }
        child.attachTo(this, after: afterRenderObject);
      }
    }

    return node;
  }

  @override
  @mustCallSuper
  Node? replaceChild(Node newNode, Node oldNode) {
    // Update renderStyle tree.
    if (newNode is Element) {
      newNode.renderStyle.parent = renderStyle;
    }
    if (oldNode is Element) {
      oldNode.renderStyle.parent = null;
    }
    return super.replaceChild(newNode, oldNode);
  }

  void _addPositionedChild(Element child, CSSPositionType position) {
    Element? containingBlockElement;
    switch (position) {
      case CSSPositionType.absolute:
        containingBlockElement = _findContainingBlock(child);
        break;
      case CSSPositionType.fixed:
        containingBlockElement = elementManager.viewportElement;
        break;
      default:
        return;
    }

    RenderLayoutBox parentRenderLayoutBox = containingBlockElement!.scrollingContentLayoutBox != null ?
      containingBlockElement.scrollingContentLayoutBox! : containingBlockElement._renderLayoutBox!;
    RenderBoxModel childRenderBoxModel = child.renderBoxModel!;
    _setPositionedChildParentData(parentRenderLayoutBox, child);
    parentRenderLayoutBox.add(childRenderBoxModel);

    _addPositionHolder(parentRenderLayoutBox, child, position);
  }

  void _addPositionHolder(RenderLayoutBox parentRenderLayoutBox, Element child, CSSPositionType position) {
    Size preferredSize = Size.zero;
    RenderBoxModel childRenderBoxModel = child.renderBoxModel!;
    RenderStyle childRenderStyle = childRenderBoxModel.renderStyle;
    if (position == CSSPositionType.sticky) {
      preferredSize = Size(0, 0);
    } else if (childRenderStyle.display != CSSDisplay.inline) {
      preferredSize = Size(
        childRenderStyle.width?.computedValue ?? 0,
        childRenderStyle.height?.computedValue ?? 0,
      );
    }
    RenderPositionHolder childPositionHolder = RenderPositionHolder(preferredSize: preferredSize);
    childRenderBoxModel.renderPositionHolder = childPositionHolder;
    childPositionHolder.realDisplayedBox = childRenderBoxModel;

    if (position == CSSPositionType.sticky) {
      // Placeholder of sticky renderBox need to inherit offset from original renderBox,
      // so it needs to layout before original renderBox
      RenderBox? preSibling = parentRenderLayoutBox.childBefore(childRenderBoxModel);
      parentRenderLayoutBox.insert(childPositionHolder, after: preSibling);
    } else {
      // Placeholder of flexbox needs to inherit size from its real display box,
      // so it needs to layout after real box layout
      child.parentElement!.addChild(childPositionHolder);
    }
  }

  /// Cache fixed renderObject to root element
  void _addFixedChild(RenderBoxModel childRenderBoxModel) {
    Element rootEl = elementManager.viewportElement;
    RenderLayoutBox rootRenderLayoutBox = rootEl.scrollingContentLayoutBox!;
    List<RenderBoxModel> fixedChildren = rootRenderLayoutBox.fixedChildren;
    if (!fixedChildren.contains(childRenderBoxModel)) {
      fixedChildren.add(childRenderBoxModel);
    }
  }

  /// Remove non fixed renderObject to root element
  void _removeFixedChild(RenderBoxModel childRenderBoxModel) {
    Element rootEl = elementManager.viewportElement;
    RenderLayoutBox? rootRenderLayoutBox = rootEl.scrollingContentLayoutBox!;
    List<RenderBoxModel> fixedChildren = rootRenderLayoutBox.fixedChildren;
    if (fixedChildren.contains(childRenderBoxModel)) {
      fixedChildren.remove(childRenderBoxModel);
    }
  }

  // FIXME: only compatible with kraken plugins
  @deprecated
  void setStyle(String property, dynamic value) {
    setRenderStyle(property, value);
  }

  void _updateRenderBoxModelWithDisplay() {
    CSSDisplay originalDisplay = renderStyle.previousDisplay;
    CSSDisplay presentDisplay = renderStyle.display;

    if (originalDisplay == presentDisplay) return;
    // Destroy renderer of element when display is changed to none.
    if (presentDisplay == CSSDisplay.none) {
      detach();
      return;
    }

    // When renderer and style listener is not created when original display is none,
    // thus it needs to create renderer when style changed.
    if (originalDisplay == CSSDisplay.none) {
      RenderBox? after;
      Element parent = this.parent as Element;
      if (parent.scrollingContentLayoutBox != null) {
        after = parent.scrollingContentLayoutBox!.lastChild;
      } else {
        after = (parent.renderBoxModel as RenderLayoutBox).lastChild;
      }
      // Update renderBoxModel and attach it to parent.
      updateRenderBoxModel();
      parent.addChildRenderObject(this, after: after);
      // FIXME: avoid ensure something in display updating.
      ensureChildAttached();
    }

    if (renderBoxModel is RenderLayoutBox) {
      RenderLayoutBox? prevRenderLayoutBox = renderBoxModel as RenderLayoutBox?;
      if (originalDisplay != CSSDisplay.none) {
        // Don't updateRenderBoxModel twice.
        updateRenderBoxModel();
      }

      bool shouldReattach = isRendererAttached && parent != null && prevRenderLayoutBox != renderBoxModel;

      if (shouldReattach) {
        RenderLayoutBox parentRenderObject = parentElement!.renderBoxModel as RenderLayoutBox;
        Element? previousSibling = this.previousSibling as Element?;
        RenderObject? previous = previousSibling?.renderer;

        parentRenderObject.remove(prevRenderLayoutBox!);
        parentRenderObject.insert(renderBoxModel!, after: previous as RenderBox?);
      } else {
        renderBoxModel!.markNeedsLayout();
      }
    }
  }

  /// Set internal style value to the element.
  void setRenderStyle(String property, dynamic present) {
    switch (property) {
      case DISPLAY:
        renderStyle.display = CSSDisplayMixin.resolveDisplay(present);
        _updateRenderBoxModelWithDisplay();
        break;

      case VERTICAL_ALIGN:
        renderStyle.verticalAlign = CSSInlineMixin.resolveVerticalAlign(present);
        break;

      case POSITION:
        CSSPositionType prevPosition = renderStyle.position;
        CSSPositionType currentPosition = CSSPositionMixin.resolvePositionType(present);
        if (prevPosition == currentPosition) return;
        renderStyle.position = currentPosition;
        _updateRenderBoxModelWithPosition(currentPosition);
        break;

      case Z_INDEX:
        renderStyle.zIndex = int.tryParse(present);
        break;
      case TOP:
        renderStyle.top = CSSLength.parseLength(present, renderStyle, property);
        break;
      case LEFT:
        renderStyle.left = CSSLength.parseLength(present, renderStyle, property);
        break;
      case BOTTOM:
        renderStyle.bottom = CSSLength.parseLength(present, renderStyle, property);
        break;
      case RIGHT:
        renderStyle.right = CSSLength.parseLength(present, renderStyle, property);
        break;
      case FLEX_DIRECTION:
        renderStyle.flexDirection = CSSFlexboxMixin.resolveFlexDirection(present);
        break;
      case FLEX_WRAP:
        renderStyle.flexWrap = CSSFlexboxMixin.resolveFlexWrap(present);
        break;
      case ALIGN_CONTENT:
        renderStyle.alignContent = CSSFlexboxMixin.resolveAlignContent(present);
        break;
      case ALIGN_ITEMS:
        renderStyle.alignItems = CSSFlexboxMixin.resolveAlignItems(present);
        break;
      case JUSTIFY_CONTENT:
        renderStyle.justifyContent = CSSFlexboxMixin.resolveJustifyContent(present);
        break;
      case ALIGN_SELF:
        renderStyle.alignSelf = CSSFlexboxMixin.resolveAlignSelf(present);
        break;
      case FLEX_GROW:
        renderStyle.flexGrow = CSSFlexboxMixin.resolveFlexGrow(present);
        break;
      case FLEX_SHRINK:
        renderStyle.flexShrink = CSSFlexboxMixin.resolveFlexShrink(present);
        break;
      case FLEX_BASIS:
        renderStyle.flexBasis = CSSLength.parseLength(present, renderStyle, property);
        break;
      case SLIVER_DIRECTION:
        renderStyle.sliverDirection = CSSSliverMixin.resolveAxis(present);
        break;
      case TEXT_ALIGN:
        renderStyle.textAlign = CSSTextMixin.resolveTextAlign(present);
        break;
      case PADDING_TOP:
        renderStyle.paddingTop = CSSLength.parseLength(present, renderStyle, property);
        break;
      case PADDING_RIGHT:
        renderStyle.paddingRight = CSSLength.parseLength(present, renderStyle, property);
        break;
      case PADDING_BOTTOM:
        renderStyle.paddingBottom = CSSLength.parseLength(present, renderStyle, property);
        break;
      case PADDING_LEFT:
        renderStyle.paddingLeft = CSSLength.parseLength(present, renderStyle, property);
        break;
      case WIDTH:
        renderStyle.width = CSSLength.parseLength(present, renderStyle, property);
        break;
      case MIN_WIDTH:
        renderStyle.minWidth = CSSLength.parseLength(present, renderStyle, property);
        break;
      case MAX_WIDTH:
        renderStyle.maxWidth = CSSLength.parseLength(present, renderStyle, property);
        break;
      case HEIGHT:
        renderStyle.height = CSSLength.parseLength(present, renderStyle, property);
        break;
      case MIN_HEIGHT:
        renderStyle.minHeight = CSSLength.parseLength(present, renderStyle, property);
        break;
      case MAX_HEIGHT:
        renderStyle.maxHeight = CSSLength.parseLength(present, renderStyle, property);
        break;
      case BACKGROUND_COLOR:
        renderStyle.backgroundColor = CSSColor.parseColor(present);
        break;
      case BACKGROUND_ATTACHMENT:
        renderStyle.backgroundAttachment = CSSBackground.resolveBackgroundAttachment(present);
        break;
      case BACKGROUND_IMAGE:
        renderStyle.backgroundImage = CSSBackground.resolveBackgroundImage(present, renderStyle, property, elementManager.controller);
        break;
      case BACKGROUND_REPEAT:
        renderStyle.backgroundRepeat = CSSBackground.resolveBackgroundRepeat(present);
        break;
      case BACKGROUND_POSITION_X:
        renderStyle.backgroundPositionX = CSSPosition.parsePosition(present, renderStyle, true);
        break;
      case BACKGROUND_POSITION_Y:
        renderStyle.backgroundPositionY = CSSPosition.parsePosition(present, renderStyle, false);
        break;
      case BACKGROUND_SIZE:
        renderStyle.backgroundSize = CSSBackground.resolveBackgroundSize(present, renderStyle, property);
        break;
      case BACKGROUND_CLIP:
        renderStyle.backgroundClip = CSSBackground.resolveBackgroundClip(present);
        break;
      case BACKGROUND_ORIGIN:
        renderStyle.backgroundOrigin = CSSBackground.resolveBackgroundOrigin(present);
        break;
      case BORDER_LEFT_WIDTH:
        renderStyle.borderLeftWidth = CSSLength.parseLength(present, renderStyle, property);
        break;
      case BORDER_TOP_WIDTH:
        renderStyle.borderTopWidth = CSSLength.parseLength(present, renderStyle, property);
        break;
      case BORDER_RIGHT_WIDTH:
        renderStyle.borderRightWidth = CSSLength.parseLength(present, renderStyle, property);
        break;
      case BORDER_BOTTOM_WIDTH:
        renderStyle.borderBottomWidth = CSSLength.parseLength(present, renderStyle, property);
        break;
      case BORDER_LEFT_STYLE:
        renderStyle.borderLeftStyle = CSSBorderSide.resolveBorderStyle(present);
        break;
      case BORDER_TOP_STYLE:
        renderStyle.borderTopStyle = CSSBorderSide.resolveBorderStyle(present);
        break;
      case BORDER_RIGHT_STYLE:
        renderStyle.borderRightStyle = CSSBorderSide.resolveBorderStyle(present);
        break;
      case BORDER_BOTTOM_STYLE:
        renderStyle.borderBottomStyle = CSSBorderSide.resolveBorderStyle(present);
        break;
      case BORDER_LEFT_COLOR:
        renderStyle.borderLeftColor = CSSColor.parseColor(present);
        break;
      case BORDER_TOP_COLOR:
        renderStyle.borderTopColor = CSSColor.parseColor(present);
        break;
      case BORDER_RIGHT_COLOR:
        renderStyle.borderRightColor = CSSColor.parseColor(present);
        break;
      case BORDER_BOTTOM_COLOR:
        renderStyle.borderBottomColor = CSSColor.parseColor(present);
        break;
      case BOX_SHADOW:
        renderStyle.boxShadow = CSSBoxShadow.parseBoxShadow(present, renderStyle, property);
        break;
      case BORDER_TOP_LEFT_RADIUS:
        renderStyle.borderTopLeftRadius = CSSBorderRadius.parseBorderRadius(present, renderStyle, property);
        break;
      case BORDER_TOP_RIGHT_RADIUS:
        renderStyle.borderTopRightRadius = CSSBorderRadius.parseBorderRadius(present, renderStyle, property);
        break;
      case BORDER_BOTTOM_LEFT_RADIUS:
        renderStyle.borderBottomLeftRadius = CSSBorderRadius.parseBorderRadius(present, renderStyle, property);
        break;
      case BORDER_BOTTOM_RIGHT_RADIUS:
        renderStyle.borderBottomRightRadius = CSSBorderRadius.parseBorderRadius(present, renderStyle, property);
        break;
      case MARGIN_LEFT:
        renderStyle.marginLeft = CSSLength.parseLength(present, renderStyle, property);
        break;
      case MARGIN_TOP:
        renderStyle.marginTop = CSSLength.parseLength(present, renderStyle, property);
        break;
      case MARGIN_RIGHT:
        renderStyle.marginRight = CSSLength.parseLength(present, renderStyle, property);
        break;
      case MARGIN_BOTTOM:
        renderStyle.marginBottom = CSSLength.parseLength(present, renderStyle, property);
        break;
      case OPACITY:
        renderStyle.opacity = CSSOpacityMixin.resolveOpacity(present);
        break;
      case VISIBILITY:
        renderStyle.visibility = CSSVisibilityMixin.resolveVisibility(present);
        break;
      case CONTENT_VISIBILITY:
        renderStyle.contentVisibility = CSSContentVisibilityMixin.resolveContentVisibility(present);
        break;
      case TRANSFORM:
        renderStyle.transform = CSSFunction.parseFunction(present);
        break;
      case TRANSFORM_ORIGIN:
        renderStyle.transformOrigin = CSSOrigin.parseOrigin(present, renderStyle, property);
        break;
      case OBJECT_FIT:
        renderStyle.objectFit = CSSObjectFitMixin.resolveBoxFit(present);
        break;
      case OBJECT_POSITION:
        renderStyle.objectPosition = CSSObjectPositionMixin.resolveObjectPosition(present);
        break;
      case FILTER:
        renderStyle.filter = CSSFunction.parseFunction(present);
        break;
      // Text Style
      case COLOR:
        // TODO: Color change should trigger currentColor update
        renderStyle.color = CSSColor.resolveColor(present);
        break;
      case TEXT_DECORATION_LINE:
        renderStyle.textDecorationLine = CSSText.resolveTextDecorationLine(present);
        break;
      case TEXT_DECORATION_STYLE:
        renderStyle.textDecorationStyle = CSSText.resolveTextDecorationStyle(present);
        break;
      case TEXT_DECORATION_COLOR:
        renderStyle.textDecorationColor = CSSColor.resolveColor(present);
        break;
      case FONT_WEIGHT:
        renderStyle.fontWeight = CSSText.resolveFontWeight(present);
        break;
      case FONT_STYLE:
        renderStyle.fontStyle = CSSText.resolveFontStyle(present);
        break;
      case FONT_FAMILY:
        renderStyle.fontFamily = CSSText.resolveFontFamilyFallback(present);
        break;
      case FONT_SIZE:
        renderStyle.fontSize = CSSLength.parseLength(present, renderStyle, property);
        break;
      case LINE_HEIGHT:
        renderStyle.lineHeight = CSSLength.parseLength(present, renderStyle, property);
        break;
      case LETTER_SPACING:
        renderStyle.letterSpacing = CSSText.resolveSpacing(present, renderStyle, property);
        break;
      case WORD_SPACING:
        renderStyle.wordSpacing = CSSText.resolveSpacing(present, renderStyle, property);
        break;
      case TEXT_SHADOW:
        renderStyle.textShadow = CSSText.resolveTextShadow(present, renderStyle, property);
        break;
      case WHITE_SPACE:
        renderStyle.whiteSpace = CSSText.resolveWhiteSpace(present);
        break;
      case TEXT_OVERFLOW:
        // Overflow will affect text-overflow ellipsis taking effect
        renderStyle.textOverflow = CSSText.resolveTextOverflow(present);
        break;
      case LINE_CLAMP:
        renderStyle.lineClamp = CSSText.parseLineClamp(present);
        break;
    }
  }

  void _applyDefaultStyle() {
    if (_defaultStyle.isNotEmpty) {
      _defaultStyle.forEach((property, dynamic value) {
        _setStyleProperty(property, value);
      });
    }
  }

  void _applyInlineStyle() {
    if (inlineStyle.isNotEmpty) {
      inlineStyle.forEach((property, dynamic value) {
        // Force inline style to be applied as important priority.
        _setStyleProperty(property, value, true);
      });
    }
  }

  void _applyStyleSheetStyle() {
    String? classNames = getProperty(_CLASS_NAME);
    if (classNames != null && classNames.isNotEmpty) {
      const String classSelectorPrefix = '.';
      for (String className in classNames.trim().split(_splitRegExp)) {
        for (CSSStyleSheet sheet in elementManager.styleSheets) {
          List<CSSRule> rules = sheet.cssRules;
          for (int i = 0; i < rules.length; i++) {
            CSSRule rule = rules[i];
            if (rule is CSSStyleRule && rule.selectorText == (classSelectorPrefix + className)) {
              var styleSheetStyle = rule.style;
              for (String propertyName in styleSheetStyle.keys) {
                _setStyleProperty(propertyName, styleSheetStyle[propertyName]);
              }
            }
          }
        }
      }
    }
  }

  // Set style property.
  void _setStyleProperty(String propertyName, value, [bool? isImportant]) {
    style.setProperty(propertyName, value, isImportant, viewportSize);
  }

  void _onStyleChanged(String property, String? original, String present) {
    setRenderStyle(property, present);
  }

  // Set inline style property.
  void setInlineStyle(String property, dynamic value) {
    // Current only for mark property is setting by inline style.
    inlineStyle[property] = value;
    if (renderBoxModel != null) {
      _setStyleProperty(property, value, true);
    }
  }

  void _applyStyle() {
    // Apply default style.
    _applyDefaultStyle();
    renderStyle.initDisplay();

    _applyInlineStyle();
    _applyStyleSheetStyle();
  }

  void recalculateStyle() {
    // TODO: only update the element's style that is changed.
    // Reset renderStyle.
    if (renderBoxModel != null) {
      // Reset style.
      style.reset();
      _applyStyle();

      renderBoxModel!.renderStyle = RenderStyle(style: style, elementDelegate: _elementDelegate);
      style.flushPendingProperties();
      renderBoxModel!.markNeedsLayout();
    }
    // Update children style.
    children.forEach((Element child) {
      child.recalculateStyle();
    });
  }

  @mustCallSuper
  void setProperty(String key, dynamic value) {
    // Each key change will emit to `setStyle`
    if (key == _STYLE_PROPERTY) {
      assert(value is Map<String, dynamic>);
      // @TODO: Consider `{ color: red }` to `{}`, need to remove invisible keys.
      (value as Map<String, dynamic>).forEach(setInlineStyle);
    } else {
      properties[key] = value;
    }
  }

  @mustCallSuper
  dynamic getProperty(String key) {
    return properties[key];
  }

  @mustCallSuper
  void removeProperty(String key) {
    properties.remove(key);

    if (key == _STYLE_PROPERTY) {
      setProperty(_STYLE_PROPERTY, null);
    }
  }

  BoundingClientRect get boundingClientRect {
    BoundingClientRect boundingClientRect = BoundingClientRect(0, 0, 0, 0, 0, 0, 0, 0);
    if (isRendererAttached) {
      RenderBox sizedBox = renderBoxModel!;
      // Force flush layout.
      if (!sizedBox.hasSize) {
        sizedBox.markNeedsLayout();
        sizedBox.owner!.flushLayout();
      }

      if (sizedBox.hasSize) {
        Offset offset = getOffset(sizedBox);
        Size size = sizedBox.size;
        boundingClientRect = BoundingClientRect(
          offset.dx,
          offset.dy,
          size.width,
          size.height,
          offset.dy,
          offset.dx + size.width,
          offset.dy + size.height,
          offset.dx);
      }
    }

    return boundingClientRect;
  }

  double getOffsetX() {
    double offset = 0;
    RenderBoxModel selfRenderBoxModel = renderBoxModel!;
    if (selfRenderBoxModel.attached) {
      Offset relative = getOffset(selfRenderBoxModel);
      offset += relative.dx;
    }
    return offset;
  }

  double getOffsetY() {
    double offset = 0;
    RenderBoxModel selfRenderBoxModel = renderBoxModel!;
    if (selfRenderBoxModel.attached) {
      Offset relative = getOffset(selfRenderBoxModel);
      offset += relative.dy;
    }
    return offset;
  }

  Offset getOffset(RenderBox renderBox) {
    // Need to flush layout to get correct size.
    elementManager
        .getRootRenderBox()
        .owner!
        .flushLayout();

    Element? element = _findContainingBlock(this);
    element ??= elementManager.viewportElement;
    return renderBox.localToGlobal(Offset.zero, ancestor: element.renderBoxModel);
  }

  void _ensureEventResponderBound() {
    // Must bind event responder on render box model whatever there is no event listener.
    RenderBoxModel? selfRenderBoxModel = renderBoxModel;
    if (selfRenderBoxModel != null) {
      // Make sure pointer responder bind.
      addEventResponder(selfRenderBoxModel);
      if (_hasIntersectionObserverEvent(eventHandlers)) {
        selfRenderBoxModel.addIntersectionChangeListener(handleIntersectionChange);
      }
    }
  }

  void addEvent(String eventType) {
    if (eventHandlers.containsKey(eventType)) return; // Only listen once.
    addEventListener(eventType, _eventResponder);
    _ensureEventResponderBound();
  }

  void removeEvent(String eventType) {
    if (!eventHandlers.containsKey(eventType)) return; // Only listen once.
    removeEventListener(eventType, _eventResponder);

    RenderBoxModel? selfRenderBoxModel = renderBoxModel;
    if (selfRenderBoxModel != null) {
      if (eventHandlers.isEmpty) {
        // Remove pointer responder if there is no event handler.
        removeEventResponder(selfRenderBoxModel);
      }

      // Remove listener when no intersection related event
      if (_isIntersectionObserverEvent(eventType) && !_hasIntersectionObserverEvent(eventHandlers)) {
        selfRenderBoxModel.removeIntersectionChangeListener(handleIntersectionChange);
      }
    }
  }

  @override
  void dispatchEvent(Event event) {
    event.currentTarget = this;
    _eventResponder(event);
    // Dispatch listener for widget.
    elementManager.eventClient?.eventListener(event);
  }

  void _eventResponder(Event event) {
    emitUIEvent(elementManager.controller.view.contextId, nativeElementPtr.ref.nativeNode.ref.nativeEventTarget, event);
  }

  void handleMethodClick() {
    Event clickEvent = MouseEvent(EVENT_CLICK, MouseEventInit(bubbles: true, cancelable: true));

    // If element not in tree, click is fired and only response to itself.
    dispatchEvent(clickEvent);
  }

  Future<Uint8List> toBlob({double? devicePixelRatio}) {
    Completer<Uint8List> completer = Completer();
    if (renderBoxModel == null) {
      completer.complete(Uint8List(0));
    } else {
      if (nodeName != 'HTML') {
        convertToRepaintBoundary();
      }
      renderBoxModel!.owner!.flushLayout();

      SchedulerBinding.instance!.addPostFrameCallback((_) async {
        Uint8List captured;
        RenderBoxModel? renderObject = renderBoxModel!;
        if (renderObject.hasSize && renderObject.size == Size.zero) {
          // Return a blob with zero length.
          captured = Uint8List(0);
        } else {
          devicePixelRatio ??= window.devicePixelRatio;
          Image image = await renderObject.toImage(pixelRatio: devicePixelRatio!);
          ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
          captured = byteData!.buffer.asUint8List();
        }

        completer.complete(captured);
      });
      SchedulerBinding.instance!.scheduleFrame();
    }
    return completer.future;
  }

  void debugHighlight() {
    if (isRendererAttached) {
      renderBoxModel?.debugShouldPaintOverlay = true;
    }
  }

  void debugHideHighlight() {
    if (isRendererAttached) {
      renderBoxModel?.debugShouldPaintOverlay = false;
    }
  }

  // Create a new RenderLayoutBox for the scrolling content.
  RenderLayoutBox createScrollingContentLayout() {
    // FIXME: Create a empty renderStyle for do not share renderStyle with element. Current update here will break flexbox.
    RenderStyle scrollingContentRenderStyle = RenderStyle(style: CSSStyleDeclaration.empty, elementDelegate: _elementDelegate);
    RenderLayoutBox scrollingContentLayoutBox = _createRenderLayout(
      repaintSelf: true,
      renderStyle: scrollingContentRenderStyle,
    );

    scrollingContentRenderStyle.overflowX = CSSOverflowType.visible;
    scrollingContentRenderStyle.overflowY = CSSOverflowType.visible;
    style.addStyleChangeListener(scrollingContentBoxStyleListener);
    scrollingContentLayoutBox.isScrollingContentBox = true;
    return scrollingContentLayoutBox;
  }

  RenderLayoutBox _createRenderLayout({
      RenderLayoutBox? prevRenderLayoutBox,
      RenderStyle? renderStyle,
      bool repaintSelf = false
  }) {
    CSSDisplay display = this.renderStyle.display;
    renderStyle ??= this.renderStyle;

    if (display == CSSDisplay.flex || display == CSSDisplay.inlineFlex) {
      RenderFlexLayout? flexLayout;

      if (prevRenderLayoutBox == null) {
        if (repaintSelf) {
          flexLayout = RenderSelfRepaintFlexLayout(
            renderStyle: renderStyle,
            elementDelegate: _elementDelegate,
          );
        } else {
          flexLayout = RenderFlexLayout(
            renderStyle: renderStyle,
            elementDelegate: _elementDelegate,
          );
        }
      } else if (prevRenderLayoutBox is RenderFlowLayout) {
        if (prevRenderLayoutBox is RenderSelfRepaintFlowLayout) {
          if (repaintSelf) {
            // RenderSelfRepaintFlowLayout --> RenderSelfRepaintFlexLayout
            flexLayout = prevRenderLayoutBox.toFlexLayout();
          } else {
            // RenderSelfRepaintFlowLayout --> RenderFlexLayout
            flexLayout = prevRenderLayoutBox.toParentRepaintFlexLayout();
          }
        } else {
          if (repaintSelf) {
            // RenderFlowLayout --> RenderSelfRepaintFlexLayout
            flexLayout = prevRenderLayoutBox.toSelfRepaintFlexLayout();
          } else {
            // RenderFlowLayout --> RenderFlexLayout
            flexLayout = prevRenderLayoutBox.toFlexLayout();
          }
        }
      } else if (prevRenderLayoutBox is RenderFlexLayout) {
        if (prevRenderLayoutBox is RenderSelfRepaintFlexLayout) {
          if (repaintSelf) {
            // RenderSelfRepaintFlexLayout --> RenderSelfRepaintFlexLayout
            flexLayout = prevRenderLayoutBox;
            return flexLayout;
          } else {
            // RenderSelfRepaintFlexLayout --> RenderFlexLayout
            flexLayout = prevRenderLayoutBox.toParentRepaint();
          }
        } else {
          if (repaintSelf) {
            // RenderFlexLayout --> RenderSelfRepaintFlexLayout
            flexLayout = prevRenderLayoutBox.toSelfRepaint();
          } else {
            // RenderFlexLayout --> RenderFlexLayout
            flexLayout = prevRenderLayoutBox;
            return flexLayout;
          }
        }
      } else if (prevRenderLayoutBox is RenderRecyclerLayout) {
        flexLayout = prevRenderLayoutBox.toFlexLayout();
      }

      return flexLayout!;
    } else if (display == CSSDisplay.block ||
      display == CSSDisplay.none ||
      display == CSSDisplay.inline ||
      display == CSSDisplay.inlineBlock) {
      RenderFlowLayout? flowLayout;

      if (prevRenderLayoutBox == null) {
        if (repaintSelf) {
          flowLayout = RenderSelfRepaintFlowLayout(
            renderStyle: renderStyle,
            elementDelegate: _elementDelegate,
          );
        } else {
          flowLayout = RenderFlowLayout(
            renderStyle: renderStyle,
            elementDelegate: _elementDelegate,
          );
        }
      } else if (prevRenderLayoutBox is RenderFlowLayout) {
        if (prevRenderLayoutBox is RenderSelfRepaintFlowLayout) {
          if (repaintSelf) {
            // RenderSelfRepaintFlowLayout --> RenderSelfRepaintFlowLayout
            flowLayout = prevRenderLayoutBox;
            return flowLayout;
          } else {
            // RenderSelfRepaintFlowLayout --> RenderFlowLayout
            flowLayout = prevRenderLayoutBox.toParentRepaint();
          }
        } else {
          if (repaintSelf) {
            // RenderFlowLayout --> RenderSelfRepaintFlowLayout
            flowLayout = prevRenderLayoutBox.toSelfRepaint();
          } else {
            // RenderFlowLayout --> RenderFlowLayout
            flowLayout = prevRenderLayoutBox;
            return flowLayout;
          }
        }
      } else if (prevRenderLayoutBox is RenderFlexLayout) {
        if (prevRenderLayoutBox is RenderSelfRepaintFlexLayout) {
          if (repaintSelf) {
            // RenderSelfRepaintFlexLayout --> RenderSelfRepaintFlowLayout
            flowLayout = prevRenderLayoutBox.toFlowLayout();
          } else {
            // RenderSelfRepaintFlexLayout --> RenderFlowLayout
            flowLayout = prevRenderLayoutBox.toParentRepaintFlowLayout();
          }
        } else {
          if (repaintSelf) {
            // RenderFlexLayout --> RenderSelfRepaintFlowLayout
            flowLayout = prevRenderLayoutBox.toSelfRepaintFlowLayout();
          } else {
            // RenderFlexLayout --> RenderFlowLayout
            flowLayout = prevRenderLayoutBox.toFlowLayout();
          }
        }
      } else if (prevRenderLayoutBox is RenderRecyclerLayout) {
        // RenderRecyclerLayout --> RenderFlowLayout
        flowLayout = prevRenderLayoutBox.toFlowLayout();
      }

      return flowLayout!;
    } else if (display == CSSDisplay.sliver) {
      RenderRecyclerLayout? renderRecyclerLayout;

      if (prevRenderLayoutBox == null) {
        renderRecyclerLayout = RenderRecyclerLayout(
          renderStyle: renderStyle,
          elementDelegate: _elementDelegate,
        );
      } else if (prevRenderLayoutBox is RenderFlowLayout) {
        renderRecyclerLayout = prevRenderLayoutBox.toRenderRecyclerLayout();
      } else if (prevRenderLayoutBox is RenderFlexLayout) {
        renderRecyclerLayout = prevRenderLayoutBox.toRenderRecyclerLayout();
      } else if (prevRenderLayoutBox is RenderRecyclerLayout) {
        renderRecyclerLayout = prevRenderLayoutBox;
      }

      return renderRecyclerLayout!;
    } else {
      throw FlutterError('Not supported display type $display');
    }
  }

  RenderIntrinsic _createRenderIntrinsic({
    RenderIntrinsic? prevRenderIntrinsic,
    bool repaintSelf = false
  }) {
    RenderIntrinsic intrinsic;

    if (prevRenderIntrinsic == null) {
      if (repaintSelf) {
        intrinsic = RenderSelfRepaintIntrinsic(
          renderStyle,
          _elementDelegate
        );
      } else {
        intrinsic = RenderIntrinsic(
          renderStyle,
          _elementDelegate
        );
      }
    } else {
      if (prevRenderIntrinsic is RenderSelfRepaintIntrinsic) {
        if (repaintSelf) {
          // RenderSelfRepaintIntrinsic --> RenderSelfRepaintIntrinsic
          intrinsic = prevRenderIntrinsic;
        } else {
          // RenderSelfRepaintIntrinsic --> RenderIntrinsic
          intrinsic = prevRenderIntrinsic.toParentRepaint();
        }
      } else {
        if (repaintSelf) {
          // RenderIntrinsic --> RenderSelfRepaintIntrinsic
          intrinsic = prevRenderIntrinsic.toSelfRepaint();
        } else {
          // RenderIntrinsic --> RenderIntrinsic
          intrinsic = prevRenderIntrinsic;
        }
      }
    }
    return intrinsic;
  }
}


Element? _findContainingBlock(Element element) {
  Element? _el = element.parentElement;
  Element rootEl = element.elementManager.viewportElement;

  while (_el != null) {
    bool isElementNonStatic = _el.renderStyle.position != CSSPositionType.static;
    bool hasTransform = _el.renderStyle.transform != null;
    // https://www.w3.org/TR/CSS2/visudet.html#containing-block-details
    if (_el == rootEl || isElementNonStatic || hasTransform) {
      break;
    }
    _el = _el.parent as Element?;
  }
  return _el;
}

bool _isIntersectionObserverEvent(String eventType) {
  return eventType == EVENT_APPEAR || eventType == EVENT_DISAPPEAR || eventType == EVENT_INTERSECTION_CHANGE;
}

bool _hasIntersectionObserverEvent(Map eventHandlers) {
  return eventHandlers.containsKey('appear') ||
      eventHandlers.containsKey('disappear') ||
      eventHandlers.containsKey('intersectionchange');
}

class BoundingClientRect {
  final double x;
  final double y;
  final double width;
  final double height;
  final double top;
  final double right;
  final double bottom;
  final double left;

  BoundingClientRect(this.x, this.y, this.width, this.height, this.top, this.right, this.bottom, this.left);

  Pointer<NativeBoundingClientRect> toNative() {
    Pointer<NativeBoundingClientRect> nativeBoundingClientRect = malloc.allocate<NativeBoundingClientRect>(sizeOf<NativeBoundingClientRect>());
    nativeBoundingClientRect.ref.width = width;
    nativeBoundingClientRect.ref.height = height;
    nativeBoundingClientRect.ref.x = x;
    nativeBoundingClientRect.ref.y = y;
    nativeBoundingClientRect.ref.top = top;
    nativeBoundingClientRect.ref.right = right;
    nativeBoundingClientRect.ref.left = left;
    nativeBoundingClientRect.ref.bottom = bottom;
    return nativeBoundingClientRect;
  }

  Map<String, dynamic> toJSON() {
    return {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'left': left,
      'top': top,
      'right': right,
      'bottom': bottom
    };
  }
}

void _setPositionedChildParentData(RenderLayoutBox parentRenderLayoutBox, Element child) {
  RenderLayoutParentData parentData = RenderLayoutParentData();
  RenderBoxModel childRenderBoxModel = child.renderBoxModel!;
  childRenderBoxModel.parentData = CSSPositionedLayout.getPositionParentData(childRenderBoxModel, parentData);
}
