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
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';
import 'package:meta/meta.dart';
import 'package:ffi/ffi.dart';

import 'element_native_methods.dart';

const String STYLE = 'style';

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

  RenderBoxModel? get renderBoxModel => _renderLayoutBox ?? _renderIntrinsic ?? null;
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
}

/// Mark the renderer of element as needs layout.
typedef void MarkRendererNeedsLayout();
/// Toggle the renderer of element between repaint boundary and non repaint boundary.
typedef void ToggleRendererRepaintBoundary();
/// Detach the renderer from its owner element.
typedef void DetachRenderer();
/// Do the preparation work before the renderer is attached.
typedef void BeforeRendererAttach();
/// Do the clean work after the renderer has attached.
typedef void AfterRendererAttach();
/// Return the targetId of current element.
typedef int GetTargetId();

/// Delegate methods passed to renderBoxModel for actions involved with element
/// (eg. convert renderBoxModel to repaint boundary then attach to element).
class ElementDelegate {
  MarkRendererNeedsLayout markRendererNeedsLayout;
  ToggleRendererRepaintBoundary toggleRendererRepaintBoundary;
  DetachRenderer detachRenderer;
  BeforeRendererAttach beforeRendererAttach;
  AfterRendererAttach afterRendererAttach;
  GetTargetId getTargetId;

  ElementDelegate(
    this.markRendererNeedsLayout,
    this.toggleRendererRepaintBoundary,
    this.detachRenderer,
    this.beforeRendererAttach,
    this.afterRendererAttach,
    this.getTargetId
  );
}

class Element extends Node
    with
        ElementBase,
        ElementNativeMethods,
        EventHandlerMixin,
        CSSOverflowMixin,
        CSSVisibilityMixin,
        CSSTransitionMixin,
        CSSFilterEffectsMixin {
  static SplayTreeMap<int, Element> _nativeMap = SplayTreeMap();

  static Element getElementOfNativePtr(Pointer<NativeElement> nativeElement) {
    Element? element = _nativeMap[nativeElement.address];
    if (element == null) throw FlutterError('Can not get element from nativeElement: $nativeElement');
    return element;
  }

  final Map<String, dynamic> properties = Map<String, dynamic>();

  /// Should create repaintBoundary for this element to repaint separately from parent.
  bool repaintSelf;

  final String tagName;

  final Map<String, dynamic> defaultStyle;

  /// The default display type.
  final String defaultDisplay;

  /// Is element an intrinsic box.
  final bool _isIntrinsicBox;

  final Pointer<NativeElement> nativeElementPtr;

  /// Style declaration from user input.
  late CSSStyleDeclaration style;

  Size get viewportSize => elementManager.viewport.viewportSize;

  /// Whether should create repaintBoundary for this element when style changed
  bool get shouldConvertToRepaintBoundary {
    // Following cases should always convert to repaint boundary for performance consideration
    // Multiframe image
    bool isMultiframeImage = this is ImageElement && (this as ImageElement).isMultiframe;
    // Intrinsic element such as Canvas
    bool isSetRepaintSelf = repaintSelf;
    // Scrolling box
    bool isScrollingBox = scrollingContentLayoutBox != null;
    // Transform element
    bool hasTransform = renderBoxModel?.renderStyle.transform != null;
    // Fixed element
    bool isPositionedFixed = renderBoxModel?.renderStyle.position == CSSPositionType.fixed;

    return isMultiframeImage || isScrollingBox ||
      isSetRepaintSelf || hasTransform || isPositionedFixed;
  }

  Element(int targetId, this.nativeElementPtr, ElementManager elementManager,
      {required this.tagName,
        this.defaultStyle = const <String, dynamic>{},
        // Whether element allows children.
        bool isIntrinsicBox = false,
        this.repaintSelf = false,
        // @HACK: overflow scroll needs to create an shadow element to create an scrolling renderBox for better scrolling performance.
        // we needs to prevent this shadow element override real element in nativeMap.
        bool isHiddenElement = false})
      : _isIntrinsicBox = isIntrinsicBox,
        defaultDisplay = defaultStyle.containsKey(DISPLAY) ? defaultStyle[DISPLAY] : INLINE,
        super(NodeType.ELEMENT_NODE, targetId, nativeElementPtr.ref.nativeNode, elementManager, tagName) {
    style = CSSStyleDeclaration(this);

    if (!isHiddenElement) {
      _nativeMap[nativeElementPtr.address] = this;
    }

    bindNativeMethods(nativeElementPtr);
    _setDefaultStyle();
  }

  ElementDelegate get elementDelegate {
    return ElementDelegate(
      _markRendererNeedsLayout,
      _toggleRendererRepaintBoundary,
      _detachRenderer,
      _beforeRendererAttach,
      _afterRendererAttach,
      _getTargetId,
    );
  }

  void _markRendererNeedsLayout() {
    renderBoxModel!.markNeedsLayout();
  }

  void _toggleRendererRepaintBoundary() {
    if (shouldConvertToRepaintBoundary) {
      convertToRepaintBoundary();
    } else {
      convertToNonRepaintBoundary();
    }
  }

  void _detachRenderer() {
    detach();
  }

  void _beforeRendererAttach() {
    willAttachRenderer();
  }

  void _afterRendererAttach() {
    style.applyTargetProperties();
    didAttachRenderer();
    ensureChildAttached();
  }

  int _getTargetId() {
    return targetId;
  }

  @override
  RenderObject? get renderer => renderBoxModel?.renderPositionHolder ?? renderBoxModel;

  @override
  RenderObject createRenderer() {
    if (renderer != null) {
      return renderer!;
    }

    RenderStyle? renderStyle;
    // Content children layout, BoxModel content.
    if (_isIntrinsicBox) {
      RenderIntrinsic renderIntrinsic = _renderIntrinsic = createRenderIntrinsic(
        this,
        repaintSelf: repaintSelf,
      );
      renderStyle = renderIntrinsic.renderStyle;
    } else {
      RenderLayoutBox renderLayoutBox = _renderLayoutBox = createRenderLayout(
        this,
        repaintSelf: repaintSelf,
      );
      renderStyle = renderLayoutBox.renderStyle;
    }

    return renderer!;
  }

  @override
  void willAttachRenderer() {
    createRenderer();
    style.addStyleChangeListener(_onStyleChanged);
  }

  @override
  void didAttachRenderer() {
    RenderBoxModel _renderBoxModel = renderBoxModel!;

    // Set display and transformedDisplay when display is not set in style.
    _renderBoxModel.renderStyle.initDisplay(style, defaultDisplay);

    // Bind pointer responder.
    addEventResponder(_renderBoxModel);

    if (_hasIntersectionObserverEvent(eventHandlers)) {
      _renderBoxModel.addIntersectionChangeListener(handleIntersectionChange);
    }
  }

  @override
  void willDetachRenderer() {
    RenderBoxModel _renderBoxModel = renderBoxModel!;

    // Remove all intersection change listeners.
    _renderBoxModel.clearIntersectionChangeListeners();

    // Remove placeholder of positioned element.
    RenderPositionHolder? renderPositionHolder = _renderBoxModel.renderPositionHolder;
    if (renderPositionHolder != null) {
      RenderLayoutBox? parent = renderPositionHolder.parent as RenderLayoutBox?;
      if (parent != null) {
        parent.remove(renderPositionHolder);
      }
    }
  }

  @override
  void didDetachRenderer() {
    style.removeStyleChangeListener(_onStyleChanged);
  }

  void _setDefaultStyle() {
    if (defaultStyle.isNotEmpty) {
      defaultStyle.forEach((property, dynamic value) {
        style.setProperty(property, value, viewportSize);
      });
    }
  }

  // TODO: debounce scroll listener
  void _scrollListener(double scrollOffset, AxisDirection axisDirection) {
    applyStickyChildrenOffset();
    paintFixedChildren(scrollOffset, axisDirection);

    if (eventHandlers.containsKey(EVENT_SCROLL)) {
      _fireScrollEvent();
    }
  }

  /// https://drafts.csswg.org/cssom-view/#scrolling-events
  void _fireScrollEvent() {
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

  /// Toggle renderBoxModel between repaint boundary and non repaint boundary
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
    RenderBoxModel targetRenderBox = createRenderBoxModel(
      this,
      prevRenderBoxModel: _renderBoxModel,
      repaintSelf: repaintSelf
    );
    // Append new renderObject
    if (parentRenderObject is ContainerRenderObjectMixin) {
      renderBoxModel = _renderBoxModel = targetRenderBox;
      _parentElement.addChildRenderObject(this, after: previousSibling);
    } else if (parentRenderObject is RenderObjectWithChildMixin) {
      parentRenderObject.child = targetRenderBox;
    }

    renderBoxModel = _renderBoxModel = targetRenderBox;
    // Update renderBoxModel reference in renderStyle
    _renderBoxModel.renderStyle.renderBoxModel = targetRenderBox;
  }

  void _updatePosition(CSSPositionType prevPosition, CSSPositionType currentPosition) {
    RenderBoxModel _renderBoxModel = renderBoxModel!;
    Element _parentElement = parentElement!;

    // Remove fixed children before convert to non repaint boundary renderObject
    if (currentPosition != CSSPositionType.fixed) {
      _removeFixedChild(_renderBoxModel);
    }

    // Move element according to position when it's already attached to render tree.
    if (isRendererAttached) {
      RenderObject _renderer = renderer!;

      RenderBox? prev = (_renderer.parentData as ContainerBoxParentData<RenderBox>).previousSibling;
      // It needs to find the previous sibling of the previous sibling if the placeholder of
      // positioned element exists and follows renderObject at the same time, eg.
      // <div style="position: relative"><div style="postion: absolute" /></div>
      if (prev == _renderBoxModel) {
        prev = (_renderBoxModel.parentData as ContainerBoxParentData<RenderBox>).previousSibling;
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

    _renderBoxModel = renderBoxModel!;

    // Add fixed children after convert to repaint boundary renderObject
    if (currentPosition == CSSPositionType.fixed) {
      _addFixedChild(_renderBoxModel);
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
        RenderLayoutBox? parentRenderLayoutBox = _scrollingContentLayoutBox != null ?
        _scrollingContentLayoutBox : _renderLayoutBox;

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
  void attachTo(Element parent, {RenderBox? after}) {
    CSSDisplay display = CSSDisplayMixin.getDisplay(style[DISPLAY] ?? defaultDisplay);
    if (display != CSSDisplay.none) {
      _beforeRendererAttach();
      parent.addChildRenderObject(this, after: after);
      _afterRendererAttach();
    }
  }

  // Detach renderObject of current node from parent
  @override
  void detach() {
    RenderBoxModel? selfRenderBoxModel = renderBoxModel;
    if (selfRenderBoxModel == null) return;

    willDetachRenderer();

    // Remove fixed children from root when dispose
    _removeFixedChild(selfRenderBoxModel);

    RenderObject? parent = selfRenderBoxModel.parent as RenderObject?;
    if (parent is ContainerRenderObjectMixin) {
      parent.remove(selfRenderBoxModel);
    } else if (parent is RenderProxyBox) {
      parent.child = null;
    }

    for (Node child in childNodes) {
      child.detach();
    }

    didDetachRenderer();

    // Call dispose method of renderBoxModel when it is detached from tree
    selfRenderBoxModel.dispose();
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

    _debugCheckNestedInline(child);
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

    super.removeChild(child);
    return child;
  }

  void _debugCheckNestedInline(Node child) {
    // @NOTE: Make sure inline-box only have inline children, or print warning.
    if ((child is Element) && !child.isInlineBox && isInlineContent) {
      print('[WARN]: Can not nest non-inline element into non-inline parent element.');
    }
  }

  @override
  @mustCallSuper
  Node insertBefore(Node child, Node referenceNode) {
    _debugCheckNestedInline(child);

    int referenceIndex = childNodes.indexOf(referenceNode);
    // Node.insertBefore will change element tree structure,
    // so get the referenceIndex before calling it.
    Node node = super.insertBefore(child, referenceNode);
    if (isRendererAttached) {
      // Only append child renderer when which is not attached.
      if (!child.isRendererAttached) {
        RenderBox? afterRenderObject;
        // `referenceNode` should not be null, or `referenceIndex` can only be -1.
        if (referenceIndex != -1 && referenceNode.isRendererAttached) {
          afterRenderObject = (referenceNode.renderer!.parentData as ContainerBoxParentData<RenderBox>).previousSibling;
        }
        child.attachTo(this, after: afterRenderObject);
      }
    }

    return node;
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
        childRenderStyle.width ?? 0,
        childRenderStyle.height ?? 0,
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
    if (fixedChildren.indexOf(childRenderBoxModel) == -1) {
      fixedChildren.add(childRenderBoxModel);
    }
  }

  /// Remove non fixed renderObject to root element
  void _removeFixedChild(RenderBoxModel childRenderBoxModel) {
    Element rootEl = elementManager.viewportElement;
    RenderLayoutBox? rootRenderLayoutBox = rootEl.scrollingContentLayoutBox!;
    List<RenderBoxModel> fixedChildren = rootRenderLayoutBox.fixedChildren;
    if (fixedChildren.indexOf(childRenderBoxModel) != -1) {
      fixedChildren.remove(childRenderBoxModel);
    }
  }

  // Inline box including inline/inline-block/inline-flex/...
  bool get isInlineBox {
    String displayValue = style[DISPLAY];
    return displayValue.startsWith(INLINE);
  }

  // Inline content means children should be inline elements.
  bool get isInlineContent {
    String displayValue = style[DISPLAY];
    return displayValue == INLINE;
  }

  void _onStyleChanged(String property, String? original, String present) {
    switch (property) {
      case DISPLAY:
        _styleDisplayChangedListener(property, original, present);
        break;

      case VERTICAL_ALIGN:
        _styleVerticalAlignChangedListener(property, original, present);
        break;

      case POSITION:
        _stylePositionChangedListener(property, original, present);
        break;

      case Z_INDEX:
        _styleZIndexChangedListener(property, original, present);
        break;

      case TOP:
      case LEFT:
      case BOTTOM:
      case RIGHT:
        _styleOffsetChangedListener(property, original, present);
        break;

      case FLEX_DIRECTION:
      case FLEX_WRAP:
      case ALIGN_CONTENT:
      case ALIGN_ITEMS:
      case JUSTIFY_CONTENT:
        _styleFlexChangedListener(property, original, present);
        break;

      case ALIGN_SELF:
      case FLEX_GROW:
      case FLEX_SHRINK:
      case FLEX_BASIS:
        _styleFlexItemChangedListener(property, original, present);
        break;

      case SLIVER_DIRECTION:
        _styleSliverDirectionChangedListener(property, original, present);
        break;

      case TEXT_ALIGN:
        _styleTextAlignChangedListener(property, original, present);
        break;

      case PADDING_TOP:
      case PADDING_RIGHT:
      case PADDING_BOTTOM:
      case PADDING_LEFT:
        _stylePaddingChangedListener(property, original, present);
        break;

      case WIDTH:
      case MIN_WIDTH:
      case MAX_WIDTH:
      case HEIGHT:
      case MIN_HEIGHT:
      case MAX_HEIGHT:
        _styleSizeChangedListener(property, original, present);
        break;

      case OVERFLOW_X:
      case OVERFLOW_Y:
        _styleOverflowChangedListener(property, original, present);
        break;

      case BACKGROUND_COLOR:
      case BACKGROUND_ATTACHMENT:
      case BACKGROUND_IMAGE:
      case BACKGROUND_REPEAT:
      case BACKGROUND_POSITION_X:
      case BACKGROUND_POSITION_Y:
      case BACKGROUND_SIZE:
      case BACKGROUND_CLIP:
      case BACKGROUND_ORIGIN:
      case BORDER_LEFT_WIDTH:
      case BORDER_TOP_WIDTH:
      case BORDER_RIGHT_WIDTH:
      case BORDER_BOTTOM_WIDTH:
      case BORDER_LEFT_STYLE:
      case BORDER_TOP_STYLE:
      case BORDER_RIGHT_STYLE:
      case BORDER_BOTTOM_STYLE:
      case BORDER_LEFT_COLOR:
      case BORDER_TOP_COLOR:
      case BORDER_RIGHT_COLOR:
      case BORDER_BOTTOM_COLOR:
      case BOX_SHADOW:
        _styleBoxChangedListener(property, original, present);
        break;

      case BORDER_TOP_LEFT_RADIUS:
      case BORDER_TOP_RIGHT_RADIUS:
      case BORDER_BOTTOM_LEFT_RADIUS:
      case BORDER_BOTTOM_RIGHT_RADIUS:
        _styleBorderRadiusChangedListener(property, original, present);
        break;

      case MARGIN_LEFT:
      case MARGIN_TOP:
      case MARGIN_RIGHT:
      case MARGIN_BOTTOM:
        _styleMarginChangedListener(property, original, present);
        break;

      case OPACITY:
        _styleOpacityChangedListener(property, original, present);
        break;
      case VISIBILITY:
        _styleVisibilityChangedListener(property, original, present);
        break;
      case CONTENT_VISIBILITY:
        _styleContentVisibilityChangedListener(property, original, present);
        break;
      case TRANSFORM:
        _styleTransformChangedListener(property, original, present);
        break;
      case TRANSFORM_ORIGIN:
        _styleTransformOriginChangedListener(property, original, present);
        break;
      case TRANSITION_DELAY:
      case TRANSITION_DURATION:
      case TRANSITION_TIMING_FUNCTION:
      case TRANSITION_PROPERTY:
        _styleTransitionChangedListener(property, original, present);
        break;

      case OBJECT_FIT:
        _styleObjectFitChangedListener(property, original, present);
        break;
      case OBJECT_POSITION:
        _styleObjectPositionChangedListener(property, original, present);
        break;

      case FILTER:
        _styleFilterChangedListener(property, original, present);
        break;
    }

    // Text Style
    switch (property) {
      case COLOR:
        _updateTextStyle(property);
        // Color change should trigger currentColor update
        _styleBoxChangedListener(property, original, present);
        break;
      case TEXT_SHADOW:
      case TEXT_DECORATION_LINE:
      case TEXT_DECORATION_STYLE:
      case TEXT_DECORATION_COLOR:
      case FONT_WEIGHT:
      case FONT_STYLE:
      case FONT_FAMILY:
      case FONT_SIZE:
      case LINE_HEIGHT:
      case LETTER_SPACING:
      case WORD_SPACING:
      case WHITE_SPACE:
      case TEXT_OVERFLOW:
      // Overflow will affect text-overflow ellipsis taking effect
      case OVERFLOW_X:
      case OVERFLOW_Y:
      case LINE_CLAMP:
        _updateTextStyle(property);
        break;
    }
  }

  void _styleDisplayChangedListener(String property, String? original, String present) {
    renderBoxModel!.renderStyle.updateDisplay(present, this);
  }

  void _styleVerticalAlignChangedListener(String property, String? original, String present) {
    renderBoxModel!.renderStyle.updateVerticalAlign(present);
  }

  void _stylePositionChangedListener(String property, String? original, String present) {
    /// Update position.
    CSSPositionType prevPosition = renderBoxModel!.renderStyle.position;
    CSSPositionType currentPosition = CSSPositionMixin.parsePositionType(present);

    // Position changed.
    if (prevPosition != currentPosition) {
      renderBoxModel!.renderStyle.updatePosition(property, present);
      _updatePosition(prevPosition, currentPosition);
    }
  }

  void _styleZIndexChangedListener(String property, String? original, String present) {
    renderBoxModel!.renderStyle.updateZIndex(property, present);
  }

  void _styleOffsetChangedListener(String property, String? original, String present) {
    /// Percentage size should be resolved in layout stage cause it needs to know its containing block's size
    if (CSSLength.isPercentage(present)) {
      // Should mark positioned element's containing block needs layout directly
      // cause RelayoutBoundary of positioned element will prevent the needsLayout flag
      // to bubble up in the RenderObject tree.
      RenderBoxModel? selfRenderBoxModel = renderBoxModel;
      if (selfRenderBoxModel == null) return;

      if (selfRenderBoxModel.parentData is RenderLayoutParentData) {
        RenderStyle renderStyle = selfRenderBoxModel.renderStyle;
        if (renderStyle.position != CSSPositionType.static) {
          RenderBoxModel? parent = selfRenderBoxModel.parent as RenderBoxModel?;
          parent!.markNeedsLayout();
        }
      }
      return;
    }

    RenderStyle renderStyle = renderBoxModel!.renderStyle;
    double? presentValue = CSSLength.toDisplayPortValue(present, renderStyle: renderStyle);
    if (presentValue == null) return;
    renderStyle.updateOffset(property, presentValue);
  }

  void _styleTextAlignChangedListener(String property, String? original, String present) {
    renderBoxModel!.renderStyle.updateFlow();
  }

  void _styleObjectFitChangedListener(String property, String? original, String present) {
    renderBoxModel!.renderStyle.updateObjectFit(property, present);
  }

  void _styleObjectPositionChangedListener(String property, String? original, String present) {
    renderBoxModel!.renderStyle.updateObjectPosition(property, present);
  }

  void _styleFilterChangedListener(String property, String? original, String present) {
    updateFilterEffects(renderBoxModel!, present);
  }

  void _styleTransitionChangedListener(String property, String? original, String present) {
    updateTransition(style);
  }

  void _styleOverflowChangedListener(String property, String? original, String present) {
    updateRenderOverflow(this, _scrollListener);
  }

  void _stylePaddingChangedListener(String property, String? original, String present) {
    /// Percentage size should be resolved in layout stage cause it needs to know its containing block's size
    RenderBoxModel selfRenderBoxModel = renderBoxModel!;
    if (CSSLength.isPercentage(present)) {
      // Mark parent needs layout to resolve percentage of child
      if (selfRenderBoxModel.parent is RenderBoxModel) {
        (selfRenderBoxModel.parent as RenderBoxModel).markNeedsLayout();
      }
      return;
    }

    RenderStyle renderStyle = selfRenderBoxModel.renderStyle;
    double presentValue = CSSLength.toDisplayPortValue(present, renderStyle: renderStyle) ?? 0;
    renderStyle.updatePadding(property, presentValue);
  }

  void _styleSizeChangedListener(String property, String? original, String present) {
    RenderBoxModel selfRenderBoxModel = renderBoxModel!;
    /// Percentage size should be resolved in layout stage cause it needs to know its containing block's size
    if (CSSLength.isPercentage(present)) {
      // Mark parent needs layout to resolve percentage of child
      if (selfRenderBoxModel.parent is RenderBoxModel) {
        (selfRenderBoxModel.parent as RenderBoxModel).markNeedsLayout();
      }
      return;
    }

    RenderStyle renderStyle = selfRenderBoxModel.renderStyle;
    double? presentValue = CSSLength.toDisplayPortValue(present, renderStyle: renderStyle);
    renderStyle.updateSizing(property, presentValue);
  }

  void _styleMarginChangedListener(String property, String? original, String present) {
    RenderBoxModel selfRenderBoxModel = renderBoxModel!;
    /// Percentage size should be resolved in layout stage cause it needs to know its containing block's size
    if (CSSLength.isPercentage(present)) {
      // Mark parent needs layout to resolve percentage of child
      if (selfRenderBoxModel.parent is RenderBoxModel) {
        (selfRenderBoxModel.parent as RenderBoxModel).markNeedsLayout();
      }
      return;
    }

    RenderStyle renderStyle = selfRenderBoxModel.renderStyle;
    double presentValue = CSSLength.toDisplayPortValue(present, renderStyle: renderStyle) ?? 0;
    renderStyle.updateMargin(property, presentValue);
    // Margin change in flex layout may affect transformed display
    // https://www.w3.org/TR/css-display-3/#transformations
    renderStyle.transformedDisplay = renderStyle.getTransformedDisplay();
  }

  void _styleFlexChangedListener(String property, String? original, String present) {
    RenderStyle renderStyle = renderBoxModel!.renderStyle;
    renderStyle.updateFlexbox();
    // Flex properties change may affect transformed display
    // https://www.w3.org/TR/css-display-3/#transformations
    renderStyle.transformedDisplay = renderStyle.getTransformedDisplay();
  }

  void _styleFlexItemChangedListener(String property, String? original, String present) {
    Element selfParentElement = parentElement!;
    CSSDisplay? parentDisplayValue = selfParentElement.renderBoxModel!.renderStyle.display;
    bool isParentFlexDisplayType = parentDisplayValue == CSSDisplay.flex || parentDisplayValue == CSSDisplay.inlineFlex;

    // Flex factor change will cause flex item self and its siblings relayout.
    if (isParentFlexDisplayType) {
      for (Element child in parent!.children) {
        if (selfParentElement.renderBoxModel is RenderFlexLayout && child.renderBoxModel != null) {
          child.renderBoxModel!.renderStyle.updateFlexItem();
          child.renderBoxModel!.markNeedsLayout();
        }
      }
    }
  }

  void _styleSliverDirectionChangedListener(String property, String? original, String present) {
    RenderBoxModel selfRenderBoxModel = renderBoxModel!;
    CSSDisplay? display = selfRenderBoxModel.renderStyle.display;
    if (display == CSSDisplay.sliver) {
      assert(renderBoxModel is RenderRecyclerLayout);
      selfRenderBoxModel.renderStyle.updateSliver(present);
    }
  }

  void _styleBoxChangedListener(String property, String? original, String present) {
    int contextId = elementManager.contextId;
    renderBoxModel!.renderStyle.updateBox(property, original, present, contextId);
  }

  void _styleBorderRadiusChangedListener(String property, String? original, String present) {
    RenderBoxModel selfRenderBoxModel = renderBoxModel!;
    /// Percentage size should be resolved in layout stage cause it needs to know its own element's size
    if (RenderStyle.isBorderRadiusPercentage(present)) {
      // Mark parent needs layout to resolve percentage of child
      if (selfRenderBoxModel.parent is RenderBoxModel) {
        (selfRenderBoxModel.parent as RenderBoxModel).markNeedsLayout();
      }
      return;
    }

    selfRenderBoxModel.renderStyle.updateBorderRadius(property, present);
  }

  void _styleOpacityChangedListener(String property, String? original, String present) {
    renderBoxModel!.renderStyle.updateOpacity(present);
  }

  void _styleVisibilityChangedListener(String property, String? original, String present) {
    // Update visibility
    updateRenderVisibility(CSSVisibilityMixin.getVisibility(present));
  }

  void _styleContentVisibilityChangedListener(String property, String? original, String present) {
    // Update content visibility.
    renderBoxModel!.renderStyle.updateRenderContentVisibility(present);
  }

  void _styleTransformChangedListener(String property, String? original, String present) {
    RenderBoxModel selfRenderBoxModel = renderBoxModel!;
    /// Percentage transform translate should be resolved in layout stage cause it needs to know its own element's size
    if (RenderStyle.isTransformTranslatePercentage(present)) {
      // Mark parent needs layout to resolve percentage of child
      if (selfRenderBoxModel.parent is RenderBoxModel) {
        (selfRenderBoxModel.parent as RenderBoxModel).markNeedsLayout();
      }
      return;
    }

    RenderStyle renderStyle = selfRenderBoxModel.renderStyle;
    Matrix4? matrix4 = CSSTransform.parseTransform(present, renderStyle.viewportSize, renderStyle);
    renderStyle.updateTransform(matrix4);
  }

  void _styleTransformOriginChangedListener(String property, String? original, String present) {
    // Update transform.
    renderBoxModel!.renderStyle.updateTransformOrigin(present);
  }

  // Update text related style
  void _updateTextStyle(String property) {
    /// Percentage font-size should be resolved when node attached
    /// cause it needs to know its parents style
    if (property == FONT_SIZE && CSSLength.isPercentage(style[FONT_SIZE])) {
      _updatePercentageFontSize();
      return;
    }

    /// Percentage line-height should be resolved when node attached
    /// cause it needs to know other style in its own element
    if (property == LINE_HEIGHT && CSSLength.isPercentage(style[LINE_HEIGHT])) {
      _updatePercentageLineHeight();
      return;
    }
    renderBoxModel!.renderStyle.updateTextStyle(property);
  }

  /// Percentage font size is set relative to parent's font size.
  void _updatePercentageFontSize() {
    RenderBoxModel selfRenderBoxModel = renderBoxModel!;
    RenderStyle parentRenderStyle = parentElement!.renderBoxModel!.renderStyle;
    double parentFontSize = parentRenderStyle.fontSize;
    double parsedFontSize = parentFontSize * CSSLength.parsePercentage(style[FONT_SIZE]);
    selfRenderBoxModel.renderStyle.fontSize = parsedFontSize;
  }

  /// Percentage line height is set relative to its own font size.
  void _updatePercentageLineHeight() {
    RenderBoxModel selfRenderBoxModel = renderBoxModel!;
    RenderStyle renderStyle = selfRenderBoxModel.renderStyle;
    double fontSize = renderStyle.fontSize;
    double parsedLineHeight = fontSize * CSSLength.parsePercentage(style[LINE_HEIGHT]);
    selfRenderBoxModel.renderStyle.lineHeight = parsedLineHeight;
  }

  // Universal style property change callback.
  @mustCallSuper
  void setStyle(String key, dynamic value) {
    // @HACK: delay transition property at next frame to make sure transition trigger after all style had been set.
    // https://github.com/WebKit/webkit/blob/master/Source/WebCore/style/StyleTreeResolver.cpp#L220
    // This it not a good solution between webkit implementation which write all new style property into an RenderStyle object
    // then trigger the animation phase.
    if (key == TRANSITION) {
      SchedulerBinding.instance!.addPostFrameCallback((timestamp) {
        style.setProperty(key, value, viewportSize, renderBoxModel?.renderStyle);
      });
      return;
    } else {
      CSSDisplay originalDisplay = CSSDisplayMixin.getDisplay(style[DISPLAY] ?? defaultDisplay);
      // @NOTE: See [CSSStyleDeclaration.setProperty], value change will trigger
      // [StyleChangeListener] to be invoked in sync.
      style.setProperty(key, value, viewportSize, renderBoxModel?.renderStyle);

      // When renderer and style listener is not created when original display is none,
      // thus it needs to create renderer when style changed.
      if (originalDisplay == CSSDisplay.none && key == DISPLAY && value != NONE) {
        RenderBox? after;
        Element parent = this.parent as Element;
        if (parent.scrollingContentLayoutBox != null) {
          after = parent.scrollingContentLayoutBox!.lastChild;
        } else {
          after = (parent.renderBoxModel as RenderLayoutBox).lastChild;
        }
        attachTo(parent, after: after);
      }
    }
  }

  @mustCallSuper
  void setProperty(String key, dynamic value) {
    // Each key change will emit to `setStyle`
    if (key == STYLE) {
      assert(value is Map<String, dynamic>);
      // @TODO: Consider `{ color: red }` to `{}`, need to remove invisible keys.
      (value as Map<String, dynamic>).forEach(setStyle);
    } else {
      properties[key] = value;
    }
  }

  @mustCallSuper
  dynamic getProperty(String key) {
    switch (key) {
      default:
        return properties[key];
    }
  }

  @mustCallSuper
  void removeProperty(String key) {
    properties.remove(key);

    if (key == STYLE) {
      setProperty(STYLE, null);
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
    // need to flush layout to get correct size
    elementManager
        .getRootRenderBox()
        .owner!
        .flushLayout();

    Element? element = _findContainingBlock(this);
    if (element == null) {
      element = elementManager.viewportElement;
    }
    return renderBox.localToGlobal(Offset.zero, ancestor: element.renderBoxModel);
  }

  @override
  void addEvent(String eventType) {
    super.addEvent(eventType);

    if (eventHandlers.containsKey(eventType)) return; // Only listen once.

    // Only add listener once for all intersection related event
    bool isIntersectionObserverEvent = _isIntersectionObserverEvent(eventType);
    bool hasIntersectionObserverEvent = isIntersectionObserverEvent && _hasIntersectionObserverEvent(eventHandlers);

    addEventListener(eventType, eventResponder);

    RenderBoxModel? selfRenderBoxModel = renderBoxModel;
    if (selfRenderBoxModel != null) {
      // Bind pointer responder.
      addEventResponder(selfRenderBoxModel);

      if (isIntersectionObserverEvent && !hasIntersectionObserverEvent) {
        selfRenderBoxModel.addIntersectionChangeListener(handleIntersectionChange);
      }
    }
  }

  void removeEvent(String eventType) {
    if (!eventHandlers.containsKey(eventType)) return; // Only listen once.
    removeEventListener(eventType, eventResponder);

    RenderBoxModel? selfRenderBoxModel = renderBoxModel;
    if (selfRenderBoxModel != null) {
      // Remove pointer responder.
      removeEventResponder(selfRenderBoxModel);

      // Remove listener when no intersection related event
      if (_isIntersectionObserverEvent(eventType) && !_hasIntersectionObserverEvent(eventHandlers)) {
        selfRenderBoxModel.removeIntersectionChangeListener(handleIntersectionChange);
      }
    }
  }

  void eventResponder(Event event) {
    emitUIEvent(elementManager.controller.view.contextId, nativeElementPtr.ref.nativeNode.ref.nativeEventTarget, event);
  }

  void handleMethodClick() {
    Event clickEvent = MouseEvent(EVENT_CLICK, MouseEventInit(bubbles: true, cancelable: true));

    // If element not in tree, click is fired and only response to itself.
    dispatchEvent(clickEvent);
  }

  Future<Uint8List> toBlob({double? devicePixelRatio}) {
    if (devicePixelRatio == null) {
      devicePixelRatio = window.devicePixelRatio;
    }

    Completer<Uint8List> completer = Completer();
    if (nodeName != 'HTML') {
      convertToRepaintBoundary();
    }
    renderBoxModel!.owner!.flushLayout();

    SchedulerBinding.instance!.addPostFrameCallback((_) async {
      Uint8List captured;
      RenderBoxModel? renderObject = nodeName == 'HTML' ? elementManager.viewportElement.renderBoxModel : renderBoxModel;
      if (renderObject!.hasSize && renderObject.size == Size.zero) {
        // Return a blob with zero length.
        captured = Uint8List(0);
      } else {
        Image image = await renderObject.toImage(pixelRatio: devicePixelRatio!);
        ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
        captured = byteData!.buffer.asUint8List();
      }

      completer.complete(captured);
    });
    SchedulerBinding.instance!.scheduleFrame();

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

  static RenderBoxModel createRenderBoxModel(
    Element element,
    {
      RenderBoxModel? prevRenderBoxModel,
      bool repaintSelf = false
    }
  ) {
    RenderBoxModel? renderBoxModel = prevRenderBoxModel ?? element.renderBoxModel;

    if (renderBoxModel is RenderIntrinsic) {
      return createRenderIntrinsic(
        element,
        prevRenderIntrinsic: prevRenderBoxModel as RenderIntrinsic?,
        repaintSelf: repaintSelf
      );
    } else {
      return createRenderLayout(
        element,
        prevRenderLayoutBox: prevRenderBoxModel as RenderLayoutBox?,
        repaintSelf: repaintSelf
      );
    }
  }

  static RenderLayoutBox createRenderLayout(
    Element element,
    {
      CSSStyleDeclaration? style,
      RenderLayoutBox? prevRenderLayoutBox,
      bool repaintSelf = false
    }
  ) {
    style = style ?? element.style;
    CSSDisplay display = CSSDisplayMixin.getDisplay(
      CSSStyleDeclaration.isNullOrEmptyValue(style[DISPLAY]) ? element.defaultDisplay : style[DISPLAY]
    );
    RenderStyle renderStyle = RenderStyle(style: style, viewportSize: element.viewportSize);
    ElementDelegate elementDelegate = element.elementDelegate;

    if (display == CSSDisplay.flex || display == CSSDisplay.inlineFlex) {
      RenderFlexLayout? flexLayout;

      if (prevRenderLayoutBox == null) {
        if (repaintSelf) {
          flexLayout = RenderSelfRepaintFlexLayout(
            renderStyle: renderStyle,
            elementDelegate: elementDelegate,
          );
        } else {
          flexLayout = RenderFlexLayout(
            renderStyle: renderStyle,
            elementDelegate: elementDelegate,
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

      flexLayout!.renderStyle.updateFlexbox();

      /// Set display and transformedDisplay when display is not set in style
      flexLayout.renderStyle.initDisplay(element.style, element.defaultDisplay);
      return flexLayout;
    } else if (display == CSSDisplay.block ||
      display == CSSDisplay.none ||
      display == CSSDisplay.inline ||
      display == CSSDisplay.inlineBlock) {
      RenderFlowLayout? flowLayout;

      if (prevRenderLayoutBox == null) {
        if (repaintSelf) {
          flowLayout = RenderSelfRepaintFlowLayout(
            renderStyle: renderStyle,
            elementDelegate: elementDelegate,
          );
        } else {
          flowLayout = RenderFlowLayout(
            renderStyle: renderStyle,
            elementDelegate: elementDelegate,
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

      flowLayout!.renderStyle.updateFlow();
      /// Set display and transformedDisplay when display is not set in style
      flowLayout.renderStyle.initDisplay(element.style, element.defaultDisplay);
      return flowLayout;
    } else if (display == CSSDisplay.sliver) {
      RenderRecyclerLayout? renderRecyclerLayout;

      if (prevRenderLayoutBox == null) {
        renderRecyclerLayout = RenderRecyclerLayout(
          renderStyle: renderStyle,
          elementDelegate: elementDelegate,
        );
      } else if (prevRenderLayoutBox is RenderFlowLayout) {
        renderRecyclerLayout = prevRenderLayoutBox.toRenderRecyclerLayout();
      } else if (prevRenderLayoutBox is RenderFlexLayout) {
        renderRecyclerLayout = prevRenderLayoutBox.toRenderRecyclerLayout();
      } else if (prevRenderLayoutBox is RenderRecyclerLayout) {
        renderRecyclerLayout = prevRenderLayoutBox;
      }

      /// Set display and transformedDisplay when display is not set in style
      renderRecyclerLayout!.renderStyle.initDisplay(element.style, element.defaultDisplay);
      return renderRecyclerLayout;
    } else {
      throw FlutterError('Not supported display type $display');
    }
  }

  static RenderIntrinsic createRenderIntrinsic(
    Element element,
    {
      RenderIntrinsic? prevRenderIntrinsic,
      bool repaintSelf = false
    }
  ) {
    RenderIntrinsic intrinsic;
    RenderStyle renderStyle = RenderStyle(style: element.style, viewportSize: element.viewportSize);
    ElementDelegate elementDelegate = element.elementDelegate;

    if (prevRenderIntrinsic == null) {
      if (repaintSelf) {
        intrinsic = RenderSelfRepaintIntrinsic(
          renderStyle,
          elementDelegate
        );
      } else {
        intrinsic = RenderIntrinsic(
          renderStyle,
          elementDelegate
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
    bool isElementNonStatic = _el.style[POSITION] != STATIC && _el.style[POSITION].isNotEmpty;
    bool hasTransform = _el.style[TRANSFORM].isNotEmpty;
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
