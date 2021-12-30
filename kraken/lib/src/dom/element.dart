/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/widget.dart';
import 'package:kraken/src/dom/element_event.dart';
import 'package:kraken/src/dom/element_view.dart';
import 'package:meta/meta.dart';

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

class Element extends Node
    with
        ElementBase,
        ElementViewMixin,
        ElementEventMixin,
        ElementOverflowMixin {

  final Map<String, dynamic> properties = <String, dynamic>{};

  // Default to unknown, assign by [createElement], used by inspector.
  String tagName = UNKNOWN;

  /// Is element an intrinsic box.
  final bool _isIntrinsicBox;

  /// The style of the element, not inline style.
  late CSSStyleDeclaration style;

  /// The default user-agent style.
  final Map<String, dynamic> _defaultStyle;

  /// The inline style is a map of style property name to style property value.
  final Map<String, dynamic> inlineStyle = {};

  /// The Element.classList is a read-only property that returns a collection of the class attributes of the element.
  final List<String> _classList = [];
  List<String> get classList {
    return _classList;
  }

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
    bool hasOverflowScroll = renderStyle.overflowX == CSSOverflowType.scroll || renderStyle.overflowX == CSSOverflowType.auto ||
      renderStyle.overflowY == CSSOverflowType.scroll || renderStyle.overflowY == CSSOverflowType.auto;
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

  Element(
    EventTargetContext? context,
    {
      Map<String, dynamic> defaultStyle = const {},
      // Whether element allows children.
      bool isIntrinsicBox = false,
      bool isDefaultRepaintBoundary = false
    })
    : _defaultStyle = defaultStyle,
      _isIntrinsicBox = isIntrinsicBox,
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

  @override
  RenderBox createRenderer() {
    if (renderBoxModel != null) {
      return renderBoxModel!;
    }
    _updateRenderBoxModel();
    return renderBoxModel!;
  }

  void _updateRenderBoxModel() {
    RenderBoxModel nextRenderBoxModel;
    if (_isIntrinsicBox) {
      nextRenderBoxModel = _createRenderIntrinsic(isRepaintBoundary: isRepaintBoundary, previousIntrinsic: _renderIntrinsic);
    } else {
      nextRenderBoxModel = _createRenderLayout(isRepaintBoundary: isRepaintBoundary, previousRenderLayoutBox: _renderLayoutBox);
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
      _ensureEventResponderBound();
    }
  }

  RenderIntrinsic _createRenderIntrinsic({
    RenderIntrinsic? previousIntrinsic,
    bool isRepaintBoundary = false
  }) {
    RenderIntrinsic nextIntrinsic;

    if (previousIntrinsic == null) {
      if (isRepaintBoundary) {
        nextIntrinsic = RenderRepaintBoundaryIntrinsic(
          renderStyle,
        );
      } else {
        nextIntrinsic = RenderIntrinsic(
          renderStyle,
        );
      }
    } else {
      if (previousIntrinsic is RenderRepaintBoundaryIntrinsic) {
        if (isRepaintBoundary) {
          // RenderRepaintBoundaryIntrinsic --> RenderRepaintBoundaryIntrinsic
          nextIntrinsic = previousIntrinsic;
        } else {
          // RenderRepaintBoundaryIntrinsic --> RenderIntrinsic
          nextIntrinsic = previousIntrinsic.toIntrinsic();
        }
      } else {
        if (isRepaintBoundary) {
          // RenderIntrinsic --> RenderRepaintBoundaryIntrinsic
          nextIntrinsic = previousIntrinsic.toRepaintBoundaryIntrinsic();
        } else {
          // RenderIntrinsic --> RenderIntrinsic
          nextIntrinsic = previousIntrinsic;
        }
      }
    }
    return nextIntrinsic;
  }

  // Create renderLayoutBox if type changed and copy children if there has previous renderLayoutBox.
  RenderLayoutBox _createRenderLayout({
      RenderLayoutBox? previousRenderLayoutBox,
      CSSRenderStyle? renderStyle,
      bool isRepaintBoundary = false
  }) {
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
        nextRenderLayoutBox = previousRenderLayoutBox.toSliverLayout(RenderSliverElementChildManager(this), _handleScroll);
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
    // Init render box model.
    if (renderStyle.display != CSSDisplay.none) {
      createRenderer();
    }
  }

  @override
  void didAttachRenderer() {
    super.didAttachRenderer();
    // Ensure that the child is attached.
    ensureChildAttached();
  }

  @override
  void willDetachRenderer() {
    super.willDetachRenderer();
    // Cancel running transition.
    renderStyle.cancelRunningTransition();

    RenderBoxModel _renderBoxModel = renderBoxModel!;

    // Remove all intersection change listeners.
    _renderBoxModel.clearIntersectionChangeListeners();

    // Remove fixed children from root when element disposed.
    _removeFixedChild(_renderBoxModel, ownerDocument.documentElement!._renderLayoutBox!);

    // Remove renderBox.
    _renderBoxModel.detachFromContainingBlock();

    // Remove pointer listener
    removeEventResponder(renderBoxModel!);
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
      SchedulerBinding.instance!.addPostFrameCallback(_consumeScrollTicker);
      SchedulerBinding.instance!.scheduleFrame();
    }
    _shouldConsumeScrollTicker = true;
  }

  /// Normally element in scroll box will not repaint on scroll because of repaint boundary optimization
  /// So it needs to manually mark element needs paint and add scroll offset in paint stage
  void _applyFixedChildrenOffset(double scrollOffset, AxisDirection axisDirection) {
    // Only root element has fixed children
    if (this == ownerDocument.documentElement && renderBoxModel != null) {
      RenderBoxModel layoutBox = (renderBoxModel as RenderLayoutBox).renderScrollingContent ?? renderBoxModel!;
      for (RenderBoxModel child in layoutBox.fixedChildren) {
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
    RenderLayoutBox? scrollContainer = (renderBoxModel as RenderLayoutBox?)!;
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
    if (!(oldPosition == CSSPositionType.static && currentPosition == CSSPositionType.relative)
      && !(oldPosition == CSSPositionType.relative && currentPosition == CSSPositionType.static)
    ) {
      RenderBoxModel _renderBoxModel = renderBoxModel!;
      // Remove fixed children before convert to non repaint boundary renderObject
      if (currentPosition != CSSPositionType.fixed) {
        _removeFixedChild(_renderBoxModel, ownerDocument.documentElement!._renderLayoutBox!);
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
      renderBoxModel!.attachToContainingBlock(containingBlockRenderBox, parent: parentRenderBox, after: previousSibling);

      // Add fixed children after convert to repaint boundary renderObject.
      if (currentPosition == CSSPositionType.fixed) {
        _addFixedChild(renderBoxModel!, ownerDocument.documentElement!._renderLayoutBox!);
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
    } else if (_renderIntrinsic != null) {
      _renderIntrinsic!.child = child;
    }
  }

  @override
  void dispose() {
    if (isRendererAttached) {
      disposeRenderObject();
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

    renderStyle.detach();
    style.dispose();
    properties.clear();
    disposeScrollable();

    super.dispose();
  }

  // Used for force update layout.
  void flushLayout() {
    if (isRendererAttached) {
      renderer!.owner!.flushLayout();
    }
  }

  // Attach renderObject of current node to parent
  @override
  void attachTo(Node parent, {RenderBox? after}) {
    _applyStyle(style);

    if (parentElement?.renderStyle.display == CSSDisplay.sliver) {
      // Sliver should not create renderer here, but need to trigger
      // render sliver list dynamical rebuild child by element tree.
      parentElement?._renderLayoutBox?.markNeedsLayout();
    } else {
      willAttachRenderer();
    }

    if (renderer != null) {
      // If element attach WidgetElement, render obeject should be attach to render tree when mount.
      if (parent is! WidgetElement) {
        RenderBoxModel.attachRenderBox(parent.renderer!, renderer!, after: after);
      }

      // Flush pending style before child attached.
      style.flushPendingProperties();

      didAttachRenderer();
    }
  }

  /// Release any resources held by [renderBoxModel].
  @override
  void disposeRenderObject() {
    if (renderBoxModel == null) return;

    willDetachRenderer();

    for (Node child in childNodes) {
      child.disposeRenderObject();
    }

    didDetachRenderer();

    // Call dispose method of renderBoxModel when it is detached from tree.
    renderBoxModel!.dispose();
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
      if (!child.isRendererAttached && renderLayoutBox != null && this is! WidgetElement) {
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
    // Not remove node type which is not present in RenderObject tree such as Comment
    // Only append node types which is visible in RenderObject tree
    // Only remove childNode when it has parent
    if (child.isRendererAttached) {
      child.disposeRenderObject();
    }
    // Update renderStyle tree.
    if (child is Element) {
      child.renderStyle.detach();
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

    switch(positionType) {
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

  // FIXME: only compatible with kraken plugins
  @deprecated
  void setStyle(String property, dynamic value) {
    setRenderStyle(property, value);
  }

  void _updateRenderBoxModelWithDisplay() {
    CSSDisplay presentDisplay = renderStyle.display;

    if (parentElement == null || !parentElement!.isConnected) return;

    // Destroy renderer of element when display is changed to none.
    if (presentDisplay == CSSDisplay.none) {
      disposeRenderObject();
      return;
    }

    // Update renderBoxModel.
    _updateRenderBoxModel();
    // Attach renderBoxModel to parent if change from `display: none` to other values.
    if (!isRendererAttached && parentElement != null && parentElement!.isRendererAttached) {
      // If element attach WidgetElement, render obeject should be attach to render tree when mount.
      if (parentNode is! WidgetElement) {
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

  void setRenderStyleProperty(String name, dynamic value) {
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
      _defaultStyle.forEach((propertyName, dynamic value) {
        style.setProperty(propertyName, value);
      });
    }
  }

  void _applyInlineStyle(CSSStyleDeclaration style) {
    if (inlineStyle.isNotEmpty) {
      inlineStyle.forEach((propertyName, dynamic value) {
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

  void _applyStyle(CSSStyleDeclaration style) {
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
      _applyStyle(newStyle);
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

  @mustCallSuper
  void setProperty(String key, dynamic value) {
    if (value == null || value == EMPTY_STRING) {
      return removeProperty(key);
    }

    if (key == _CLASS_NAME) {
      className = value;
    } else {
      properties[key] = value;
    }
  }

  @mustCallSuper
  dynamic getProperty(String key) {
    if (key == _CLASS_NAME) {
      return className;
    } else {
      return properties[key];
    }
  }

  @mustCallSuper
  void removeProperty(String key) {
    if (key == _STYLE_PROPERTY) {
      _removeInlineStyle();
    } else if (key == _CLASS_NAME) {
      className = EMPTY_STRING;
    } else {
      properties.remove(key);
    }
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
    ownerDocument.documentElement!.renderBoxModel!.owner!.flushLayout();

    Element? element = _findContainingBlock(this, ownerDocument.documentElement!);
    element ??= ownerDocument.documentElement!;
    return renderBox.localToGlobal(Offset.zero, ancestor: element.renderBoxModel);
  }

  void _ensureEventResponderBound() {
    // Must bind event responder on render box model whatever there is no event listener.
    RenderBoxModel? _renderBoxModel = renderBoxModel;
    if (_renderBoxModel != null) {
      // Make sure pointer responder bind.
      addEventResponder(_renderBoxModel);
      if (_hasIntersectionObserverEvent(eventHandlers)) {
        _renderBoxModel.addIntersectionChangeListener(handleIntersectionChange);
      }
    }
  }

  void addEvent(String eventType) {
    if (eventHandlers.containsKey(eventType)) return; // Only listen once.
    addEventListener(eventType, dispatchEvent);
    _ensureEventResponderBound();
  }

  void removeEvent(String eventType) {
    if (!eventHandlers.containsKey(eventType)) return; // Only listen once.
    removeEventListener(eventType, dispatchEvent);

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

  void click() {
    Event clickEvent = MouseEvent(EVENT_CLICK, MouseEventInit(bubbles: true, cancelable: true));
    // If element not in tree, click is fired and only response to itself.
    dispatchEvent(clickEvent);
  }

  Future<Uint8List> toBlob({ double? devicePixelRatio }) {
    devicePixelRatio ??= window.devicePixelRatio;

    Completer<Uint8List> completer = Completer();
    forceToRepaintBoundary = true;
    renderBoxModel!.owner!.flushLayout();

    SchedulerBinding.instance!.addPostFrameCallback((_) async {
      Uint8List captured;
      RenderBoxModel? _renderBoxModel = renderBoxModel;
      if (_renderBoxModel!.hasSize && _renderBoxModel.size.isEmpty) {
        // Return a blob with zero length.
        captured = Uint8List(0);
      } else {
        Image image = await _renderBoxModel.toImage(pixelRatio: devicePixelRatio!);
        ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
        captured = byteData!.buffer.asUint8List();
      }

      completer.complete(captured);
      forceToRepaintBoundary = false;
      renderBoxModel!.owner!.flushLayout();
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
    // https://www.w3.org/TR/CSS2/visudet.html#containing-block-details
    if (parent == viewportElement || isNonStatic || hasTransform) {
      break;
    }
    parent = parent.parentElement;
  }
  return parent;
}

bool _isIntersectionObserverEvent(String eventType) {
  return eventType == EVENT_APPEAR || eventType == EVENT_DISAPPEAR || eventType == EVENT_INTERSECTION_CHANGE;
}

bool _hasIntersectionObserverEvent(Map eventHandlers) {
  return eventHandlers.containsKey('appear') ||
      eventHandlers.containsKey('disappear') ||
      eventHandlers.containsKey('intersectionchange');
}

// Cache fixed renderObject to root element
void _addFixedChild(RenderBoxModel childRenderBoxModel, RenderLayoutBox rootRenderLayoutBox) {
  rootRenderLayoutBox = rootRenderLayoutBox.renderScrollingContent ?? rootRenderLayoutBox;
  List<RenderBoxModel> fixedChildren = rootRenderLayoutBox.fixedChildren;
  if (!fixedChildren.contains(childRenderBoxModel)) {
    fixedChildren.add(childRenderBoxModel);
  }
}

// Remove non fixed renderObject from root element
void _removeFixedChild(RenderBoxModel childRenderBoxModel, RenderLayoutBox rootRenderLayoutBox) {
  rootRenderLayoutBox = rootRenderLayoutBox.renderScrollingContent ?? rootRenderLayoutBox;
  List<RenderBoxModel> fixedChildren = rootRenderLayoutBox.fixedChildren;
  if (fixedChildren.contains(childRenderBoxModel)) {
    fixedChildren.remove(childRenderBoxModel);
  }
}
