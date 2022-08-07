/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';
import 'package:webf/rendering.dart';

final RegExp _splitRegExp = RegExp(r'\s+');
const String _ONE_SPACE = ' ';
const String _STYLE_PROPERTY = 'style';
const String _CLASS_NAME = 'class';

/// Defined by W3C Standard,
/// Most element's default width is 300 in pixel,
/// height is 150 in pixel.
const String ELEMENT_DEFAULT_WIDTH = '300px';
const String ELEMENT_DEFAULT_HEIGHT = '150px';
const String UNKNOWN = 'UNKNOWN';

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
  RenderReplaced? _renderReplaced;
  RenderBoxModel? get renderBoxModel => _renderLayoutBox ?? _renderReplaced;
  set renderBoxModel(RenderBoxModel? value) {
    if (value == null) {
      _renderReplaced = null;
      _renderLayoutBox = null;
    } else if (value is RenderReplaced) {
      _renderReplaced = value;
    } else if (value is RenderLayoutBox) {
      _renderLayoutBox = value;
    } else {
      if (!kReleaseMode) throw FlutterError('Unknown RenderBoxModel value.');
    }
  }

  late CSSRenderStyle renderStyle;
}

typedef BeforeRendererAttach = RenderObject Function();
typedef GetTargetId = int Function();
typedef GetRootElementFontSize = double Function();
typedef GetChildNodes = List<Node> Function();

/// Get the viewport size of current element.
typedef GetViewportSize = Size Function();

/// Get the render box model of current element.
typedef GetRenderBoxModel = RenderBoxModel? Function();

abstract class Element extends Node with ElementBase, ElementEventMixin, ElementOverflowMixin {
  // Default to unknown, assign by [createElement], used by inspector.
  String tagName = UNKNOWN;

  // Is element an replaced element.
  // https://drafts.csswg.org/css-display/#replaced-element
  final bool _isReplacedElement;

  // The attrs.
  final Map<String, String> attributes = <String, String>{};

  /// The style of the element, not inline style.
  late CSSStyleDeclaration style;

  /// The default user-agent style.
  final Map<String, dynamic> _defaultStyle;

  /// The inline style is a map of style property name to style property value.
  final Map<String, dynamic> inlineStyle = {};

  /// The Element.classList is a read-only property that returns a collection of the class attributes of the element.
  final List<String> _classList = [];

  List<String> get classList => _classList;

  set className(String className) {
    _classList.clear();
    List<String> classList = className.split(_splitRegExp);
    if (classList.isNotEmpty) {
      _classList.addAll(classList);
    }
    recalculateStyle();
  }

  String get className => _classList.join(_ONE_SPACE);

  final bool _isDefaultRepaintBoundary;

  /// Whether should as a repaintBoundary for this element when style changed
  bool get isRepaintBoundary {
    // Following cases should always convert to repaint boundary for performance consideration.
    // Intrinsic element such as <canvas>.
    if (_isDefaultRepaintBoundary || _forceToRepaintBoundary) return true;

    // Overflow style.
    bool hasOverflowScroll = renderStyle.overflowX == CSSOverflowType.scroll ||
        renderStyle.overflowX == CSSOverflowType.auto ||
        renderStyle.overflowY == CSSOverflowType.scroll ||
        renderStyle.overflowY == CSSOverflowType.auto;
    // Transform style.
    bool hasTransform = renderStyle.transformMatrix != null;
    // Fixed position style.
    bool hasPositionedFixed = renderStyle.position == CSSPositionType.fixed;

    return hasOverflowScroll || hasTransform || hasPositionedFixed;
  }

  bool _forceToRepaintBoundary = false;
  set forceToRepaintBoundary(bool value) {
    if (_forceToRepaintBoundary == value) {
      return;
    }
    _forceToRepaintBoundary = value;
    _updateRenderBoxModel();
  }

  Element(BindingContext? context,
      {Map<String, dynamic>? defaultStyle, bool isReplacedElement = false, bool isDefaultRepaintBoundary = false})
      : _defaultStyle = defaultStyle ?? const {},
        _isReplacedElement = isReplacedElement,
        _isDefaultRepaintBoundary = isDefaultRepaintBoundary,
        super(NodeType.ELEMENT_NODE, context) {
    // Init style and add change listener.
    style = CSSStyleDeclaration.computedStyle(this, _defaultStyle, _onStyleChanged);

    // Init render style.
    renderStyle = CSSRenderStyle(target: this);
  }

  @override
  String get nodeName => tagName;

  @override
  RenderBox? get renderer => renderBoxModel;

  // https://developer.mozilla.org/en-US/docs/Web/API/Element/children
  // The children is defined at interface [ParentNode].
  List<Element> get children {
    List<Element> _children = [];
    for (Node child in childNodes) {
      if (child is Element) _children.add(child);
    }
    return _children;
  }

  @override
  RenderBox createRenderer() {
    if (renderBoxModel != null) {
      return renderBoxModel!;
    }
    _updateRenderBoxModel();
    return renderBoxModel!;
  }

  String? collectElementChildText() {
    StringBuffer buffer = StringBuffer();
    childNodes.forEach((node) {
      if (node is TextNode) {
        buffer.write(node.data);
      }
    });
    if (buffer.isNotEmpty) {
      return buffer.toString();
    } else {
      return null;
    }
  }

  // https://www.w3.org/TR/cssom-view-1/#extensions-to-the-htmlelement-interface
  // https://www.w3.org/TR/cssom-view-1/#extension-to-the-element-interface
  @override
  getBindingProperty(String key) {
    switch (key) {
      case 'offsetTop':
        return offsetTop;
      case 'offsetLeft':
        return offsetLeft;
      case 'offsetWidth':
        return offsetWidth;
      case 'offsetHeight':
        return offsetHeight;

      case 'scrollTop':
        return scrollTop;
      case 'scrollLeft':
        return scrollLeft;
      case 'scrollWidth':
        return scrollWidth;
      case 'scrollHeight':
        return scrollHeight;

      case 'clientTop':
        return clientTop;
      case 'clientLeft':
        return clientLeft;
      case 'clientWidth':
        return clientWidth;
      case 'clientHeight':
        return clientHeight;

      case 'className':
        return className;
      case 'classList':
        return classList;

      default:
        return super.getBindingProperty(key);
    }
  }

  @override
  void setBindingProperty(String key, value) {
    switch (key) {
      case 'scrollTop':
        scrollTop = castToType<double>(value);
        break;
      case 'scrollLeft':
        scrollLeft = castToType<double>(value);
        break;

      case 'className':
        className = castToType<String>(value);
        break;

      default:
        super.setBindingProperty(key, value);
    }
  }

  @override
  invokeBindingMethod(String method, List args) {
    switch (method) {
      case 'getBoundingClientRect':
        return getBoundingClientRect().toNative();
      case 'scroll':
        return scroll(castToType<double>(args[0]), castToType<double>(args[1]));
      case 'scrollBy':
        return scrollBy(castToType<double>(args[0]), castToType<double>(args[1]));
      case 'scrollTo':
        return scrollTo(castToType<double>(args[0]), castToType<double>(args[1]));
      case 'click':
        return click();

      default:
        super.invokeBindingMethod(method, args);
    }
  }

  void _updateRenderBoxModel() {
    RenderBoxModel nextRenderBoxModel;
    if (_isReplacedElement) {
      nextRenderBoxModel =
          _createRenderReplaced(isRepaintBoundary: isRepaintBoundary, previousReplaced: _renderReplaced);
    } else {
      nextRenderBoxModel =
          _createRenderLayout(isRepaintBoundary: isRepaintBoundary, previousRenderLayoutBox: _renderLayoutBox);
    }

    RenderBox? previousRenderBoxModel = renderBoxModel;
    if (nextRenderBoxModel != previousRenderBoxModel) {
      RenderObject? parentRenderObject;
      RenderBox? after;
      if (previousRenderBoxModel != null) {
        parentRenderObject = previousRenderBoxModel.parent as RenderObject?;

        if (previousRenderBoxModel.parentData is ContainerParentDataMixin<RenderBox>) {
          after = (previousRenderBoxModel.parentData as ContainerParentDataMixin<RenderBox>).previousSibling;
        }

        RenderBoxModel.detachRenderBox(previousRenderBoxModel);

        if (parentRenderObject != null) {
          RenderBoxModel.attachRenderBox(parentRenderObject, nextRenderBoxModel, after: after);
        }
      }
      renderBoxModel = nextRenderBoxModel;

      // Ensure that the event responder is bound.
      ensureEventResponderBound();
    }
  }

  RenderReplaced _createRenderReplaced({RenderReplaced? previousReplaced, bool isRepaintBoundary = false}) {
    RenderReplaced nextReplaced;

    if (previousReplaced == null) {
      if (isRepaintBoundary) {
        nextReplaced = RenderRepaintBoundaryReplaced(
          renderStyle,
        );
      } else {
        nextReplaced = RenderReplaced(
          renderStyle,
        );
      }
    } else {
      if (previousReplaced is RenderRepaintBoundaryReplaced) {
        if (isRepaintBoundary) {
          // RenderRepaintBoundaryReplaced --> RenderRepaintBoundaryReplaced
          nextReplaced = previousReplaced;
        } else {
          // RenderRepaintBoundaryReplaced --> RenderReplaced
          nextReplaced = previousReplaced.toReplaced();
        }
      } else {
        if (isRepaintBoundary) {
          // RenderReplaced --> RenderRepaintBoundaryReplaced
          nextReplaced = previousReplaced.toRepaintBoundaryReplaced();
        } else {
          // RenderReplaced --> RenderReplaced
          nextReplaced = previousReplaced;
        }
      }
    }
    return nextReplaced;
  }

  // Create renderLayoutBox if type changed and copy children if there has previous renderLayoutBox.
  RenderLayoutBox _createRenderLayout(
      {RenderLayoutBox? previousRenderLayoutBox, CSSRenderStyle? renderStyle, bool isRepaintBoundary = false}) {
    renderStyle = renderStyle ?? this.renderStyle;
    CSSDisplay display = this.renderStyle.display;
    RenderLayoutBox? nextRenderLayoutBox;

    if (display == CSSDisplay.flex || display == CSSDisplay.inlineFlex) {
      if (previousRenderLayoutBox == null) {
        if (isRepaintBoundary) {
          nextRenderLayoutBox = RenderRepaintBoundaryFlexLayout(
            renderStyle: renderStyle,
          );
        } else {
          nextRenderLayoutBox = RenderFlexLayout(
            renderStyle: renderStyle,
          );
        }
      } else if (previousRenderLayoutBox is RenderFlowLayout) {
        if (previousRenderLayoutBox is RenderRepaintBoundaryFlowLayout) {
          if (isRepaintBoundary) {
            // RenderRepaintBoundaryFlowLayout --> RenderRepaintBoundaryFlexLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toRepaintBoundaryFlexLayout();
          } else {
            // RenderRepaintBoundaryFlowLayout --> RenderFlexLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toFlexLayout();
          }
        } else {
          if (isRepaintBoundary) {
            // RenderFlowLayout --> RenderRepaintBoundaryFlexLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toRepaintBoundaryFlexLayout();
          } else {
            // RenderFlowLayout --> RenderFlexLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toFlexLayout();
          }
        }
      } else if (previousRenderLayoutBox is RenderFlexLayout) {
        if (previousRenderLayoutBox is RenderRepaintBoundaryFlexLayout) {
          if (isRepaintBoundary) {
            // RenderRepaintBoundaryFlexLayout --> RenderRepaintBoundaryFlexLayout
            nextRenderLayoutBox = previousRenderLayoutBox;
          } else {
            // RenderRepaintBoundaryFlexLayout --> RenderFlexLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toFlexLayout();
          }
        } else {
          if (isRepaintBoundary) {
            // RenderFlexLayout --> RenderRepaintBoundaryFlexLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toRepaintBoundaryFlexLayout();
          } else {
            // RenderFlexLayout --> RenderFlexLayout
            nextRenderLayoutBox = previousRenderLayoutBox;
          }
        }
      } else if (previousRenderLayoutBox is RenderSliverListLayout) {
        // RenderSliverListLayout --> RenderFlexLayout
        nextRenderLayoutBox = previousRenderLayoutBox.toFlexLayout();
      }
    } else if (display == CSSDisplay.block ||
        display == CSSDisplay.none ||
        display == CSSDisplay.inline ||
        display == CSSDisplay.inlineBlock) {
      if (previousRenderLayoutBox == null) {
        if (isRepaintBoundary) {
          nextRenderLayoutBox = RenderRepaintBoundaryFlowLayout(
            renderStyle: renderStyle,
          );
        } else {
          nextRenderLayoutBox = RenderFlowLayout(
            renderStyle: renderStyle,
          );
        }
      } else if (previousRenderLayoutBox is RenderFlowLayout) {
        if (previousRenderLayoutBox is RenderRepaintBoundaryFlowLayout) {
          if (isRepaintBoundary) {
            // RenderRepaintBoundaryFlowLayout --> RenderRepaintBoundaryFlowLayout
            nextRenderLayoutBox = previousRenderLayoutBox;
          } else {
            // RenderRepaintBoundaryFlowLayout --> RenderFlowLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toFlowLayout();
          }
        } else {
          if (isRepaintBoundary) {
            // RenderFlowLayout --> RenderRepaintBoundaryFlowLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toRepaintBoundaryFlowLayout();
          } else {
            // RenderFlowLayout --> RenderFlowLayout
            nextRenderLayoutBox = previousRenderLayoutBox;
          }
        }
      } else if (previousRenderLayoutBox is RenderFlexLayout) {
        if (previousRenderLayoutBox is RenderRepaintBoundaryFlexLayout) {
          if (isRepaintBoundary) {
            // RenderRepaintBoundaryFlexLayout --> RenderRepaintBoundaryFlowLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toRepaintBoundaryFlowLayout();
          } else {
            // RenderRepaintBoundaryFlexLayout --> RenderFlowLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toFlowLayout();
          }
        } else {
          if (isRepaintBoundary) {
            // RenderFlexLayout --> RenderRepaintBoundaryFlowLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toRepaintBoundaryFlowLayout();
          } else {
            // RenderFlexLayout --> RenderFlowLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toFlowLayout();
          }
        }
      } else if (previousRenderLayoutBox is RenderSliverListLayout) {
        // RenderSliverListLayout --> RenderFlowLayout
        nextRenderLayoutBox = previousRenderLayoutBox.toFlowLayout();
      }
    } else if (display == CSSDisplay.sliver) {
      if (previousRenderLayoutBox == null) {
        nextRenderLayoutBox = RenderSliverListLayout(
          renderStyle: renderStyle,
          manager: RenderSliverElementChildManager(this),
          onScroll: _handleScroll,
        );
      } else if (previousRenderLayoutBox is RenderFlowLayout || previousRenderLayoutBox is RenderFlexLayout) {
        //  RenderFlow/FlexLayout --> RenderSliverListLayout
        nextRenderLayoutBox =
            previousRenderLayoutBox.toSliverLayout(RenderSliverElementChildManager(this), _handleScroll);
      } else if (previousRenderLayoutBox is RenderSliverListLayout) {
        nextRenderLayoutBox = previousRenderLayoutBox;
      }
    } else {
      throw FlutterError('Not supported display type $display');
    }

    // Update scrolling content layout type.
    if (previousRenderLayoutBox != nextRenderLayoutBox && previousRenderLayoutBox?.renderScrollingContent != null) {
      updateScrollingContentBox();
    }

    return nextRenderLayoutBox!;
  }

  @override
  void willAttachRenderer() {
    super.willAttachRenderer();
    // Init render box model.
    if (renderStyle.display != CSSDisplay.none) {
      createRenderer();
    }
  }

  @override
  void didAttachRenderer() {
    super.didAttachRenderer();
    // The node attach may affect the whitespace of the nextSibling and previousSibling text node so prev and next node require layout.
    renderBoxModel?.markAdjacentRenderParagraphNeedsLayout();
    // Ensure that the child is attached.
    ensureChildAttached();
  }

  @override
  void willDetachRenderer() {
    super.willDetachRenderer();

    // Cancel running transition.
    renderStyle.cancelRunningTransition();

    RenderBoxModel? renderBoxModel = this.renderBoxModel;
    if (renderBoxModel != null) {
      // The node detach may affect the whitespace of the nextSibling and previousSibling text node so prev and next node require layout.
      renderBoxModel.markAdjacentRenderParagraphNeedsLayout();

      // Remove all intersection change listeners.
      renderBoxModel.clearIntersectionChangeListeners();

      // Remove fixed children from root when element disposed.
      if (ownerDocument.viewport != null) {
        _removeFixedChild(renderBoxModel, ownerDocument.viewport!);
      }
      // Remove renderBox.
      renderBoxModel.detachFromContainingBlock();

      // Clear pointer listener
      clearEventResponder(renderBoxModel);
    }
  }

  BoundingClientRect getBoundingClientRect() => boundingClientRect;

  bool _shouldConsumeScrollTicker = false;
  void _consumeScrollTicker(_) {
    if (_shouldConsumeScrollTicker && hasEventListener(EVENT_SCROLL)) {
      _dispatchScrollEvent();
      _shouldConsumeScrollTicker = false;
    }
  }

  /// https://drafts.csswg.org/cssom-view/#scrolling-events
  void _dispatchScrollEvent() {
    dispatchEvent(Event(EVENT_SCROLL));
  }

  void _handleScroll(double scrollOffset, AxisDirection axisDirection) {
    if (renderBoxModel == null) return;
    _applyStickyChildrenOffset();
    _applyFixedChildrenOffset(scrollOffset, axisDirection);

    if (!_shouldConsumeScrollTicker) {
      // Make sure scroll listener trigger most to 1 time each frame.
      SchedulerBinding.instance.addPostFrameCallback(_consumeScrollTicker);
      SchedulerBinding.instance.scheduleFrame();
    }
    _shouldConsumeScrollTicker = true;
  }

  /// Normally element in scroll box will not repaint on scroll because of repaint boundary optimization
  /// So it needs to manually mark element needs paint and add scroll offset in paint stage
  void _applyFixedChildrenOffset(double scrollOffset, AxisDirection axisDirection) {
    RenderViewportBox? viewport = ownerDocument.viewport;
    // Only root element has fixed children.
    if (this == ownerDocument.documentElement && viewport != null) {
      for (RenderBoxModel child in viewport.fixedChildren) {
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
  void _applyStickyChildrenOffset() {
    RenderLayoutBox scrollContainer = renderBoxModel as RenderLayoutBox;
    for (RenderBoxModel stickyChild in scrollContainer.stickyChildren) {
      CSSPositionedLayout.applyStickyChildOffset(scrollContainer, stickyChild);
    }
  }

  // Find all the nested position absolute elements which need to change the containing block
  // from other element to this element when element's position is changed from static to relative.
  // Take following html for example, div of id=4 should reposition from div of id=1 to div of id=2.
  // <div id="1" style="position: relative">
  //    <div id="2" style="position: relative"> <!-- changed from "static" to "relative" -->
  //        <div id="3">
  //            <div id="4" style="position: absolute">
  //            </div>
  //        </div>
  //    </div>
  // </div>
  List<Element> findNestedPositionAbsoluteChildren() {
    List<Element> positionAbsoluteChildren = [];

    if (!isRendererAttached) return positionAbsoluteChildren;

    children.forEach((Element child) {
      if (!child.isRendererAttached) return;

      RenderBoxModel childRenderBoxModel = child.renderBoxModel!;
      RenderStyle childRenderStyle = childRenderBoxModel.renderStyle;
      if (childRenderStyle.position == CSSPositionType.absolute) {
        positionAbsoluteChildren.add(child);
      }
      // No need to loop layout box whose position is not static.
      if (childRenderStyle.position != CSSPositionType.static) {
        return;
      }
      if (childRenderBoxModel is RenderLayoutBox) {
        List<Element> mergedChildren = child.findNestedPositionAbsoluteChildren();
        for (Element child in mergedChildren) {
          positionAbsoluteChildren.add(child);
        }
      }
    });

    return positionAbsoluteChildren;
  }

  // Find all the direct position absolute elements which need to change the containing block
  // from this element to other element when element's position is changed from relative to static.
  // Take following html for example, div of id=4 should reposition from div of id=2 to div of id=1.
  // <div id="1" style="position: relative">
  //    <div id="2" style="position: static"> <!-- changed from "relative" to "static" -->
  //        <div id="3">
  //            <div id="4" style="position: absolute">
  //            </div>
  //        </div>
  //    </div>
  // </div>
  List<Element> findDirectPositionAbsoluteChildren() {
    List<Element> directPositionAbsoluteChildren = [];

    if (!isRendererAttached) return directPositionAbsoluteChildren;

    RenderBox? child = (renderBoxModel as RenderLayoutBox).firstChild;

    while (child != null) {
      final ContainerParentDataMixin<RenderBox>? childParentData =
          child.parentData as ContainerParentDataMixin<RenderBox>?;
      if (child is! RenderLayoutBox) {
        child = childParentData!.nextSibling;
        continue;
      }
      if (child.renderStyle.position == CSSPositionType.absolute) {
        directPositionAbsoluteChildren.add(child.renderStyle.target);
      }
      child = childParentData!.nextSibling;
    }

    return directPositionAbsoluteChildren;
  }

  void _updateRenderBoxModelWithPosition(CSSPositionType oldPosition) {
    CSSPositionType currentPosition = renderStyle.position;

    // No need to detach and reattach renderBoxMode when its position
    // changes between static and relative.
    if (!(oldPosition == CSSPositionType.static && currentPosition == CSSPositionType.relative) &&
        !(oldPosition == CSSPositionType.relative && currentPosition == CSSPositionType.static)) {
      RenderBoxModel _renderBoxModel = renderBoxModel!;
      // Remove fixed children before convert to non repaint boundary renderObject
      if (currentPosition != CSSPositionType.fixed) {
        _removeFixedChild(_renderBoxModel, ownerDocument.viewport!);
      }

      // Find the renderBox of its containing block.
      RenderBox? containingBlockRenderBox = getContainingBlockRenderBox();
      // Find the previous siblings to insert before renderBoxModel is detached.
      RenderBox? previousSibling = _renderBoxModel.getPreviousSibling();
      // Detach renderBoxModel from its original parent.
      _renderBoxModel.detachFromContainingBlock();
      // Change renderBoxModel type in cases such as position changes to fixed which
      // need to create repaintBoundary.
      _updateRenderBoxModel();
      // Original parent renderBox.
      RenderBox parentRenderBox = parentNode!.renderer!;
      // Attach renderBoxModel to its containing block.
      renderBoxModel!
          .attachToContainingBlock(containingBlockRenderBox, parent: parentRenderBox, after: previousSibling);

      // Add fixed children after convert to repaint boundary renderObject.
      if (currentPosition == CSSPositionType.fixed) {
        _addFixedChild(renderBoxModel!, ownerDocument.viewport!);
      }
    }

    // Need to change the containing block of nested position absolute children from its upper parent
    // to this element when element's position is changed from static to relative.
    if (oldPosition == CSSPositionType.static) {
      List<Element> positionAbsoluteChildren = findNestedPositionAbsoluteChildren();
      positionAbsoluteChildren.forEach((Element child) {
        child.addToContainingBlock();
      });

      // Need to change the containing block of direct position absolute children from this element
      // to its upper parent when element's position is changed from relative to static.
    } else if (currentPosition == CSSPositionType.static) {
      List<Element> directPositionAbsoluteChildren = findDirectPositionAbsoluteChildren();
      directPositionAbsoluteChildren.forEach((Element child) {
        child.addToContainingBlock();
      });
    }
  }

  // Add element to its containing block which includes the steps of detach the renderBoxModel
  // from its original parent and attach to its new containing block.
  void addToContainingBlock() {
    RenderBoxModel _renderBoxModel = renderBoxModel!;
    // Find the renderBox of its containing block.
    RenderBox? containingBlockRenderBox = getContainingBlockRenderBox();
    // Find the previous siblings to insert before renderBoxModel is detached.
    RenderBox? previousSibling = _renderBoxModel.getPreviousSibling();
    // Detach renderBoxModel from its original parent.
    _renderBoxModel.detachFromContainingBlock();
    // Original parent renderBox.
    RenderBox parentRenderBox = parentNode!.renderer!;
    // Attach renderBoxModel of to its containing block.
    _renderBoxModel.attachToContainingBlock(containingBlockRenderBox, parent: parentRenderBox, after: previousSibling);
  }

  void addChild(RenderBox child) {
    if (_renderLayoutBox != null) {
      RenderLayoutBox? scrollingContentBox = _renderLayoutBox!.renderScrollingContent;
      if (scrollingContentBox != null) {
        scrollingContentBox.add(child);
      } else {
        _renderLayoutBox!.add(child);
      }
    } else if (_renderReplaced != null) {
      _renderReplaced!.child = child;
    }
  }

  @override
  void dispose() {
    renderStyle.detach();
    style.dispose();
    attributes.clear();
    disposeScrollable();
    super.dispose();
  }

  // Used for force update layout.
  void flushLayout() {
    if (isRendererAttached) {
      renderer!.owner!.flushLayout();
    }
  }

  bool _obtainSliverChild() {
    if (parentElement?.renderStyle.display == CSSDisplay.sliver) {
      // Sliver should not create renderer here, but need to trigger
      // render sliver list dynamical rebuild child by element tree.
      parentElement?._renderLayoutBox?.markNeedsLayout();
      return true;
    }
    return false;
  }

  // Attach renderObject of current node to parent
  @override
  void attachTo(Node parent, {RenderBox? after}) {
    applyStyle(style);

    if (_obtainSliverChild()) {
      // Rebuild all the sliver children.
      RenderLayoutBox? parentRenderBoxModel = parentElement!.renderBoxModel as RenderLayoutBox?;
      parentRenderBoxModel?.removeAll();
    } else {
      willAttachRenderer();
    }

    if (renderer != null) {
      // If element attach WidgetElement, render object should be attach to render tree when mount.
      if (parent.renderObjectManagerType == RenderObjectManagerType.WEBF_NODE) {
        RenderBoxModel.attachRenderBox(parent.renderer!, renderer!, after: after);
      }

      // Flush pending style before child attached.
      style.flushPendingProperties();

      didAttachRenderer();
    }
  }

  /// Unmount [renderBoxModel].
  @override
  void unmountRenderObject({bool deep = true, bool keepFixedAlive = false, bool dispose = true}) {
    // Ignore the fixed element to unmount render object.
    // It's useful for sliver manager to unmount child render object, but excluding fixed elements.
    if (keepFixedAlive && renderStyle.position == CSSPositionType.fixed) {
      return;
    }

    willDetachRenderer();

    // Dispose all renderObject when deep.
    if (deep) {
      for (Node child in [...childNodes]) {
        child.unmountRenderObject(deep: deep, keepFixedAlive: keepFixedAlive);
      }
    }

    didDetachRenderer();
    if (dispose) {
      renderBoxModel?.dispose();
    }

    renderBoxModel = null;
  }

  @override
  void ensureChildAttached() {
    if (isRendererAttached) {
      for (Node child in childNodes) {
        if (_renderLayoutBox != null && !child.isRendererAttached) {
          RenderBox? after;
          RenderLayoutBox? scrollingContentBox = _renderLayoutBox!.renderScrollingContent;
          if (scrollingContentBox != null) {
            after = scrollingContentBox.lastChild;
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

    RenderLayoutBox? renderLayoutBox = _renderLayoutBox;
    if (isRendererAttached) {
      // Only append child renderer when which is not attached.
      if (!child.isRendererAttached &&
          renderLayoutBox != null &&
          renderObjectManagerType == RenderObjectManagerType.WEBF_NODE) {
        RenderBox? after;
        RenderLayoutBox? scrollingContentBox = renderLayoutBox.renderScrollingContent;
        if (scrollingContentBox != null) {
          after = scrollingContentBox.lastChild;
        } else {
          after = renderLayoutBox.lastChild;
        }

        child.attachTo(this, after: after);
      }
    }

    return child;
  }

  @override
  @mustCallSuper
  Node removeChild(Node child) {
    super.removeChild(child);

    // Update renderStyle tree.
    if (child is Element) {
      child.renderStyle.detach();
    }

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
      // If afterRenderObject is null, which means insert child at the head of parent.
      RenderBox? afterRenderObject;

      // Only append child renderer when which is not attached.
      if (!child.isRendererAttached) {
        if (referenceIndex < childNodes.length) {
          while (referenceIndex >= 0) {
            Node reference = childNodes[referenceIndex];
            if (reference.isRendererAttached) {
              afterRenderObject = reference.renderer;
              break;
            } else {
              referenceIndex--;
            }
          }
        }

        // Renderer of referenceNode may not moved to a difference place compared to its original place
        // in the dom tree due to position absolute/fixed.
        // Use the renderPositionPlaceholder to get the same place as dom tree in this case.
        if (afterRenderObject is RenderBoxModel) {
          RenderBox? renderPositionPlaceholder = afterRenderObject.renderPositionPlaceholder;
          if (renderPositionPlaceholder != null) {
            afterRenderObject = renderPositionPlaceholder;
          }
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

  RenderBox? getContainingBlockRenderBox() {
    RenderBox? containingBlockRenderBox;
    CSSPositionType positionType = renderStyle.position;

    switch (positionType) {
      case CSSPositionType.relative:
      case CSSPositionType.static:
      case CSSPositionType.sticky:
        containingBlockRenderBox = parentNode!.renderer;
        break;
      case CSSPositionType.absolute:
        // If the element has 'position: absolute', the containing block is established by the nearest ancestor with
        // a 'position' of 'absolute', 'relative' or 'fixed', in the following way:
        //  1. In the case that the ancestor is an inline element, the containing block is the bounding box around
        //    the padding boxes of the first and the last inline boxes generated for that element.
        //    In CSS 2.1, if the inline element is split across multiple lines, the containing block is undefined.
        //  2. Otherwise, the containing block is formed by the padding edge of the ancestor.
        containingBlockRenderBox = _findContainingBlock(this, ownerDocument.documentElement!)?._renderLayoutBox;
        break;
      case CSSPositionType.fixed:
        // If the element has 'position: fixed', the containing block is established by the viewport
        // in the case of continuous media or the page area in the case of paged media.
        containingBlockRenderBox = ownerDocument.documentElement!._renderLayoutBox;
        break;
    }
    return containingBlockRenderBox;
  }

  @mustCallSuper
  String? getAttribute(String qualifiedName) {
    return attributes[qualifiedName];
  }

  @mustCallSuper
  void setAttribute(String qualifiedName, String value) {
    if (_STYLE_PROPERTY == qualifiedName) {
      // @TODO: Parse inline style css text.
    } else if (_CLASS_NAME == qualifiedName) {
      className = value;
    }
    internalSetAttribute(qualifiedName, value);
  }

  void internalSetAttribute(String qualifiedName, String value) {
    attributes[qualifiedName] = value;
  }

  @mustCallSuper
  void removeAttribute(String qualifiedName) {
    if (qualifiedName == _STYLE_PROPERTY) {
      _removeInlineStyle();
    } else if (qualifiedName == _CLASS_NAME) {
      className = EMPTY_STRING;
    }
    attributes.remove(qualifiedName);
  }

  @mustCallSuper
  bool hasAttribute(String qualifiedName) {
    return attributes.containsKey(qualifiedName);
  }

  // FIXME: only compatible with kraken plugins
  @deprecated
  void setStyle(String property, value) {
    setRenderStyle(property, value);
  }

  void _updateRenderBoxModelWithDisplay() {
    CSSDisplay presentDisplay = renderStyle.display;

    if (parentElement == null || !parentElement!.isConnected) return;

    // Destroy renderer of element when display is changed to none.
    if (presentDisplay == CSSDisplay.none) {
      unmountRenderObject(deep: true);
      return;
    }

    // Update renderBoxModel.
    _updateRenderBoxModel();
    // Attach renderBoxModel to parent if change from `display: none` to other values.
    if (!isRendererAttached && parentElement != null && parentElement!.isRendererAttached) {
      // If element attach WidgetElement, render object should be attach to render tree when mount.
      if (parentElement!.renderObjectManagerType == RenderObjectManagerType.WEBF_NODE) {
        RenderBoxModel _renderBoxModel = renderBoxModel!;
        // Find the renderBox of its containing block.
        RenderBox? containingBlockRenderBox = getContainingBlockRenderBox();
        // Find the previous siblings to insert before renderBoxModel is detached.
        RenderBox? preSibling = previousSibling?.renderer;
        // Original parent renderBox.
        RenderBox parentRenderBox = parentNode!.renderer!;
        _renderBoxModel.attachToContainingBlock(containingBlockRenderBox, parent: parentRenderBox, after: preSibling);
      }
      ensureChildAttached();
    }
  }

  void setRenderStyleProperty(String name, value) {
    // Memorize the variable value to renderStyle object.
    if (CSSVariable.isVariable(name)) {
      renderStyle.setCSSVariable(name, value.toString());
      return;
    }

    // Get the computed value of CSS variable.
    if (value is CSSVariable) {
      value = value.computedValue(name);
    }

    switch (name) {
      case DISPLAY:
        renderStyle.display = value;
        _updateRenderBoxModelWithDisplay();
        break;
      case Z_INDEX:
        renderStyle.zIndex = value;
        break;
      case OVERFLOW_X:
        CSSOverflowType oldEffectiveOverflowY = renderStyle.effectiveOverflowY;
        renderStyle.overflowX = value;
        _updateRenderBoxModel();
        updateRenderBoxModelWithOverflowX(_handleScroll);
        // Change overflowX may affect effectiveOverflowY.
        // https://drafts.csswg.org/css-overflow/#overflow-properties
        CSSOverflowType effectiveOverflowY = renderStyle.effectiveOverflowY;
        if (effectiveOverflowY != oldEffectiveOverflowY) {
          updateRenderBoxModelWithOverflowY(_handleScroll);
        }
        updateOverflowRenderBox();
        break;
      case OVERFLOW_Y:
        CSSOverflowType oldEffectiveOverflowX = renderStyle.effectiveOverflowX;
        renderStyle.overflowY = value;
        _updateRenderBoxModel();
        updateRenderBoxModelWithOverflowY(_handleScroll);
        // Change overflowY may affect the effectiveOverflowX.
        // https://drafts.csswg.org/css-overflow/#overflow-properties
        CSSOverflowType effectiveOverflowX = renderStyle.effectiveOverflowX;
        if (effectiveOverflowX != oldEffectiveOverflowX) {
          updateRenderBoxModelWithOverflowX(_handleScroll);
        }
        updateOverflowRenderBox();
        break;
      case OPACITY:
        renderStyle.opacity = value;
        break;
      case VISIBILITY:
        renderStyle.visibility = value;
        break;
      case CONTENT_VISIBILITY:
        renderStyle.contentVisibility = value;
        break;
      case POSITION:
        CSSPositionType oldPosition = renderStyle.position;
        renderStyle.position = value;
        _updateRenderBoxModelWithPosition(oldPosition);
        break;
      case TOP:
        renderStyle.top = value;
        break;
      case LEFT:
        renderStyle.left = value;
        break;
      case BOTTOM:
        renderStyle.bottom = value;
        break;
      case RIGHT:
        renderStyle.right = value;
        break;
      // Size
      case WIDTH:
        renderStyle.width = value;
        break;
      case MIN_WIDTH:
        renderStyle.minWidth = value;
        break;
      case MAX_WIDTH:
        renderStyle.maxWidth = value;
        break;
      case HEIGHT:
        renderStyle.height = value;
        break;
      case MIN_HEIGHT:
        renderStyle.minHeight = value;
        break;
      case MAX_HEIGHT:
        renderStyle.maxHeight = value;
        break;
      // Flex
      case FLEX_DIRECTION:
        renderStyle.flexDirection = value;
        break;
      case FLEX_WRAP:
        renderStyle.flexWrap = value;
        break;
      case ALIGN_CONTENT:
        renderStyle.alignContent = value;
        break;
      case ALIGN_ITEMS:
        renderStyle.alignItems = value;
        break;
      case JUSTIFY_CONTENT:
        renderStyle.justifyContent = value;
        break;
      case ALIGN_SELF:
        renderStyle.alignSelf = value;
        break;
      case FLEX_GROW:
        renderStyle.flexGrow = value;
        break;
      case FLEX_SHRINK:
        renderStyle.flexShrink = value;
        break;
      case FLEX_BASIS:
        renderStyle.flexBasis = value;
        break;
      // Background
      case BACKGROUND_COLOR:
        renderStyle.backgroundColor = value;
        break;
      case BACKGROUND_ATTACHMENT:
        renderStyle.backgroundAttachment = value;
        break;
      case BACKGROUND_IMAGE:
        renderStyle.backgroundImage = value;
        break;
      case BACKGROUND_REPEAT:
        renderStyle.backgroundRepeat = value;
        break;
      case BACKGROUND_POSITION_X:
        renderStyle.backgroundPositionX = value;
        break;
      case BACKGROUND_POSITION_Y:
        renderStyle.backgroundPositionY = value;
        break;
      case BACKGROUND_SIZE:
        renderStyle.backgroundSize = value;
        break;
      case BACKGROUND_CLIP:
        renderStyle.backgroundClip = value;
        break;
      case BACKGROUND_ORIGIN:
        renderStyle.backgroundOrigin = value;
        break;
      // Padding
      case PADDING_TOP:
        renderStyle.paddingTop = value;
        break;
      case PADDING_RIGHT:
        renderStyle.paddingRight = value;
        break;
      case PADDING_BOTTOM:
        renderStyle.paddingBottom = value;
        break;
      case PADDING_LEFT:
        renderStyle.paddingLeft = value;
        break;
      // Border
      case BORDER_LEFT_WIDTH:
        renderStyle.borderLeftWidth = value;
        break;
      case BORDER_TOP_WIDTH:
        renderStyle.borderTopWidth = value;
        break;
      case BORDER_RIGHT_WIDTH:
        renderStyle.borderRightWidth = value;
        break;
      case BORDER_BOTTOM_WIDTH:
        renderStyle.borderBottomWidth = value;
        break;
      case BORDER_LEFT_STYLE:
        renderStyle.borderLeftStyle = value;
        break;
      case BORDER_TOP_STYLE:
        renderStyle.borderTopStyle = value;
        break;
      case BORDER_RIGHT_STYLE:
        renderStyle.borderRightStyle = value;
        break;
      case BORDER_BOTTOM_STYLE:
        renderStyle.borderBottomStyle = value;
        break;
      case BORDER_LEFT_COLOR:
        renderStyle.borderLeftColor = value;
        break;
      case BORDER_TOP_COLOR:
        renderStyle.borderTopColor = value;
        break;
      case BORDER_RIGHT_COLOR:
        renderStyle.borderRightColor = value;
        break;
      case BORDER_BOTTOM_COLOR:
        renderStyle.borderBottomColor = value;
        break;
      case BOX_SHADOW:
        renderStyle.boxShadow = value;
        break;
      case BORDER_TOP_LEFT_RADIUS:
        renderStyle.borderTopLeftRadius = value;
        break;
      case BORDER_TOP_RIGHT_RADIUS:
        renderStyle.borderTopRightRadius = value;
        break;
      case BORDER_BOTTOM_LEFT_RADIUS:
        renderStyle.borderBottomLeftRadius = value;
        break;
      case BORDER_BOTTOM_RIGHT_RADIUS:
        renderStyle.borderBottomRightRadius = value;
        break;
      // Margin
      case MARGIN_LEFT:
        renderStyle.marginLeft = value;
        break;
      case MARGIN_TOP:
        renderStyle.marginTop = value;
        break;
      case MARGIN_RIGHT:
        renderStyle.marginRight = value;
        break;
      case MARGIN_BOTTOM:
        renderStyle.marginBottom = value;
        break;
      // Text
      case COLOR:
        renderStyle.color = value;
        _updateColorRelativePropertyWithColor(this);
        break;
      case TEXT_DECORATION_LINE:
        renderStyle.textDecorationLine = value;
        break;
      case TEXT_DECORATION_STYLE:
        renderStyle.textDecorationStyle = value;
        break;
      case TEXT_DECORATION_COLOR:
        renderStyle.textDecorationColor = value;
        break;
      case FONT_WEIGHT:
        renderStyle.fontWeight = value;
        break;
      case FONT_STYLE:
        renderStyle.fontStyle = value;
        break;
      case FONT_FAMILY:
        renderStyle.fontFamily = value;
        break;
      case FONT_SIZE:
        renderStyle.fontSize = value;
        _updateFontRelativeLengthWithFontSize();
        break;
      case LINE_HEIGHT:
        renderStyle.lineHeight = value;
        break;
      case LETTER_SPACING:
        renderStyle.letterSpacing = value;
        break;
      case WORD_SPACING:
        renderStyle.wordSpacing = value;
        break;
      case TEXT_SHADOW:
        renderStyle.textShadow = value;
        break;
      case WHITE_SPACE:
        renderStyle.whiteSpace = value;
        break;
      case TEXT_OVERFLOW:
        // Overflow will affect text-overflow ellipsis taking effect
        renderStyle.textOverflow = value;
        break;
      case LINE_CLAMP:
        renderStyle.lineClamp = value;
        break;
      case VERTICAL_ALIGN:
        renderStyle.verticalAlign = value;
        break;
      case TEXT_ALIGN:
        renderStyle.textAlign = value;
        break;
      // Transform
      case TRANSFORM:
        renderStyle.transform = value;
        _updateRenderBoxModel();
        break;
      case TRANSFORM_ORIGIN:
        renderStyle.transformOrigin = value;
        break;
      // Transition
      case TRANSITION_DELAY:
        renderStyle.transitionDelay = value;
        break;
      case TRANSITION_DURATION:
        renderStyle.transitionDuration = value;
        break;
      case TRANSITION_TIMING_FUNCTION:
        renderStyle.transitionTimingFunction = value;
        break;
      case TRANSITION_PROPERTY:
        renderStyle.transitionProperty = value;
        break;
      // Others
      case OBJECT_FIT:
        renderStyle.objectFit = value;
        break;
      case OBJECT_POSITION:
        renderStyle.objectPosition = value;
        break;
      case FILTER:
        renderStyle.filter = value;
        break;
      case SLIVER_DIRECTION:
        renderStyle.sliverDirection = value;
        break;
    }
  }

  void setRenderStyle(String property, String present) {
    dynamic value = present.isEmpty ? null : renderStyle.resolveValue(property, present);
    setRenderStyleProperty(property, value);
  }

  void _updateColorRelativePropertyWithColor(Element element) {
    element.renderStyle.updateColorRelativeProperty();
    if (element.children.isNotEmpty) {
      element.children.forEach((Element child) {
        if (!child.renderStyle.hasColor) {
          _updateColorRelativePropertyWithColor(child);
        }
      });
    }
  }

  void _updateFontRelativeLengthWithFontSize() {
    // Update all the children's length value.
    _updateChildrenFontRelativeLength(this);

    if (renderBoxModel!.isDocumentRootBox) {
      // Update all the document tree.
      _updateChildrenRootFontRelativeLength(this);
    }
  }

  void _updateChildrenFontRelativeLength(Element element) {
    element.renderStyle.updateFontRelativeLength();
    if (element.children.isNotEmpty) {
      element.children.forEach((Element child) {
        if (!child.renderStyle.hasFontSize) {
          _updateChildrenFontRelativeLength(child);
        }
      });
    }
  }

  void _updateChildrenRootFontRelativeLength(Element element) {
    element.renderStyle.updateRootFontRelativeLength();
    if (element.children.isNotEmpty) {
      element.children.forEach((Element child) {
        _updateChildrenRootFontRelativeLength(child);
      });
    }
  }

  void _applyDefaultStyle(CSSStyleDeclaration style) {
    if (_defaultStyle.isNotEmpty) {
      _defaultStyle.forEach((propertyName, value) {
        style.setProperty(propertyName, value);
      });
    }
  }

  void _applyInlineStyle(CSSStyleDeclaration style) {
    if (inlineStyle.isNotEmpty) {
      inlineStyle.forEach((propertyName, value) {
        // Force inline style to be applied as important priority.
        style.setProperty(propertyName, value, true);
      });
    }
  }

  void _applySheetStyle(CSSStyleDeclaration style) {
    if (classList.isNotEmpty) {
      const String classSelectorPrefix = '.';
      for (String className in classList) {
        for (CSSStyleSheet sheet in ownerDocument.styleSheets) {
          List<CSSRule> rules = sheet.cssRules;
          for (int i = 0; i < rules.length; i++) {
            CSSRule rule = rules[i];
            if (rule is CSSStyleRule && rule.selectorText == (classSelectorPrefix + className)) {
              var sheetStyle = rule.style;
              for (String propertyName in sheetStyle.keys) {
                style.setProperty(propertyName, sheetStyle[propertyName], false);
              }
            }
          }
        }
      }
    }
  }

  void _onStyleChanged(String propertyName, String? prevValue, String currentValue) {
    if (renderStyle.shouldTransition(propertyName, prevValue, currentValue)) {
      renderStyle.runTransition(propertyName, prevValue, currentValue);
    } else {
      setRenderStyle(propertyName, currentValue);
    }
  }

  // Set inline style property.
  void setInlineStyle(String property, String value) {
    // Current only for mark property is setting by inline style.
    inlineStyle[property] = value;
    style.setProperty(property, value, true);
  }

  void applyStyle(CSSStyleDeclaration style) {
    // Apply default style.
    _applyDefaultStyle(style);
    // Init display from style directly cause renderStyle is not flushed yet.
    renderStyle.initDisplay();

    _applyInlineStyle(style);
    _applySheetStyle(style);
  }

  void recalculateStyle() {
    // TODO: current only support class selector in stylesheet
    if (renderBoxModel != null && classList.isNotEmpty) {
      // Diff style.
      CSSStyleDeclaration newStyle = CSSStyleDeclaration();
      applyStyle(newStyle);
      Map<String, String?> diffs = style.diff(newStyle);
      if (diffs.isNotEmpty) {
        // Update render style.
        diffs.forEach((String propertyName, String? value) {
          style.setProperty(propertyName, value);
        });
        style.flushPendingProperties();
      }
    }
  }

  void recalculateNestedStyle() {
    recalculateStyle();
    // Update children style.
    children.forEach((Element child) {
      child.recalculateNestedStyle();
    });
  }

  void _removeInlineStyle() {
    inlineStyle.forEach((String property, _) {
      _removeInlineStyleProperty(property);
    });
    style.flushPendingProperties();
  }

  void _removeInlineStyleProperty(String property) {
    inlineStyle.remove(property);
    style.removeProperty(property, true);
  }

  // The Element.getBoundingClientRect() method returns a DOMRect object providing information
  // about the size of an element and its position relative to the viewport.
  // https://drafts.csswg.org/cssom-view/#dom-element-getboundingclientrect
  BoundingClientRect get boundingClientRect {
    BoundingClientRect boundingClientRect = BoundingClientRect.zero;
    if (isRendererAttached) {
      flushLayout();
      RenderBoxModel sizedBox = renderBoxModel!;
      // Force flush layout.
      if (!sizedBox.hasSize) {
        sizedBox.markNeedsLayout();
        sizedBox.owner!.flushLayout();
      }

      if (sizedBox.hasSize) {
        Offset offset = _getOffset(sizedBox, ancestor: ownerDocument.documentElement);
        Size size = sizedBox.size;
        boundingClientRect = BoundingClientRect(offset.dx, offset.dy, size.width, size.height, offset.dy,
            offset.dx + size.width, offset.dy + size.height, offset.dx);
      }
    }

    return boundingClientRect;
  }

  // The HTMLElement.offsetLeft read-only property returns the number of pixels that the upper left corner
  // of the current element is offset to the left within the HTMLElement.offsetParent node.
  // https://drafts.csswg.org/cssom-view/#dom-htmlelement-offsetleft
  int get offsetLeft {
    int offset = 0;
    if (!isRendererAttached) {
      return offset;
    }
    Offset relative = _getOffset(renderBoxModel!, ancestor: offsetParent);
    offset += relative.dx.toInt();
    return offset;
  }

  // The HTMLElement.offsetTop read-only property returns the distance of the outer border
  // of the current element relative to the inner border of the top of the offsetParent node.
  // https://drafts.csswg.org/cssom-view/#dom-htmlelement-offsettop
  int get offsetTop {
    int offset = 0;
    if (!isRendererAttached) {
      return offset;
    }
    Offset relative = _getOffset(renderBoxModel!, ancestor: offsetParent);
    offset += relative.dy.toInt();
    return offset;
  }

  // The HTMLElement.offsetParent read-only property returns a reference to the element
  // which is the closest (nearest in the containment hierarchy) positioned ancestor element.
  //  https://drafts.csswg.org/cssom-view/#dom-htmlelement-offsetparent
  Element? get offsetParent {
    // Returns null in the following cases.
    // https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/offsetParent
    if (renderStyle.display == CSSDisplay.none ||
        renderStyle.position == CSSPositionType.fixed ||
        this is BodyElement ||
        this == ownerDocument.documentElement) {
      return null;
    }

    Element? parent = parentElement;

    while (parent != null) {
      bool isNonStatic = parent.renderStyle.position != CSSPositionType.static;
      if (parent is BodyElement || isNonStatic) {
        break;
      }
      parent = parent.parentElement;
    }
    return parent;
  }

  // Get the offset of current element relative to specified ancestor element.
  Offset _getOffset(RenderBoxModel renderBox, {Element? ancestor}) {
    // Need to flush layout to get correct size.
    flushLayout();

    // Returns (0, 0) when ancestor is null.
    if (ancestor == null || ancestor.renderBoxModel == null) {
      return Offset.zero;
    }
    return renderBox.getOffsetToAncestor(Offset.zero, ancestor.renderBoxModel!);
  }

  void click() {
    flushLayout();
    Event clickEvent = MouseEvent(EVENT_CLICK, MouseEventInit(bubbles: true, cancelable: true));
    // If element not in tree, click is fired and only response to itself.
    dispatchEvent(clickEvent);
  }

  /// Moves the focus to the element.
  /// https://html.spec.whatwg.org/multipage/interaction.html#dom-focus
  void focus() {
    // TODO
  }

  /// Moves the focus to the viewport. Use of this method is discouraged;
  /// if you want to focus the viewport, call the focus() method on the Document's document element.
  /// https://html.spec.whatwg.org/multipage/interaction.html#dom-blur
  void blur() {
    // TODO
  }

  Future<Uint8List> toBlob({double? devicePixelRatio}) {
    flushLayout();
    forceToRepaintBoundary = true;

    Completer<Uint8List> completer = Completer();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      Uint8List captured;
      RenderBoxModel _renderBoxModel = renderBoxModel!;

      if (_renderBoxModel.hasSize && _renderBoxModel.size.isEmpty) {
        // Return a blob with zero length.
        captured = Uint8List(0);
      } else {
        Image image = await _renderBoxModel.toImage(pixelRatio: devicePixelRatio ?? window.devicePixelRatio);
        ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
        captured = byteData!.buffer.asUint8List();
      }

      completer.complete(captured);
      forceToRepaintBoundary = false;
      // May be disposed before this callback.
      flushLayout();
    });
    SchedulerBinding.instance.scheduleFrame();

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

  @override
  String toString() {
    return '$tagName Element($hashCode)';
  }

  // Create a new RenderLayoutBox for the scrolling content.
  RenderLayoutBox createScrollingContentLayout() {
    // FIXME: Create an empty renderStyle for do not share renderStyle with element.
    CSSRenderStyle scrollingContentRenderStyle = CSSRenderStyle(target: this);
    // Scrolling content layout need to be share the same display with its outer layout box.
    scrollingContentRenderStyle.display = renderStyle.display;
    RenderLayoutBox scrollingContentLayoutBox = _createRenderLayout(
      isRepaintBoundary: true,
      renderStyle: scrollingContentRenderStyle,
    );
    scrollingContentLayoutBox.isScrollingContentBox = true;
    return scrollingContentLayoutBox;
  }
}

// https://www.w3.org/TR/css-position-3/#def-cb
Element? _findContainingBlock(Element child, Element viewportElement) {
  Element? parent = child.parentElement;

  while (parent != null) {
    bool isNonStatic = parent.renderStyle.position != CSSPositionType.static;
    bool hasTransform = parent.renderStyle.transform != null;
    bool isSliverItem = parent.renderStyle.parent?.display == CSSDisplay.sliver;
    // https://www.w3.org/TR/CSS2/visudet.html#containing-block-details
    if (parent == viewportElement || isNonStatic || hasTransform || isSliverItem) {
      break;
    }
    parent = parent.parentElement;
  }
  return parent;
}

// Cache fixed renderObject to root element
void _addFixedChild(RenderBoxModel childRenderBoxModel, RenderViewportBox viewport) {
  List<RenderBoxModel> fixedChildren = viewport.fixedChildren;
  if (!fixedChildren.contains(childRenderBoxModel)) {
    fixedChildren.add(childRenderBoxModel);
  }
}

// Remove non fixed renderObject from root element
void _removeFixedChild(RenderBoxModel childRenderBoxModel, RenderViewportBox viewport) {
  List<RenderBoxModel> fixedChildren = viewport.fixedChildren;
  if (fixedChildren.contains(childRenderBoxModel)) {
    fixedChildren.remove(childRenderBoxModel);
  }
}

// Reflect attribute type as property.
// String: Any input.
// Bool: Any input is true.
// Int: Any valid input, or 0.
// Double: Any valid input, or 0.0.
T attributeToProperty<T>(String value) {
  // The most using type.
  if (T == String) {
    return value as T;
  } else if (T == bool) {
    return true as T;
  } else if (T == int) {
    return (int.tryParse(value) ?? 0) as T;
  } else if (T == double) {
    return (double.tryParse(value) ?? 0.0) as T;
  } else {
    return value as T;
  }
}
