import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'auxiliary.dart';

/// A super powerful Stack, build flexible layouts with constraints.
/// Similar to ConstraintLayout for Android and AutoLayout for iOS.
/// But the code implementation is much more efficient, it has O(n)
/// layout time complexity and no linear equation solving is required.
///
/// It is a layout and a more modern general layout framework.
///
/// No matter how complex the layout is and how deep the constraints are
/// it has almost the same performance as a single Flex or Stack.
/// When facing complex layouts, it provides better performance, flexibility
/// and a very flat code hierarchy than Flex and Stack. Say no to 'nested hell'.
///
/// Flutter ConstraintLayout has extremely high layout performance.
/// It does not require linear equations to solve. At any time, each
/// child element will only be laid out once. When its own width or
/// height is set to wrapContent, some child elements may calculate
/// the offset twice.
///
/// ConstraintLayout itself can be arbitrarily nested without performance
/// issues, each child element in the render tree is only laid out once, and
/// the time complexity is O(n) instead of O(2n) or worse.
///
/// Warning: For layout performance considerations, constraints are always
/// one-way, and there should be no two child elements directly or indirectly
/// restrain each other(for example, the right side of A is constrained to the
/// left side of B, and the left side of B is in turn constrained to A right). Each
/// constraint should describe exactly where the child elements are located. Although
/// constraints can only be one-way, you can still better handle things that were
/// previously (Android ConstraintLayout) two-way constraints, such as
/// chains(not yet supported, please use with Flex).
///
/// author: hackware
/// home page: https:///github.com/hackware1993
/// email: hackware1993@gmail.com
class ConstraintLayout extends MultiChildRenderObjectWidget {
  /// Constraints can be separated from widgets
  final List<ConstraintDefine>? childConstraints;

  /// It will display the time-consuming of constraint calculation, layout, and drawing
  final bool showLayoutPerformanceOverlay;

  /// Guideline and Barrier will be displayed
  final bool showHelperWidgets;

  /// Will show the click area of each child element
  final bool showClickArea;

  /// Will show the z-index of each child element
  final bool showZIndex;

  /// Will show the constraint depth (layout priority) of each child element
  final bool showChildDepth;

  final bool debugPrintConstraints;

  // fixed size、matchParent、wrapContent
  final double width;
  final double height;

  /// When size is non-null, both width and height are set to size
  final double? size;

  /// Every frame, ConstraintLayout compares the parameters and decides the following things:
  ///    1. Does the constraint need to be recalculated?
  ///    2. Does it need to be relayout?
  ///    3. Does it need to be redrawn?
  ///    4. Do you need to rearrange the drawing order?
  ///    5. Do you need to rearrange the order of event distribution?
  ///These comparisons will not be a performance bottleneck, but will increase CPU usage. If you know
  ///enough about the internals of ConstraintLayout, you can use ConstraintLayoutController to manually trigger
  ///these operations to stop parameter comparison.
  final ConstraintLayoutController? controller;

  final bool? rtl;

  ConstraintLayout({
    Key? key,
    this.childConstraints,
    List<Widget>? children,
    this.showLayoutPerformanceOverlay = false,
    this.showHelperWidgets = false,
    this.showClickArea = false,
    this.showZIndex = false,
    this.showChildDepth = false,
    this.debugPrintConstraints = false,
    this.width = matchParent,
    this.height = matchParent,
    this.size,
    this.controller,
    this.rtl,
  }) : super(
          key: key,
          children: children ?? [],
        );

  @override
  RenderObject createRenderObject(BuildContext context) {
    assert(width >= 0 || width == matchParent || width == wrapContent);
    assert(height >= 0 || height == matchParent || height == wrapContent);
    assert(size == null ||
        (size! >= 0 || size == matchParent || size == wrapContent));
    double selfWidth = width;
    double selfHeight = height;
    if (size != null) {
      selfWidth = size!;
      selfHeight = size!;
    }
    return _ConstraintRenderBox()
      .._rtl = rtl ?? Directionality.of(context) == TextDirection.rtl
      ..childConstraints = childConstraints
      .._showLayoutPerformanceOverlay = showLayoutPerformanceOverlay
      .._showHelperWidgets = showHelperWidgets
      .._showClickArea = showClickArea
      .._showZIndex = showZIndex
      .._showChildDepth = showChildDepth
      .._debugPrintConstraints = debugPrintConstraints
      .._width = selfWidth
      .._height = selfHeight
      .._controller = controller?._copy();
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) {
    assert(width >= 0 || width == matchParent || width == wrapContent);
    assert(height >= 0 || height == matchParent || height == wrapContent);
    assert(size == null ||
        (size! >= 0 || size == matchParent || size == wrapContent));
    double selfWidth = width;
    double selfHeight = height;
    if (size != null) {
      selfWidth = size!;
      selfHeight = size!;
    }
    (renderObject as _ConstraintRenderBox)
      ..rtl = rtl ?? Directionality.of(context) == TextDirection.rtl
      ..childConstraints = childConstraints
      ..showLayoutPerformanceOverlay = showLayoutPerformanceOverlay
      ..showHelperWidgets = showHelperWidgets
      ..showClickArea = showClickArea
      ..showZIndex = showZIndex
      ..showChildDepth = showChildDepth
      ..debugPrintConstraints = debugPrintConstraints
      ..width = selfWidth
      ..height = selfHeight
      ..controller = controller?._copy();
  }
}

/// Wrapper constraints design for simplicity of use, it will eventually convert to base constraints.
const Object _wrapperConstraint = Object();
const Object _baseConstraint = Object();

final ConstraintId parent = ConstraintId('parent');
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

enum BarrierDirection {
  left,
  top,
  right,
  bottom,
}

/// For percentage layout
enum PercentageAnchor {
  /// Based on the size of the constraint
  constraint,

  /// Based on the size of the parent
  parent,
}

/// Each child element can be set with an id so that they can be referenced
/// by other child elements. If not set, other child elements can be referenced
/// by relative id. But once an id is defined, it cannot be referenced using
/// a relative id.
class ConstraintId {
  /// Uniqueness must be guaranteed
  final String id;

  /// To simplify the setting of margins
  /// margin can be negative
  double? _leftMargin;
  double? _topMargin;
  double? _rightMargin;
  double? _bottomMargin;
  double? _leftGoneMargin;
  double? _topGoneMargin;
  double? _rightGoneMargin;
  double? _bottomGoneMargin;

  /// Speed up constraint calculation
  ConstrainedNode? _contextCacheNode;
  int? _contextHash;

  ConstraintId(this.id);

  @protected
  ConstraintId _copy() {
    return ConstraintId(id);
  }

  bool _isMarginSet() {
    return _leftMargin != null ||
        _topMargin != null ||
        _rightMargin != null ||
        _bottomMargin != null ||
        _leftGoneMargin != null ||
        _topGoneMargin != null ||
        _rightGoneMargin != null ||
        _bottomGoneMargin != null;
  }

  ConstraintId leftMargin(double margin) {
    if (_isMarginSet()) {
      _leftMargin = margin;
      return this;
    } else {
      return _copy().._leftMargin = margin;
    }
  }

  ConstraintId topMargin(double margin) {
    if (_isMarginSet()) {
      _topMargin = margin;
      return this;
    } else {
      return _copy().._topMargin = margin;
    }
  }

  ConstraintId rightMargin(double margin) {
    if (_isMarginSet()) {
      _rightMargin = margin;
      return this;
    } else {
      return _copy().._rightMargin = margin;
    }
  }

  ConstraintId bottomMargin(double margin) {
    if (_isMarginSet()) {
      _bottomMargin = margin;
      return this;
    } else {
      return _copy().._bottomMargin = margin;
    }
  }

  ConstraintId leftGoneMargin(double margin) {
    if (_isMarginSet()) {
      _leftGoneMargin = margin;
      return this;
    } else {
      return _copy().._leftGoneMargin = margin;
    }
  }

  ConstraintId topGoneMargin(double margin) {
    if (_isMarginSet()) {
      _topGoneMargin = margin;
      return this;
    } else {
      return _copy().._topGoneMargin = margin;
    }
  }

  ConstraintId rightGoneMargin(double margin) {
    if (_isMarginSet()) {
      _rightGoneMargin = margin;
      return this;
    } else {
      return _copy().._rightGoneMargin = margin;
    }
  }

  ConstraintId bottomGoneMargin(double margin) {
    if (_isMarginSet()) {
      _bottomGoneMargin = margin;
      return this;
    } else {
      return _copy().._bottomGoneMargin = margin;
    }
  }

  ConstrainedNode? _getCacheNode(int hash) {
    if (_contextHash == hash) {
      return _contextCacheNode!;
    }
    return null;
  }

  void _setCacheNode(int hash, ConstrainedNode node) {
    _contextHash = hash;
    _contextCacheNode = node;
  }

  late final ConstraintAlign left =
      ConstraintAlign(this, ConstraintAlignType.left)
        .._margin = _leftMargin
        .._goneMargin = _leftGoneMargin;

  late final ConstraintAlign top =
      ConstraintAlign(this, ConstraintAlignType.top)
        .._margin = _topMargin
        .._goneMargin = _topGoneMargin;

  late final ConstraintAlign right =
      ConstraintAlign(this, ConstraintAlignType.right)
        .._margin = _rightMargin
        .._goneMargin = _rightGoneMargin;

  late final ConstraintAlign bottom =
      ConstraintAlign(this, ConstraintAlignType.bottom)
        .._margin = _bottomMargin
        .._goneMargin = _bottomGoneMargin;

  late final ConstraintAlign baseline =
      ConstraintAlign(this, ConstraintAlignType.baseline)
        .._margin = _bottomMargin
        .._goneMargin = _bottomGoneMargin;

  late final ConstraintAlign _leftReverse =
      ConstraintAlign(this, ConstraintAlignType.left)
        .._margin = _rightMargin
        .._goneMargin = _rightGoneMargin;

  late final ConstraintAlign _topReverse =
      ConstraintAlign(this, ConstraintAlignType.top)
        .._margin = _bottomMargin
        .._goneMargin = _bottomGoneMargin;

  late final ConstraintAlign _rightReverse =
      ConstraintAlign(this, ConstraintAlignType.right)
        .._margin = _leftMargin
        .._goneMargin = _leftGoneMargin;

  late final ConstraintAlign _bottomReverse =
      ConstraintAlign(this, ConstraintAlignType.bottom)
        .._margin = _topMargin
        .._goneMargin = _topGoneMargin;

  late final ConstraintAlign center =
      ConstraintAlign(this, ConstraintAlignType.center);

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
    return (other).id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  String toString() {
    return 'ConstraintId{name: $id}';
  }
}

/// A relative id type that refers to a child element by its index
class IndexConstraintId extends ConstraintId {
  /// [0, childCount-1]
  /// -1 represents the last element
  /// -2 represents the second to last element, and so on
  final int _siblingIndex;

  IndexConstraintId(this._siblingIndex)
      : super('parent.children[$_siblingIndex]');

  @override
  ConstraintId _copy() {
    return IndexConstraintId(_siblingIndex);
  }
}

/// A relative id type that is referenced by index offsets between child elements
class RelativeConstraintId extends ConstraintId {
  /// [-childCount+1),childCount-1]
  /// cannot be 0 because it cannot refer to itself
  final int _siblingIndexOffset;

  RelativeConstraintId(this._siblingIndexOffset)
      : super('$_siblingIndexOffset');

  @override
  ConstraintId _copy() {
    return RelativeConstraintId(_siblingIndexOffset);
  }
}

class ConstraintAlign {
  final ConstraintId _id;
  final ConstraintAlignType _type;

  /// margin can be negative
  double? _margin;
  double? _goneMargin;

  /// [0.0,1.0]
  /// The default value is 0.5, which means centering
  double? _bias;

  ConstraintAlign(this._id, this._type);

  ConstraintAlign margin(double margin) {
    if (_margin != null || _goneMargin != null || _bias != null) {
      _margin = margin;
      return this;
    } else {
      return ConstraintAlign(_id, _type).._margin = margin;
    }
  }

  ConstraintAlign goneMargin(double goneMargin) {
    if (_margin != null || _goneMargin != null || _bias != null) {
      _goneMargin = goneMargin;
      return this;
    } else {
      return ConstraintAlign(_id, _type).._goneMargin = goneMargin;
    }
  }

  ConstraintAlign bias(double bias) {
    if (_margin != null || _goneMargin != null || _bias != null) {
      _bias = bias;
      return this;
    } else {
      return ConstraintAlign(_id, _type).._bias = bias;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConstraintAlign &&
          runtimeType == other.runtimeType &&
          _id == other._id &&
          _type == other._type &&
          _bias == other._bias;

  @override
  int get hashCode => _id.hashCode ^ _type.hashCode ^ _bias.hashCode;
}

typedef OnLayoutCallback = void Function(RenderBox renderBox, Rect rect);

typedef OnPaintCallback = void Function(RenderBox renderBox, Offset offset,
    Size size, Offset? anchorPoint, double? angle);

typedef CalcSizeCallback = BoxConstraints Function(
    RenderBox parent, List<ConstrainedNode> anchors);

typedef CalcOffsetCallback = Offset Function(
    RenderBox parent, ConstrainedNode self, List<ConstrainedNode> anchors);

class ConstraintDefine {
  final ConstraintId? _id;

  ConstraintDefine(this._id)

      /// You cannot define a relative id for yourself
      : assert(_id is! IndexConstraintId),
        assert(_id is! RelativeConstraintId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConstraintDefine &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;
}

/// For pinned position and translate
enum AnchorType {
  absolute,
  percent,
}

class Anchor {
  final double _xOffset;
  final AnchorType _xType;
  final double _yOffset;
  final AnchorType _yType;

  Anchor(this._xOffset, this._xType, this._yOffset, this._yType);

  Offset _resolve(Size size) {
    assert(() {
      debugCheckAnchorBounds(_xOffset, _xType, size.width);
      debugCheckAnchorBounds(_yOffset, _yType, size.height);
      return true;
    }());
    double x;
    double y;
    if (_xType == AnchorType.absolute) {
      x = _xOffset;
    } else {
      x = _xOffset * size.width;
    }
    if (_yType == AnchorType.absolute) {
      y = _yOffset;
    } else {
      y = _yOffset * size.height;
    }
    return Offset(x, y);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Anchor &&
          runtimeType == other.runtimeType &&
          _xOffset == other._xOffset &&
          _xType == other._xType &&
          _yOffset == other._yOffset &&
          _yType == other._yType;

  @override
  int get hashCode =>
      _xOffset.hashCode ^ _xType.hashCode ^ _yOffset.hashCode ^ _yType.hashCode;
}

/// Has no effect in pinned position layout mode.
/// You can use it to do the rotation of child elements.
class PinnedTranslate extends Offset {
  final PinnedInfo _pinnedInfo;

  PinnedTranslate(this._pinnedInfo) : super(0, 0);

  PinnedTranslate._shift(this._pinnedInfo, double x, double y) : super(x, y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is PinnedTranslate &&
          runtimeType == other.runtimeType &&
          _pinnedInfo == other._pinnedInfo;

  @override
  PinnedTranslate operator +(Offset other) =>
      PinnedTranslate._shift(_pinnedInfo, other.dx, other.dy);

  @override
  int get hashCode => super.hashCode ^ _pinnedInfo.hashCode;
}

class PinnedInfo {
  /// [0.0,360.0]
  /// Exceeding the range will be automatically converted
  double angle;

  /// Nullable when used in pinned translate, representing a rotation
  /// relative to itself
  final ConstraintId? targetId;

  final Anchor selfAnchor;

  /// Nullable when used in pinned translate, provided targetId is empty
  final Anchor? targetAnchor;

  PinnedInfo(
    this.targetId,
    this.selfAnchor,
    this.targetAnchor, {
    this.angle = 0.0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PinnedInfo &&
          runtimeType == other.runtimeType &&
          angle == other.angle &&
          targetId == other.targetId &&
          selfAnchor == other.selfAnchor &&
          targetAnchor == other.targetAnchor;

  @override
  int get hashCode =>
      angle.hashCode ^
      targetId.hashCode ^
      selfAnchor.hashCode ^
      targetAnchor.hashCode;
}

class ConstraintLayoutController {
  int _constraintsVersion = 1;
  int _layoutVersion = 1;
  int _paintVersion = 1;
  int _paintingOrderVersion = 1;
  int _eventOrderVersion = 1;

  ConstraintLayoutController markNeedsRecalculateConstraints() {
    _constraintsVersion++;
    _layoutVersion++;
    _paintVersion++;
    _paintingOrderVersion++;
    _eventOrderVersion++;
    return this;
  }

  ConstraintLayoutController markNeedsLayout() {
    _layoutVersion++;
    _paintVersion++;
    return this;
  }

  ConstraintLayoutController markNeedsPaint() {
    _paintVersion++;
    return this;
  }

  ConstraintLayoutController markNeedsReorderPaintingOrder() {
    _paintingOrderVersion++;
    _eventOrderVersion++;
    return this;
  }

  ConstraintLayoutController markNeedsReorderEventOrder() {
    _eventOrderVersion++;
    return this;
  }

  ConstraintLayoutController _copy() {
    return ConstraintLayoutController()
      .._constraintsVersion = _constraintsVersion
      .._layoutVersion = _layoutVersion
      .._paintVersion = _paintVersion
      .._paintingOrderVersion = _paintingOrderVersion
      .._eventOrderVersion = _eventOrderVersion;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConstraintLayoutController &&
          runtimeType == other.runtimeType &&
          _constraintsVersion == other._constraintsVersion &&
          _layoutVersion == other._layoutVersion &&
          _paintVersion == other._paintVersion &&
          _paintingOrderVersion == other._paintingOrderVersion &&
          _eventOrderVersion == other._eventOrderVersion;

  @override
  int get hashCode =>
      _constraintsVersion.hashCode ^
      _layoutVersion.hashCode ^
      _paintVersion.hashCode ^
      _paintingOrderVersion.hashCode ^
      _eventOrderVersion.hashCode;
}

class Constraint extends ConstraintDefine {
  /// 'wrap_content'、'match_parent'、'match_constraint'、'48, etc'
  /// 'match_parent' will be converted to the base constraints
  final double width;
  final double height;

  /// When size is non-null, both width and height are set to size
  final double? size;

  /// Expand the click area without changing the actual size
  final EdgeInsets clickPadding;

  final CLVisibility visibility;

  /// Both margin and goneMargin can be negative
  final bool percentageMargin;
  final EdgeInsets margin;
  final EdgeInsets goneMargin;

  /// These are the base constraints constraint on sibling id or parent
  /// The essence of constraints is alignment
  @_baseConstraint
  final ConstraintAlign? left;
  @_baseConstraint
  final ConstraintAlign? top;
  @_baseConstraint
  final ConstraintAlign? right;
  @_baseConstraint
  final ConstraintAlign? bottom;
  @_baseConstraint
  final ConstraintAlign? baseline;

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
  @_wrapperConstraint
  final ConstraintId? outTopLeftTo;
  @_wrapperConstraint
  final ConstraintId? outTopCenterTo;
  @_wrapperConstraint
  final ConstraintId? outTopRightTo;
  @_wrapperConstraint
  final ConstraintId? outCenterLeftTo;
  @_wrapperConstraint
  final ConstraintId? outCenterRightTo;
  @_wrapperConstraint
  final ConstraintId? outBottomLeftTo;
  @_wrapperConstraint
  final ConstraintId? outBottomCenterTo;
  @_wrapperConstraint
  final ConstraintId? outBottomRightTo;
  @_wrapperConstraint
  final ConstraintId? centerTopLeftTo;
  @_wrapperConstraint
  final ConstraintId? centerTopCenterTo;
  @_wrapperConstraint
  final ConstraintId? centerTopRightTo;
  @_wrapperConstraint
  final ConstraintId? centerCenterLeftTo;
  @_wrapperConstraint
  final ConstraintId? centerCenterRightTo;
  @_wrapperConstraint
  final ConstraintId? centerBottomLeftTo;
  @_wrapperConstraint
  final ConstraintId? centerBottomCenterTo;
  @_wrapperConstraint
  final ConstraintId? centerBottomRightTo;

  final OnLayoutCallback? layoutCallback;
  final OnPaintCallback? paintCallback;

  /// To offset relative to its own size
  final bool percentageTranslate;

  /// Only takes effect when width is wrapContent
  final double minWidth;
  final double maxWidth;

  /// Only takes effect when height is wrapContent
  final double minHeight;
  final double maxHeight;

  /// Only takes effect if the size of one side is matchConstraint and the size of the other side can be
  /// inferred (fixed size, matchParent, matchConstraint with two constraints)
  final double? widthHeightRatio;

  /// By default, ConstraintLayout will automatically decide which side to base on and
  /// calculate the size of the other side based on widthHeightRatio. But if both sides
  /// are matchConstraint, it cannot be determined automatically. At this point, you need
  /// to specify the ratioBaseOnWidth parameter. The default value of null means automatically decide
  final bool? ratioBaseOnWidth;

  /// When the click areas of child elements overlap, the larger the eIndex, the
  /// priority to respond to the event
  final int? eIndex;

  /// pinned position and traditional layout are mutually exclusive
  /// pinned translate doesn't work when using pinned position
  final PinnedInfo? pinnedInfo;

  /// For arbitrary position
  final List<ConstraintId>? anchors;
  final CalcSizeCallback? calcSizeCallback;
  final CalcOffsetCallback? calcOffsetCallback;

  Constraint({
    ConstraintId? id,
    this.width = wrapContent,
    this.height = wrapContent,
    this.size,
    @_baseConstraint this.left,
    @_baseConstraint this.top,
    @_baseConstraint this.right,
    @_baseConstraint this.bottom,
    @_baseConstraint this.baseline,
    this.clickPadding = EdgeInsets.zero,
    this.visibility = visible,
    this.percentageMargin = false,
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
    @_wrapperConstraint this.outTopLeftTo,
    @_wrapperConstraint this.outTopCenterTo,
    @_wrapperConstraint this.outTopRightTo,
    @_wrapperConstraint this.outCenterLeftTo,
    @_wrapperConstraint this.outCenterRightTo,
    @_wrapperConstraint this.outBottomLeftTo,
    @_wrapperConstraint this.outBottomCenterTo,
    @_wrapperConstraint this.outBottomRightTo,
    @_wrapperConstraint this.centerTopLeftTo,
    @_wrapperConstraint this.centerTopCenterTo,
    @_wrapperConstraint this.centerTopRightTo,
    @_wrapperConstraint this.centerCenterLeftTo,
    @_wrapperConstraint this.centerCenterRightTo,
    @_wrapperConstraint this.centerBottomLeftTo,
    @_wrapperConstraint this.centerBottomCenterTo,
    @_wrapperConstraint this.centerBottomRightTo,
    this.layoutCallback,
    this.paintCallback,
    this.percentageTranslate = false,
    this.minWidth = 0,
    this.maxWidth = matchParent,
    this.minHeight = 0,
    this.maxHeight = matchParent,
    this.widthHeightRatio,
    this.ratioBaseOnWidth,
    this.eIndex,
    this.pinnedInfo,
    this.anchors,
    this.calcSizeCallback,
    this.calcOffsetCallback,
  }) : super(id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is Constraint &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height &&
          size == other.size &&
          clickPadding == other.clickPadding &&
          visibility == other.visibility &&
          percentageMargin == other.percentageMargin &&
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
          outTopLeftTo == other.outTopLeftTo &&
          outTopCenterTo == other.outTopCenterTo &&
          outTopRightTo == other.outTopRightTo &&
          outCenterLeftTo == other.outCenterLeftTo &&
          outCenterRightTo == other.outCenterRightTo &&
          outBottomLeftTo == other.outBottomLeftTo &&
          outBottomCenterTo == other.outBottomCenterTo &&
          outBottomRightTo == other.outBottomRightTo &&
          centerTopLeftTo == other.centerTopLeftTo &&
          centerTopCenterTo == other.centerTopCenterTo &&
          centerTopRightTo == other.centerTopRightTo &&
          centerCenterLeftTo == other.centerCenterLeftTo &&
          centerCenterRightTo == other.centerCenterRightTo &&
          centerBottomLeftTo == other.centerBottomLeftTo &&
          centerBottomCenterTo == other.centerBottomCenterTo &&
          centerBottomRightTo == other.centerBottomRightTo &&
          layoutCallback == other.layoutCallback &&
          paintCallback == other.paintCallback &&
          percentageTranslate == other.percentageTranslate &&
          minWidth == other.minWidth &&
          maxWidth == other.maxWidth &&
          minHeight == other.minHeight &&
          maxHeight == other.maxHeight &&
          widthHeightRatio == other.widthHeightRatio &&
          ratioBaseOnWidth == other.ratioBaseOnWidth &&
          eIndex == other.eIndex &&
          pinnedInfo == other.pinnedInfo &&
          listEquals(anchors, other.anchors) &&
          calcSizeCallback == other.calcSizeCallback &&
          calcOffsetCallback == other.calcOffsetCallback;

  @override
  int get hashCode =>
      super.hashCode ^
      width.hashCode ^
      height.hashCode ^
      size.hashCode ^
      clickPadding.hashCode ^
      visibility.hashCode ^
      percentageMargin.hashCode ^
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
      outTopLeftTo.hashCode ^
      outTopCenterTo.hashCode ^
      outTopRightTo.hashCode ^
      outCenterLeftTo.hashCode ^
      outCenterRightTo.hashCode ^
      outBottomLeftTo.hashCode ^
      outBottomCenterTo.hashCode ^
      outBottomRightTo.hashCode ^
      centerTopLeftTo.hashCode ^
      centerTopCenterTo.hashCode ^
      centerTopRightTo.hashCode ^
      centerCenterLeftTo.hashCode ^
      centerCenterRightTo.hashCode ^
      centerBottomLeftTo.hashCode ^
      centerBottomCenterTo.hashCode ^
      centerBottomRightTo.hashCode ^
      layoutCallback.hashCode ^
      paintCallback.hashCode ^
      percentageTranslate.hashCode ^
      minWidth.hashCode ^
      maxWidth.hashCode ^
      minHeight.hashCode ^
      maxHeight.hashCode ^
      widthHeightRatio.hashCode ^
      ratioBaseOnWidth.hashCode ^
      eIndex.hashCode ^
      pinnedInfo.hashCode ^
      anchors.hashCode ^
      calcSizeCallback.hashCode ^
      calcOffsetCallback.hashCode;

  bool _validate() {
    assert(debugCheckSize(width));
    assert(debugCheckSize(height));
    assert(size == null || debugCheckSize(size!));
    assert(left == null ||
        (left!._type == ConstraintAlignType.left ||
            left!._type == ConstraintAlignType.center ||
            left!._type == ConstraintAlignType.right));
    assert(top == null ||
        (top!._type == ConstraintAlignType.top ||
            top!._type == ConstraintAlignType.center ||
            top!._type == ConstraintAlignType.bottom));
    assert(right == null ||
        (right!._type == ConstraintAlignType.left ||
            right!._type == ConstraintAlignType.center ||
            right!._type == ConstraintAlignType.right));
    assert(bottom == null ||
        (bottom!._type == ConstraintAlignType.top ||
            bottom!._type == ConstraintAlignType.center ||
            bottom!._type == ConstraintAlignType.bottom));
    assert(baseline == null ||
        (baseline!._type == ConstraintAlignType.top ||
            baseline!._type == ConstraintAlignType.center ||
            baseline!._type == ConstraintAlignType.bottom ||
            baseline!._type == ConstraintAlignType.baseline));
    assert(debugEnsurePercent('widthPercent', widthPercent));
    assert(debugEnsurePercent('heightPercent', heightPercent));
    assert(debugEnsurePercent('horizontalBias', horizontalBias));
    assert(debugEnsurePercent('verticalBias', verticalBias));
    assert(!percentageMargin ||
        debugEnsureNegativePercent('leftMargin', margin.left));
    assert(!percentageMargin ||
        debugEnsureNegativePercent('topMargin', margin.top));
    assert(!percentageMargin ||
        debugEnsureNegativePercent('rightMargin', margin.right));
    assert(!percentageMargin ||
        debugEnsureNegativePercent('bottomMargin', margin.bottom));
    assert(!percentageMargin ||
        debugEnsureNegativePercent('leftGoneMargin', goneMargin.left));
    assert(!percentageMargin ||
        debugEnsureNegativePercent('topGoneMargin', goneMargin.top));
    assert(!percentageMargin ||
        debugEnsureNegativePercent('rightGoneMargin', goneMargin.right));
    assert(!percentageMargin ||
        debugEnsureNegativePercent('bottomGoneMargin', goneMargin.bottom));
    assert(minWidth >= 0);
    assert(maxWidth == matchParent || maxWidth >= minWidth);
    assert(minHeight >= 0);
    assert(maxHeight == matchParent || maxHeight >= minHeight);
    assert(widthHeightRatio == null || widthHeightRatio! > 0);
    return true;
  }

  void _applyTo(RenderObject renderObject) {
    _ConstraintRenderBox constraintRenderBox =
        (renderObject.parent as _ConstraintRenderBox);

    ConstraintAlign? left = this.left;
    ConstraintAlign? top = this.top;
    ConstraintAlign? right = this.right;
    ConstraintAlign? bottom = this.bottom;
    ConstraintAlign? baseline = this.baseline;

    double width = this.width;
    double height = this.height;
    if (size != null) {
      width = size!;
      height = size!;
    }

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

    if (outTopLeftTo != null) {
      right = outTopLeftTo!._leftReverse;
      bottom = outTopLeftTo!._topReverse;
    }

    if (outTopCenterTo != null) {
      left = outTopCenterTo!.left;
      right = outTopCenterTo!.right;
      bottom = outTopCenterTo!._topReverse;
    }

    if (outTopRightTo != null) {
      left = outTopRightTo!._rightReverse;
      bottom = outTopRightTo!._topReverse;
    }

    if (outCenterLeftTo != null) {
      top = outCenterLeftTo!.top;
      bottom = outCenterLeftTo!.bottom;
      right = outCenterLeftTo!._leftReverse;
    }

    if (outCenterRightTo != null) {
      top = outCenterRightTo!.top;
      bottom = outCenterRightTo!.bottom;
      left = outCenterRightTo!._rightReverse;
    }

    if (outBottomLeftTo != null) {
      right = outBottomLeftTo!._leftReverse;
      top = outBottomLeftTo!._bottomReverse;
    }

    if (outBottomCenterTo != null) {
      left = outBottomCenterTo!.left;
      right = outBottomCenterTo!.right;
      top = outBottomCenterTo!._bottomReverse;
    }

    if (outBottomRightTo != null) {
      left = outBottomRightTo!._rightReverse;
      top = outBottomRightTo!._bottomReverse;
    }

    if (centerTopLeftTo != null) {
      left = centerTopLeftTo!.left;
      right = centerTopLeftTo!._leftReverse;
      top = centerTopLeftTo!.top;
      bottom = centerTopLeftTo!._topReverse;
    }

    if (centerTopCenterTo != null) {
      left = centerTopCenterTo!.left;
      right = centerTopCenterTo!.right;
      top = centerTopCenterTo!.top;
      bottom = centerTopCenterTo!._topReverse;
    }

    if (centerTopRightTo != null) {
      left = centerTopRightTo!._rightReverse;
      right = centerTopRightTo!.right;
      top = centerTopRightTo!.top;
      bottom = centerTopRightTo!._topReverse;
    }

    if (centerCenterLeftTo != null) {
      left = centerCenterLeftTo!.left;
      right = centerCenterLeftTo!._leftReverse;
      top = centerCenterLeftTo!.top;
      bottom = centerCenterLeftTo!.bottom;
    }

    if (centerCenterRightTo != null) {
      left = centerCenterRightTo!._rightReverse;
      right = centerCenterRightTo!.right;
      top = centerCenterRightTo!.top;
      bottom = centerCenterRightTo!.bottom;
    }

    if (centerBottomLeftTo != null) {
      left = centerBottomLeftTo!.left;
      right = centerBottomLeftTo!._leftReverse;
      top = centerBottomLeftTo!._bottomReverse;
      bottom = centerBottomLeftTo!.bottom;
    }

    if (centerBottomCenterTo != null) {
      left = centerBottomCenterTo!.left;
      right = centerBottomCenterTo!.right;
      top = centerBottomCenterTo!._bottomReverse;
      bottom = centerBottomCenterTo!.bottom;
    }

    if (centerBottomRightTo != null) {
      left = centerBottomRightTo!._rightReverse;
      right = centerBottomRightTo!.right;
      top = centerBottomRightTo!._bottomReverse;
      bottom = centerBottomRightTo!.bottom;
    }

    double horizontalBias = this.horizontalBias;

    EdgeInsets margin = this.margin;
    EdgeInsets goneMargin = this.goneMargin;

    EdgeInsets clickPadding = this.clickPadding;

    if (constraintRenderBox._rtl) {
      ConstraintAlign? convertedLeft;
      ConstraintAlign? convertedRight;
      if (left != null) {
        /// left: box.right -> right: box.left
        ConstraintAlignType type;
        if (left._type == ConstraintAlignType.left) {
          type = ConstraintAlignType.right;
        } else if (left._type == ConstraintAlignType.right) {
          type = ConstraintAlignType.left;
        } else {
          type = ConstraintAlignType.center;
        }
        convertedRight = ConstraintAlign(left._id, type);
        convertedRight._margin = left._margin;
        convertedRight._goneMargin = left._goneMargin;
        if (left._bias != null) {
          convertedRight._bias = 1 - left._bias!;
        }
      }
      if (right != null) {
        /// right: box.left -> left: box.right
        ConstraintAlignType type;
        if (right._type == ConstraintAlignType.left) {
          type = ConstraintAlignType.right;
        } else if (right._type == ConstraintAlignType.right) {
          type = ConstraintAlignType.left;
        } else {
          type = ConstraintAlignType.center;
        }
        convertedLeft = ConstraintAlign(right._id, type);
        convertedLeft._margin = right._margin;
        convertedLeft._goneMargin = right._goneMargin;
        if (right._bias != null) {
          convertedLeft._bias = 1 - right._bias!;
        }
      }
      left = convertedLeft;
      right = convertedRight;

      horizontalBias = 1 - horizontalBias;

      margin = margin.copyWith(left: margin.right, right: margin.left);
      goneMargin =
          goneMargin.copyWith(left: goneMargin.right, right: goneMargin.left);

      clickPadding = clickPadding.copyWith(
          left: clickPadding.right, right: clickPadding.left);
    }

    if (left != null) {
      if (left._margin != null) {
        margin = margin.add(EdgeInsets.only(
          left: left._margin!,
        )) as EdgeInsets;
      }
      if (left._goneMargin != null) {
        goneMargin = goneMargin.add(EdgeInsets.only(
          left: left._goneMargin!,
        )) as EdgeInsets;
      }
    }

    if (top != null) {
      if (top._margin != null) {
        margin = margin.add(EdgeInsets.only(
          top: top._margin!,
        )) as EdgeInsets;
      }
      if (top._goneMargin != null) {
        goneMargin = goneMargin.add(EdgeInsets.only(
          top: top._goneMargin!,
        )) as EdgeInsets;
      }
    }

    if (right != null) {
      if (right._margin != null) {
        margin = margin.add(EdgeInsets.only(
          right: right._margin!,
        )) as EdgeInsets;
      }
      if (right._goneMargin != null) {
        goneMargin = goneMargin.add(EdgeInsets.only(
          right: right._goneMargin!,
        )) as EdgeInsets;
      }
    }

    if (bottom != null) {
      if (bottom._margin != null) {
        margin = margin.add(EdgeInsets.only(
          bottom: bottom._margin!,
        )) as EdgeInsets;
      }
      if (bottom._goneMargin != null) {
        goneMargin = goneMargin.add(EdgeInsets.only(
          bottom: bottom._goneMargin!,
        )) as EdgeInsets;
      }
    }

    if (baseline != null) {
      if (baseline._margin != null) {
        margin = margin.add(EdgeInsets.only(
          bottom: baseline._margin!,
        )) as EdgeInsets;
      }
      if (baseline._goneMargin != null) {
        goneMargin = goneMargin.add(EdgeInsets.only(
          bottom: baseline._goneMargin!,
        )) as EdgeInsets;
      }
    }

    /// Convert wrapper constraints finish

    /// Constraint priority: matchParent > wrapper constraints > base constraints
    if (width == matchParent) {
      assert(() {
        if (left != null || right != null) {
          throw ConstraintLayoutException(
              'When setting the width to match_parent for child with id $_id, there is no need to set left or right constraint.');
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
              'When setting the height to match_parent for child with id $_id, there is no need to set top or bottom or baseline constraint.');
        }
        return true;
      }());
      top = parent.top;
      bottom = parent.bottom;
      baseline = null;
    }

    ConstraintBoxData parentData =
        renderObject.parentData! as ConstraintBoxData;
    parentData.clickPadding = clickPadding;
    parentData.layoutCallback = layoutCallback;
    parentData.paintCallback = paintCallback;

    if (constraintRenderBox._controller != null) {
      parentData.id = _id;
      parentData.width = width;
      parentData.height = height;
      parentData.visibility = visibility;
      parentData.percentageMargin = percentageMargin;
      parentData.margin = margin;
      parentData.goneMargin = goneMargin;
      parentData.left = left;
      parentData.right = right;
      parentData.top = top;
      parentData.bottom = bottom;
      parentData.baseline = baseline;
      parentData.textBaseline = textBaseline;
      parentData.zIndex = zIndex;
      parentData.translateConstraint = translateConstraint;
      parentData.translate = translate;
      parentData.widthPercent = widthPercent;
      parentData.heightPercent = heightPercent;
      parentData.widthPercentageAnchor = widthPercentageAnchor;
      parentData.heightPercentageAnchor = heightPercentageAnchor;
      parentData.horizontalBias = horizontalBias;
      parentData.verticalBias = verticalBias;
      parentData.percentageTranslate = percentageTranslate;
      parentData.minWidth = minWidth;
      parentData.maxWidth = maxWidth;
      parentData.minHeight = minHeight;
      parentData.maxHeight = maxHeight;
      parentData.widthHeightRatio = widthHeightRatio;
      parentData.ratioBaseOnWidth = ratioBaseOnWidth;
      parentData.eIndex = eIndex;
      parentData.pinnedInfo = pinnedInfo;
      parentData.anchors = anchors;
      parentData.calcSizeCallback = calcSizeCallback;
      parentData.calcOffsetCallback = calcOffsetCallback;
      return;
    }

    bool needsRecalculateConstraints = false;
    bool needsLayout = false;
    bool needsReorderPaintingOrder = false;
    bool needsPaint = false;
    bool needsReorderEventOrder = false;

    if (parentData.id != _id) {
      parentData.id = _id;
      needsRecalculateConstraints = true;
      needsLayout = true;
    }

    if (parentData.width != width) {
      needsRecalculateConstraints = true;
      if (parentData.width != null) {
        if (getMinimalConstraintCount(parentData.width!) ==
            getMinimalConstraintCount(width)) {
          needsRecalculateConstraints = false;
        }
      }
      parentData.width = width;
      needsLayout = true;
    }

    if (parentData.height != height) {
      needsRecalculateConstraints = true;
      if (parentData.height != null) {
        if (getMinimalConstraintCount(parentData.height!) ==
            getMinimalConstraintCount(height)) {
          needsRecalculateConstraints = false;
        }
      }
      parentData.height = height;
      needsLayout = true;
    }

    if (parentData.visibility != visibility) {
      if (parentData.visibility == gone || visibility == gone) {
        needsLayout = true;
      } else {
        needsPaint = true;
      }
      parentData.visibility = visibility;
    }

    if (parentData.percentageMargin != percentageMargin) {
      parentData.percentageMargin = percentageMargin;
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

    if (parentData.left != left) {
      parentData.left = left;
      needsRecalculateConstraints = true;
      needsLayout = true;
    }

    if (parentData.right != right) {
      parentData.right = right;
      needsRecalculateConstraints = true;
      needsLayout = true;
    }

    if (parentData.top != top) {
      parentData.top = top;
      needsRecalculateConstraints = true;
      needsLayout = true;
    }

    if (parentData.bottom != bottom) {
      parentData.bottom = bottom;
      needsRecalculateConstraints = true;
      needsLayout = true;
    }

    if (parentData.baseline != baseline) {
      parentData.baseline = baseline;
      needsRecalculateConstraints = true;
      needsLayout = true;
    }

    if (parentData.textBaseline != textBaseline) {
      parentData.textBaseline = textBaseline;
      needsLayout = true;
    }

    if (parentData.zIndex != zIndex) {
      parentData.zIndex = zIndex;
      needsReorderPaintingOrder = true;
      needsReorderEventOrder = true;
      needsPaint = true;
    }

    if (parentData.translateConstraint != translateConstraint) {
      parentData.translateConstraint = translateConstraint;
      needsLayout = true;
    }

    if (parentData.translate.runtimeType != translate.runtimeType) {
      needsRecalculateConstraints = true;
      needsLayout = true;
    } else {
      if (translate.runtimeType == Offset) {
        if (parentData.translate != translate) {
          if (translateConstraint) {
            needsLayout = true;
          } else {
            needsPaint = true;
          }
        }
      } else {
        PinnedInfo lastInfo =
            (parentData.translate as PinnedTranslate)._pinnedInfo;
        PinnedInfo currentInto = (translate as PinnedTranslate)._pinnedInfo;
        if (lastInfo.targetId == currentInto.targetId) {
          if (lastInfo.selfAnchor != currentInto.selfAnchor ||
              lastInfo.targetAnchor != currentInto.targetAnchor) {
            if (translateConstraint) {
              needsLayout = true;
            } else {
              needsPaint = true;
            }
          } else {
            if (lastInfo.angle != currentInto.angle) {
              needsPaint = true;
            }
          }
        } else {
          needsRecalculateConstraints = true;
          needsLayout = true;
        }
      }
    }
    parentData.translate = translate;

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

    if (parentData.percentageTranslate != percentageTranslate) {
      parentData.percentageTranslate = percentageTranslate;
      needsPaint = true;
    }

    if (parentData.minWidth != minWidth) {
      parentData.minWidth = minWidth;
      needsLayout = true;
    }

    if (parentData.maxWidth != maxWidth) {
      parentData.maxWidth = maxWidth;
      needsLayout = true;
    }

    if (parentData.minHeight != minHeight) {
      parentData.minHeight = minHeight;
      needsLayout = true;
    }

    if (parentData.maxHeight != maxHeight) {
      parentData.maxHeight = maxHeight;
      needsLayout = true;
    }

    if (parentData.widthHeightRatio != widthHeightRatio) {
      parentData.widthHeightRatio = widthHeightRatio;
      needsLayout = true;
    }

    if (parentData.ratioBaseOnWidth != ratioBaseOnWidth) {
      parentData.ratioBaseOnWidth = ratioBaseOnWidth;
      needsLayout = true;
    }

    if (parentData.eIndex != eIndex) {
      parentData.eIndex = eIndex;
      needsReorderEventOrder = true;
    }

    if (parentData.pinnedInfo != pinnedInfo) {
      if (parentData.pinnedInfo == null || pinnedInfo == null) {
        needsRecalculateConstraints = true;
        needsLayout = true;
      } else {
        if (parentData.pinnedInfo!.targetId != pinnedInfo!.targetId) {
          needsRecalculateConstraints = true;
          needsLayout = true;
        } else if (parentData.pinnedInfo!.selfAnchor !=
                pinnedInfo!.selfAnchor ||
            parentData.pinnedInfo!.targetAnchor != pinnedInfo!.targetAnchor) {
          needsLayout = true;
        } else if (parentData.pinnedInfo!.angle != pinnedInfo!.angle) {
          needsPaint = true;
        }
      }
      parentData.pinnedInfo = pinnedInfo;
    }

    if (!listEquals(parentData.anchors, anchors)) {
      parentData.anchors = anchors;
      needsRecalculateConstraints = true;
      needsLayout = true;
    }

    if (parentData.calcSizeCallback != calcSizeCallback) {
      parentData.calcSizeCallback = calcSizeCallback;
      needsLayout = true;
    }

    if (parentData.calcOffsetCallback != calcOffsetCallback) {
      parentData.calcOffsetCallback = calcOffsetCallback;
      needsLayout = true;
    }

    if (needsLayout) {
      RenderObject? targetParent = renderObject.parent;
      if (needsRecalculateConstraints) {
        if (targetParent is _ConstraintRenderBox) {
          targetParent.markNeedsRecalculateConstraints();
        }
      }
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    } else {
      if (needsReorderPaintingOrder) {
        RenderObject? targetParent = renderObject.parent;
        if (targetParent is _ConstraintRenderBox) {
          targetParent.needsReorderPaintingOrder = true;
        }
      }
      if (needsReorderEventOrder) {
        RenderObject? targetParent = renderObject.parent;
        if (targetParent is _ConstraintRenderBox) {
          targetParent.needsReorderEventOrder = true;
        }
      }
      if (needsPaint) {
        RenderObject? targetParent = renderObject.parent;
        if (targetParent is RenderObject) {
          targetParent.markNeedsPaint();
        }
      }
    }
  }
}

enum ConstraintAlignType {
  left,
  right,
  top,
  bottom,
  baseline,
  center,
}

class ConstraintBoxData extends ContainerBoxParentData<RenderBox> {
  ConstraintId? id;
  double? width;
  double? height;
  EdgeInsets? clickPadding;
  CLVisibility? visibility;
  bool? percentageMargin;
  EdgeInsets? margin;
  EdgeInsets? goneMargin;
  ConstraintAlign? left;
  ConstraintAlign? top;
  ConstraintAlign? right;
  ConstraintAlign? bottom;
  ConstraintAlign? baseline;
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
  OnLayoutCallback? layoutCallback;
  OnPaintCallback? paintCallback;
  bool? percentageTranslate;
  double? minWidth;
  double? maxWidth;
  double? minHeight;
  double? maxHeight;
  double? widthHeightRatio;
  bool? ratioBaseOnWidth;
  int? eIndex;
  PinnedInfo? pinnedInfo;
  List<ConstraintId>? anchors;
  CalcSizeCallback? calcSizeCallback;
  CalcOffsetCallback? calcOffsetCallback;

  // for internal use
  late Map<ConstraintId, ConstrainedNode> _constrainedNodeMap;
  BarrierDirection? _direction;
  List<ConstraintId>? _referencedIds;
  bool _isGuideline = false;
  bool _isBarrier = false;
  Size? _helperSize;
}

/// Each child element needs to be wrapped with Constrained to declare constraint information
class Constrained extends ParentDataWidget<ConstraintBoxData> {
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
    assert(constraint._validate());
    constraint._applyTo(renderObject);
  }

  @override
  Type get debugTypicalAncestorWidgetClass {
    return ConstraintLayout;
  }
}

/// For constraints and widgets separation
class UnConstrained extends ParentDataWidget<ConstraintBoxData> {
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
    List<ConstraintDefine>? childConstraints =
        (renderObject.parent as _ConstraintRenderBox)._childConstraints;
    assert(childConstraints != null,
        'Can not find Constraint for child with id $id.');
    Iterable<ConstraintDefine> constraintIterable =
        childConstraints!.where((element) => element._id == id);
    assert(constraintIterable.isNotEmpty,
        'Can not find Constraint for child with id $id.');
    assert(constraintIterable.length == 1, 'Duplicate id in childConstraints.');
    assert(constraintIterable.first is Constraint);
    Constraint constraint = constraintIterable.first as Constraint;
    assert(constraint._validate());
    constraint._applyTo(renderObject);
  }

  @override
  Type get debugTypicalAncestorWidgetClass {
    return ConstraintLayout;
  }
}

class _ConstraintRenderBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ConstraintBoxData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ConstraintBoxData> {
  List<ConstraintDefine>? _childConstraints;
  late bool _showLayoutPerformanceOverlay;
  late bool _showHelperWidgets;
  late bool _showClickArea;
  late bool _showZIndex;
  late bool _showChildDepth;
  late bool _debugPrintConstraints;
  late bool _rtl;

  late double _width;
  late double _height;
  ConstraintLayoutController? _controller;

  bool _needsRecalculateConstraints = true;
  bool _needsReorderPaintingOrder = true;
  bool _needsReorderEventOrder = true;

  int buildNodeTreesCount = 0;

  final Map<ConstraintId, ConstrainedNode> helperNodeMap = HashMap();

  /// For layout
  late List<ConstrainedNode> layoutOrderList;

  /// For paint
  late List<ConstrainedNode> paintingOrderList;

  /// For event dispatch
  late List<ConstrainedNode> eventOrderList;

  static const int maxTimeUsage = 20;
  Queue<int> constraintCalculationTimeUsage = Queue();
  Queue<int> layoutTimeUsage = Queue();
  Queue<int> paintTimeUsage = Queue();

  set childConstraints(List<ConstraintDefine>? value) {
    if (!listEquals(_childConstraints, value)) {
      _childConstraints = value;
      helperNodeMap.clear();
      for (final element in _childConstraints ?? []) {
        if (element is GuidelineDefine) {
          ConstraintBoxData constraintBoxData = ConstraintBoxData();
          _HelperBox.initParentData(constraintBoxData);
          _GuidelineRenderBox.initParentData(
            constraintBoxData,
            id: element._id!,
            horizontal: element.horizontal,
            guidelineBegin: element.guidelineBegin,
            guidelineEnd: element.guidelineEnd,
            guidelinePercent: element.guidelinePercent,
          );
          ConstrainedNode constrainedNode = ConstrainedNode()
            ..nodeId = element._id!
            ..parentData = constraintBoxData
            ..index = -1
            ..depth = 1;
          helperNodeMap[element._id!] = constrainedNode;
        } else if (element is BarrierDefine) {
          ConstraintBoxData constraintBoxData = ConstraintBoxData();
          _HelperBox.initParentData(constraintBoxData);
          _BarrierRenderBox.initParentData(
            constraintBoxData,
            id: element._id!,
            direction: element.direction,
            referencedIds: element.referencedIds,
          );
          ConstrainedNode constrainedNode = ConstrainedNode()
            ..nodeId = element._id!
            ..parentData = constraintBoxData
            ..index = -1;
          helperNodeMap[element._id!] = constrainedNode;
        }
      }
      markNeedsRecalculateConstraints();
      markNeedsLayout();
    }
  }

  set showLayoutPerformanceOverlay(bool value) {
    if (_showLayoutPerformanceOverlay != value) {
      _showLayoutPerformanceOverlay = value;
      if (value) {
        markNeedsRecalculateConstraints();
        markNeedsLayout();
      }
    }
  }

  set showHelperWidgets(bool value) {
    if (_showHelperWidgets != value) {
      _showHelperWidgets = value;
      markNeedsPaint();
    }
  }

  set showClickArea(bool value) {
    if (_showClickArea != value) {
      _showClickArea = value;
      markNeedsPaint();
    }
  }

  set showZIndex(bool value) {
    if (_showZIndex != value) {
      _showZIndex = value;
      markNeedsPaint();
    }
  }

  set showChildDepth(bool value) {
    if (_showChildDepth != value) {
      _showChildDepth = value;
      markNeedsPaint();
    }
  }

  set debugPrintConstraints(bool value) {
    if (_debugPrintConstraints != value) {
      _debugPrintConstraints = value;
      if (value) {
        markNeedsRecalculateConstraints();
        markNeedsLayout();
      }
    }
  }

  set needsReorderPaintingOrder(bool value) {
    if (_needsReorderPaintingOrder != value) {
      _needsReorderPaintingOrder = value;
      markNeedsPaint();
    }
  }

  set needsReorderEventOrder(bool value) {
    if (_needsReorderEventOrder != value) {
      _needsReorderEventOrder = value;
    }
  }

  set width(double value) {
    if (_width != value) {
      if (_width == wrapContent || value == wrapContent) {
        markNeedsRecalculateConstraints();
      }
      _width = value;
      markNeedsLayout();
    }
  }

  set height(double value) {
    if (_height != value) {
      if (_height == wrapContent || value == wrapContent) {
        markNeedsRecalculateConstraints();
      }
      _height = value;
      markNeedsLayout();
    }
  }

  set controller(ConstraintLayoutController? value) {
    if (_controller == null && value == null) {
      // Do nothing
    } else if (_controller == null || value == null) {
      _controller = value;
      markNeedsRecalculateConstraints();
      markNeedsLayout();
    } else {
      if (_controller!._constraintsVersion != value._constraintsVersion) {
        markNeedsRecalculateConstraints();
        markNeedsLayout();
      } else {
        if (_controller!._paintingOrderVersion != value._paintingOrderVersion) {
          needsReorderPaintingOrder = true;
          needsReorderEventOrder = true;
        } else {
          if (_controller!._eventOrderVersion != value._eventOrderVersion) {
            needsReorderEventOrder = true;
          }
        }
        if (_controller!._layoutVersion != value._layoutVersion) {
          markNeedsLayout();
        } else {
          if (_controller!._paintVersion != value._paintVersion) {
            markNeedsPaint();
          }
        }
      }
      _controller = value;
    }
  }

  set rtl(bool value) {
    if (_rtl != value) {
      _rtl = value;
      markNeedsRecalculateConstraints();
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! ConstraintBoxData) {
      child.parentData = ConstraintBoxData();

      /// Do not do special treatment for built-in components, treat them as ordinary
      /// child elements, but have a size of 0 and are gone
      if (child is _HelperBox) {
        child.updateParentData();
      }
    }
  }

  /// Make sure the id of the child elements is not repeated
  /// Make sure every id that is relied on is valid
  void debugCheckIds() {
    RenderBox? child = firstChild;
    Set<ConstraintId> declaredIdSet = HashSet();
    declaredIdSet.add(parent);

    if (helperNodeMap.isNotEmpty) {
      for (final element in helperNodeMap.keys) {
        if (!declaredIdSet.add(element)) {
          throw ConstraintLayoutException('Duplicate id in ConstraintLayout.');
        }
      }
    }

    Set<ConstraintId> referencedIdSet = HashSet();
    while (child != null) {
      ConstraintBoxData childParentData = child.parentData as ConstraintBoxData;

      if (childParentData.width == null) {
        throw ConstraintLayoutException(
            'Must provide Constraint for child elements, try use Constrained widget.');
      }

      if (childParentData.id != null) {
        if (!declaredIdSet.add(childParentData.id!)) {
          throw ConstraintLayoutException('Duplicate id in ConstraintLayout.');
        }
      }

      if (childParentData.left != null) {
        referencedIdSet.add(childParentData.left!._id);
      }

      if (childParentData.top != null) {
        referencedIdSet.add(childParentData.top!._id);
      }

      if (childParentData.right != null) {
        referencedIdSet.add(childParentData.right!._id);
      }

      if (childParentData.bottom != null) {
        referencedIdSet.add(childParentData.bottom!._id);
      }

      if (childParentData.baseline != null) {
        referencedIdSet.add(childParentData.baseline!._id);
      }

      if (child is _BarrierRenderBox) {
        referencedIdSet.addAll(childParentData._referencedIds!);
      }

      if (childParentData.pinnedInfo != null) {
        referencedIdSet.add(childParentData.pinnedInfo!.targetId!);
      }

      if (childParentData.translate is PinnedTranslate) {
        ConstraintId? targetId =
            (childParentData.translate as PinnedTranslate)._pinnedInfo.targetId;
        if (targetId != null) {
          referencedIdSet.add(targetId);
        }
      }

      if (childParentData.anchors != null &&
          childParentData.anchors!.isNotEmpty) {
        for (final element in childParentData.anchors!) {
          referencedIdSet.add(element);
        }
      }

      child = childParentData.nextSibling;
    }

    /// All ids referenced by Barrier must be defined
    for (final element in helperNodeMap.values) {
      if (element.isBarrier) {
        referencedIdSet.addAll(element.referencedIds!);
      }
    }

    /// The id used by all constraints must be defined
    Set<ConstraintId> undeclaredIdSet =
        referencedIdSet.difference(declaredIdSet);
    Set<IndexConstraintId> indexIds =
        undeclaredIdSet.whereType<IndexConstraintId>().toSet();
    Set<RelativeConstraintId> relativeIds =
        undeclaredIdSet.whereType<RelativeConstraintId>().toSet();
    if ((indexIds.length + relativeIds.length) != undeclaredIdSet.length) {
      throw ConstraintLayoutException(
          'These ids ${undeclaredIdSet.difference(indexIds).difference(relativeIds)} are not yet defined.');
    }
  }

  Map<ConstraintId, ConstrainedNode> buildConstrainedNodeTrees(
      bool selfSizeConfirmed) {
    Map<ConstraintId, ConstrainedNode> nodesMap = {};
    buildNodeTreesCount++;
    ConstrainedNode parentNode = ConstrainedNode()
      ..nodeId = parent
      ..depth = selfSizeConfirmed ? 0 : childCount + 1
      ..notLaidOut = false;
    if (!selfSizeConfirmed) {
      nodesMap[parent] = parentNode;
    }

    ConstrainedNode getConstrainedNodeForChild(ConstraintId id,
        [int? childIndex]) {
      if (id == parent) {
        return parentNode;
      }

      if (id is RelativeConstraintId) {
        int targetIndex = childIndex! + id._siblingIndexOffset;
        id = IndexConstraintId(targetIndex);
      } else if (id is IndexConstraintId) {
        if (id._siblingIndex < 0) {
          id = IndexConstraintId(childCount + id._siblingIndex);
        }
      }

      ConstrainedNode? node;
      int? contextHash;
      if (id.runtimeType == ConstraintId) {
        /// Fewer reads to nodesMap for faster constraint building
        contextHash = buildNodeTreesCount ^ hashCode;
        node = id._getCacheNode(contextHash);
        if (node != null) {
          return node;
        }
      }

      node = nodesMap[id];
      if (node == null) {
        node = ConstrainedNode()..nodeId = id;
        nodesMap[id] = node;
      }

      if (id.runtimeType == ConstraintId) {
        id._setCacheNode(contextHash!, node);
      }

      return node;
    }

    if (helperNodeMap.isNotEmpty) {
      nodesMap.addAll(helperNodeMap);
      for (final element in helperNodeMap.values) {
        if (element.parentData.left != null) {
          element.leftConstraint =
              getConstrainedNodeForChild(element.parentData.left!._id);
          element.leftAlignType = element.parentData.left!._type;
        }

        if (element.parentData.top != null) {
          element.topConstraint =
              getConstrainedNodeForChild(element.parentData.top!._id);
          element.topAlignType = element.parentData.top!._type;
        }

        if (element.parentData.right != null) {
          element.rightConstraint =
              getConstrainedNodeForChild(element.parentData.right!._id);
          element.rightAlignType = element.parentData.right!._type;
        }

        if (element.parentData.bottom != null) {
          element.bottomConstraint =
              getConstrainedNodeForChild(element.parentData.bottom!._id);
          element.bottomAlignType = element.parentData.bottom!._type;
        }

        if (element.isBarrier) {
          element.parentData._constrainedNodeMap = nodesMap;
        }
      }
    }

    RenderBox? child = firstChild;
    int childIndex = -1;
    while (child != null) {
      childIndex++;
      ConstraintBoxData childParentData = child.parentData as ConstraintBoxData;
      childParentData._constrainedNodeMap = nodesMap;

      ConstrainedNode currentNode = getConstrainedNodeForChild(
          childParentData.id ?? IndexConstraintId(childIndex));
      currentNode.parentData = childParentData;
      currentNode.index = childIndex;
      currentNode.renderBox = child;

      if (childParentData.left != null) {
        currentNode.leftConstraint =
            getConstrainedNodeForChild(childParentData.left!._id, childIndex);
        currentNode.leftAlignType = childParentData.left!._type;
      }

      if (childParentData.top != null) {
        currentNode.topConstraint =
            getConstrainedNodeForChild(childParentData.top!._id, childIndex);
        currentNode.topAlignType = childParentData.top!._type;
      }

      if (childParentData.right != null) {
        currentNode.rightConstraint =
            getConstrainedNodeForChild(childParentData.right!._id, childIndex);
        currentNode.rightAlignType = childParentData.right!._type;
      }

      if (childParentData.bottom != null) {
        currentNode.bottomConstraint =
            getConstrainedNodeForChild(childParentData.bottom!._id, childIndex);
        currentNode.bottomAlignType = childParentData.bottom!._type;
      }

      if (childParentData.baseline != null) {
        currentNode.baselineConstraint = getConstrainedNodeForChild(
            childParentData.baseline!._id, childIndex);
        currentNode.baselineAlignType = childParentData.baseline!._type;
      }

      if (childParentData.pinnedInfo != null) {
        currentNode.pinnedConstraint = getConstrainedNodeForChild(
            childParentData.pinnedInfo!.targetId!, childIndex);
      }

      if (childParentData.translate is PinnedTranslate) {
        ConstraintId? targetId =
            (childParentData.translate as PinnedTranslate)._pinnedInfo.targetId;
        if (targetId != null) {
          currentNode.pinnedConstraint =
              getConstrainedNodeForChild(targetId, childIndex);
        }
      }

      if (childParentData.anchors != null &&
          childParentData.anchors!.isNotEmpty) {
        currentNode.anchors = [
          for (final element in childParentData.anchors!)
            getConstrainedNodeForChild(element, childIndex)
        ];
      }

      child = childParentData.nextSibling;
    }

    return nodesMap;
  }

  @override
  void adoptChild(covariant RenderObject child) {
    super.adoptChild(child);
    markNeedsRecalculateConstraints();
  }

  @override
  void dropChild(covariant RenderObject child) {
    super.dropChild(child);
    markNeedsRecalculateConstraints();
  }

  void markNeedsRecalculateConstraints() {
    _needsRecalculateConstraints = true;
    _needsReorderPaintingOrder = true;
    _needsReorderEventOrder = true;
  }

  @override
  void performLayout() {
    Stopwatch? stopwatch;
    if (_showLayoutPerformanceOverlay) {
      stopwatch = Stopwatch()..start();
    }

    double resolvedWidth;
    if (_width >= 0) {
      resolvedWidth = constraints.constrainWidth(_width);
    } else {
      if (_width == matchParent) {
        if (constraints.maxWidth == double.infinity) {
          resolvedWidth = wrapContent;
        } else {
          resolvedWidth = constraints.maxWidth;
        }
      } else {
        resolvedWidth = wrapContent;
      }
    }

    double resolvedHeight;
    if (_height >= 0) {
      resolvedHeight = constraints.constrainHeight(_height);
    } else {
      if (_height == matchParent) {
        if (constraints.maxHeight == double.infinity) {
          resolvedHeight = wrapContent;
        } else {
          resolvedHeight = constraints.maxHeight;
        }
      } else {
        resolvedHeight = wrapContent;
      }
    }

    bool selfSizeConfirmed = false;
    if (resolvedWidth != wrapContent && resolvedHeight != wrapContent) {
      size = Size(resolvedWidth, resolvedHeight);
      selfSizeConfirmed = true;
    } else if (resolvedWidth != wrapContent) {
      size = Size(resolvedWidth, constraints.minHeight);
    } else if (resolvedHeight != wrapContent) {
      size = Size(constraints.minWidth, resolvedHeight);
    }

    if (_needsRecalculateConstraints) {
      Stopwatch? constraintCalculationWatch;
      if (stopwatch != null) {
        constraintCalculationWatch = Stopwatch()..start();
      }

      assert(() {
        debugCheckIds();
        return true;
      }());

      /// Traverse once, building the constrained node tree for each child element
      Map<ConstraintId, ConstrainedNode> nodesMap =
          buildConstrainedNodeTrees(selfSizeConfirmed);
      ConstrainedNode? parentNode = nodesMap.remove(parent);

      assert(() {
        List<ConstrainedNode> nodeList = nodesMap.values.toList();
        debugCheckConstraintsIntegrity(nodeList);
        debugCheckLoopConstraints(
            nodeList, selfSizeConfirmed, resolvedWidth, resolvedHeight);
        return true;
      }());

      if (childCount > 20) {
        // Count sort by child depth, the complexity is O(n)
        List<List<ConstrainedNode>> bucket =
            List.generate(childCount * 2 + 1, (_) => []);
        for (final element in nodesMap.values) {
          bucket[element.getDepth(
                  selfSizeConfirmed, resolvedWidth, resolvedHeight)]
              .add(element);
        }
        if (!selfSizeConfirmed) {
          bucket[childCount + 1].add(parentNode!);
        }
        layoutOrderList = [];
        for (final element in bucket) {
          if (element.isNotEmpty) {
            layoutOrderList.addAll(element);
          }
        }
      } else {
        layoutOrderList = nodesMap.values.toList();
        if (!selfSizeConfirmed) {
          layoutOrderList.add(parentNode!);
        }
        insertionSort<ConstrainedNode>(layoutOrderList, (left, right) {
          return left.getDepth(
                  selfSizeConfirmed, resolvedWidth, resolvedHeight) -
              right.getDepth(selfSizeConfirmed, resolvedWidth, resolvedHeight);
        });
      }

      // Most of the time, it is basically ordered, and the complexity is O(n)
      paintingOrderList = nodesMap.values.toList();
      insertionSort<ConstrainedNode>(paintingOrderList, (left, right) {
        int result = left.zIndex - right.zIndex;
        if (result == 0) {
          result = left.index - right.index;
        }
        return result;
      });

      // Most of the time, it is basically ordered, and the complexity is O(n)
      eventOrderList = nodesMap.values.toList();
      insertionSort<ConstrainedNode>(eventOrderList, (left, right) {
        int result = left.eIndex - right.eIndex;
        if (result == 0) {
          result = left.index - right.index;
        }
        return result;
      });

      assert(() {
        /// Print constraints
        if (_debugPrintConstraints) {
          debugPrint('ConstraintLayout@$hashCode constraints: ' +
              toJsonList(layoutOrderList));
        }
        return true;
      }());

      _needsRecalculateConstraints = false;
      _needsReorderPaintingOrder = false;
      _needsReorderEventOrder = false;

      if (constraintCalculationWatch != null) {
        constraintCalculationTimeUsage
            .add(constraintCalculationWatch.elapsedMicroseconds);
        if (constraintCalculationTimeUsage.length > maxTimeUsage) {
          constraintCalculationTimeUsage.removeFirst();
        }
      }
    }

    layoutByConstrainedNodeTrees(
        selfSizeConfirmed, resolvedWidth, resolvedHeight);

    if (stopwatch != null) {
      layoutTimeUsage.add(stopwatch.elapsedMicroseconds);
      if (layoutTimeUsage.length > maxTimeUsage) {
        layoutTimeUsage.removeFirst();
      }
    }
  }

  void layoutByConstrainedNodeTrees(
      bool selfSizeConfirmed, double resolvedWidth, double resolvedHeight) {
    for (int i = 0; i < layoutOrderList.length; i++) {
      final ConstrainedNode element = layoutOrderList[i];

      if (!selfSizeConfirmed) {
        if (element.isParent()) {
          size = Size(
              resolvedWidth == wrapContent
                  ? constraints.minWidth
                  : resolvedWidth,
              resolvedHeight == wrapContent
                  ? constraints.minHeight
                  : resolvedHeight);
          double contentWidth = -double.infinity;
          double contentHeight = -double.infinity;
          for (int j = 0; j < i; j++) {
            ConstrainedNode sizeConfirmedChild = layoutOrderList[j];

            if (sizeConfirmedChild.laidOutLater) {
              BoxConstraints childConstraints =
                  calculateChildSize(sizeConfirmedChild, false);

              /// Helper widgets may have no RenderObject
              if (sizeConfirmedChild.renderBox != null) {
                /// Due to the design of the Flutter framework, even if a child element is gone, it still has to be laid out
                /// I don't understand why the official design is this way
                sizeConfirmedChild.renderBox!.layout(
                  childConstraints,
                  parentUsesSize: true,
                );
              }
            }

            if (sizeConfirmedChild.isBarrier) {
              if (sizeConfirmedChild.direction == BarrierDirection.top ||
                  sizeConfirmedChild.direction == BarrierDirection.bottom) {
                sizeConfirmedChild.helperSize = Size(size.width, 0);
              } else {
                sizeConfirmedChild.helperSize = Size(0, size.height);
              }
            }

            sizeConfirmedChild.offset =
                calculateChildOffset(sizeConfirmedChild);
            double childSpanWidth = sizeConfirmedChild.getMeasuredWidth();
            double childSpanHeight = sizeConfirmedChild.getMeasuredHeight();

            if (sizeConfirmedChild.leftConstraint != null &&
                sizeConfirmedChild.rightConstraint != null) {
            } else if (sizeConfirmedChild.leftConstraint != null) {
              childSpanWidth += sizeConfirmedChild.getX();
            } else if (sizeConfirmedChild.rightConstraint != null) {
              childSpanWidth += size.width - sizeConfirmedChild.getRight();
            } else {
              childSpanWidth += sizeConfirmedChild.getX();
            }

            if (sizeConfirmedChild.topConstraint != null &&
                sizeConfirmedChild.bottomConstraint != null) {
            } else if (sizeConfirmedChild.topConstraint != null) {
              childSpanHeight += sizeConfirmedChild.getY();
            } else if (sizeConfirmedChild.bottomConstraint != null) {
              childSpanHeight += size.height - sizeConfirmedChild.getBottom();
            } else {
              childSpanHeight += sizeConfirmedChild.getY();
            }

            if (childSpanWidth > contentWidth) {
              contentWidth = childSpanWidth;
            }

            if (childSpanHeight > contentHeight) {
              contentHeight = childSpanHeight;
            }
          }
          size = Size(
              resolvedWidth == wrapContent
                  ? constraints.constrainWidth(contentWidth)
                  : resolvedWidth,
              resolvedHeight == wrapContent
                  ? constraints.constrainHeight(contentHeight)
                  : resolvedHeight);
          for (int j = 0; j < i; j++) {
            ConstrainedNode sizeConfirmedChild = layoutOrderList[j];
            if (sizeConfirmedChild.isBarrier) {
              if (sizeConfirmedChild.direction == BarrierDirection.top ||
                  sizeConfirmedChild.direction == BarrierDirection.bottom) {
                sizeConfirmedChild.helperSize = Size(size.width, 0);
              } else {
                sizeConfirmedChild.helperSize = Size(0, size.height);
              }
            }
            sizeConfirmedChild.offset =
                calculateChildOffset(sizeConfirmedChild);
            if (sizeConfirmedChild.layoutCallback != null) {
              sizeConfirmedChild.layoutCallback!.call(
                  sizeConfirmedChild.renderBox!,
                  Rect.fromLTWH(
                      sizeConfirmedChild.getX(),
                      sizeConfirmedChild.getY(),
                      sizeConfirmedChild.getMeasuredWidth(),
                      sizeConfirmedChild.getMeasuredHeight()));
            }
          }
          selfSizeConfirmed = true;
          continue;
        }

        if (element.isBarrier) {
          element.laidOutLater = true;
          continue;
        }

        if (element.width == matchConstraint ||
            element.height == matchConstraint) {
          element.laidOutLater = true;
          continue;
        }
      }

      BoxConstraints childConstraints =
          calculateChildSize(element, selfSizeConfirmed);

      /// Helper widgets may have no RenderObject
      if (element.renderBox != null) {
        /// Due to the design of the Flutter framework, even if a child element is gone, it still has to be laid out
        /// I don't understand why the official design is this way
        element.renderBox!.layout(
          childConstraints,
          parentUsesSize: true,
        );
      }

      if (selfSizeConfirmed) {
        if (element.isGuideline) {
          element.helperSize =
              Size(childConstraints.minWidth, childConstraints.minHeight);
        } else if (element.isBarrier) {
          if (element.direction == BarrierDirection.top ||
              element.direction == BarrierDirection.bottom) {
            element.helperSize = Size(size.width, 0);
          } else {
            element.helperSize = Size(0, size.height);
          }
        }

        element.offset = calculateChildOffset(element);
        if (element.layoutCallback != null) {
          element.layoutCallback!.call(
              element.renderBox!,
              Rect.fromLTWH(element.getX(), element.getY(),
                  element.getMeasuredWidth(), element.getMeasuredHeight()));
        }
      }
    }
  }

  BoxConstraints calculateChildSize(
      ConstrainedNode node, bool selfSizeConfirmed) {
    if (node.anchors != null) {
      BoxConstraints boxConstraints =
          node.calcSizeCallback!.call(this, node.anchors!);
      assert(boxConstraints.maxWidth >= boxConstraints.minWidth &&
          boxConstraints.minWidth >= 0);
      assert(boxConstraints.maxHeight >= boxConstraints.minHeight &&
          boxConstraints.minHeight >= 0);
      if (boxConstraints.maxWidth == 0 || boxConstraints.maxHeight == 0) {
        node.notLaidOut = true;
      } else {
        node.notLaidOut = false;
      }
      return boxConstraints;
    }

    EdgeInsets margin = node.margin;
    EdgeInsets goneMargin = node.goneMargin;

    /// Calculate child width
    double minWidth;
    double maxWidth;
    double minHeight;
    double maxHeight;
    if (node.visibility == gone) {
      minWidth = 0;
      maxWidth = 0;
      minHeight = 0;
      maxHeight = 0;
    } else {
      double width = node.width;
      if (width == wrapContent) {
        minWidth = node.minWidth;
        if (node.maxWidth == matchParent) {
          if (selfSizeConfirmed) {
            if (node.renderBox is _ConstraintRenderBox) {
              maxWidth = double.infinity;
            } else {
              maxWidth = size.width;
            }
          } else {
            maxWidth = double.infinity;
          }
        } else {
          maxWidth = node.maxWidth;
        }
      } else if (width == matchParent) {
        minWidth = size.width -
            getHorizontalInsets(margin, node.percentageMargin, size.width);
        assert(() {
          if (minWidth < 0) {
            debugPrint(
                'Warning: The child element with id ${node.nodeId} has a negative width');
          }
          return true;
        }());
        maxWidth = minWidth;
      } else if (width == matchConstraint) {
        if (node.widthHeightRatio != null &&
            node.heightIsExact &&
            node.ratioBaseOnWidth != true) {
          /// The width needs to be calculated later based on the height
          node.widthBasedHeight = true;
          minWidth = 0;
          maxWidth = double.infinity;
        } else {
          if (node.widthPercentageAnchor == PercentageAnchor.constraint) {
            double left;
            if (node.leftAlignType == ConstraintAlignType.left) {
              left = node.leftConstraint!.getX();
            } else if (node.leftAlignType == ConstraintAlignType.center) {
              left = node.leftConstraint!
                  .getXPercent(node.parentData.left!._bias ?? 0.5, this);
            } else {
              left = node.leftConstraint!.getRight(this);
            }
            double right;
            if (node.rightAlignType == ConstraintAlignType.left) {
              right = node.rightConstraint!.getX();
            } else if (node.rightAlignType == ConstraintAlignType.center) {
              right = node.rightConstraint!
                  .getXPercent(node.parentData.right!._bias ?? 0.5, this);
            } else {
              right = node.rightConstraint!.getRight(this);
            }
            double leftMargin;
            if (node.leftConstraint!.notLaidOut) {
              leftMargin = getLeftInsets(
                  goneMargin, node.percentageMargin, right - left);
            } else {
              leftMargin =
                  getLeftInsets(margin, node.percentageMargin, right - left);
            }
            double rightMargin;
            if (node.rightConstraint!.notLaidOut) {
              rightMargin = getRightInsets(
                  goneMargin, node.percentageMargin, right - left);
            } else {
              rightMargin =
                  getRightInsets(margin, node.percentageMargin, right - left);
            }
            minWidth =
                (right - rightMargin - left - leftMargin) * node.widthPercent;
          } else {
            minWidth = (size.width -
                    getHorizontalInsets(
                        margin, node.percentageMargin, size.width)) *
                node.widthPercent;
          }
          assert(() {
            if (minWidth < 0) {
              debugPrint(
                  'Warning: The child element with id ${node.nodeId} has a negative width');
            }
            return true;
          }());
          maxWidth = minWidth;
        }
      } else {
        minWidth = width;
        maxWidth = width;
      }

      /// Calculate child height
      double height = node.height;
      if (height == wrapContent) {
        minHeight = node.minHeight;
        if (node.maxHeight == matchParent) {
          if (selfSizeConfirmed) {
            if (node.renderBox is _ConstraintRenderBox) {
              maxHeight = double.infinity;
            } else {
              maxHeight = size.height;
            }
          } else {
            maxHeight = double.infinity;
          }
        } else {
          maxHeight = node.maxHeight;
        }
      } else if (height == matchParent) {
        minHeight = size.height -
            getVerticalInsets(margin, node.percentageMargin, size.height);
        assert(() {
          if (minHeight < 0) {
            debugPrint(
                'Warning: The child element with id ${node.nodeId} has a negative height');
          }
          return true;
        }());
        maxHeight = minHeight;
      } else if (height == matchConstraint) {
        if (node.widthHeightRatio != null &&
            node.widthIsExact &&
            node.ratioBaseOnWidth != false) {
          /// The height needs to be calculated later based on the width
          /// minWidth == maxWidth
          minHeight = minWidth / node.widthHeightRatio!;
          maxHeight = minHeight;
        } else {
          if (node.heightPercentageAnchor == PercentageAnchor.constraint) {
            double top;
            if (node.topAlignType == ConstraintAlignType.top) {
              top = node.topConstraint!.getY();
            } else if (node.topAlignType == ConstraintAlignType.center) {
              top = node.topConstraint!
                  .getYPercent(node.parentData.top!._bias ?? 0.5, this);
            } else {
              top = node.topConstraint!.getBottom(this);
            }
            double bottom;
            if (node.bottomAlignType == ConstraintAlignType.top) {
              bottom = node.bottomConstraint!.getY();
            } else if (node.bottomAlignType == ConstraintAlignType.center) {
              bottom = node.bottomConstraint!
                  .getYPercent(node.parentData.bottom!._bias ?? 0.5, this);
            } else {
              bottom = node.bottomConstraint!.getBottom(this);
            }
            double topMargin;
            if (node.topConstraint!.notLaidOut) {
              topMargin =
                  getTopInsets(goneMargin, node.percentageMargin, bottom - top);
            } else {
              topMargin =
                  getTopInsets(margin, node.percentageMargin, bottom - top);
            }
            double bottomMargin;
            if (node.bottomConstraint!.notLaidOut) {
              bottomMargin = getBottomInsets(
                  goneMargin, node.percentageMargin, bottom - top);
            } else {
              bottomMargin =
                  getBottomInsets(margin, node.percentageMargin, bottom - top);
            }
            minHeight =
                (bottom - bottomMargin - top - topMargin) * node.heightPercent;
          } else {
            minHeight = (size.height -
                    getVerticalInsets(
                        margin, node.percentageMargin, size.height)) *
                node.heightPercent;
          }
          assert(() {
            if (minHeight < 0) {
              debugPrint(
                  'Warning: The child element with id ${node.nodeId} has a negative height');
            }
            return true;
          }());
          maxHeight = minHeight;
        }
      } else {
        minHeight = height;
        maxHeight = height;
      }
    }

    /// The width needs to be calculated based on the height
    if (node.widthBasedHeight) {
      /// minHeight == maxHeight
      minWidth = minHeight * node.widthHeightRatio!;
      maxWidth = minWidth;
    }

    /// Measure
    if (maxWidth <= 0 || maxHeight <= 0) {
      node.notLaidOut = true;
      if (maxWidth < 0) {
        minWidth = 0;
        maxWidth = 0;
      }
      if (maxHeight < 0) {
        minHeight = 0;
        maxHeight = 0;
      }
      assert(() {
        if ((!node.isGuideline && !node.isBarrier) && node.visibility != gone) {
          debugPrint(
              'Warning: The child element with id ${node.nodeId} has a negative size, will not be laid out and paint.');
        }
        return true;
      }());
    } else {
      node.notLaidOut = false;
    }

    return BoxConstraints(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
    );
  }

  Offset calculateChildOffset(ConstrainedNode node) {
    if (node.anchors != null) {
      Offset offset = node.calcOffsetCallback!.call(this, node, node.anchors!);
      if (node.translateConstraint) {
        offset += node.translate;
      }
      return offset;
    }

    PinnedInfo? pinnedInfo;
    if (node.pinnedInfo != null) {
      pinnedInfo = node.pinnedInfo!;
    } else if (node.translate is PinnedTranslate && node.translateConstraint) {
      pinnedInfo = (node.translate as PinnedTranslate)._pinnedInfo;
    }
    if (pinnedInfo != null) {
      if (node.pinnedConstraint != null) {
        Offset selfOffset = pinnedInfo.selfAnchor._resolve(node.getSize());
        Offset targetOffset = pinnedInfo.targetAnchor!
            ._resolve(node.pinnedConstraint!.getSize(this));
        double offsetX =
            node.pinnedConstraint!.getX() + targetOffset.dx - selfOffset.dx;
        double offsetY =
            node.pinnedConstraint!.getY() + targetOffset.dy - selfOffset.dy;
        Offset offset = Offset(offsetX, offsetY);
        if (node.pinnedInfo != null && node.translateConstraint) {
          offset += node.translate;
        }
        return offset;
      }
    }

    EdgeInsets margin = node.margin;
    EdgeInsets goneMargin = node.goneMargin;
    double offsetX = 0;
    double offsetY = 0;
    if (node.isBarrier) {
      BarrierDirection direction = node.direction!;
      List<double> list = [];
      for (final id in node.referencedIds!) {
        if (direction == BarrierDirection.left) {
          list.add(node.parentData._constrainedNodeMap[id]!.getX());
        } else if (direction == BarrierDirection.top) {
          list.add(node.parentData._constrainedNodeMap[id]!.getY());
        } else if (direction == BarrierDirection.right) {
          list.add(node.parentData._constrainedNodeMap[id]!.getRight());
        } else {
          list.add(node.parentData._constrainedNodeMap[id]!.getBottom());
        }
      }
      if (direction == BarrierDirection.left) {
        offsetX = getMinDouble(list);
        offsetY = 0;
      } else if (direction == BarrierDirection.top) {
        offsetX = 0;
        offsetY = getMinDouble(list);
      } else if (direction == BarrierDirection.right) {
        offsetX = getMaxDouble(list);
        offsetY = 0;
      } else {
        offsetX = 0;
        offsetY = getMaxDouble(list);
      }
    } else {
      /// Calculate child x offset
      if (node.leftConstraint != null && node.rightConstraint != null) {
        double left;
        if (node.leftAlignType == ConstraintAlignType.left) {
          left = node.leftConstraint!.getX();
        } else if (node.leftAlignType == ConstraintAlignType.center) {
          left = node.leftConstraint!
              .getXPercent(node.parentData.left!._bias ?? 0.5, this);
        } else {
          left = node.leftConstraint!.getRight(this);
        }
        double right;
        if (node.rightAlignType == ConstraintAlignType.left) {
          right = node.rightConstraint!.getX();
        } else if (node.rightAlignType == ConstraintAlignType.center) {
          right = node.rightConstraint!
              .getXPercent(node.parentData.right!._bias ?? 0.5, this);
        } else {
          right = node.rightConstraint!.getRight(this);
        }
        double leftMargin;
        if (node.leftConstraint!.notLaidOut) {
          leftMargin =
              getLeftInsets(goneMargin, node.percentageMargin, right - left);
        } else {
          leftMargin =
              getLeftInsets(margin, node.percentageMargin, right - left);
        }
        double rightMargin;
        if (node.rightConstraint!.notLaidOut) {
          rightMargin =
              getRightInsets(goneMargin, node.percentageMargin, right - left);
        } else {
          rightMargin =
              getRightInsets(margin, node.percentageMargin, right - left);
        }
        offsetX = left +
            leftMargin +
            (right -
                    rightMargin -
                    left -
                    leftMargin -
                    node.getMeasuredWidth()) *
                node.horizontalBias;
      } else if (node.leftConstraint != null) {
        double left;
        if (node.leftAlignType == ConstraintAlignType.left) {
          left = node.leftConstraint!.getX();
        } else if (node.leftAlignType == ConstraintAlignType.center) {
          left = node.leftConstraint!
              .getXPercent(node.parentData.left!._bias ?? 0.5, this);
        } else {
          left = node.leftConstraint!.getRight(this);
        }
        if (node.leftConstraint!.notLaidOut) {
          left += getLeftInsets(goneMargin, node.percentageMargin, size.width);
        } else {
          left += getLeftInsets(margin, node.percentageMargin, size.width);
        }
        offsetX = left;
      } else if (node.rightConstraint != null) {
        double right;
        if (node.rightAlignType == ConstraintAlignType.left) {
          right = node.rightConstraint!.getX();
        } else if (node.rightAlignType == ConstraintAlignType.center) {
          right = node.rightConstraint!
              .getXPercent(node.parentData.right!._bias ?? 0.5, this);
        } else {
          right = node.rightConstraint!.getRight(this);
        }
        if (node.rightConstraint!.notLaidOut) {
          right -=
              getRightInsets(goneMargin, node.percentageMargin, size.width);
        } else {
          right -= getRightInsets(margin, node.percentageMargin, size.width);
        }
        offsetX = right - node.getMeasuredWidth();
      } else {
        /// It is not possible to execute this branch
      }

      /// Calculate child y offset
      if (node.topConstraint != null && node.bottomConstraint != null) {
        double top;
        if (node.topAlignType == ConstraintAlignType.top) {
          top = node.topConstraint!.getY();
        } else if (node.topAlignType == ConstraintAlignType.center) {
          top = node.topConstraint!
              .getYPercent(node.parentData.top!._bias ?? 0.5, this);
        } else {
          top = node.topConstraint!.getBottom(this);
        }
        double bottom;
        if (node.bottomAlignType == ConstraintAlignType.top) {
          bottom = node.bottomConstraint!.getY();
        } else if (node.bottomAlignType == ConstraintAlignType.center) {
          bottom = node.bottomConstraint!
              .getYPercent(node.parentData.bottom!._bias ?? 0.5, this);
        } else {
          bottom = node.bottomConstraint!.getBottom(this);
        }
        double topMargin;
        if (node.topConstraint!.notLaidOut) {
          topMargin =
              getTopInsets(goneMargin, node.percentageMargin, bottom - top);
        } else {
          topMargin = getTopInsets(margin, node.percentageMargin, bottom - top);
        }
        double bottomMargin;
        if (node.bottomConstraint!.notLaidOut) {
          bottomMargin =
              getBottomInsets(goneMargin, node.percentageMargin, bottom - top);
        } else {
          bottomMargin =
              getBottomInsets(margin, node.percentageMargin, bottom - top);
        }
        offsetY = top +
            topMargin +
            (bottom -
                    bottomMargin -
                    top -
                    topMargin -
                    node.getMeasuredHeight()) *
                node.verticalBias;
      } else if (node.topConstraint != null) {
        double top;
        if (node.topAlignType == ConstraintAlignType.top) {
          top = node.topConstraint!.getY();
        } else if (node.topAlignType == ConstraintAlignType.center) {
          top = node.topConstraint!
              .getYPercent(node.parentData.top!._bias ?? 0.5, this);
        } else {
          top = node.topConstraint!.getBottom(this);
        }
        if (node.topConstraint!.notLaidOut) {
          top += getTopInsets(goneMargin, node.percentageMargin, size.height);
        } else {
          top += getTopInsets(margin, node.percentageMargin, size.height);
        }
        offsetY = top;
      } else if (node.bottomConstraint != null) {
        double bottom;
        if (node.bottomAlignType == ConstraintAlignType.top) {
          bottom = node.bottomConstraint!.getY();
        } else if (node.bottomAlignType == ConstraintAlignType.center) {
          bottom = node.bottomConstraint!
              .getYPercent(node.parentData.bottom!._bias ?? 0.5, this);
        } else {
          bottom = node.bottomConstraint!.getBottom(this);
        }
        if (node.bottomConstraint!.notLaidOut) {
          bottom -=
              getBottomInsets(goneMargin, node.percentageMargin, size.height);
        } else {
          bottom -= getBottomInsets(margin, node.percentageMargin, size.height);
        }
        offsetY = bottom - node.getMeasuredHeight();
      } else if (node.baselineConstraint != null) {
        if (node.baselineAlignType == ConstraintAlignType.top) {
          offsetY = node.baselineConstraint!.getY() -
              node.getDistanceToBaseline(node.textBaseline, false);
        } else if (node.baselineAlignType == ConstraintAlignType.center) {
          offsetY = node.baselineConstraint!
                  .getYPercent(node.parentData.baseline!._bias ?? 0.5) -
              node.getDistanceToBaseline(node.textBaseline, false);
        } else if (node.baselineAlignType == ConstraintAlignType.bottom) {
          offsetY = node.baselineConstraint!.getBottom(this) -
              node.getDistanceToBaseline(node.textBaseline, false);
        } else {
          offsetY = node.baselineConstraint!
                  .getDistanceToBaseline(node.textBaseline, true) -
              node.getDistanceToBaseline(node.textBaseline, false);
        }
        if (node.baselineConstraint!.notLaidOut) {
          offsetY +=
              getTopInsets(goneMargin, node.percentageMargin, size.height);
          offsetY -=
              getBottomInsets(goneMargin, node.percentageMargin, size.height);
        } else {
          offsetY += getTopInsets(margin, node.percentageMargin, size.height);
          offsetY -=
              getBottomInsets(margin, node.percentageMargin, size.height);
        }
      } else {
        /// It is not possible to execute this branch
      }
    }

    if (node.translateConstraint) {
      Offset translate = node.translate;
      offsetX += translate.dx;
      offsetY += translate.dy;
    }

    return Offset(offsetX, offsetY);
  }

  @override
  bool hitTestChildren(
    BoxHitTestResult result, {
    required Offset position,
  }) {
    if (_needsReorderEventOrder) {
      insertionSort<ConstrainedNode>(eventOrderList, (left, right) {
        int result = left.eIndex - right.eIndex;
        if (result == 0) {
          result = left.index - right.index;
        }
        return result;
      });
      _needsReorderEventOrder = false;
    }

    for (final element in eventOrderList.reversed) {
      if (element.shouldNotPaint()) {
        continue;
      }

      Offset clickShift = Offset.zero;
      if (!element.translateConstraint) {
        clickShift = element.translate;
      }

      if (element.translate is PinnedTranslate &&
          !element.translateConstraint) {
        if (element.pinnedConstraint != null) {
          PinnedInfo pinnedInfo =
              (element.translate as PinnedTranslate)._pinnedInfo;
          Offset selfOffset = pinnedInfo.selfAnchor._resolve(element.getSize());
          Offset targetOffset = pinnedInfo.targetAnchor!
              ._resolve(element.pinnedConstraint!.getSize(this));
          double offsetX = element.pinnedConstraint!.getX() +
              targetOffset.dx -
              selfOffset.dx -
              element.getX();
          double offsetY = element.pinnedConstraint!.getY() +
              targetOffset.dy -
              selfOffset.dy -
              element.getY();
          clickShift = Offset(offsetX, offsetY);
        }
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
            x + element.getMeasuredWidth() + clickPadding.right;
        double clickPaddingBottom =
            y + element.getMeasuredHeight() + clickPadding.bottom;
        double xClickPercent = (offsetPos.dx - clickPaddingLeft) /
            (clickPaddingRight - clickPaddingLeft);
        double yClickPercent = (offsetPos.dy - clickPaddingTop) /
            (clickPaddingBottom - clickPaddingTop);
        double realClickX = x + xClickPercent * element.getMeasuredWidth();
        double realClickY = y + yClickPercent * element.getMeasuredHeight();
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
    Stopwatch? stopwatch;
    if (_showLayoutPerformanceOverlay) {
      stopwatch = Stopwatch()..start();
    }

    if (_needsReorderPaintingOrder) {
      insertionSort<ConstrainedNode>(paintingOrderList, (left, right) {
        int result = left.zIndex - right.zIndex;
        if (result == 0) {
          result = left.index - right.index;
        }
        return result;
      });
      _needsReorderPaintingOrder = false;
    }

    for (final element in paintingOrderList) {
      if (element.shouldNotPaint()) {
        continue;
      }

      Offset paintShift = Offset.zero;
      if (!element.translateConstraint) {
        paintShift = element.translate;
      }

      PinnedInfo? pinnedInfo;
      if (element.pinnedInfo != null) {
        pinnedInfo = element.pinnedInfo;
      } else if (element.translate is PinnedTranslate) {
        pinnedInfo = (element.translate as PinnedTranslate)._pinnedInfo;
        if (!element.translateConstraint) {
          if (element.pinnedConstraint != null) {
            Offset selfOffset =
                pinnedInfo.selfAnchor._resolve(element.getSize());
            Offset targetOffset = pinnedInfo.targetAnchor!
                ._resolve(element.pinnedConstraint!.getSize(this));
            double offsetX = element.pinnedConstraint!.getX() +
                targetOffset.dx -
                selfOffset.dx -
                element.getX();
            double offsetY = element.pinnedConstraint!.getY() +
                targetOffset.dy -
                selfOffset.dy -
                element.getY();
            paintShift = Offset(offsetX, offsetY);
          }
        }
      }
      if (pinnedInfo != null) {
        context.canvas.save();
        Offset anchorOffset = pinnedInfo.selfAnchor._resolve(element.getSize());
        context.canvas.translate(
            element.offset.dx + offset.dx + paintShift.dx + anchorOffset.dx,
            element.offset.dy + offset.dy + paintShift.dy + anchorOffset.dy);
        context.canvas.rotate(pinnedInfo.angle * pi / 180);
        context.paintChild(element.renderBox!, -anchorOffset);
        context.canvas.restore();
        if (element.paintCallback != null) {
          Offset paintOffset = Offset(element.offset.dx + paintShift.dx,
              element.offset.dy + paintShift.dy);
          element.paintCallback!.call(element.renderBox!, paintOffset,
              element.getSize(), paintOffset + anchorOffset, pinnedInfo.angle);
        }
      } else {
        context.paintChild(
            element.renderBox!, element.offset + offset + paintShift);
        if (element.paintCallback != null) {
          Offset paintOffset = element.offset + paintShift;
          element.paintCallback!.call(
              element.renderBox!, paintOffset, element.getSize(), null, null);
        }
      }

      /// Draw child's click area
      if (_showClickArea) {
        drawClickArea(element, context, offset + paintShift);
      }

      /// Draw child's z index
      if (_showZIndex) {
        drawZIndex(element, context, offset + paintShift);
      }

      if (_showChildDepth) {
        drawChildDepth(element, context, offset + paintShift);
      }
    }

    if (_showHelperWidgets) {
      for (final element in paintingOrderList) {
        drawHelperNodes(element, context, offset);
      }
    }

    if (stopwatch != null) {
      paintTimeUsage.add(stopwatch.elapsedMicroseconds);
      if (paintTimeUsage.length > maxTimeUsage) {
        paintTimeUsage.removeFirst();
      }
      debugShowPerformance(context, offset, constraintCalculationTimeUsage,
          layoutTimeUsage, paintTimeUsage);
    }
  }
}

/// All child elements and helper widgets will be converted to ConstrainedNode before layout
class ConstrainedNode {
  late ConstraintId nodeId;
  RenderBox? renderBox;
  ConstrainedNode? leftConstraint;
  ConstrainedNode? topConstraint;
  ConstrainedNode? rightConstraint;
  ConstrainedNode? bottomConstraint;
  ConstrainedNode? baselineConstraint;
  ConstrainedNode? pinnedConstraint;
  List<ConstrainedNode>? anchors;
  ConstraintAlignType? leftAlignType;
  ConstraintAlignType? topAlignType;
  ConstraintAlignType? rightAlignType;
  ConstraintAlignType? bottomAlignType;
  ConstraintAlignType? baselineAlignType;
  int depth = -1;
  late bool notLaidOut;
  late ConstraintBoxData parentData;
  late int index;
  bool widthBasedHeight = false;

  double get width => parentData.width!;

  double get height => parentData.height!;

  int get zIndex => parentData.zIndex ?? index;

  int get eIndex => parentData.eIndex ?? zIndex;

  bool laidOutLater = false;

  Offset get offset => parentData.offset;

  Offset get translate {
    if (!percentageTranslate || parentData.translate is PinnedTranslate) {
      return parentData.translate!;
    } else {
      double dx = renderBox!.size.width * parentData.translate!.dx;
      double dy = renderBox!.size.height * parentData.translate!.dy;
      return Offset(dx, dy);
    }
  }

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

  bool get percentageMargin => parentData.percentageMargin!;

  double get minWidth => parentData.minWidth!;

  double get maxWidth => parentData.maxWidth!;

  double get minHeight => parentData.minHeight!;

  double get maxHeight => parentData.maxHeight!;

  PercentageAnchor get widthPercentageAnchor =>
      parentData.widthPercentageAnchor!;

  PercentageAnchor get heightPercentageAnchor =>
      parentData.heightPercentageAnchor!;

  OnLayoutCallback? get layoutCallback => parentData.layoutCallback;

  OnPaintCallback? get paintCallback => parentData.paintCallback;

  List<ConstraintId>? get referencedIds => parentData._referencedIds;

  BarrierDirection? get direction => parentData._direction;

  bool get percentageTranslate => parentData.percentageTranslate!;

  double? get widthHeightRatio => parentData.widthHeightRatio;

  bool? get ratioBaseOnWidth => parentData.ratioBaseOnWidth;

  bool get isGuideline => parentData._isGuideline;

  bool get isBarrier => parentData._isBarrier;

  Size? get helperSize => parentData._helperSize;

  PinnedInfo? get pinnedInfo => parentData.pinnedInfo;

  CalcSizeCallback? get calcSizeCallback => parentData.calcSizeCallback;

  CalcOffsetCallback? get calcOffsetCallback => parentData.calcOffsetCallback;

  set helperSize(Size? size) {
    parentData._helperSize = size;
  }

  /// fixed size, matchParent, matchConstraint with two constraints
  bool get widthIsExact =>
      width >= 0 ||
      (width == matchParent) ||
      (width == matchConstraint &&
          widthPercentageAnchor == PercentageAnchor.parent) ||
      (width == matchConstraint &&
          leftConstraint != null &&
          rightConstraint != null);

  /// fixed size, matchParent, matchConstraint with two constraints
  bool get heightIsExact =>
      height >= 0 ||
      (height == matchParent) ||
      (height == matchConstraint &&
          heightPercentageAnchor == PercentageAnchor.parent) ||
      (height == matchConstraint &&
          (topConstraint != null && bottomConstraint != null));

  set offset(Offset value) {
    parentData.offset = value;
  }

  bool isParent() {
    return nodeId == parent;
  }

  bool shouldNotPaint() {
    return visibility == gone || visibility == invisible || notLaidOut;
  }

  double getX() {
    if (isParent()) {
      return 0;
    }
    return offset.dx;
  }

  double getXPercent(double percent, [RenderBox? parent]) {
    if (isParent()) {
      return parent!.size.width * percent;
    }
    return offset.dx + getMeasuredWidth() * percent;
  }

  double getY() {
    if (isParent()) {
      return 0;
    }
    return offset.dy;
  }

  double getYPercent(double percent, [RenderBox? parent]) {
    if (isParent()) {
      return parent!.size.height * percent;
    }
    return offset.dy + getMeasuredHeight() * percent;
  }

  double getRight([RenderBox? parent]) {
    if (isParent()) {
      return parent!.size.width;
    }
    return getX() + getMeasuredWidth();
  }

  double getBottom([RenderBox? parent]) {
    if (isParent()) {
      return parent!.size.height;
    }
    return getY() + getMeasuredHeight();
  }

  Size getSize([RenderBox? parent]) {
    if (isParent()) {
      return parent!.size;
    }
    return renderBox!.size;
  }

  double getMeasuredWidth() {
    if (isGuideline || isBarrier) {
      return helperSize!.width;
    }
    return renderBox!.size.width;
  }

  double getMeasuredHeight() {
    if (isGuideline || isBarrier) {
      return helperSize!.height;
    }
    return renderBox!.size.height;
  }

  double getDistanceToBaseline(TextBaseline textBaseline, bool absolute) {
    if (isParent()) {
      return 0;
    }
    if (isGuideline || isBarrier) {
      return getY();
    }
    double? baseline =
        renderBox!.getDistanceToBaseline(textBaseline, onlyReal: true);
    if (baseline == null) {
      baseline = getY();
    } else {
      if (absolute) {
        baseline += getY();
      }
    }
    return baseline;
  }

  int getDepthFor(ConstrainedNode constrainedNode, bool? parentSizeConfirmed,
      double? resolvedWidth, double? resolvedHeight) {
    if (parentSizeConfirmed == false) {
      if (constrainedNode.isParent()) {
        /// The width and height can be calculated directly without relying on parent
        if ((width >= 0 ||
                width == wrapContent ||
                (width == matchParent && resolvedWidth != wrapContent)) &&
            (height >= 0 ||
                height == wrapContent ||
                (height == matchParent && resolvedHeight != wrapContent))) {
          return 0;
        }
      }
    }
    return constrainedNode.getDepth(
        parentSizeConfirmed, resolvedWidth, resolvedHeight);
  }

  int getDepth(bool? parentSizeConfirmed, double? resolvedWidth,
      double? resolvedHeight) {
    if (depth < 0) {
      if (isBarrier) {
        List<int> list = [
          for (final id in referencedIds!)
            parentData._constrainedNodeMap[id]!
                .getDepth(parentSizeConfirmed, resolvedWidth, resolvedHeight)
        ];
        depth = getMaxInt(list) + 1;
      } else {
        List<int> list = [
          if (leftConstraint != null)
            getDepthFor(leftConstraint!, parentSizeConfirmed, resolvedWidth,
                resolvedHeight),
          if (topConstraint != null)
            getDepthFor(topConstraint!, parentSizeConfirmed, resolvedWidth,
                resolvedHeight),
          if (rightConstraint != null)
            getDepthFor(rightConstraint!, parentSizeConfirmed, resolvedWidth,
                resolvedHeight),
          if (bottomConstraint != null)
            getDepthFor(bottomConstraint!, parentSizeConfirmed, resolvedWidth,
                resolvedHeight),
          if (baselineConstraint != null)
            getDepthFor(baselineConstraint!, parentSizeConfirmed, resolvedWidth,
                resolvedHeight),
          if (pinnedConstraint != null)
            getDepthFor(pinnedConstraint!, parentSizeConfirmed, resolvedWidth,
                resolvedHeight),
          if (anchors != null)
            for (final element in anchors!)
              getDepthFor(
                  element, parentSizeConfirmed, resolvedWidth, resolvedHeight),
        ];
        depth = getMaxInt(list) + 1;
      }
    }
    return depth;
  }
}

class _HelperBox extends RenderBox {
  static void initParentData(ConstraintBoxData constraintBoxData) {
    constraintBoxData.width = 0;
    constraintBoxData.height = 0;
    constraintBoxData.clickPadding = EdgeInsets.zero;
    constraintBoxData.visibility = invisible;
    constraintBoxData.percentageMargin = false;
    constraintBoxData.margin = EdgeInsets.zero;
    constraintBoxData.goneMargin = EdgeInsets.zero;
    constraintBoxData.left = null;
    constraintBoxData.top = null;
    constraintBoxData.right = null;
    constraintBoxData.bottom = null;
    constraintBoxData.baseline = null;
    constraintBoxData.textBaseline = TextBaseline.alphabetic;
    constraintBoxData.zIndex = null;
    constraintBoxData.translate = Offset.zero;
    constraintBoxData.translateConstraint = false;
    constraintBoxData.widthPercent = 1;
    constraintBoxData.heightPercent = 1;
    constraintBoxData.widthPercentageAnchor = PercentageAnchor.constraint;
    constraintBoxData.heightPercentageAnchor = PercentageAnchor.constraint;
    constraintBoxData.horizontalBias = 0.5;
    constraintBoxData.verticalBias = 0.5;
    constraintBoxData.layoutCallback = null;
    constraintBoxData.paintCallback = null;
    constraintBoxData.percentageTranslate = false;
    constraintBoxData.minWidth = 0;
    constraintBoxData.maxWidth = matchParent;
    constraintBoxData.minHeight = 0;
    constraintBoxData.maxHeight = matchParent;
    constraintBoxData.widthHeightRatio = null;
    constraintBoxData.ratioBaseOnWidth = null;
    constraintBoxData.eIndex = null;
    constraintBoxData.pinnedInfo = null;
    constraintBoxData.anchors = null;
    constraintBoxData.calcSizeCallback = null;
    constraintBoxData.calcOffsetCallback = null;
    constraintBoxData._direction = null;
    constraintBoxData._referencedIds = null;
    constraintBoxData._isGuideline = false;
    constraintBoxData._isBarrier = false;
    constraintBoxData._helperSize = null;
  }

  @protected
  @mustCallSuper
  void updateParentData() {
    ConstraintBoxData constraintBoxData = parentData as ConstraintBoxData;
    initParentData(constraintBoxData);
  }
}

class GuidelineDefine extends ConstraintDefine {
  final double? guidelineBegin;
  final double? guidelineEnd;
  final double? guidelinePercent;
  final bool horizontal;

  GuidelineDefine({
    required ConstraintId id,
    this.guidelineBegin,
    this.guidelineEnd,
    this.guidelinePercent,
    this.horizontal = false,
  }) : super(id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is GuidelineDefine &&
          runtimeType == other.runtimeType &&
          guidelineBegin == other.guidelineBegin &&
          guidelineEnd == other.guidelineEnd &&
          guidelinePercent == other.guidelinePercent &&
          horizontal == other.horizontal;

  @override
  int get hashCode =>
      super.hashCode ^
      guidelineBegin.hashCode ^
      guidelineEnd.hashCode ^
      guidelinePercent.hashCode ^
      horizontal.hashCode;
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
      debugEnsurePercent('guidelinePercent', guidelinePercent);
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

class _GuidelineRenderBox extends _HelperBox {
  late ConstraintId _id;
  late bool _horizontal;
  double? _guidelineBegin;
  double? _guidelineEnd;
  double? _guidelinePercent;

  set id(ConstraintId value) {
    if (_id != value) {
      _id = value;
      updateParentData();
      (this.parent as _ConstraintRenderBox).markNeedsRecalculateConstraints();
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
    ConstraintBoxData constraintBoxData = parentData as ConstraintBoxData;
    initParentData(
      constraintBoxData,
      id: _id,
      horizontal: _horizontal,
      guidelineBegin: _guidelineBegin,
      guidelineEnd: _guidelineEnd,
      guidelinePercent: _guidelinePercent,
    );
  }

  @override
  void performLayout() {
    if (_horizontal) {
      size = Size(constraints.minWidth, 0);
    } else {
      size = Size(0, constraints.minHeight);
    }
  }

  static void initParentData(
    ConstraintBoxData constraintBoxData, {
    required ConstraintId id,
    required bool horizontal,
    double? guidelineBegin,
    double? guidelineEnd,
    double? guidelinePercent,
  }) {
    constraintBoxData.id = id;
    constraintBoxData._isGuideline = true;
    if (horizontal) {
      if (guidelineBegin != null) {
        constraintBoxData.left = parent.left;
        constraintBoxData.top = parent.top;
        constraintBoxData.right = parent.right;
        constraintBoxData.width = matchParent;
        constraintBoxData.margin = EdgeInsets.only(top: guidelineBegin);
      } else if (guidelineEnd != null) {
        constraintBoxData.left = parent.left;
        constraintBoxData.right = parent.right;
        constraintBoxData.bottom = parent.bottom;
        constraintBoxData.width = matchParent;
        constraintBoxData.margin = EdgeInsets.only(bottom: guidelineEnd);
      } else {
        constraintBoxData.left = parent.left;
        constraintBoxData.top = parent.top;
        constraintBoxData.right = parent.right;
        constraintBoxData.width = matchParent;
        constraintBoxData.margin = EdgeInsets.only(
          top: guidelinePercent!,
        );
        constraintBoxData.percentageMargin = true;
      }
    } else {
      if (guidelineBegin != null) {
        constraintBoxData.left = parent.left;
        constraintBoxData.top = parent.top;
        constraintBoxData.bottom = parent.bottom;
        constraintBoxData.height = matchParent;
        constraintBoxData.margin = EdgeInsets.only(left: guidelineBegin);
      } else if (guidelineEnd != null) {
        constraintBoxData.top = parent.top;
        constraintBoxData.right = parent.right;
        constraintBoxData.bottom = parent.bottom;
        constraintBoxData.height = matchParent;
        constraintBoxData.margin = EdgeInsets.only(right: guidelineEnd);
      } else {
        constraintBoxData.left = parent.left;
        constraintBoxData.top = parent.top;
        constraintBoxData.bottom = parent.bottom;
        constraintBoxData.height = matchParent;
        constraintBoxData.margin = EdgeInsets.only(
          left: guidelinePercent!,
        );
        constraintBoxData.percentageMargin = true;
      }
    }
  }
}

class BarrierDefine extends ConstraintDefine {
  final BarrierDirection direction;
  final List<ConstraintId> referencedIds;

  BarrierDefine({
    required ConstraintId id,
    required this.direction,
    required this.referencedIds,
  }) : super(id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is BarrierDefine &&
          runtimeType == other.runtimeType &&
          direction == other.direction &&
          referencedIds == other.referencedIds;

  @override
  int get hashCode =>
      super.hashCode ^ direction.hashCode ^ referencedIds.hashCode;
}

class Barrier extends LeafRenderObjectWidget {
  final ConstraintId id;
  final BarrierDirection direction;
  final List<ConstraintId> referencedIds;

  const Barrier({
    Key? key,
    required this.id,
    required this.direction,
    required this.referencedIds,
  }) : super(key: key);

  bool _checkParam() {
    if (referencedIds.isEmpty) {
      throw ConstraintLayoutException('referencedIds can not be empty.');
    }
    if (referencedIds.toSet().length != referencedIds.length) {
      throw ConstraintLayoutException('Duplicate id in referencedIds.');
    }
    return true;
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    assert(_checkParam());
    return _BarrierRenderBox()
      .._id = id
      .._direction = direction
      .._referencedIds = referencedIds;
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderObject renderObject) {
    assert(_checkParam());
    (renderObject as _BarrierRenderBox)
      ..id = id
      ..direction = direction
      ..referencedIds = referencedIds;
  }
}

class _BarrierRenderBox extends _HelperBox {
  late ConstraintId _id;
  late BarrierDirection _direction;
  late List<ConstraintId> _referencedIds;

  @override
  void updateParentData() {
    super.updateParentData();
    ConstraintBoxData constraintBoxData = parentData as ConstraintBoxData;
    initParentData(
      constraintBoxData,
      id: _id,
      direction: _direction,
      referencedIds: _referencedIds,
    );
  }

  set id(ConstraintId value) {
    if (_id != value) {
      _id = value;
      updateParentData();
      (this.parent as _ConstraintRenderBox).markNeedsRecalculateConstraints();
      markParentNeedsLayout();
    }
  }

  set direction(BarrierDirection value) {
    if (_direction != value) {
      _direction = value;
      updateParentData();
      markParentNeedsLayout();
    }
  }

  set referencedIds(List<ConstraintId> value) {
    if (!listEquals(_referencedIds, value)) {
      _referencedIds = value;
      updateParentData();
      (this.parent as _ConstraintRenderBox).markNeedsRecalculateConstraints();
      markParentNeedsLayout();
    }
  }

  @override
  void performLayout() {
    if (_direction == BarrierDirection.top ||
        _direction == BarrierDirection.bottom) {
      size = Size(constraints.minWidth, 0);
    } else {
      size = Size(0, constraints.minHeight);
    }
  }

  static void initParentData(
    ConstraintBoxData constraintBoxData, {
    required ConstraintId id,
    required BarrierDirection direction,
    required List<ConstraintId> referencedIds,
  }) {
    constraintBoxData.id = id;
    constraintBoxData._isBarrier = true;
    constraintBoxData._direction = direction;
    constraintBoxData._referencedIds = referencedIds;
    if (direction == BarrierDirection.top ||
        direction == BarrierDirection.bottom) {
      constraintBoxData.top = parent.top;
      constraintBoxData.left = parent.left;
      constraintBoxData.right = parent.right;
    } else {
      constraintBoxData.left = parent.left;
      constraintBoxData.top = parent.top;
      constraintBoxData.bottom = parent.bottom;
    }
  }
}
