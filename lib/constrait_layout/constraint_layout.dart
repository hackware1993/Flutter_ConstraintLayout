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
/// exactly where the child elements are located.
///
/// features:
///   1. build flexible layouts with constraints
///   2. margin and goneMargin
///   3. clickPadding (quickly expand the click area of child elements without changing their actual size)
///   4. visibility control
///   5. constraint integrity hint
///   6. bias
///   7. z-index
///   8. percentage layout
///   9. guideline
///
///  not implement
///   . barrier
///   . constraints visualization
///   . chain
///
/// author: hackware
/// home page: https:///github.com/hackware1993
/// email: hackware1993@gmail.com
class ConstraintLayout extends MultiChildRenderObjectWidget {
  /// Constraints can be separated from widgets
  final List<Constraint>? childConstraints;

  /// TODO implement debug function
  final bool debugShowGuideline;
  final bool debugShowPreview;

  /// Already supported
  final bool debugShowClickArea;
  final bool debugPrintConstraints;
  final bool debugPrintLayoutTime;
  final bool debugCheckConstraints;
  final bool releasePrintLayoutTime;
  final String? debugName;
  final bool debugShowZIndex;

  ConstraintLayout({
    Key? key,
    this.childConstraints,
    required List<Widget> children,
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
    assert(_debugEnsureNotEmptyString('debugName', debugName));
    return _ConstraintRenderBox()
      .._childConstraints = childConstraints
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
    assert(_debugEnsureNotEmptyString('debugName', debugName));
    (renderObject as _ConstraintRenderBox)
      ..childConstraints = childConstraints
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

List<Constrained> horizontalChain({
  _Align? left,
  _Align? right,
  ConstraintId? centerHorizontalTo,
  required List<Constrained> hChainList,
}) {
  assert(hChainList.length > 1,
      'The number of child elements in the chain must be > 1.');
  return [];
}

List<Constrained> verticalChain({
  _Align? top,
  _Align? bottom,
  ConstraintId? centerVerticalTo,
  required List<Constrained> vChainList,
}) {
  assert(vChainList.length > 1,
      'The number of child elements in the chain must be > 1.');
  return [];
}

/// Wrapper constraints design for simplicity of use, it will eventually convert to base constraints.
const Object _wrapperConstraint = Object();
const Object _baseConstraint = Object();

extension WidgetsExt on Widget {
  Constrained applyConstraint({
    Key? key,
    ConstraintId? id,
    required double width,
    required double height,
    @_baseConstraint _Align? left,
    @_baseConstraint _Align? top,
    @_baseConstraint _Align? right,
    @_baseConstraint _Align? bottom,
    @_baseConstraint _Align? baseline,
    EdgeInsets clickPadding = EdgeInsets.zero,
    CLVisibility visibility = visible,
    EdgeInsets margin = EdgeInsets.zero,
    EdgeInsets goneMargin = EdgeInsets.zero,
    TextBaseline textBaseline = TextBaseline.alphabetic,
    int? zIndex, // default is child index
    Offset translate = Offset.zero,
    bool translateConstraint = false,
    double widthPercent = 1,
    double heightPercent = 1,
    PercentageAnchor widthPercentageAnchor = PercentageAnchor.constraint,
    PercentageAnchor heightPercentageAnchor = PercentageAnchor.constraint,
    double horizontalBias = 0.5,
    double verticalBias = 0.5,
    @_wrapperConstraint ConstraintId? topLeftTo,
    @_wrapperConstraint ConstraintId? topCenterTo,
    @_wrapperConstraint ConstraintId? topRightTo,
    @_wrapperConstraint ConstraintId? centerLeftTo,
    @_wrapperConstraint ConstraintId? centerTo,
    @_wrapperConstraint ConstraintId? centerRightTo,
    @_wrapperConstraint ConstraintId? bottomLeftTo,
    @_wrapperConstraint ConstraintId? bottomCenterTo,
    @_wrapperConstraint ConstraintId? bottomRightTo,
    @_wrapperConstraint ConstraintId? centerHorizontalTo,
    @_wrapperConstraint ConstraintId? centerVerticalTo,
    OnLayoutCallback? callback,
  }) {
    return Constrained(
      key: key,
      constraint: Constraint(
        id: id,
        width: width,
        height: height,
        left: left,
        top: top,
        right: right,
        bottom: bottom,
        baseline: baseline,
        clickPadding: clickPadding,
        visibility: visibility,
        margin: margin,
        goneMargin: goneMargin,
        textBaseline: textBaseline,
        zIndex: zIndex,
        translate: translate,
        translateConstraint: translateConstraint,
        widthPercent: widthPercent,
        heightPercent: heightPercent,
        widthPercentageAnchor: widthPercentageAnchor,
        heightPercentageAnchor: heightPercentageAnchor,
        horizontalBias: horizontalBias,
        verticalBias: verticalBias,
        topLeftTo: topLeftTo,
        topCenterTo: topCenterTo,
        topRightTo: topRightTo,
        centerLeftTo: centerLeftTo,
        centerTo: centerTo,
        centerRightTo: centerRightTo,
        bottomLeftTo: bottomLeftTo,
        bottomCenterTo: bottomCenterTo,
        bottomRightTo: bottomRightTo,
        centerHorizontalTo: centerHorizontalTo,
        centerVerticalTo: centerVerticalTo,
        callback: callback,
      ),
      child: this,
    );
  }

  Constrained apply({
    Key? key,
    required Constraint constraint,
  }) {
    return Constrained(
      key: key,
      constraint: constraint,
      child: this,
    );
  }

  UnConstrained applyConstraintId({
    Key? key,
    required ConstraintId id,
  }) {
    return UnConstrained(
      key: key,
      id: id,
      child: this,
    );
  }
}

bool _debugEnsureNotEmptyString(String name, String? value) {
  if (value != null && value.trim().isEmpty) {
    throw ConstraintLayoutException(
        '$name can be null, but not an empty string.');
  }
  return true;
}

bool _debugEnsurePercent(String name, double? percent) {
  if (percent == null || percent < 0 || percent > 1) {
    throw ConstraintLayoutException('$name is between [0-1].');
  }
  return true;
}

ConstraintId parent = ConstraintId();
const double matchConstraint = -3.1415926;
const double matchParent = -2.7182818;
const double wrapContent = -0.6180339;
const CLVisibility visible = CLVisibility.visible;
const CLVisibility gone = CLVisibility.gone;
const CLVisibility invisible = CLVisibility.invisible;

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

enum PercentageAnchor {
  constraint,
  parent,
}

class ConstraintId {
  String? name;

  ConstraintId({this.name}) {
    left.id = this;
    top.id = this;
    right.id = this;
    bottom.id = this;
    baseline.id = this;
  }

  _Align left = _Align(null, _AlignType.left);

  _Align top = _Align(null, _AlignType.top);

  _Align right = _Align(null, _AlignType.right);

  _Align bottom = _Align(null, _AlignType.bottom);

  _Align baseline = _Align(null, _AlignType.baseline);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! ConstraintId) {
      return false;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    if ((other).name == null && name == null) {
      return false;
    }
    return (other).name == name;
  }

  @override
  int get hashCode {
    if (name == null) {
      return super.hashCode;
    } else {
      return name.hashCode;
    }
  }

  @override
  String toString() {
    return 'ConstraintId{name: $name}';
  }
}

class _Align {
  ConstraintId? id;
  _AlignType type;

  _Align(this.id, this.type);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Align &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type;

  @override
  int get hashCode => id.hashCode ^ type.hashCode;
}

typedef OnLayoutCallback = void Function(RenderObject renderObject, Rect rect);

class Constraint {
  /// id can be null, but not an empty string
  final ConstraintId? id;

  /// 'wrap_content'、'match_parent'、'match_constraint'、'48, etc'
  /// 'match_parent' will be converted to the base constraints
  final double width;
  final double height;

  /// Expand the click area without changing the actual size
  final EdgeInsets clickPadding;

  final CLVisibility visibility;

  /// both margin and goneMargin can be negative
  final EdgeInsets margin;
  final EdgeInsets goneMargin;

  /// These are the base constraints constraint on sibling id or parent
  @_baseConstraint
  final _Align? left;
  @_baseConstraint
  final _Align? top;
  @_baseConstraint
  final _Align? right;
  @_baseConstraint
  final _Align? bottom;
  @_baseConstraint
  final _Align? baseline;

  /// When setting baseline alignment, height must be wrap_content or fixed size, other vertical constraints will be illegal.
  /// Warning: Due to a bug in the flutter framework, baseline alignment may not take effect in debug mode
  /// See https:///github.com/flutter/flutter/issues/101179

  final TextBaseline textBaseline;
  final int? zIndex;
  final Offset translate;

  /// When translate, whether to translate elements that depend on itself
  final bool translateConstraint;

  /// Only takes effect when width is matchConstraint
  final double widthPercent;

  /// Only takes effect when height is matchConstraint
  final double heightPercent;

  final PercentageAnchor widthPercentageAnchor;

  final PercentageAnchor heightPercentageAnchor;

  /// Only takes effect if both left and right constraints exist
  final double horizontalBias;

  /// Only takes effect if both top and bottom constraints exist
  final double verticalBias;

  /// These are wrapper constraints for simplicity of use, which will eventually convert to base constraints.
  @_wrapperConstraint
  final ConstraintId? topLeftTo;
  @_wrapperConstraint
  final ConstraintId? topCenterTo;
  @_wrapperConstraint
  final ConstraintId? topRightTo;
  @_wrapperConstraint
  final ConstraintId? centerLeftTo;
  @_wrapperConstraint
  final ConstraintId? centerTo;
  @_wrapperConstraint
  final ConstraintId? centerRightTo;
  @_wrapperConstraint
  final ConstraintId? bottomLeftTo;
  @_wrapperConstraint
  final ConstraintId? bottomCenterTo;
  @_wrapperConstraint
  final ConstraintId? bottomRightTo;
  @_wrapperConstraint
  final ConstraintId? centerHorizontalTo;
  @_wrapperConstraint
  final ConstraintId? centerVerticalTo;

  final OnLayoutCallback? callback;

  const Constraint({
    this.id,
    required this.width,
    required this.height,
    @_baseConstraint this.left,
    @_baseConstraint this.top,
    @_baseConstraint this.right,
    @_baseConstraint this.bottom,
    @_baseConstraint this.baseline,
    this.clickPadding = EdgeInsets.zero,
    this.visibility = visible,
    this.margin = EdgeInsets.zero,
    this.goneMargin = EdgeInsets.zero,
    this.textBaseline = TextBaseline.alphabetic,
    this.zIndex, // default is child index
    this.translate = Offset.zero,
    this.translateConstraint = false,
    this.widthPercent = 1,
    this.heightPercent = 1,
    this.widthPercentageAnchor = PercentageAnchor.constraint,
    this.heightPercentageAnchor = PercentageAnchor.constraint,
    this.horizontalBias = 0.5,
    this.verticalBias = 0.5,
    @_wrapperConstraint this.topLeftTo,
    @_wrapperConstraint this.topCenterTo,
    @_wrapperConstraint this.topRightTo,
    @_wrapperConstraint this.centerLeftTo,
    @_wrapperConstraint this.centerTo,
    @_wrapperConstraint this.centerRightTo,
    @_wrapperConstraint this.bottomLeftTo,
    @_wrapperConstraint this.bottomCenterTo,
    @_wrapperConstraint this.bottomRightTo,
    @_wrapperConstraint this.centerHorizontalTo,
    @_wrapperConstraint this.centerVerticalTo,
    this.callback,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Constraint &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          width == other.width &&
          height == other.height &&
          clickPadding == other.clickPadding &&
          visibility == other.visibility &&
          margin == other.margin &&
          goneMargin == other.goneMargin &&
          left == other.left &&
          top == other.top &&
          right == other.right &&
          bottom == other.bottom &&
          baseline == other.baseline &&
          textBaseline == other.textBaseline &&
          zIndex == other.zIndex &&
          translate == other.translate &&
          translateConstraint == other.translateConstraint &&
          widthPercent == other.widthPercent &&
          heightPercent == other.heightPercent &&
          widthPercentageAnchor == other.widthPercentageAnchor &&
          heightPercentageAnchor == other.heightPercentageAnchor &&
          horizontalBias == other.horizontalBias &&
          verticalBias == other.verticalBias &&
          topLeftTo == other.topLeftTo &&
          topCenterTo == other.topCenterTo &&
          topRightTo == other.topRightTo &&
          centerLeftTo == other.centerLeftTo &&
          centerTo == other.centerTo &&
          centerRightTo == other.centerRightTo &&
          bottomLeftTo == other.bottomLeftTo &&
          bottomCenterTo == other.bottomCenterTo &&
          bottomRightTo == other.bottomRightTo &&
          centerHorizontalTo == other.centerHorizontalTo &&
          centerVerticalTo == other.centerVerticalTo &&
          callback == other.callback;

  @override
  int get hashCode =>
      id.hashCode ^
      width.hashCode ^
      height.hashCode ^
      clickPadding.hashCode ^
      visibility.hashCode ^
      margin.hashCode ^
      goneMargin.hashCode ^
      left.hashCode ^
      top.hashCode ^
      right.hashCode ^
      bottom.hashCode ^
      baseline.hashCode ^
      textBaseline.hashCode ^
      zIndex.hashCode ^
      translate.hashCode ^
      translateConstraint.hashCode ^
      widthPercent.hashCode ^
      heightPercent.hashCode ^
      widthPercentageAnchor.hashCode ^
      heightPercentageAnchor.hashCode ^
      horizontalBias.hashCode ^
      verticalBias.hashCode ^
      topLeftTo.hashCode ^
      topCenterTo.hashCode ^
      topRightTo.hashCode ^
      centerLeftTo.hashCode ^
      centerTo.hashCode ^
      centerRightTo.hashCode ^
      bottomLeftTo.hashCode ^
      bottomCenterTo.hashCode ^
      bottomRightTo.hashCode ^
      centerHorizontalTo.hashCode ^
      centerVerticalTo.hashCode ^
      callback.hashCode;

  bool checkSize(double size) {
    if (size == matchParent || size == wrapContent || size == matchConstraint) {
      return true;
    } else {
      if (size == double.infinity || size < 0) {
        throw ConstraintLayoutException(
            'width or height can not be infinity or negative.');
      }
      return true;
    }
  }

  bool validate() {
    assert(checkSize(width));
    assert(checkSize(height));
    assert(left == null ||
        (left!.type == _AlignType.left || left!.type == _AlignType.right));
    assert(top == null ||
        (top!.type == _AlignType.top || top!.type == _AlignType.bottom));
    assert(right == null ||
        (right!.type == _AlignType.left || right!.type == _AlignType.right));
    assert(bottom == null ||
        (bottom!.type == _AlignType.top || bottom!.type == _AlignType.bottom));
    assert(baseline == null ||
        (baseline!.type == _AlignType.top ||
            baseline!.type == _AlignType.bottom ||
            baseline!.type == _AlignType.baseline));
    assert(_debugEnsurePercent('widthPercent', widthPercent));
    assert(_debugEnsurePercent('heightPercent', heightPercent));
    assert(_debugEnsurePercent('horizontalBias', horizontalBias));
    assert(_debugEnsurePercent('verticalBias', verticalBias));
    return true;
  }

  void applyTo(RenderObject renderObject) {
    _Align? left = this.left;
    _Align? top = this.top;
    _Align? right = this.right;
    _Align? bottom = this.bottom;
    _Align? baseline = this.baseline;

    /// Convert wrapper constraints first

    if (topLeftTo != null) {
      left = topLeftTo!.left;
      top = topLeftTo!.top;
    }

    if (topCenterTo != null) {
      left = topCenterTo!.left;
      right = topCenterTo!.right;
      top = topCenterTo!.top;
    }

    if (topRightTo != null) {
      top = topRightTo!.top;
      right = topRightTo!.right;
    }

    if (centerLeftTo != null) {
      left = centerLeftTo!.left;
      top = centerLeftTo!.top;
      bottom = centerLeftTo!.bottom;
    }

    if (centerTo != null) {
      left = centerTo!.left;
      right = centerTo!.right;
      top = centerTo!.top;
      bottom = centerTo!.bottom;
    }

    if (centerRightTo != null) {
      right = centerRightTo!.right;
      top = centerRightTo!.top;
      bottom = centerRightTo!.bottom;
    }

    if (bottomLeftTo != null) {
      left = bottomLeftTo!.left;
      bottom = bottomLeftTo!.bottom;
    }

    if (bottomCenterTo != null) {
      left = bottomCenterTo!.left;
      right = bottomCenterTo!.right;
      bottom = bottomCenterTo!.bottom;
    }

    if (bottomRightTo != null) {
      right = bottomRightTo!.right;
      bottom = bottomRightTo!.bottom;
    }

    if (centerHorizontalTo != null) {
      left = centerHorizontalTo!.left;
      right = centerHorizontalTo!.right;
    }

    if (centerVerticalTo != null) {
      top = centerVerticalTo!.top;
      bottom = centerVerticalTo!.bottom;
    }

    /// Convert wrapper constraints finish

    /// Constraint priority: match_parent > wrapper constraints > base constraints
    if (width == matchParent) {
      assert(() {
        if (left != null || right != null) {
          throw ConstraintLayoutException(
              'When setting the width to match_parent for child with id $id, there is no need to set left or right constraint.');
        }
        return true;
      }());
      left = parent.left;
      right = parent.right;
    }

    if (height == matchParent) {
      assert(() {
        if (top != null || bottom != null || baseline != null) {
          throw ConstraintLayoutException(
              'When setting the height to match_parent for child with id $id, there is no need to set top or bottom or baseline constraint.');
        }
        return true;
      }());
      top = parent.top;
      bottom = parent.bottom;
      baseline = null;
    }

    _ConstraintBoxData parentData =
        renderObject.parentData! as _ConstraintBoxData;
    bool needsLayout = false;
    bool needsPaint = false;
    bool needsReorderChildren = false;

    if (parentData.id != id) {
      parentData.id = id;
      needsLayout = true;
    }

    if (parentData.width != width) {
      parentData.width = width;
      needsLayout = true;
    }

    if (parentData.height != height) {
      parentData.height = height;
      needsLayout = true;
    }

    parentData.clickPadding = clickPadding;

    if (parentData.visibility != visibility) {
      if (parentData.visibility == gone || visibility == gone) {
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

    if (parentData.left != left) {
      parentData.left = left;
      needsLayout = true;
    }

    if (parentData.right != right) {
      parentData.right = right;
      needsLayout = true;
    }

    if (parentData.top != top) {
      parentData.top = top;
      needsLayout = true;
    }

    if (parentData.bottom != bottom) {
      parentData.bottom = bottom;
      needsLayout = true;
    }

    if (parentData.baseline != baseline) {
      parentData.baseline = baseline;
      needsLayout = true;
    }

    if (parentData.textBaseline != textBaseline) {
      parentData.textBaseline = textBaseline;
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

    if (parentData.widthPercent != widthPercent) {
      parentData.widthPercent = widthPercent;
      needsLayout = true;
    }

    if (parentData.heightPercent != heightPercent) {
      parentData.heightPercent = heightPercent;
      needsLayout = true;
    }

    if (parentData.widthPercentageAnchor != widthPercentageAnchor) {
      parentData.widthPercentageAnchor = widthPercentageAnchor;
      needsLayout = true;
    }

    if (parentData.heightPercentageAnchor != heightPercentageAnchor) {
      parentData.heightPercentageAnchor = heightPercentageAnchor;
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

    parentData.callback = callback;

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
}

enum _AlignType {
  left,
  right,
  top,
  bottom,
  baseline,
}

class _ConstraintBoxData extends ContainerBoxParentData<RenderBox> {
  ConstraintId? id;
  double? width;
  double? height;
  EdgeInsets? clickPadding;
  CLVisibility? visibility;
  EdgeInsets? margin;
  EdgeInsets? goneMargin;
  _Align? left;
  _Align? top;
  _Align? right;
  _Align? bottom;
  _Align? baseline;
  TextBaseline? textBaseline;
  int? zIndex;
  Offset? translate;
  bool? translateConstraint;
  double? widthPercent;
  double? heightPercent;
  PercentageAnchor? widthPercentageAnchor;
  PercentageAnchor? heightPercentageAnchor;
  double? horizontalBias;
  double? verticalBias;
  OnLayoutCallback? callback;
}

class Constrained extends ParentDataWidget<_ConstraintBoxData> {
  final Constraint constraint;

  const Constrained({
    Key? key,
    required Widget child,
    required this.constraint,
  })  : assert(child is! Constrained,
            'Constrained can not be wrapped with Constrained.'),
        assert(child is! UnConstrained,
            'UnConstrained can not be wrapped with Constrained.'),
        assert(child is! Guideline,
            'Guideline can not be wrapped with Constrained.'),
        assert(
            child is! Barrier, 'Barrier can not be wrapped with Constrained.'),
        super(
          key: key,
          child: child,
        );

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parent is _ConstraintRenderBox);
    assert(constraint.validate());
    constraint.applyTo(renderObject);
  }

  @override
  Type get debugTypicalAncestorWidgetClass {
    return ConstraintLayout;
  }
}

class UnConstrained extends ParentDataWidget<_ConstraintBoxData> {
  final ConstraintId id;

  const UnConstrained({
    Key? key,
    required this.id,
    required Widget child,
  })  : assert(child is! UnConstrained,
            'UnConstrained can not be wrapped with UnConstrained.'),
        assert(child is! Constrained,
            'Constrained can not be wrapped with UnConstrained.'),
        assert(child is! Guideline,
            'Guideline can not be wrapped with UnConstrained.'),
        assert(child is! Barrier,
            'Barrier can not be wrapped with UnConstrained.'),
        super(
          key: key,
          child: child,
        );

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parent is _ConstraintRenderBox);
    List<Constraint>? childConstraints =
        (renderObject.parent as _ConstraintRenderBox)._childConstraints;
    assert(childConstraints != null,
        'Can not find Constraint for child with id $id.');
    Iterable<Constraint> constraintIterable =
        childConstraints!.where((element) => element.id == id);
    assert(constraintIterable.isNotEmpty,
        'Can not find Constraint for child with id $id.');
    assert(constraintIterable.length == 1, 'Duplicate id in childConstraints.');
    Constraint constraint = constraintIterable.first;
    assert(constraint.validate());
    constraint.applyTo(renderObject);
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
  List<Constraint>? _childConstraints;
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
  final Map<ConstraintId, _ConstrainedNode> _tempConstrainedNodes = HashMap();
  late List<_ConstrainedNode> _paintingOrderList;

  set childConstraints(List<Constraint>? value) {
    if (_childConstraints != value) {
      _childConstraints = value;
      markNeedsLayout();
    }
  }

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

      /// Do not do special treatment for built-in components, treat them as ordinary
      /// child elements, but have a size of 0 and are gone
      if (child is _InternalBox) {
        (child).updateParentData();
      }
    }
  }

  /// Make sure the id of the child elements is not repeated
  /// Make sure every id that is relied on is valid
  void _debugCheckIds() {
    RenderBox? child = firstChild;
    Set<ConstraintId> idSet = HashSet();
    idSet.add(parent);
    Set<ConstraintId> constraintsIdSet = HashSet();
    while (child != null) {
      _ConstraintBoxData childParentData =
          child.parentData as _ConstraintBoxData;

      assert(() {
        if (_debugCheckConstraints) {
          if (childParentData.width == null) {
            throw ConstraintLayoutException(
                'Must provide Constraint for child elements, try use Constrained widget.');
          }
        }
        return true;
      }());

      if (childParentData.id != null) {
        if (!idSet.add(childParentData.id!)) {
          throw ConstraintLayoutException('Duplicate id in ConstraintLayout.');
        }
      }
      if (childParentData.left != null) {
        constraintsIdSet.add(childParentData.left!.id!);
      }
      if (childParentData.top != null) {
        constraintsIdSet.add(childParentData.top!.id!);
      }
      if (childParentData.right != null) {
        constraintsIdSet.add(childParentData.right!.id!);
      }
      if (childParentData.bottom != null) {
        constraintsIdSet.add(childParentData.bottom!.id!);
      }
      if (childParentData.baseline != null) {
        constraintsIdSet.add(childParentData.baseline!.id!);
      }
      child = childParentData.nextSibling;
    }
    Set<ConstraintId> illegalIdSet = constraintsIdSet.difference(idSet);
    if (illegalIdSet.isNotEmpty) {
      throw ConstraintLayoutException(
          'These ids $illegalIdSet are not yet defined.');
    }
  }

  /// There should be no loop constraints
  void _debugCheckLoopConstraints() {
    for (final element in _constrainedNodes.values) {
      try {
        element.getDepth();
      } on StackOverflowError catch (_) {
        throw ConstraintLayoutException(
            'There are some loop constraints, please check the code. For layout performance considerations, constraints are always one-way, and there should be no two child elements directly or indirectly restrain each other. Each constraint should describe exactly where the child elements are located. Use Guideline to break loop constraints.');
      }
    }
  }

  /// Each child element must have complete constraints both horizontally and vertically
  void _debugCheckConstraintsIntegrity() {
    for (final element in _constrainedNodes.values) {
      /// Check constraint integrity in the horizontal direction
      if (element.width == wrapContent || element.width >= 0) {
        if (element.leftConstraint == null && element.rightConstraint == null) {
          throw ConstraintLayoutException(
              'Need to set a left or right constraint for ${element.nodeId}.');
        }
      } else if (element.width == matchConstraint) {
        if (element.leftConstraint == null || element.rightConstraint == null) {
          throw ConstraintLayoutException(
              'Need to set left and right constraints for ${element.nodeId}.');
        }
      }

      /// Check constraint integrity in the vertical direction
      if (element.height == wrapContent || element.height >= 0) {
        int verticalConstraintCount = (element.topConstraint == null ? 0 : 1) +
            (element.bottomConstraint == null ? 0 : 1) +
            (element.baselineConstraint == null ? 0 : 10);
        if (verticalConstraintCount == 0) {
          throw ConstraintLayoutException(
              'Need to set a top or bottom or baseline constraint for ${element.nodeId}.');
        } else if (verticalConstraintCount > 10) {
          throw ConstraintLayoutException(
              'When the baseline constraint is set, the top or bottom constraint can not be set for ${element.nodeId}.');
        }
      } else if (element.height == matchConstraint) {
        if (element.baselineConstraint != null) {
          throw ConstraintLayoutException(
              'When setting a baseline constraint for ${element.nodeId}, its height must be fixed or wrap_content.');
        }
        if (element.topConstraint == null || element.bottomConstraint == null) {
          throw ConstraintLayoutException(
              'Need to set both top and bottom constraints for ${element.nodeId}.');
        }
      } else {
        /// match_parent
        if (element.baselineConstraint != null) {
          throw ConstraintLayoutException(
              'When setting a baseline constraint for ${element.nodeId}, its height must be fixed or wrap_content.');
        }
      }
    }
  }

  _ConstrainedNode _getConstrainedNodeForChild(
    RenderBox? child,
    ConstraintId id,
  ) {
    _ConstrainedNode node = _tempConstrainedNodes.putIfAbsent(
        id, () => _ConstrainedNode()..nodeId = id);
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

      _ConstrainedNode currentNode = _getConstrainedNodeForChild(
          child,
          childParentData.id ??
              ConstraintId(name: 'child[$childIndex]@${child.hashCode}'));
      currentNode.parentData = childParentData;
      currentNode.index = childIndex;

      if (childParentData.left != null) {
        currentNode.leftConstraint =
            _getConstrainedNodeForChild(null, childParentData.left!.id!);
        currentNode.leftAlignType = childParentData.left!.type;
      }

      if (childParentData.top != null) {
        currentNode.topConstraint =
            _getConstrainedNodeForChild(null, childParentData.top!.id!);
        currentNode.topAlignType = childParentData.top!.type;
      }

      if (childParentData.right != null) {
        currentNode.rightConstraint =
            _getConstrainedNodeForChild(null, childParentData.right!.id!);
        currentNode.rightAlignType = childParentData.right!.type;
      }

      if (childParentData.bottom != null) {
        currentNode.bottomConstraint =
            _getConstrainedNodeForChild(null, childParentData.bottom!.id!);
        currentNode.bottomAlignType = childParentData.bottom!.type;
      }

      if (childParentData.baseline != null) {
        currentNode.baselineConstraint =
            _getConstrainedNodeForChild(null, childParentData.baseline!.id!);
        currentNode.baselineAlignType = childParentData.baseline!.type;
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

    /// Always fill the parent layout
    /// TODO will support wrap_content in the future
    size = constraints.constrain(const Size(double.infinity, double.infinity));

    assert(() {
      if (_debugCheckConstraints) {
        _debugCheckIds();
      }
      return true;
    }());

    /// Traverse once, building the constrained node tree for each child element
    _buildConstrainedNodeTrees();

    assert(() {
      if (_debugCheckConstraints) {
        _debugCheckConstraintsIntegrity();
        _debugCheckLoopConstraints();
      }
      return true;
    }());

    /// Sort by the depth of constraint from shallow to deep, the lowest depth is 0, representing parent
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
      /// Print constraints
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
      EdgeInsets margin = element.margin;
      EdgeInsets goneMargin = element.goneMargin;

      /// Calculate child width
      double minWidth = 0;
      double maxWidth = double.infinity;
      double minHeight = 0;
      double maxHeight = double.infinity;
      if (element.visibility == gone) {
        minWidth = 0;
        maxWidth = 0;
        minWidth = 0;
        maxHeight = 0;
      } else {
        double width = element.width;
        if (width == wrapContent) {
          maxWidth = size.width;
        } else if (width == matchParent) {
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
        } else if (width == matchConstraint) {
          if (element.widthPercentageAnchor == PercentageAnchor.constraint) {
            double left;
            if (element.leftAlignType == _AlignType.left) {
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
            if (element.rightAlignType == _AlignType.left) {
              right = element.rightConstraint!.getX();
            } else {
              right = element.rightConstraint!.getRight(size);
            }
            if (element.rightConstraint!.isNotLaidOut()) {
              right -= _getRightInsets(goneMargin);
            } else {
              right -= _getRightInsets(margin);
            }
            minWidth = (right - left) * element.widthPercent;
          } else {
            minWidth = (size.width - _getHorizontalInsets(margin)) *
                element.widthPercent;
          }
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

        /// Calculate child height
        double height = element.height;
        if (height == wrapContent) {
          maxHeight = size.height;
        } else if (height == matchParent) {
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
        } else if (height == matchConstraint) {
          if (element.heightPercentageAnchor == PercentageAnchor.constraint) {
            double top;
            if (element.topAlignType == _AlignType.top) {
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
            if (element.bottomAlignType == _AlignType.top) {
              bottom = element.bottomConstraint!.getY();
            } else {
              bottom = element.bottomConstraint!.getBottom(size);
            }
            if (element.bottomConstraint!.isNotLaidOut()) {
              bottom -= _getBottomInsets(goneMargin);
            } else {
              bottom -= _getBottomInsets(margin);
            }
            minHeight = (bottom - top) * element.heightPercent;
          } else {
            minHeight = (size.height - _getVerticalInsets(margin)) *
                element.heightPercent;
          }
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

      /// Measure
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

      /// Calculate child x offset
      double offsetX = 0;
      if (element.leftConstraint != null && element.rightConstraint != null) {
        double left;
        if (element.leftAlignType == _AlignType.left) {
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
        if (element.rightAlignType == _AlignType.left) {
          right = element.rightConstraint!.getX();
        } else {
          right = element.rightConstraint!.getRight(size);
        }
        if (element.rightConstraint!.isNotLaidOut()) {
          right -= _getRightInsets(goneMargin);
        } else {
          right -= _getRightInsets(margin);
        }
        offsetX = left +
            (right - left - element.getMeasuredWidth(size)) *
                element.horizontalBias;
      } else if (element.leftConstraint != null) {
        double left;
        if (element.leftAlignType == _AlignType.left) {
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
        if (element.rightAlignType == _AlignType.left) {
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
        /// It is not possible to execute this branch
      }

      /// Calculate child y offset
      double offsetY = 0;
      if (element.topConstraint != null && element.bottomConstraint != null) {
        double top;
        if (element.topAlignType == _AlignType.top) {
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
        if (element.bottomAlignType == _AlignType.top) {
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
        if (element.topAlignType == _AlignType.top) {
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
        if (element.bottomAlignType == _AlignType.top) {
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
        if (element.baselineAlignType == _AlignType.top) {
          offsetY = element.baselineConstraint!.getY() -
              element.getDistanceToBaseline(element.textBaseline, false);
        } else if (element.baselineAlignType == _AlignType.bottom) {
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
        /// It is not possible to execute this branch
      }

      element.offset = Offset(offsetX, offsetY);
      if (element.callback != null) {
        element.callback!.call(
            element.renderBox!,
            Rect.fromLTWH(offsetX, offsetY, element.getMeasuredWidth(size),
                element.getMeasuredHeight(size)));
      }
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

      /// Expand the click area without changing the actual size
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

      /// Draw child's click area
      assert(() {
        if (_debugShowClickArea) {
          Paint paint = Paint();
          paint.color = Colors.yellow.withAlpha(192);
          EdgeInsets clickPadding = element.clickPadding;
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

      /// Draw child's z index
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
  late ConstraintId nodeId;
  RenderBox? renderBox;
  _ConstrainedNode? leftConstraint;
  _ConstrainedNode? topConstraint;
  _ConstrainedNode? rightConstraint;
  _ConstrainedNode? bottomConstraint;
  _ConstrainedNode? baselineConstraint;
  _AlignType? leftAlignType;
  _AlignType? topAlignType;
  _AlignType? rightAlignType;
  _AlignType? bottomAlignType;
  _AlignType? baselineAlignType;
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

  double get widthPercent => parentData.widthPercent!;

  double get heightPercent => parentData.heightPercent!;

  PercentageAnchor get widthPercentageAnchor =>
      parentData.widthPercentageAnchor!;

  PercentageAnchor get heightPercentageAnchor =>
      parentData.heightPercentageAnchor!;

  OnLayoutCallback? get callback => parentData.callback;

  set offset(Offset value) {
    parentData.offset = value;
  }

  bool isParent() {
    return nodeId == parent;
  }

  bool shouldNotPaint() {
    return visibility == gone || visibility == invisible || isNotLaidOut();
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
      /// ignore: invalid_use_of_protected_member
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
      if (nodeId == parent) {
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

  /// For debug message print
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (nodeId == parent) {
      map['nodeId'] = 'parent';
    } else {
      map['nodeId'] = nodeId;
      if (leftConstraint != null) {
        if (leftAlignType == _AlignType.left) {
          map['leftAlignType'] = 'toLeft';
        } else {
          map['leftAlignType'] = 'toRight';
        }
        if (leftConstraint!.isParent()) {
          map['leftConstraint'] = 'parent';
        } else {
          map['leftConstraint'] = leftConstraint!.toJson();
        }
      }
      if (topConstraint != null) {
        if (topAlignType == _AlignType.top) {
          map['topAlignType'] = 'toTop';
        } else {
          map['topAlignType'] = 'toBottom';
        }
        if (topConstraint!.isParent()) {
          map['topConstraint'] = 'parent';
        } else {
          map['topConstraint'] = topConstraint!.toJson();
        }
      }
      if (rightConstraint != null) {
        if (rightAlignType == _AlignType.left) {
          map['rightAlignType'] = 'toLeft';
        } else {
          map['rightAlignType'] = 'toRight';
        }
        if (rightConstraint!.isParent()) {
          map['rightConstraint'] = 'parent';
        } else {
          map['rightConstraint'] = rightConstraint!.toJson();
        }
      }
      if (bottomConstraint != null) {
        if (bottomAlignType == _AlignType.top) {
          map['bottomAlignType'] = 'toTop';
        } else {
          map['bottomAlignType'] = 'toBottom';
        }
        if (bottomConstraint!.isParent()) {
          map['bottomConstraint'] = 'parent';
        } else {
          map['bottomConstraint'] = bottomConstraint!.toJson();
        }
      }
      if (baselineConstraint != null) {
        if (baselineAlignType == _AlignType.top) {
          map['baselineAlignType'] = 'toTop';
        } else if (baselineAlignType == _AlignType.bottom) {
          map['baselineAlignType'] = 'toBottom';
        } else {
          map['baselineAlignType'] = 'toBaseline';
        }
        if (baselineConstraint!.isParent()) {
          map['baselineConstraint'] = 'parent';
        } else {
          map['baselineConstraint'] = baselineConstraint!.toJson();
        }
      }
    }
    map['depth'] = getDepth();
    return map;
  }
}

class _InternalBox extends RenderBox {
  @protected
  @mustCallSuper
  void updateParentData() {
    _ConstraintBoxData constraintBoxData = parentData as _ConstraintBoxData;
    constraintBoxData.visibility = gone;
    constraintBoxData.translate = Offset.zero;
    constraintBoxData.translateConstraint = false;
    constraintBoxData.goneMargin = EdgeInsets.zero;
    constraintBoxData.horizontalBias = 0.5;
    constraintBoxData.verticalBias = 0.5;
    constraintBoxData.clickPadding = EdgeInsets.zero;
    constraintBoxData.textBaseline = TextBaseline.alphabetic;
  }

  @override
  void performLayout() {
    size = Size.zero;
  }
}

class Guideline extends LeafRenderObjectWidget {
  final ConstraintId id;
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

  bool _checkParam() {
    int guideConstraintCount = (guidelineBegin == null ? 0 : 1) +
        (guidelineEnd == null ? 0 : 1) +
        (guidelinePercent == null ? 0 : 1);
    if (guideConstraintCount == 0) {
      throw ConstraintLayoutException(
          'Must set one of guidelineBegin、guidelineEnd、guidelinePercent.');
    } else if (guideConstraintCount != 1) {
      throw ConstraintLayoutException(
          'Must set only one of guidelineBegin、guidelineEnd、guidelinePercent.');
    }
    if (guidelinePercent != null) {
      _debugEnsurePercent('guidelinePercent', guidelinePercent);
    }
    return true;
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    assert(_checkParam());
    return _GuidelineRenderBox()
      .._id = id
      .._guidelineBegin = guidelineBegin
      .._guidelineEnd = guidelineEnd
      .._guidelinePercent = guidelinePercent
      .._horizontal = horizontal;
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) {
    assert(_checkParam());
    (renderObject as _GuidelineRenderBox)
      ..id = id
      ..guidelineBegin = guidelineBegin
      ..guidelineEnd = guidelineEnd
      ..guidelinePercent = guidelinePercent
      ..horizontal = horizontal;
  }
}

class _GuidelineRenderBox extends _InternalBox {
  late ConstraintId _id;
  double? _guidelineBegin;
  double? _guidelineEnd;
  double? _guidelinePercent;
  late bool _horizontal;

  set id(ConstraintId value) {
    if (_id != value) {
      _id = value;
      updateParentData();
      markParentNeedsLayout();
    }
  }

  set guidelineBegin(double? value) {
    if (_guidelineBegin != value) {
      _guidelineBegin = value;
      updateParentData();
      markParentNeedsLayout();
    }
  }

  set guidelineEnd(double? value) {
    if (_guidelineEnd != value) {
      _guidelineEnd = value;
      updateParentData();
      markParentNeedsLayout();
    }
  }

  set guidelinePercent(double? value) {
    if (_guidelinePercent != value) {
      _guidelinePercent = value;
      updateParentData();
      markParentNeedsLayout();
    }
  }

  set horizontal(bool value) {
    if (_horizontal != value) {
      _horizontal = value;
      updateParentData();
      markParentNeedsLayout();
    }
  }

  @override
  void updateParentData() {
    super.updateParentData();
    _ConstraintBoxData constraintBoxData = parentData as _ConstraintBoxData;
    constraintBoxData.id = _id;
    if (_horizontal) {
      if (_guidelineBegin != null) {
        constraintBoxData.top = parent.top;
        constraintBoxData.bottom = null;
        constraintBoxData.width = matchParent;
        constraintBoxData.height = 0;
        constraintBoxData.margin = EdgeInsets.only(top: _guidelineBegin!);
      } else if (_guidelineEnd != null) {
        constraintBoxData.bottom = parent.bottom;
        constraintBoxData.top = null;
        constraintBoxData.width = matchParent;
        constraintBoxData.height = 0;
        constraintBoxData.margin = EdgeInsets.only(bottom: _guidelineEnd!);
      } else {}
    } else {
      if (_guidelineBegin != null) {
        constraintBoxData.left = parent.left;
        constraintBoxData.right = null;
        constraintBoxData.width = 0;
        constraintBoxData.height = matchParent;
        constraintBoxData.margin = EdgeInsets.only(left: _guidelineBegin!);
      } else if (_guidelineEnd != null) {
        constraintBoxData.right = parent.right;
        constraintBoxData.left = null;
        constraintBoxData.width = 0;
        constraintBoxData.height = matchParent;
        constraintBoxData.margin = EdgeInsets.only(right: _guidelineEnd!);
      } else {}
    }
  }
}

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

class _BarrierRenderBox extends _InternalBox {}

class ConstraintLayoutException implements Exception {
  final String msg;

  ConstraintLayoutException(this.msg);

  @override
  String toString() {
    return 'ConstraintLayoutException throw: $msg';
  }
}
