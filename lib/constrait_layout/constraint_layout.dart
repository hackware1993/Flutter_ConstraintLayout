import 'dart:collection';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// No matter how complex the layout is and how deep the constraints
/// are, each child element of ConstraintLayout will only be measured once
/// This results in extremely high layout performance.
///
/// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
/// Warning:
/// For layout performance considerations, constraints are always
/// one-way, and there is no two child elements that directly or
/// indirectly restrain each other. Each constraint should describe
/// exactly where the child elements are located. The following code
/// is not allowed and will cause a stack overflow exception：
///        ConstraintLayout(
//           children: [
//             Constrained(
//               id: 'leftOne',
//               width: CL.matchConstraint,
//               height: CL.matchParent,
//               leftToLeft: CL.parent,
//               rightToLeft: 'rightOne',
//               child: Container(
//                 color: Colors.redAccent,
//               ),
//             ),
//             Constrained(
//               id: 'rightOne',
//               width: CL.matchConstraint,
//               height: CL.matchParent,
//               leftToRight: 'leftOne',
//               rightToRight: CL.parent,
//               child: Container(
//                 color: Colors.blue,
//               ),
//             )
//           ],
//         )
/// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
///
/// features:
///   1. build flexible layouts with constraints
///   2. margin and goneMargin
///   3. clickPadding (quickly expand the click area of child elements without changing their actual size)
///   4. visibility control
///   5. constraint integrity hint
///   6. bias
///   7. z-index
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
  // TODO implement debug function
  final bool debugShowGuideline;
  final bool debugShowPreview;

  // already supported
  final bool debugShowClickArea;
  final bool debugPrintConstraints;
  final bool debugPrintLayoutTime;
  final bool debugCheckConstraints;
  final bool releasePrintLayoutTime;
  final String? debugName;
  final bool debugShowZIndex;

  ConstraintLayout({
    Key? key,
    List<Widget> children = const <Widget>[],
    this.debugShowGuideline = false,
    this.debugShowPreview = false,
    this.debugShowClickArea = false,
    this.debugPrintConstraints = false,
    this.debugPrintLayoutTime = true,
    this.debugCheckConstraints = true,
    this.releasePrintLayoutTime = false,
    this.debugName,
    this.debugShowZIndex = false,
  }) : super(
          key: key,
          children: children,
        );

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _ConstraintRenderBox()
      .._debugShowGuideline = debugShowGuideline
      .._debugShowPreview = debugShowPreview
      .._debugShowClickArea = debugShowClickArea
      .._debugPrintConstraints = debugPrintConstraints
      .._debugPrintLayoutTime = debugPrintLayoutTime
      .._debugCheckConstraints = debugCheckConstraints
      .._releasePrintLayoutTime = releasePrintLayoutTime
      .._debugName = debugName
      .._debugShowZIndex = debugShowZIndex;
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
      ..debugPrintConstraints = debugPrintConstraints
      ..debugPrintLayoutTime = debugPrintLayoutTime
      ..debugCheckConstraints = debugCheckConstraints
      ..releasePrintLayoutTime = releasePrintLayoutTime
      ..debugName = debugName
      ..debugShowZIndex = debugShowZIndex;
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

enum _ConstraintType {
  toLeft,
  toRight,
  toTop,
  toBottom,
  toBaseline,
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
  int? zIndex;
  Offset? translate;
  bool? translateConstraint;
  String? baselineToTop;
  String? baselineToBottom;
  String? baselineToBaseline;
  TextBaseline? textBaseline;
}

class Constrained extends ParentDataWidget<_ConstraintBoxData> {
  // 'wrap_content'、'match_parent'、'match_constraint'、'48, etc'
  final double width;

  // 'wrap_content'、'match_parent'、'match_constraint'、'48, etc'
  final double height;

  // id can be null, but not an empty string
  final String? id;

  // expand the click area without changing the actual size
  final EdgeInsets clickPadding;

  final CLVisibility visibility;

  // margin can be negative
  final EdgeInsets margin;
  final EdgeInsets goneMargin;
  final double horizontalBias;
  final double verticalBias;

  /// depends on sibling id or CL.parent
  final String? leftToLeft;
  final String? leftToRight;
  final String? rightToLeft;
  final String? rightToRight;
  final String? topToTop;
  final String? topToBottom;
  final String? bottomToTop;
  final String? bottomToBottom;

  /// when setting baseline alignment, height must be wrap_content or fixed size
  /// other vertical constraints will be ignored
  /// Warning:
  /// Due to a bug in the flutter framework, baseline alignment may not take effect in debug mode
  /// See https://github.com/flutter/flutter/issues/101179
  final String? baselineToTop;
  final String? baselineToBottom;
  final String? baselineToBaseline;
  final TextBaseline textBaseline;

  final String? center;
  final String? centerHorizontal;
  final String? centerVertical;

  final int? zIndex;
  final Offset translate;
  final bool translateConstraint;

  // TODO support chain
  // final ChainStyle? chainStyle;
  // TODO support circle positioned
  // TODO support dimension ratio
  // TODO support barrier
  // TODO support guideline
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
    this.clickPadding = EdgeInsets.zero,
    this.visibility = CL.visible,
    this.margin = EdgeInsets.zero,
    this.goneMargin = EdgeInsets.zero,
    this.center,
    this.centerHorizontal,
    this.centerVertical,
    this.horizontalBias = 0.5,
    this.verticalBias = 0.5,
    this.zIndex, // default is child index
    this.translate = Offset.zero,
    this.translateConstraint = false,
    this.baselineToTop,
    this.baselineToBottom,
    this.baselineToBaseline,
    this.textBaseline = TextBaseline.alphabetic,
  }) : super(
          key: key,
          child: child,
        );

  bool checkSize(double size) {
    if (size == CL.matchParent ||
        size == CL.wrapContent ||
        size == CL.matchConstraint) {
      return true;
    } else {
      return size != double.infinity && size > 0;
    }
  }

  bool checkConstraint(String? constraint) {
    return constraint == null || constraint.trim().isNotEmpty;
  }

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is _ConstraintBoxData);

    // bounds check
    assert(checkSize(width));
    assert(checkSize(height));
    assert(checkConstraint(id));
    assert(checkConstraint(this.leftToLeft));
    assert(checkConstraint(this.leftToRight));
    assert(checkConstraint(this.rightToLeft));
    assert(checkConstraint(this.rightToRight));
    assert(checkConstraint(this.topToTop));
    assert(checkConstraint(this.topToBottom));
    assert(checkConstraint(this.bottomToTop));
    assert(checkConstraint(this.bottomToBottom));
    assert(checkConstraint(this.baselineToTop));
    assert(checkConstraint(this.baselineToBottom));
    assert(checkConstraint(this.baselineToBaseline));
    assert((horizontalBias >= 0 && horizontalBias <= 1));
    assert((verticalBias >= 0 && verticalBias <= 1));

    String? leftToLeft = this.leftToLeft;
    String? leftToRight = this.leftToRight;
    String? rightToLeft = this.rightToLeft;
    String? rightToRight = this.rightToRight;
    String? topToTop = this.topToTop;
    String? topToBottom = this.topToBottom;
    String? bottomToTop = this.bottomToTop;
    String? bottomToBottom = this.bottomToBottom;
    String? baselineToTop = this.baselineToTop;
    String? baselineToBottom = this.baselineToBottom;
    String? baselineToBaseline = this.baselineToBaseline;

    if (width == CL.matchParent) {
      assert(() {
        if (leftToLeft != null ||
            leftToRight != null ||
            rightToLeft != null ||
            rightToRight != null) {
          throw Exception(
              'When setting the width to match_parent for child with id $id, there is no need to set left or right constraint.');
        }

        if (centerHorizontal != null) {
          throw Exception(
              'When setting the width to match_parent for child with id $id, there is no need to set centerHorizontal.');
        }
        return true;
      }());
      leftToLeft = CL.parent;
      rightToRight = CL.parent;
      leftToRight = null;
      rightToLeft = null;
    }

    if (height == CL.matchParent) {
      assert(() {
        if (topToTop != null ||
            topToBottom != null ||
            bottomToTop != null ||
            bottomToBottom != null ||
            baselineToTop != null ||
            baselineToBottom != null ||
            baselineToBaseline != null) {
          throw Exception(
              'When setting the height to match_parent for child with id $id, there is no need to set top or bottom or baseline constraint.');
        }

        if (centerVertical != null) {
          throw Exception(
              'When setting the height to match_parent for child with id $id, there is no need to set centerVertical.');
        }
        return true;
      }());
      topToTop = CL.parent;
      bottomToBottom = CL.parent;
      topToBottom = null;
      bottomToTop = null;
      baselineToTop = null;
      baselineToBottom = null;
      baselineToBaseline = null;
    }

    assert(() {
      if (width == CL.matchParent && height == CL.matchParent) {
        if (center != null) {
          throw Exception(
              'When setting the width and height to match_parent for child with id $id, there is no need to set center.');
        }
      }
      return true;
    }());

    if (centerHorizontal != null) {
      assert(() {
        if (leftToLeft != null ||
            leftToRight != null ||
            rightToLeft != null ||
            rightToRight != null) {
          throw Exception(
              'When setting centerHorizontal for child with id $id, there is no need to set left or right constraint.');
        }
        return true;
      }());
      leftToLeft = centerHorizontal;
      rightToRight = centerHorizontal;
      leftToRight = null;
      rightToLeft = null;
    }

    if (centerVertical != null) {
      assert(() {
        if (topToTop != null ||
            topToBottom != null ||
            bottomToTop != null ||
            bottomToBottom != null ||
            baselineToTop != null ||
            baselineToBottom != null ||
            baselineToBaseline != null) {
          throw Exception(
              'When setting centerVertical for child with id $id, there is no need to set top or bottom or baseline constraint.');
        }
        return true;
      }());
      topToTop = centerVertical;
      bottomToBottom = centerVertical;
      topToBottom = null;
      bottomToTop = null;
      baselineToTop = null;
      baselineToBottom = null;
      baselineToBaseline = null;
    }

    if (center != null) {
      assert(() {
        if (leftToLeft != null ||
            leftToRight != null ||
            rightToLeft != null ||
            rightToRight != null ||
            topToTop != null ||
            topToBottom != null ||
            bottomToTop != null ||
            bottomToBottom != null ||
            baselineToTop != null ||
            baselineToBottom != null ||
            baselineToBaseline != null) {
          throw Exception(
              'When setting center for child with id $id, there is no need to set left or right or top or bottom or baseline constraint.');
        }
        return true;
      }());
      leftToLeft = center;
      rightToRight = center;
      topToTop = center;
      bottomToBottom = center;
      leftToRight = null;
      rightToLeft = null;
      topToBottom = null;
      bottomToTop = null;
      baselineToTop = null;
      baselineToBottom = null;
      baselineToBaseline = null;
    }

    _ConstraintBoxData parentData =
        renderObject.parentData! as _ConstraintBoxData;
    bool needsLayout = false;
    bool needsPaint = false;
    bool needsReorderChildren = false;

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

    if (parentData.baselineToTop != baselineToTop) {
      parentData.baselineToTop = baselineToTop;
      needsLayout = true;
    }

    if (parentData.baselineToBottom != baselineToBottom) {
      parentData.baselineToBottom = baselineToBottom;
      needsLayout = true;
    }

    if (parentData.baselineToBaseline != baselineToBaseline) {
      parentData.baselineToBaseline = baselineToBaseline;
      needsLayout = true;
    }

    if (parentData.textBaseline != textBaseline) {
      parentData.textBaseline = textBaseline;
      needsLayout = true;
    }

    parentData.clickPadding = clickPadding;

    if (parentData.visibility != visibility) {
      if (parentData.visibility == CL.gone || visibility == CL.gone) {
        needsLayout = true;
      } else {
        needsPaint = true;
      }
      parentData.visibility = visibility;
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

    if (parentData.zIndex != zIndex) {
      parentData.zIndex = zIndex;
      needsPaint = true;
      needsReorderChildren = true;
    }

    if (parentData.translateConstraint != translateConstraint) {
      parentData.translateConstraint = translateConstraint;
      needsLayout = true;
    }

    if (parentData.translate != translate) {
      parentData.translate = translate;
      if (translateConstraint) {
        needsLayout = true;
      } else {
        needsPaint = true;
      }
    }

    if (needsLayout) {
      AbstractNode? targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    } else {
      if (needsReorderChildren) {
        AbstractNode? targetParent = renderObject.parent;
        if (targetParent is _ConstraintRenderBox) {
          targetParent.needsReorderChildren = true;
        }
      }
      if (needsPaint) {
        AbstractNode? targetParent = renderObject.parent;
        if (targetParent is RenderObject) {
          targetParent.markNeedsPaint();
        }
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
  late bool _debugShowGuideline;
  late bool _debugShowPreview;
  late bool _debugShowClickArea;
  late bool _debugPrintConstraints;
  late bool _debugPrintLayoutTime;
  late bool _debugCheckConstraints;
  late bool _releasePrintLayoutTime;
  String? _debugName;
  late bool _debugShowZIndex;
  late bool _needsReorderChildren;

  final Map<RenderBox, _ConstrainedNode> _constrainedNodes = HashMap();
  final Map<String, _ConstrainedNode> _tempConstrainedNodes = HashMap();
  late List<_ConstrainedNode> _paintingOrderList;

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

  set debugPrintConstraints(bool value) {
    if (_debugPrintConstraints != value) {
      _debugPrintConstraints = value;
      markNeedsLayout();
    }
  }

  set debugPrintLayoutTime(bool value) {
    if (_debugPrintLayoutTime != value) {
      _debugPrintLayoutTime = value;
      markNeedsLayout();
    }
  }

  set debugCheckConstraints(bool value) {
    if (_debugCheckConstraints != value) {
      _debugCheckConstraints = value;
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

  set debugShowZIndex(bool value) {
    if (_debugShowZIndex != value) {
      _debugShowZIndex = value;
      markNeedsPaint();
    }
  }

  set needsReorderChildren(bool value) {
    if (_needsReorderChildren != value) {
      _needsReorderChildren = value;
      markNeedsPaint();
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
    Set<String> constraintsIdSet = HashSet();
    while (child != null) {
      _ConstraintBoxData childParentData =
          child.parentData as _ConstraintBoxData;
      if (childParentData.id != null) {
        if (!idSet.add(childParentData.id!)) {
          throw Exception('Duplicate id in ConstraintLayout.');
        }
      }
      if (childParentData.leftToLeft != null) {
        constraintsIdSet.add(childParentData.leftToLeft!);
      }
      if (childParentData.leftToRight != null) {
        constraintsIdSet.add(childParentData.leftToRight!);
      }
      if (childParentData.rightToLeft != null) {
        constraintsIdSet.add(childParentData.rightToLeft!);
      }
      if (childParentData.rightToRight != null) {
        constraintsIdSet.add(childParentData.rightToRight!);
      }
      if (childParentData.topToTop != null) {
        constraintsIdSet.add(childParentData.topToTop!);
      }
      if (childParentData.topToBottom != null) {
        constraintsIdSet.add(childParentData.topToBottom!);
      }
      if (childParentData.bottomToTop != null) {
        constraintsIdSet.add(childParentData.bottomToTop!);
      }
      if (childParentData.bottomToBottom != null) {
        constraintsIdSet.add(childParentData.bottomToBottom!);
      }
      if (childParentData.baselineToTop != null) {
        constraintsIdSet.add(childParentData.baselineToTop!);
      }
      if (childParentData.baselineToBottom != null) {
        constraintsIdSet.add(childParentData.baselineToBottom!);
      }
      if (childParentData.baselineToBaseline != null) {
        constraintsIdSet.add(childParentData.baselineToBaseline!);
      }
      child = childParentData.nextSibling;
    }
    Set<String> illegalIdSet = constraintsIdSet.difference(idSet);
    if (illegalIdSet.isNotEmpty) {
      throw Exception('These ids $illegalIdSet are not yet defined.');
    }
  }

  // there should be no loop constraints
  void _debugCheckLoopConstraints() {
    for (final element in _constrainedNodes.values) {
      try {
        element.getDepth();
      } on StackOverflowError catch (_) {
        const msg =
            'There are some loop constraints, please check the code. For layout performance considerations, constraints are always one-way, and there is no two child elements that directly or indirectly restrain each other. Each constraint should describe exactly where the child elements are located. Use Guideline to break loop constraints.';
        throw Exception(msg);
      }
    }
  }

  // each child element must have complete constraints both horizontally and vertically
  void _debugCheckConstraintsIntegrity() {
    for (final element in _constrainedNodes.values) {
      // check constraint integrity in the horizontal direction
      if (element.width == CL.wrapContent || element.width > 0) {
        if (element.leftConstraint == null && element.rightConstraint == null) {
          throw Exception(
              'Need to set a left or right constraint for ${element.nodeId}.');
        }
      } else if (element.width == CL.matchConstraint) {
        if (element.leftConstraint == null || element.rightConstraint == null) {
          throw Exception(
              'Need to set left and right constraints for ${element.nodeId}.');
        }
      }

      // check constraint integrity in the vertical direction
      if (element.height == CL.wrapContent || element.height > 0) {
        int verticalConstraintCount = (element.topConstraint == null ? 0 : 1) +
            (element.bottomConstraint == null ? 0 : 1) +
            (element.baselineConstraint == null ? 0 : 10);
        if (verticalConstraintCount == 0) {
          throw Exception(
              'Need to set a top or bottom or baseline constraint for ${element.nodeId}.');
        } else if (verticalConstraintCount > 10) {
          throw Exception(
              'When the baseline constraint is set, the top or bottom constraint can not be set for ${element.nodeId}.');
        }
      } else if (element.height == CL.matchConstraint) {
        if (element.baselineConstraint != null) {
          throw Exception(
              'When setting a baseline constraint for ${element.nodeId}, its height must be fixed or wrap_content.');
        }
        if (element.topConstraint == null || element.bottomConstraint == null) {
          throw Exception(
              'Need to set both top and bottom constraints for ${element.nodeId}.');
        }
      } else {
        // match_parent
        if (element.baselineConstraint != null) {
          throw Exception(
              'When setting a baseline constraint for ${element.nodeId}, its height must be fixed or wrap_content.');
        }
      }
    }
  }

  void _debugEnsureNullConstraint(
    _ConstrainedNode node,
    _ConstrainedNode? constrainedNode,
    String direction,
  ) {
    if (_debugCheckConstraints) {
      if (constrainedNode != null) {
        debugPrint(
            'Warning: The child element with id ${node.nodeId} has a duplicate $direction constraint.');
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

  _ConstrainedNode _getConstrainedNodeForChild(
    RenderBox? child,
    String id,
  ) {
    _ConstrainedNode? node = _tempConstrainedNodes[id];
    if (node == null) {
      node = _ConstrainedNode();
      node.nodeId = id;
      _tempConstrainedNodes[id] = node;
    }
    if (child != null && node.renderBox == null) {
      node.renderBox = child;
      _constrainedNodes[child] = node;
    }
    return node;
  }

  void _buildConstrainedNodeTrees() {
    _constrainedNodes.clear();
    _tempConstrainedNodes.clear();
    RenderBox? child = firstChild;
    int childIndex = -1;

    while (child != null) {
      childIndex++;
      _ConstraintBoxData childParentData =
          child.parentData as _ConstraintBoxData;

      assert(() {
        if (_debugCheckConstraints) {
          if (childParentData.width == null) {
            if (!_isInternalBox(child!)) {
              throw Exception(
                  'Child elements must be wrapped with Constrained.');
            }
          } else {
            if (_isInternalBox(child!)) {
              throw Exception(
                  'Guideline, Barrier can not be wrapped with Constrained.');
            }
          }
        }
        return true;
      }());

      _ConstrainedNode currentNode = _getConstrainedNodeForChild(
          child, childParentData.id ?? 'child[$childIndex]@${child.hashCode}');
      currentNode.parentData = childParentData;
      currentNode.index = childIndex;

      if (childParentData.leftToLeft != null) {
        assert(() {
          _debugEnsureNullConstraint(
              currentNode, currentNode.leftConstraint, 'left');
          return true;
        }());
        currentNode.leftConstraint =
            _getConstrainedNodeForChild(null, childParentData.leftToLeft!);
        currentNode.leftConstraintType = _ConstraintType.toLeft;
      }

      if (childParentData.leftToRight != null) {
        assert(() {
          _debugEnsureNullConstraint(
              currentNode, currentNode.leftConstraint, 'left');
          return true;
        }());
        currentNode.leftConstraint =
            _getConstrainedNodeForChild(null, childParentData.leftToRight!);
        currentNode.leftConstraintType = _ConstraintType.toRight;
      }

      if (childParentData.rightToLeft != null) {
        assert(() {
          _debugEnsureNullConstraint(
              currentNode, currentNode.rightConstraint, 'right');
          return true;
        }());
        currentNode.rightConstraint =
            _getConstrainedNodeForChild(null, childParentData.rightToLeft!);
        currentNode.rightConstraintType = _ConstraintType.toLeft;
      }

      if (childParentData.rightToRight != null) {
        assert(() {
          _debugEnsureNullConstraint(
              currentNode, currentNode.rightConstraint, 'right');
          return true;
        }());
        currentNode.rightConstraint =
            _getConstrainedNodeForChild(null, childParentData.rightToRight!);
        currentNode.rightConstraintType = _ConstraintType.toRight;
      }

      if (childParentData.topToTop != null) {
        assert(() {
          _debugEnsureNullConstraint(
              currentNode, currentNode.topConstraint, 'top');
          return true;
        }());
        currentNode.topConstraint =
            _getConstrainedNodeForChild(null, childParentData.topToTop!);
        currentNode.topConstraintType = _ConstraintType.toTop;
      }

      if (childParentData.topToBottom != null) {
        assert(() {
          _debugEnsureNullConstraint(
              currentNode, currentNode.topConstraint, 'top');
          return true;
        }());
        currentNode.topConstraint =
            _getConstrainedNodeForChild(null, childParentData.topToBottom!);
        currentNode.topConstraintType = _ConstraintType.toBottom;
      }

      if (childParentData.bottomToTop != null) {
        assert(() {
          _debugEnsureNullConstraint(
              currentNode, currentNode.bottomConstraint, 'bottom');
          return true;
        }());
        currentNode.bottomConstraint =
            _getConstrainedNodeForChild(null, childParentData.bottomToTop!);
        currentNode.bottomConstraintType = _ConstraintType.toTop;
      }

      if (childParentData.bottomToBottom != null) {
        assert(() {
          _debugEnsureNullConstraint(
              currentNode, currentNode.bottomConstraint, 'bottom');
          return true;
        }());
        currentNode.bottomConstraint =
            _getConstrainedNodeForChild(null, childParentData.bottomToBottom!);
        currentNode.bottomConstraintType = _ConstraintType.toBottom;
      }

      if (childParentData.baselineToTop != null) {
        assert(() {
          _debugEnsureNullConstraint(
              currentNode, currentNode.baselineConstraint, 'baseline');
          return true;
        }());
        currentNode.baselineConstraint =
            _getConstrainedNodeForChild(null, childParentData.baselineToTop!);
        currentNode.baselineConstraintType = _ConstraintType.toTop;
      }

      if (childParentData.baselineToBottom != null) {
        assert(() {
          _debugEnsureNullConstraint(
              currentNode, currentNode.baselineConstraint, 'baseline');
          return true;
        }());
        currentNode.baselineConstraint = _getConstrainedNodeForChild(
            null, childParentData.baselineToBottom!);
        currentNode.baselineConstraintType = _ConstraintType.toBottom;
      }

      if (childParentData.baselineToBaseline != null) {
        assert(() {
          _debugEnsureNullConstraint(
              currentNode, currentNode.baselineConstraint, 'baseline');
          return true;
        }());
        currentNode.baselineConstraint = _getConstrainedNodeForChild(
            null, childParentData.baselineToBaseline!);
        currentNode.baselineConstraintType = _ConstraintType.toBaseline;
      }

      child = childParentData.nextSibling;
    }

    _tempConstrainedNodes.clear();
  }

  @override
  void performLayout() {
    int startTime = 0;
    if (_releasePrintLayoutTime && kReleaseMode) {
      startTime = DateTime.now().millisecondsSinceEpoch;
    }
    assert(() {
      if (_debugPrintLayoutTime) {
        startTime = DateTime.now().millisecondsSinceEpoch;
      }
      return true;
    }());

    // always fill the parent layout
    // TODO will support wrap_content in the future
    size = constraints.constrain(const Size(double.infinity, double.infinity));

    assert(() {
      if (_debugCheckConstraints) {
        _debugCheckIds();
      }
      return true;
    }());

    // traverse once, building the constrained node tree for each child element
    _buildConstrainedNodeTrees();

    assert(() {
      if (_debugCheckConstraints) {
        _debugCheckConstraintsIntegrity();
        _debugCheckLoopConstraints();
      }
      return true;
    }());

    // sort by the depth of constraint from shallow to deep, the lowest depth is 0, representing parent
    List<_ConstrainedNode> constrainedNodeTrees =
        _constrainedNodes.values.toList();
    constrainedNodeTrees.sort((left, right) {
      return left.getDepth() - right.getDepth();
    });

    _paintingOrderList = _constrainedNodes.values.toList();
    _paintingOrderList.sort((left, right) {
      int result = left.zIndex - right.zIndex;
      if (result == 0) {
        result = left.index - right.index;
      }
      return result;
    });
    _needsReorderChildren = false;

    assert(() {
      // print constraints
      if (_debugPrintConstraints) {
        debugPrint('ConstraintLayout@${_debugName ?? hashCode} constraints: ' +
            jsonEncode(constrainedNodeTrees.map((e) => e.toJson()).toList()));
      }
      return true;
    }());

    _layoutByConstrainedNodeTrees(constrainedNodeTrees);

    if (_releasePrintLayoutTime && kReleaseMode) {
      print(
          'ConstraintLayout@${_debugName ?? hashCode} layout time = ${DateTime.now().millisecondsSinceEpoch - startTime} ms(current is release mode).');
    }
    assert(() {
      if (_debugPrintLayoutTime) {
        debugPrint(
            'ConstraintLayout@${_debugName ?? hashCode} layout time = ${DateTime.now().millisecondsSinceEpoch - startTime} ms(current is debug mode, release mode may take less time).');
      }
      return true;
    }());
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

  void _layoutByConstrainedNodeTrees(
      List<_ConstrainedNode> constrainedNodeTrees) {
    for (final element in constrainedNodeTrees) {
      EdgeInsets? margin = element.margin;
      EdgeInsets? goneMargin = element.goneMargin;

      // calculate child width
      double minWidth = 0;
      double maxWidth = double.infinity;
      double minHeight = 0;
      double maxHeight = double.infinity;
      if (element.visibility == CL.gone) {
        minWidth = 0;
        maxWidth = 0;
        minWidth = 0;
        maxHeight = 0;
      } else {
        double width = element.width;
        if (width == CL.wrapContent) {
          maxWidth = size.width;
        } else if (width == CL.matchParent) {
          minWidth = size.width - _getHorizontalInsets(margin);
          assert(() {
            if (_debugCheckConstraints) {
              if (minWidth < 0) {
                debugPrint(
                    'Warning: The child element with id ${element.nodeId} has a negative width');
              }
            }
            return true;
          }());
          maxWidth = minWidth;
        } else if (width == CL.matchConstraint) {
          double left;
          if (element.leftConstraintType == _ConstraintType.toLeft) {
            left = element.leftConstraint!.getX();
          } else {
            left = element.leftConstraint!.getRight(size);
          }
          if (element.leftConstraint!.isNotLaidOut()) {
            left += _getLeftInsets(goneMargin);
          } else {
            left += _getLeftInsets(margin);
          }
          double right;
          if (element.rightConstraintType == _ConstraintType.toLeft) {
            right = element.rightConstraint!.getX();
          } else {
            right = element.rightConstraint!.getRight(size);
          }
          if (element.rightConstraint!.isNotLaidOut()) {
            right -= _getRightInsets(goneMargin);
          } else {
            right -= _getRightInsets(margin);
          }
          minWidth = right - left;
          assert(() {
            if (_debugCheckConstraints) {
              if (minWidth < 0) {
                debugPrint(
                    'Warning: The child element with id ${element.nodeId} has a negative width');
              }
            }
            return true;
          }());
          maxWidth = minWidth;
        } else {
          minWidth = width;
          maxWidth = width;
        }

        // calculate child height
        double height = element.height;
        if (height == CL.wrapContent) {
          maxHeight = size.height;
        } else if (height == CL.matchParent) {
          minHeight = size.height - _getVerticalInsets(margin);
          assert(() {
            if (_debugCheckConstraints) {
              if (minHeight < 0) {
                debugPrint(
                    'Warning: The child element with id ${element.nodeId} has a negative height');
              }
            }
            return true;
          }());
          maxHeight = minHeight;
        } else if (height == CL.matchConstraint) {
          double top;
          if (element.topConstraintType == _ConstraintType.toTop) {
            top = element.topConstraint!.getY();
          } else {
            top = element.topConstraint!.getBottom(size);
          }
          if (element.topConstraint!.isNotLaidOut()) {
            top += _getTopInsets(goneMargin);
          } else {
            top += _getTopInsets(margin);
          }
          double bottom;
          if (element.bottomConstraintType == _ConstraintType.toTop) {
            bottom = element.bottomConstraint!.getY();
          } else {
            bottom = element.bottomConstraint!.getBottom(size);
          }
          if (element.bottomConstraint!.isNotLaidOut()) {
            bottom -= _getBottomInsets(goneMargin);
          } else {
            bottom -= _getBottomInsets(margin);
          }
          minHeight = bottom - top;
          assert(() {
            if (_debugCheckConstraints) {
              if (minHeight < 0) {
                debugPrint(
                    'Warning: The child element with id ${element.nodeId} has a negative height');
              }
            }
            return true;
          }());
          maxHeight = minHeight;
        } else {
          minHeight = height;
          maxHeight = height;
        }
      }

      // measure
      if (maxWidth <= 0 || maxHeight <= 0) {
        element.renderBox!.layout(
          const BoxConstraints.tightFor(width: 0, height: 0),
          parentUsesSize: false,
        );
        element.laidOut = false;
        assert(() {
          if (_debugCheckConstraints) {
            debugPrint(
                'Warning: The child element with id ${element.nodeId} has a negative size, will not be laid out and paint.');
          }
          return true;
        }());
      } else {
        element.renderBox!.layout(
          BoxConstraints(
            minWidth: minWidth,
            maxWidth: maxWidth,
            minHeight: minHeight,
            maxHeight: maxHeight,
          ),
          parentUsesSize: true,
        );
        element.laidOut = true;
      }

      // calculate child x offset
      double offsetX = 0;
      if (element.leftConstraint != null && element.rightConstraint != null) {
        double left;
        if (element.leftConstraintType == _ConstraintType.toLeft) {
          left = element.leftConstraint!.getX();
        } else {
          left = element.leftConstraint!.getRight(size);
        }
        if (element.leftConstraint!.isNotLaidOut()) {
          left += _getLeftInsets(goneMargin);
        } else {
          left += _getLeftInsets(margin);
        }
        double right;
        if (element.rightConstraintType == _ConstraintType.toLeft) {
          right = element.rightConstraint!.getX();
        } else {
          right = element.rightConstraint!.getRight(size);
        }
        if (element.rightConstraint!.isNotLaidOut()) {
          right -= _getRightInsets(goneMargin);
        } else {
          right -= _getRightInsets(margin);
        }
        double horizontalBias = element.horizontalBias;
        offsetX = left +
            (right - left - element.getMeasuredWidth(size)) * horizontalBias;
      } else if (element.leftConstraint != null) {
        double left;
        if (element.leftConstraintType == _ConstraintType.toLeft) {
          left = element.leftConstraint!.getX();
        } else {
          left = element.leftConstraint!.getRight(size);
        }
        if (element.leftConstraint!.isNotLaidOut()) {
          left += _getLeftInsets(goneMargin);
        } else {
          left += _getLeftInsets(margin);
        }
        offsetX = left;
      } else if (element.rightConstraint != null) {
        double right;
        if (element.rightConstraintType == _ConstraintType.toLeft) {
          right = element.rightConstraint!.getX();
        } else {
          right = element.rightConstraint!.getRight(size);
        }
        if (element.rightConstraint!.isNotLaidOut()) {
          right -= _getRightInsets(goneMargin);
        } else {
          right -= _getRightInsets(margin);
        }
        offsetX = right - element.getMeasuredWidth(size);
      } else {
        // it is not possible to execute this branch
      }

      // calculate child y offset
      double offsetY = 0;
      if (element.topConstraint != null && element.bottomConstraint != null) {
        double top;
        if (element.topConstraintType == _ConstraintType.toTop) {
          top = element.topConstraint!.getY();
        } else {
          top = element.topConstraint!.getBottom(size);
        }
        if (element.topConstraint!.isNotLaidOut()) {
          top += _getTopInsets(goneMargin);
        } else {
          top += _getTopInsets(margin);
        }
        double bottom;
        if (element.bottomConstraintType == _ConstraintType.toTop) {
          bottom = element.bottomConstraint!.getY();
        } else {
          bottom = element.bottomConstraint!.getBottom(size);
        }
        if (element.bottomConstraint!.isNotLaidOut()) {
          bottom -= _getBottomInsets(goneMargin);
        } else {
          bottom -= _getBottomInsets(margin);
        }
        double verticalBias = element.verticalBias;
        offsetY = top +
            (bottom - top - element.getMeasuredHeight(size)) * verticalBias;
      } else if (element.topConstraint != null) {
        double top;
        if (element.topConstraintType == _ConstraintType.toTop) {
          top = element.topConstraint!.getY();
        } else {
          top = element.topConstraint!.getBottom(size);
        }
        if (element.topConstraint!.isNotLaidOut()) {
          top += _getTopInsets(goneMargin);
        } else {
          top += _getTopInsets(margin);
        }
        offsetY = top;
      } else if (element.bottomConstraint != null) {
        double bottom;
        if (element.bottomConstraintType == _ConstraintType.toTop) {
          bottom = element.bottomConstraint!.getY();
        } else {
          bottom = element.bottomConstraint!.getBottom(size);
        }
        if (element.bottomConstraint!.isNotLaidOut()) {
          bottom -= _getBottomInsets(goneMargin);
        } else {
          bottom -= _getBottomInsets(margin);
        }
        offsetY = bottom - element.getMeasuredHeight(size);
      } else if (element.baselineConstraint != null) {
        if (element.baselineConstraintType == _ConstraintType.toTop) {
          offsetY = element.baselineConstraint!.getY() -
              element.getDistanceToBaseline(element.textBaseline, false);
        } else if (element.baselineConstraintType == _ConstraintType.toBottom) {
          offsetY = element.baselineConstraint!.getBottom(size) -
              element.getDistanceToBaseline(element.textBaseline, false);
        } else {
          offsetY = element.baselineConstraint!
                  .getDistanceToBaseline(element.textBaseline, true) -
              element.getDistanceToBaseline(element.textBaseline, false);
        }
        if (element.baselineConstraint!.isNotLaidOut()) {
          offsetY += _getTopInsets(goneMargin);
        } else {
          offsetY += _getTopInsets(margin);
        }
      } else {
        // it is not possible to execute this branch
      }

      element.offset = Offset(offsetX, offsetY);
    }
  }

  @override
  bool hitTestChildren(
    BoxHitTestResult result, {
    required Offset position,
  }) {
    for (final element in _paintingOrderList.reversed) {
      if (element.shouldNotPaint()) {
        continue;
      }

      Offset clickShift = Offset.zero;
      if (!element.translateConstraint) {
        clickShift = element.translate;
      }

      // expand the click area without changing the actual size
      Offset offsetPos = Offset(position.dx, position.dy);
      EdgeInsets clickPadding = element.clickPadding;
      if (clickPadding != EdgeInsets.zero) {
        double x = element.getX();
        x += clickShift.dx;
        double y = element.getY();
        y += clickShift.dy;
        double clickPaddingLeft = x - clickPadding.left;
        double clickPaddingTop = y - clickPadding.top;
        double clickPaddingRight =
            x + element.getMeasuredWidth(size) + clickPadding.right;
        double clickPaddingBottom =
            y + element.getMeasuredHeight(size) + clickPadding.bottom;
        double xClickPercent = (offsetPos.dx - clickPaddingLeft) /
            (clickPaddingRight - clickPaddingLeft);
        double yClickPercent = (offsetPos.dy - clickPaddingTop) /
            (clickPaddingBottom - clickPaddingTop);
        double realClickX = x + xClickPercent * element.getMeasuredWidth(size);
        double realClickY = y + yClickPercent * element.getMeasuredHeight(size);
        offsetPos = Offset(realClickX, realClickY);
      }

      bool isHit = result.addWithPaintOffset(
        offset: element.offset + clickShift,
        position: offsetPos,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return element.renderBox!.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
    }

    return false;
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset,
  ) {
    int startTime = 0;
    if (_releasePrintLayoutTime && kReleaseMode) {
      startTime = DateTime.now().millisecondsSinceEpoch;
    }
    assert(() {
      if (_debugPrintLayoutTime) {
        startTime = DateTime.now().millisecondsSinceEpoch;
      }
      return true;
    }());

    if (_needsReorderChildren) {
      _paintingOrderList.sort((left, right) {
        int result = left.zIndex - right.zIndex;
        if (result == 0) {
          result = left.index - right.index;
        }
        return result;
      });
      _needsReorderChildren = false;
    }

    for (final element in _paintingOrderList) {
      if (element.shouldNotPaint()) {
        continue;
      }

      Offset paintShift = Offset.zero;
      if (!element.translateConstraint) {
        paintShift = element.translate;
      }
      context.paintChild(
          element.renderBox!, element.offset + offset + paintShift);

      // draw child's click area
      assert(() {
        if (_debugShowClickArea) {
          Paint paint = Paint();
          paint.color = Colors.yellow.withAlpha(192);
          EdgeInsets? clickPadding = element.clickPadding;
          Rect rect = Rect.fromLTRB(
              element.getX() - _getLeftInsets(clickPadding),
              element.getY() - _getTopInsets(clickPadding),
              element.getX() +
                  element.getMeasuredWidth(size) +
                  _getRightInsets(clickPadding),
              element.getY() +
                  element.getMeasuredHeight(size) +
                  _getBottomInsets(clickPadding));
          rect = rect.shift(offset).shift(paintShift);
          context.canvas.drawRect(rect, paint);
          ui.ParagraphBuilder paragraphBuilder =
              ui.ParagraphBuilder(ui.ParagraphStyle(
            textAlign: TextAlign.center,
            fontSize: 12,
          ));
          paragraphBuilder.addText("CLICK AREA");
          ui.Paragraph paragraph = paragraphBuilder.build();
          paragraph.layout(ui.ParagraphConstraints(
            width: rect.width,
          ));
          context.canvas.drawParagraph(
              paragraph, rect.centerLeft + Offset(0, -paragraph.height / 2));
        }
        return true;
      }());

      // draw child's z index
      assert(() {
        if (_debugShowZIndex) {
          ui.ParagraphBuilder paragraphBuilder =
              ui.ParagraphBuilder(ui.ParagraphStyle(
            textAlign: TextAlign.center,
            fontSize: 10,
          ));
          paragraphBuilder.addText("z-index ${element.zIndex}");
          ui.Paragraph paragraph = paragraphBuilder.build();
          paragraph.layout(ui.ParagraphConstraints(
            width: element.getMeasuredWidth(size),
          ));
          context.canvas
              .drawParagraph(paragraph, element.offset + offset + paintShift);
        }
        return true;
      }());
    }

    if (_releasePrintLayoutTime && kReleaseMode) {
      print(
          'ConstraintLayout@${_debugName ?? hashCode} paint time = ${DateTime.now().millisecondsSinceEpoch - startTime} ms(current is release mode).');
    }
    assert(() {
      if (_debugPrintLayoutTime) {
        debugPrint(
            'ConstraintLayout@${_debugName ?? hashCode} paint time = ${DateTime.now().millisecondsSinceEpoch - startTime} ms(current is debug mode, release mode may take less time).');
      }
      return true;
    }());
  }
}

class _ConstrainedNode {
  late String nodeId;
  RenderBox? renderBox;
  _ConstrainedNode? leftConstraint;
  _ConstrainedNode? topConstraint;
  _ConstrainedNode? rightConstraint;
  _ConstrainedNode? bottomConstraint;
  _ConstrainedNode? baselineConstraint;
  _ConstraintType? leftConstraintType;
  _ConstraintType? topConstraintType;
  _ConstraintType? rightConstraintType;
  _ConstraintType? bottomConstraintType;
  _ConstraintType? baselineConstraintType;
  int depth = -1;
  late bool laidOut;
  late _ConstraintBoxData parentData;
  late int index;

  double get width => parentData.width!;

  double get height => parentData.height!;

  int get zIndex => parentData.zIndex ?? index;

  Offset get offset {
    if (translateConstraint) {
      return parentData.offset + translate;
    } else {
      return parentData.offset;
    }
  }

  Offset get translate => parentData.translate!;

  bool get translateConstraint => parentData.translateConstraint!;

  EdgeInsets get margin => parentData.margin!;

  EdgeInsets get goneMargin => parentData.goneMargin!;

  CLVisibility get visibility => parentData.visibility!;

  double get horizontalBias => parentData.horizontalBias!;

  double get verticalBias => parentData.verticalBias!;

  EdgeInsets get clickPadding => parentData.clickPadding!;

  TextBaseline get textBaseline => parentData.textBaseline!;

  set offset(Offset value) {
    parentData.offset = value;
  }

  bool isParent() {
    return nodeId == CL.parent;
  }

  bool shouldNotPaint() {
    return visibility == CL.gone ||
        visibility == CL.invisible ||
        isNotLaidOut();
  }

  bool isNotLaidOut() {
    if (isParent()) {
      return false;
    }
    return !laidOut;
  }

  double getX() {
    if (isParent()) {
      return 0;
    }
    return offset.dx;
  }

  double getY() {
    if (isParent()) {
      return 0;
    }
    return offset.dy;
  }

  double getRight(Size size) {
    if (isParent()) {
      return size.width;
    }
    return getX() + getMeasuredWidth(size);
  }

  double getBottom(Size size) {
    if (isParent()) {
      return size.height;
    }
    return getY() + getMeasuredHeight(size);
  }

  double getMeasuredWidth(Size size) {
    if (isParent()) {
      return size.width;
    }
    if (!laidOut) {
      return 0;
    }
    return renderBox!.size.width;
  }

  double getMeasuredHeight(Size size) {
    if (isParent()) {
      return size.height;
    }
    if (!laidOut) {
      return 0;
    }
    return renderBox!.size.height;
  }

  double getDistanceToBaseline(TextBaseline textBaseline, bool absolute) {
    if (isParent()) {
      return 0;
    }
    if (!laidOut) {
      return getY();
    }
    double? baseline;
    if (kDebugMode) {
      baseline = renderBox!.getDistanceToBaseline(textBaseline, onlyReal: true);
    } else {
      // ignore: invalid_use_of_protected_member
      baseline = renderBox!.computeDistanceToActualBaseline(textBaseline);
    }
    if (baseline == null) {
      baseline = getY();
    } else {
      if (absolute) {
        baseline += getY();
      }
    }
    return baseline;
  }

  int getDepthFor(_ConstrainedNode? constrainedNode) {
    if (constrainedNode == null) {
      return -1;
    }
    return constrainedNode.getDepth();
  }

  int getDepth() {
    if (depth < 0) {
      if (nodeId == CL.parent) {
        depth = 0;
      } else {
        List<int> list = [
          getDepthFor(leftConstraint),
          getDepthFor(topConstraint),
          getDepthFor(rightConstraint),
          getDepthFor(bottomConstraint),
          getDepthFor(baselineConstraint),
        ];
        list.sort((left, right) => left - right);
        depth = list.last + 1;
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
      if (leftConstraint != null) {
        if (leftConstraint!.isParent()) {
          map['leftConstraint'] = 'parent';
        } else {
          map['leftConstraint'] = leftConstraint!.toJson();
        }
        if (leftConstraintType == _ConstraintType.toLeft) {
          map['leftConstraintType'] = 'toLeft';
        } else {
          map['leftConstraintType'] = 'toRight';
        }
      }
      if (topConstraint != null) {
        if (topConstraint!.isParent()) {
          map['topConstraint'] = 'parent';
        } else {
          map['topConstraint'] = topConstraint!.toJson();
        }
        if (topConstraintType == _ConstraintType.toTop) {
          map['topConstraintType'] = 'toTop';
        } else {
          map['topConstraintType'] = 'toBottom';
        }
      }
      if (rightConstraint != null) {
        if (rightConstraint!.isParent()) {
          map['rightConstraint'] = 'parent';
        } else {
          map['rightConstraint'] = rightConstraint!.toJson();
        }
        if (rightConstraintType == _ConstraintType.toLeft) {
          map['rightConstraintType'] = 'toLeft';
        } else {
          map['rightConstraintType'] = 'toRight';
        }
      }
      if (bottomConstraint != null) {
        if (bottomConstraint!.isParent()) {
          map['bottomConstraint'] = 'parent';
        } else {
          map['bottomConstraint'] = bottomConstraint!.toJson();
        }
        if (bottomConstraintType == _ConstraintType.toTop) {
          map['bottomConstraintType'] = 'toTop';
        } else {
          map['bottomConstraintType'] = 'toBottom';
        }
      }
      if (baselineConstraint != null) {
        if (baselineConstraint!.isParent()) {
          map['baselineConstraint'] = 'parent';
        } else {
          map['baselineConstraint'] = baselineConstraint!.toJson();
        }
        if (baselineConstraintType == _ConstraintType.toTop) {
          map['baselineConstraintType'] = 'toTop';
        } else if (baselineConstraintType == _ConstraintType.toBottom) {
          map['baselineConstraintType'] = 'toBottom';
        } else {
          map['baselineConstraintType'] = 'toBaseline';
        }
      }
    }
    map['depth'] = getDepth();
    return map;
  }
}

class Guideline extends LeafRenderObjectWidget {
  final String id;
  final double? guidelineBegin;
  final double? guidelineEnd;
  final double? guidelinePercent;
  final bool horizontal;

  const Guideline({
    Key? key,
    required this.id,
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
