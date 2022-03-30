import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// No matter how complex the layout is and how deep the dependencies
/// are, each child element of ConstraintLayout will only be measured once
/// This results in extremely high layout performance.
///
/// features:
///   1. build flexible layouts with constraints
///   2. margin and goneMargin
///   3. clickPadding(expand the click area of child elements without changing their actual size)
///   4. visibility control
///   5. constraint integrity hint
///   6. bias
///
///  not implement
///   . guideline
///   . barrier
///   . constraints visualization
///   . chain
///
/// author: hackware
/// home page: https://github.com/hackware1993
/// email: cfb1993@163.com
class ConstraintLayout extends MultiChildRenderObjectWidget {
  final bool debugShowGuideline;
  final bool debugShowPreview;
  final bool debugShowClickArea;
  final bool debugPrintDependencies;
  final bool debugPrintLayoutTime;
  final bool debugCheckDependencies;
  final bool releasePrintLayoutTime;
  final String? debugName;

  ConstraintLayout({
    Key? key,
    List<Widget> children = const <Widget>[],
    this.debugShowGuideline = false,
    this.debugShowPreview = false,
    this.debugShowClickArea = false,
    this.debugPrintDependencies = false,
    this.debugPrintLayoutTime = true,
    this.debugCheckDependencies = true,
    this.releasePrintLayoutTime = false,
    this.debugName,
  }) : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _ConstraintRenderBox()
      ..debugShowGuideline = debugShowGuideline
      ..debugShowPreview = debugShowPreview
      ..debugShowClickArea = debugShowClickArea
      ..debugPrintDependencies = debugPrintDependencies
      ..debugPrintLayoutTime = debugPrintLayoutTime
      ..debugCheckDependencies = debugCheckDependencies
      ..releasePrintLayoutTime = releasePrintLayoutTime
      ..debugName = debugName;
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) {
    (renderObject as _ConstraintRenderBox)
      ..debugShowGuideline = debugShowGuideline
      ..debugShowPreview = debugShowPreview
      ..debugShowClickArea = debugShowClickArea
      ..debugPrintDependencies = debugPrintDependencies
      ..debugPrintLayoutTime = debugPrintLayoutTime
      ..debugCheckDependencies = debugCheckDependencies
      ..releasePrintLayoutTime = releasePrintLayoutTime
      ..debugName = debugName;
  }
}

class CL {
  // size constraint
  static const double matchConstraint = -3.1415926;
  static const double matchParent = -2.7182818;
  static const double wrapContent = -0.6180339;

  // visibility
  static const CLVisibility visible = CLVisibility.visible;
  static const CLVisibility gone = CLVisibility.gone;
  static const CLVisibility invisible = CLVisibility.invisible;

  // anchor
  static const String parent = 'ZG9uJ3QgZnVjayBtb3VudGFpbiE=';
}

enum CLVisibility {
  visible,
  gone,
  invisible,
}

enum ChainStyle {
  spread,
  spreadInside,
  packet,
}

enum BarrierDirection {
  left,
  top,
  right,
  bottom,
}

class _ConstraintBoxData extends ContainerBoxParentData<RenderBox> {
  double? width;
  double? height;
  String? id;
  String? leftToLeft;
  String? leftToRight;
  String? rightToLeft;
  String? rightToRight;
  String? topToTop;
  String? topToBottom;
  String? bottomToTop;
  String? bottomToBottom;
  EdgeInsets? clickPadding;
  CLVisibility? visibility;
  EdgeInsets? margin;
  EdgeInsets? goneMargin;
  double? horizontalBias;
  double? verticalBias;
}

class Constrained extends ParentDataWidget<_ConstraintBoxData> {
  // 'wrap_content'、'match_parent'、'match_constraint'、'48, etc'
  final double width;

  // 'wrap_content'、'match_parent'、'match_constraint'、'48, etc'
  final double height;

  // id can be null, but not an empty string
  final String? id;

  // expand the click area without changing the actual size
  final EdgeInsets? clickPadding;

  final CLVisibility? visibility;

  // margin can be negative
  final EdgeInsets? margin;
  final EdgeInsets? goneMargin;
  final double? horizontalBias;
  final double? verticalBias;

  /// depends on sibling id or CL.parent
  final String? leftToLeft;
  final String? leftToRight;
  final String? rightToLeft;
  final String? rightToRight;
  final String? topToTop;
  final String? topToBottom;
  final String? bottomToTop;
  final String? bottomToBottom;

  final bool? center;
  final bool? centerHorizontal;
  final bool? centerVertical;

  // TODO support chain
  // final ChainStyle? chainStyle;
  // TODO support circle positioned
  // TODO support dimension ratio
  // TODO support barrier
  // TODO support guideline
  // TODO support baseline align
  // TODO support bias
  // TODO consider flow
  // group is pointless

  const Constrained({
    Key? key,
    required Widget child,
    required this.width,
    required this.height,
    this.id,
    this.leftToLeft,
    this.leftToRight,
    this.rightToLeft,
    this.rightToRight,
    this.topToTop,
    this.topToBottom,
    this.bottomToTop,
    this.bottomToBottom,
    this.clickPadding,
    this.visibility,
    this.margin,
    this.goneMargin,
    this.center,
    this.centerHorizontal,
    this.centerVertical,
    this.horizontalBias,
    this.verticalBias,
  }) : super(key: key, child: child);

  bool checkSize(double size) {
    if (size == CL.matchParent ||
        size == CL.wrapContent ||
        size == CL.matchConstraint) {
      return true;
    } else {
      return size != double.infinity && size > 0;
    }
  }

  bool checkDependency(String? dependency) {
    return dependency == null || dependency.trim().isNotEmpty;
  }

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is _ConstraintBoxData);
    assert(checkSize(width));
    assert(checkSize(height));
    assert(checkDependency(id));
    assert(checkDependency(this.leftToLeft));
    assert(checkDependency(this.leftToRight));
    assert(checkDependency(this.rightToLeft));
    assert(checkDependency(this.rightToRight));
    assert(checkDependency(this.topToTop));
    assert(checkDependency(this.topToBottom));
    assert(checkDependency(this.bottomToTop));
    assert(checkDependency(this.bottomToBottom));
    assert(horizontalBias == null ||
        (horizontalBias! >= 0 && horizontalBias! <= 1));
    assert(verticalBias == null || (verticalBias! >= 0 && verticalBias! <= 1));

    String? leftToLeft = this.leftToLeft;
    String? leftToRight = this.leftToRight;
    String? rightToLeft = this.rightToLeft;
    String? rightToRight = this.rightToRight;
    String? topToTop = this.topToTop;
    String? topToBottom = this.topToBottom;
    String? bottomToTop = this.bottomToTop;
    String? bottomToBottom = this.bottomToBottom;

    if (width == CL.matchParent) {
      leftToLeft = CL.parent;
      rightToRight = CL.parent;
      leftToRight = null;
      rightToLeft = null;
    }

    if (height == CL.matchParent) {
      topToTop = CL.parent;
      bottomToBottom = CL.parent;
      topToBottom = null;
      bottomToTop = null;
    }

    if (centerHorizontal == true) {
      leftToLeft = CL.parent;
      rightToRight = CL.parent;
      leftToRight = null;
      rightToLeft = null;
    }

    if (centerVertical == true) {
      topToTop = CL.parent;
      bottomToBottom = CL.parent;
      topToBottom = null;
      bottomToTop = null;
    }

    if (center == true) {
      leftToLeft = CL.parent;
      rightToRight = CL.parent;
      topToTop = CL.parent;
      bottomToBottom = CL.parent;
      leftToRight = null;
      rightToLeft = null;
      topToBottom = null;
      bottomToTop = null;
    }

    _ConstraintBoxData parentData =
        renderObject.parentData! as _ConstraintBoxData;
    bool needsLayout = false;

    if (parentData.width != width) {
      parentData.width = width;
      needsLayout = true;
    }

    if (parentData.height != height) {
      parentData.height = height;
      needsLayout = true;
    }

    if (parentData.id != id) {
      parentData.id = id;
      needsLayout = true;
    }

    if (parentData.leftToLeft != leftToLeft) {
      parentData.leftToLeft = leftToLeft;
      needsLayout = true;
    }

    if (parentData.leftToRight != leftToRight) {
      parentData.leftToRight = leftToRight;
      needsLayout = true;
    }

    if (parentData.rightToLeft != rightToLeft) {
      parentData.rightToLeft = rightToLeft;
      needsLayout = true;
    }

    if (parentData.rightToRight != rightToRight) {
      parentData.rightToRight = rightToRight;
      needsLayout = true;
    }

    if (parentData.topToTop != topToTop) {
      parentData.topToTop = topToTop;
      needsLayout = true;
    }

    if (parentData.topToBottom != topToBottom) {
      parentData.topToBottom = topToBottom;
      needsLayout = true;
    }

    if (parentData.bottomToTop != bottomToTop) {
      parentData.bottomToTop = bottomToTop;
      needsLayout = true;
    }

    if (parentData.bottomToBottom != bottomToBottom) {
      parentData.bottomToBottom = bottomToBottom;
      needsLayout = true;
    }

    parentData.clickPadding = clickPadding;

    if (parentData.visibility != visibility) {
      parentData.visibility = visibility;
      needsLayout = true;
    }

    if (parentData.margin != margin) {
      parentData.margin = margin;
      needsLayout = true;
    }

    if (parentData.goneMargin != goneMargin) {
      parentData.goneMargin = goneMargin;
      needsLayout = true;
    }

    if (parentData.horizontalBias != horizontalBias) {
      parentData.horizontalBias = horizontalBias;
      needsLayout = true;
    }

    if (parentData.verticalBias != verticalBias) {
      parentData.verticalBias = verticalBias;
      needsLayout = true;
    }

    if (needsLayout) {
      AbstractNode? targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass {
    return ConstraintLayout;
  }
}

class _ConstraintRenderBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ConstraintBoxData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ConstraintBoxData> {
  // TODO implement debug function
  bool? _debugShowGuideline;
  bool? _debugShowPreview;
  bool? _debugShowClickArea;
  bool? _debugPrintDependencies;
  bool? _debugPrintLayoutTime;
  bool? _debugCheckDependencies;
  bool? _releasePrintLayoutTime;
  String? _debugName;

  final Map<RenderBox, _NodeDependency> _nodeDependencies = HashMap();
  final Map<String, _NodeDependency> _tempNodeDependencies = HashMap();

  set debugShowGuideline(bool value) {
    if (_debugShowGuideline != value) {
      _debugShowGuideline = value;
      markNeedsPaint();
    }
  }

  set debugShowPreview(bool value) {
    if (_debugShowPreview != value) {
      _debugShowPreview = value;
      markNeedsPaint();
    }
  }

  set debugShowClickArea(bool value) {
    if (_debugShowClickArea != value) {
      _debugShowClickArea = value;
      markNeedsPaint();
    }
  }

  set debugPrintDependencies(bool value) {
    if (_debugPrintDependencies != value) {
      _debugPrintDependencies = value;
      markNeedsLayout();
    }
  }

  set debugPrintLayoutTime(bool value) {
    if (_debugPrintLayoutTime != value) {
      _debugPrintLayoutTime = value;
      markNeedsLayout();
    }
  }

  set debugCheckDependencies(bool value) {
    if (_debugCheckDependencies != value) {
      _debugCheckDependencies = value;
      markNeedsLayout();
    }
  }

  set releasePrintLayoutTime(bool value) {
    if (_releasePrintLayoutTime != value) {
      _releasePrintLayoutTime = value;
      markNeedsLayout();
    }
  }

  set debugName(String? value) {
    if (_debugName != value) {
      _debugName = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! _ConstraintBoxData) {
      child.parentData = _ConstraintBoxData();
    }
  }

  // make sure the id of the child elements is not repeated
  // make sure every id that is relied on is valid
  void _debugCheckIds() {
    RenderBox? child = firstChild;
    Set<String> idSet = HashSet();
    idSet.add(CL.parent);
    Set<String> dependencyIdSet = HashSet();
    while (child != null) {
      _ConstraintBoxData childParentData =
          child.parentData as _ConstraintBoxData;
      if (childParentData.id != null) {
        if (!idSet.add(childParentData.id!)) {
          throw Exception('Duplicate id in ConstraintLayout.');
        }
      }
      if (childParentData.leftToLeft != null) {
        dependencyIdSet.add(childParentData.leftToLeft!);
      }
      if (childParentData.leftToRight != null) {
        dependencyIdSet.add(childParentData.leftToRight!);
      }
      if (childParentData.rightToLeft != null) {
        dependencyIdSet.add(childParentData.rightToLeft!);
      }
      if (childParentData.rightToRight != null) {
        dependencyIdSet.add(childParentData.rightToRight!);
      }
      if (childParentData.topToTop != null) {
        dependencyIdSet.add(childParentData.topToTop!);
      }
      if (childParentData.topToBottom != null) {
        dependencyIdSet.add(childParentData.topToBottom!);
      }
      if (childParentData.bottomToTop != null) {
        dependencyIdSet.add(childParentData.bottomToTop!);
      }
      if (childParentData.bottomToBottom != null) {
        dependencyIdSet.add(childParentData.bottomToBottom!);
      }
      child = childParentData.nextSibling;
    }
    Set<String> illegalIdSet = dependencyIdSet.difference(idSet);
    if (illegalIdSet.isNotEmpty) {
      throw Exception('These ids $illegalIdSet are not yet defined.');
    }
  }

  // there should be no circular dependencies in a single direction
  void _debugCheckCircularDependency() {
    for (final element in _nodeDependencies.values) {
      _NodeDependency? start = element;
      while (true) {
        if (start == null || start.nodeId == CL.parent) {
          break;
        }
        if (start.leftDependency == element) {
          throw Exception(
              'There is a circular left dependency in horizontal direction, between ${start.nodeId} and ${element.nodeId}.');
        }
        start = start.leftDependency;
      }
      start = element;
      while (true) {
        if (start == null || start.nodeId == CL.parent) {
          break;
        }
        if (start.rightDependency == element) {
          throw Exception(
              'There is a circular right dependency in horizontal direction, between ${start.nodeId} and ${element.nodeId}.');
        }
        start = start.rightDependency;
      }
      start = element;
      while (true) {
        if (start == null || start.nodeId == CL.parent) {
          break;
        }
        if (start.topDependency == element) {
          throw Exception(
              'There is a circular top dependency in vertical direction, between ${start.nodeId} and ${element.nodeId}.');
        }
        start = start.topDependency;
      }
      start = element;
      while (true) {
        if (start == null || start.nodeId == CL.parent) {
          break;
        }
        if (start.bottomDependency == element) {
          throw Exception(
              'There is a circular bottom dependency in vertical direction, between ${start.nodeId} and ${element.nodeId}.');
        }
        start = start.bottomDependency;
      }
    }
  }

  // each child element must have complete dependencies both horizontally and vertically
  void _debugCheckDependencyIntegrity() {
    for (final element in _nodeDependencies.values) {
      // check constraint integrity in the horizontal direction
      if (element.width == CL.wrapContent || element.width! > 0) {
        if (element.leftDependency == null && element.rightDependency == null) {
          throw Exception(
              'Need to set a left or right dependency in the horizontal direction for ${element.nodeId}.');
        }
      } else if (element.width == CL.matchConstraint) {
        if (element.leftDependency == null || element.rightDependency == null) {
          throw Exception(
              'Need to set left and right dependencies in the horizontal direction for ${element.nodeId}.');
        }
      }

      // check constraint integrity in the vertical direction
      if (element.height == CL.wrapContent || element.height! > 0) {
        if (element.topDependency == null && element.bottomDependency == null) {
          throw Exception(
              'Need to set a top or bottom dependency in the vertical direction for ${element.nodeId}.');
        }
      } else if (element.height == CL.matchConstraint) {
        if (element.topDependency == null || element.bottomDependency == null) {
          throw Exception(
              'Need to set both top and bottom dependencies in the vertical direction for ${element.nodeId}.');
        }
      }
    }
  }

  void _debugEnsureNullDependency(
    _NodeDependency node,
    _NodeDependency? dependency,
    String direction,
  ) {
    if (_debugCheckDependencies == true && kDebugMode) {
      if (dependency != null) {
        debugPrint(
            'Warning: The child element with id ${node.nodeId} has a duplicate $direction dependency.');
      }
    }
  }

  bool _isInternalBox(RenderBox renderBox) {
    if (renderBox is _GuidelineRenderBox) {
      return true;
    } else if (renderBox is _BarrierRenderBox) {
      return true;
    }
    return false;
  }

  // child and id will not be null at the same time
  _NodeDependency _getNodeDependencyForChild(
    RenderBox? child,
    String? id,
  ) {
    _NodeDependency? node;
    if (child != null) {
      node = _nodeDependencies[child];
    }
    if (node == null) {
      if (id != null) {
        node = _tempNodeDependencies[id];
      }
    }
    node ??= _NodeDependency();
    if (child != null && node.renderBox == null) {
      node.renderBox = child;
      _nodeDependencies[child] = node;
    }
    if (id != null && node.nodeId == null) {
      node.nodeId = id;
      _tempNodeDependencies[id] = node;
    }
    return node;
  }

  void _buildDependencyGraph() {
    _nodeDependencies.clear();
    _tempNodeDependencies.clear();
    RenderBox? child = firstChild;
    int childIndex = 0;

    while (child != null) {
      _ConstraintBoxData childParentData =
          child.parentData as _ConstraintBoxData;

      if (_debugCheckDependencies == true && kDebugMode) {
        if (childParentData.width == null) {
          if (!_isInternalBox(child)) {
            throw Exception('Child elements must be wrapped with Constrained.');
          }
        } else {
          if (_isInternalBox(child)) {
            throw Exception(
                'Guideline, Barrier can not be wrapped with Constrained.');
          }
        }
      }

      _NodeDependency currentNode = _getNodeDependencyForChild(
          child, childParentData.id ?? 'child[$childIndex]@${child.hashCode}');
      currentNode.width = childParentData.width;
      currentNode.height = childParentData.height;
      currentNode.visibility = childParentData.visibility;

      if (childParentData.leftToLeft != null) {
        _debugEnsureNullDependency(
            currentNode, currentNode.leftDependency, 'left');
        currentNode.leftDependency =
            _getNodeDependencyForChild(null, childParentData.leftToLeft);
        currentNode.leftDependencyType = 0;
      }
      if (childParentData.leftToRight != null) {
        _debugEnsureNullDependency(
            currentNode, currentNode.leftDependency, 'left');
        currentNode.leftDependency =
            _getNodeDependencyForChild(null, childParentData.leftToRight);
        currentNode.leftDependencyType = 1;
      }
      if (childParentData.rightToLeft != null) {
        _debugEnsureNullDependency(
            currentNode, currentNode.rightDependency, 'right');
        currentNode.rightDependency =
            _getNodeDependencyForChild(null, childParentData.rightToLeft);
        currentNode.rightDependencyType = 0;
      }
      if (childParentData.rightToRight != null) {
        _debugEnsureNullDependency(
            currentNode, currentNode.rightDependency, 'right');
        currentNode.rightDependency =
            _getNodeDependencyForChild(null, childParentData.rightToRight);
        currentNode.rightDependencyType = 1;
      }
      if (childParentData.topToTop != null) {
        _debugEnsureNullDependency(
            currentNode, currentNode.topDependency, 'top');
        currentNode.topDependency =
            _getNodeDependencyForChild(null, childParentData.topToTop);
        currentNode.topDependencyType = 0;
      }
      if (childParentData.topToBottom != null) {
        _debugEnsureNullDependency(
            currentNode, currentNode.topDependency, 'top');
        currentNode.topDependency =
            _getNodeDependencyForChild(null, childParentData.topToBottom);
        currentNode.topDependencyType = 1;
      }
      if (childParentData.bottomToTop != null) {
        _debugEnsureNullDependency(
            currentNode, currentNode.bottomDependency, 'bottom');
        currentNode.bottomDependency =
            _getNodeDependencyForChild(null, childParentData.bottomToTop);
        currentNode.bottomDependencyType = 0;
      }
      if (childParentData.bottomToBottom != null) {
        _debugEnsureNullDependency(
            currentNode, currentNode.bottomDependency, 'bottom');
        currentNode.bottomDependency =
            _getNodeDependencyForChild(null, childParentData.bottomToBottom);
        currentNode.bottomDependencyType = 1;
      }

      childIndex++;
      child = childParentData.nextSibling;
    }

    _tempNodeDependencies.clear();
  }

  @override
  void performLayout() {
    int startTime = 0;

    if (_releasePrintLayoutTime == true && kReleaseMode) {
      startTime = DateTime.now().millisecondsSinceEpoch;
    }
    if (_debugPrintLayoutTime == true && kDebugMode) {
      startTime = DateTime.now().millisecondsSinceEpoch;
    }

    // always fill the parent layout
    size = constraints.constrain(const Size(double.infinity, double.infinity));

    if (_debugCheckDependencies == true && kDebugMode) {
      _debugCheckIds();
    }

    // traverse once to build a directed acyclic graph
    _buildDependencyGraph();

    if (_debugCheckDependencies == true && kDebugMode) {
      _debugCheckDependencyIntegrity();
      _debugCheckCircularDependency();
    }

    // sort by the depth of dependency from shallow to deep, the lowest depth is 0, representing parent
    List<_NodeDependency> nodeDependencies = _nodeDependencies.values.toList();
    nodeDependencies.sort((left, right) {
      return left.getDepth() - right.getDepth();
    });

    // print dependencies
    if (_debugPrintDependencies == true && kDebugMode) {
      debugPrint('ConstraintLayout@${_debugName ?? hashCode} dependencies: ' +
          jsonEncode(nodeDependencies.map((e) => e.toJson()).toList()));
    }

    _layoutByDependency(nodeDependencies);

    if (_releasePrintLayoutTime == true && kReleaseMode) {
      print(
          'ConstraintLayout@${_debugName ?? hashCode} layout time = ${DateTime.now().millisecondsSinceEpoch - startTime} ms(current is release mode).');
    }
    if (_debugPrintLayoutTime == true && kDebugMode) {
      debugPrint(
          'ConstraintLayout@${_debugName ?? hashCode} layout time = ${DateTime.now().millisecondsSinceEpoch - startTime} ms(current is debug mode, release mode may take less time).');
    }
  }

  static double _getLeftInsets(EdgeInsets? insets) {
    if (insets == null) {
      return 0;
    }
    return insets.left;
  }

  static double _getTopInsets(EdgeInsets? insets) {
    if (insets == null) {
      return 0;
    }
    return insets.top;
  }

  static double _getRightInsets(EdgeInsets? insets) {
    if (insets == null) {
      return 0;
    }
    return insets.right;
  }

  static double _getBottomInsets(EdgeInsets? insets) {
    if (insets == null) {
      return 0;
    }
    return insets.bottom;
  }

  static double _getHorizontalInsets(EdgeInsets? insets) {
    return _getLeftInsets(insets) + _getRightInsets(insets);
  }

  static double _getVerticalInsets(EdgeInsets? insets) {
    return _getTopInsets(insets) + _getBottomInsets(insets);
  }

  void _layoutByDependency(List<_NodeDependency> nodeDependencies) {
    for (final element in nodeDependencies) {
      _ConstraintBoxData childParentData =
          element.renderBox!.parentData as _ConstraintBoxData;

      EdgeInsets? margin = childParentData.margin;
      EdgeInsets? goneMargin = childParentData.goneMargin;

      // calculate child width
      double width = childParentData.width!;
      double minWidth = 0;
      double maxWidth = double.infinity;
      if (width == CL.wrapContent) {
        maxWidth = size.width;
      } else if (width == CL.matchParent) {
        minWidth = size.width - _getHorizontalInsets(margin);
        maxWidth = minWidth;
      } else if (width == CL.matchConstraint) {
        double left;
        if (element.leftDependencyType == 0) {
          left = element.leftDependency!.getX();
        } else {
          left = element.leftDependency!.getRight(size);
        }
        if (element.leftDependency!.visibility == CL.gone) {
          left += _getLeftInsets(goneMargin ?? margin);
        } else {
          left += _getLeftInsets(margin);
        }
        double right;
        if (element.rightDependencyType == 0) {
          right = element.rightDependency!.getX();
        } else {
          right = element.rightDependency!.getRight(size);
        }
        if (element.rightDependency!.visibility == CL.gone) {
          right -= _getRightInsets(goneMargin ?? margin);
        } else {
          right -= _getRightInsets(margin);
        }
        minWidth = right - left;
        if (_debugCheckDependencies == true && kDebugMode) {
          if (minWidth < 0) {
            debugPrint(
                'Warning: The child element with id ${element.nodeId} has a negative width');
          }
        }
        maxWidth = minWidth;
      } else {
        minWidth = width;
        maxWidth = width;
      }

      // calculate child height
      double height = childParentData.height!;
      double minHeight = 0;
      double maxHeight = double.infinity;
      if (height == CL.wrapContent) {
        maxHeight = size.height;
      } else if (height == CL.matchParent) {
        minHeight = size.height - _getVerticalInsets(margin);
        maxHeight = minHeight;
      } else if (height == CL.matchConstraint) {
        double top;
        if (element.topDependencyType == 0) {
          top = element.topDependency!.getY();
        } else {
          top = element.topDependency!.getBottom(size);
        }
        if (element.topDependency!.visibility == CL.gone) {
          top += _getTopInsets(goneMargin ?? margin);
        } else {
          top += _getTopInsets(margin);
        }
        double bottom;
        if (element.bottomDependencyType == 0) {
          bottom = element.bottomDependency!.getY();
        } else {
          bottom = element.bottomDependency!.getBottom(size);
        }
        if (element.bottomDependency!.visibility == CL.gone) {
          bottom -= _getBottomInsets(goneMargin ?? margin);
        } else {
          bottom -= _getBottomInsets(margin);
        }
        minHeight = bottom - top;
        if (_debugCheckDependencies == true && kDebugMode) {
          if (minHeight < 0) {
            debugPrint(
                'Warning: The child element with id ${element.nodeId} has a negative height');
          }
        }
        maxHeight = minHeight;
      } else {
        minHeight = height;
        maxHeight = height;
      }

      if (childParentData.visibility != CL.gone) {
        // measure
        if (minWidth < 0) {
          minWidth = 0;
        }
        if (maxWidth < 0) {
          maxWidth = 0;
        }
        if (minHeight < 0) {
          minHeight = 0;
        }
        if (maxHeight < 0) {
          maxHeight = 0;
        }
        element.renderBox!.layout(
          BoxConstraints(
            minWidth: minWidth,
            maxWidth: maxWidth,
            minHeight: minHeight,
            maxHeight: maxHeight,
          ),
          parentUsesSize: true,
        );
      }

      // calculate child x offset
      double offsetX = 0;
      if (element.leftDependency != null && element.rightDependency != null) {
        double left;
        if (element.leftDependencyType == 0) {
          left = element.leftDependency!.getX();
        } else {
          left = element.leftDependency!.getRight(size);
        }
        if (element.leftDependency!.visibility == CL.gone) {
          left += _getLeftInsets(goneMargin ?? margin);
        } else {
          left += _getLeftInsets(margin);
        }
        double right;
        if (element.rightDependencyType == 0) {
          right = element.rightDependency!.getX();
        } else {
          right = element.rightDependency!.getRight(size);
        }
        if (element.rightDependency!.visibility == CL.gone) {
          right -= _getRightInsets(goneMargin ?? margin);
        } else {
          right -= _getRightInsets(margin);
        }
        double horizontalBias = childParentData.horizontalBias ?? 0.5;
        offsetX =
            left + (right - left - element.getWidth(size)) * horizontalBias;
      } else if (element.leftDependency != null) {
        double left;
        if (element.leftDependencyType == 0) {
          left = element.leftDependency!.getX();
        } else {
          left = element.leftDependency!.getRight(size);
        }
        if (element.leftDependency!.visibility == CL.gone) {
          left += _getLeftInsets(goneMargin ?? margin);
        } else {
          left += _getLeftInsets(margin);
        }
        offsetX = left;
      } else if (element.rightDependency != null) {
        double right;
        if (element.rightDependencyType == 0) {
          right = element.rightDependency!.getX();
        } else {
          right = element.rightDependency!.getRight(size);
        }
        if (element.rightDependency!.visibility == CL.gone) {
          right -= _getRightInsets(goneMargin ?? margin);
        } else {
          right -= _getRightInsets(margin);
        }
        offsetX = right - element.getWidth(size);
      } else {
        // it is not possible to execute this branch
      }

      // calculate child y offset
      double offsetY = 0;
      if (element.topDependency != null && element.bottomDependency != null) {
        double top;
        if (element.topDependencyType == 0) {
          top = element.topDependency!.getY();
        } else {
          top = element.topDependency!.getBottom(size);
        }
        if (element.topDependency!.visibility == CL.gone) {
          top += _getTopInsets(goneMargin ?? margin);
        } else {
          top += _getTopInsets(margin);
        }
        double bottom;
        if (element.bottomDependencyType == 0) {
          bottom = element.bottomDependency!.getY();
        } else {
          bottom = element.bottomDependency!.getBottom(size);
        }
        if (element.bottomDependency!.visibility == CL.gone) {
          bottom -= _getBottomInsets(goneMargin ?? margin);
        } else {
          bottom -= _getBottomInsets(margin);
        }
        double verticalBias = childParentData.verticalBias ?? 0.5;
        offsetY = top + (bottom - top - element.getHeight(size)) * verticalBias;
      } else if (element.topDependency != null) {
        double top;
        if (element.topDependencyType == 0) {
          top = element.topDependency!.getY();
        } else {
          top = element.topDependency!.getBottom(size);
        }
        if (element.topDependency!.visibility == CL.gone) {
          top += _getTopInsets(goneMargin ?? margin);
        } else {
          top += _getTopInsets(margin);
        }
        offsetY = top;
      } else if (element.bottomDependency != null) {
        double bottom;
        if (element.bottomDependencyType == 0) {
          bottom = element.bottomDependency!.getY();
        } else {
          bottom = element.bottomDependency!.getBottom(size);
        }
        if (element.bottomDependency!.visibility == CL.gone) {
          bottom -= _getBottomInsets(goneMargin ?? margin);
        } else {
          bottom -= _getBottomInsets(margin);
        }
        offsetY = bottom - element.getHeight(size);
      } else {
        // it is not possible to execute this branch
      }

      childParentData.offset = Offset(offsetX, offsetY);
    }
  }

  @override
  bool hitTestChildren(
    BoxHitTestResult result, {
    required Offset position,
  }) {
    RenderBox? child = lastChild;
    while (child != null) {
      _ConstraintBoxData childParentData =
          child.parentData as _ConstraintBoxData;

      // expand the click area without changing the actual size
      Offset offsetPos = Offset(position.dx, position.dy);
      EdgeInsets? clickPadding = childParentData.clickPadding;
      if (clickPadding != null) {
        Size size = child.size;
        double clickPaddingLeft = childParentData.offset.dx - clickPadding.left;
        double clickPaddingTop = childParentData.offset.dy - clickPadding.top;
        double clickPaddingRight =
            childParentData.offset.dx + size.width + clickPadding.right;
        double clickPaddingBottom =
            childParentData.offset.dy + size.height + clickPadding.bottom;
        double xClickPercent = (offsetPos.dx - clickPaddingLeft) /
            (clickPaddingRight - clickPaddingLeft);
        double yClickPercent = (offsetPos.dy - clickPaddingTop) /
            (clickPaddingBottom - clickPaddingTop);
        double realClickX =
            childParentData.offset.dx + xClickPercent * size.width;
        double realClickY =
            childParentData.offset.dy + yClickPercent * size.height;
        offsetPos = Offset(realClickX, realClickY);
      }

      bool isHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: offsetPos,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return child!.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
      child = childParentData.previousSibling;
    }
    return false;
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset,
  ) {
    RenderBox? child = firstChild;
    while (child != null) {
      _ConstraintBoxData childParentData =
          child.parentData as _ConstraintBoxData;
      if (childParentData.visibility == CL.gone ||
          childParentData.visibility == CL.invisible) {
        child = childParentData.nextSibling;
        continue;
      }
      context.paintChild(child, childParentData.offset + offset);

      // draw child's click area
      if (_debugShowClickArea == true && kDebugMode) {
        Paint paint = Paint();
        paint.color = Colors.yellow.withAlpha(192);
        EdgeInsets? clickPadding = childParentData.clickPadding;
        Rect rect = Rect.fromLTRB(
            childParentData.offset.dx - _getLeftInsets(clickPadding),
            childParentData.offset.dy - _getTopInsets(clickPadding),
            childParentData.offset.dx +
                child.size.width +
                _getRightInsets(clickPadding),
            childParentData.offset.dy +
                child.size.height +
                _getBottomInsets(clickPadding));
        context.canvas.drawRect(rect.shift(offset), paint);
        ui.ParagraphBuilder paragraphBuilder =
            ui.ParagraphBuilder(ui.ParagraphStyle(
          textAlign: TextAlign.center,
          fontSize: 12,
        ));
        paragraphBuilder.addText("CLICK AREA");
        ui.Paragraph paragraph = paragraphBuilder.build();
        paragraph.layout(ui.ParagraphConstraints(
          width: child.size.width,
        ));
        context.canvas.drawParagraph(
            paragraph,
            (childParentData.offset + offset) +
                Offset(0, (child.size.height - paragraph.height) / 2));
      }

      child = childParentData.nextSibling;
    }
  }
}

class _NodeDependency {
  String? nodeId;
  double? width;
  double? height;
  RenderBox? renderBox;
  _NodeDependency? leftDependency;
  _NodeDependency? topDependency;
  _NodeDependency? rightDependency;
  _NodeDependency? bottomDependency;
  int? leftDependencyType; // 0 toLeft，1 toRight
  int? topDependencyType; // 0 toTop，1 toBottom
  int? rightDependencyType; // 0 toLeft，1 toRight
  int? bottomDependencyType; // toTop，1 toBottom
  int depth = -1;
  CLVisibility? visibility;

  bool isParent() {
    return nodeId == CL.parent;
  }

  double getX() {
    if (isParent()) {
      return 0;
    }
    return (renderBox!.parentData as _ConstraintBoxData).offset.dx;
  }

  double getY() {
    if (isParent()) {
      return 0;
    }
    return (renderBox!.parentData as _ConstraintBoxData).offset.dy;
  }

  double getRight(Size size) {
    if (isParent()) {
      return size.width;
    }
    return getX() + getWidth(size);
  }

  double getBottom(Size size) {
    if (isParent()) {
      return size.height;
    }
    return getY() + getHeight(size);
  }

  double getWidth(Size size) {
    if (isParent()) {
      return size.width;
    }
    if (visibility == CL.gone) {
      return 0;
    }
    return renderBox!.size.width;
  }

  double getHeight(Size size) {
    if (isParent()) {
      return size.height;
    }
    if (visibility == CL.gone) {
      return 0;
    }
    return renderBox!.size.height;
  }

  int getDepthFor(_NodeDependency? nodeDependency) {
    if (nodeDependency == null) {
      return -1;
    }
    return nodeDependency.getDepth();
  }

  int getDepth() {
    if (depth < 0) {
      if (nodeId == CL.parent) {
        depth = 0;
      } else {
        depth = max(
                max(
                    max(getDepthFor(leftDependency),
                        getDepthFor(topDependency)),
                    getDepthFor(rightDependency)),
                getDepthFor(bottomDependency)) +
            1;
      }
    }
    return depth;
  }

  // for debug message print
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (nodeId == CL.parent) {
      map['nodeId'] = 'parent';
    } else {
      map['nodeId'] = nodeId;
      if (leftDependency != null) {
        if (leftDependency!.isParent()) {
          map['leftDependency'] = 'parent';
        } else {
          map['leftDependency'] = leftDependency!.toJson();
        }
        if (leftDependencyType == 0) {
          map['leftDependencyType'] = 'toLeft';
        } else {
          map['leftDependencyType'] = 'toRight';
        }
      }
      if (topDependency != null) {
        if (topDependency!.isParent()) {
          map['topDependency'] = 'parent';
        } else {
          map['topDependency'] = topDependency!.toJson();
        }
        if (topDependencyType == 0) {
          map['topDependencyType'] = 'toTop';
        } else {
          map['topDependencyType'] = 'toBottom';
        }
      }
      if (rightDependency != null) {
        if (rightDependency!.isParent()) {
          map['rightDependency'] = 'parent';
        } else {
          map['rightDependency'] = rightDependency!.toJson();
        }
        if (rightDependencyType == 0) {
          map['rightDependencyType'] = 'toLeft';
        } else {
          map['rightDependencyType'] = 'toRight';
        }
      }
      if (bottomDependency != null) {
        if (bottomDependency!.isParent()) {
          map['bottomDependency'] = 'parent';
        } else {
          map['bottomDependency'] = bottomDependency!.toJson();
        }
        if (bottomDependencyType == 0) {
          map['bottomDependencyType'] = 'toTop';
        } else {
          map['bottomDependencyType'] = 'toBottom';
        }
      }
    }
    map['depth'] = getDepth();
    return map;
  }
}

class Guideline extends LeafRenderObjectWidget {
  final double? guidelineBegin;
  final double? guidelineEnd;
  final double? guidelinePercent;
  final bool horizontal;

  const Guideline({
    Key? key,
    this.guidelineBegin,
    this.guidelineEnd,
    this.guidelinePercent,
    this.horizontal = false,
  }) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _GuidelineRenderBox();
}

class _GuidelineRenderBox extends RenderBox {}

class Barrier extends LeafRenderObjectWidget {
  final BarrierDirection direction;
  final String referencedIds;

  const Barrier({
    Key? key,
    required this.direction,
    required this.referencedIds,
  }) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) => _BarrierRenderBox();
}

class _BarrierRenderBox extends RenderBox {}
