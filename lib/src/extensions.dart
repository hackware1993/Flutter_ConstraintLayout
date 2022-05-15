import 'dart:math';

import 'package:flutter/material.dart';

import 'core.dart';

ConstraintId cId(String id) {
  return ConstraintId(id);
}

ConstraintId rId(int childIndex) {
  assert(childIndex >= 0);
  return IndexConstraintId(childIndex);
}

ConstraintId sId(int siblingIndexOffset) {
  /// Can't rely on oneself
  assert(siblingIndexOffset != 0);
  return RelativeConstraintId(siblingIndexOffset);
}

/// For performance optimization
class OffBuildWidget extends StatelessWidget {
  final String id;
  final Widget child;

  const OffBuildWidget({
    Key? key,
    required this.id,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }

  @override
  // ignore: invalid_override_of_non_virtual_member
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OffBuildWidget &&
          runtimeType == other.runtimeType &&
          id == (other).id;

  @override
  // ignore: invalid_override_of_non_virtual_member
  int get hashCode => id.hashCode;
}

/// For easy use
extension ConstrainedWidgetsExt on Widget {
  Constrained applyConstraint({
    ConstraintId? id,
    double width = wrapContent,
    double height = wrapContent,
    double? size,
    ConstraintAlign? left,
    ConstraintAlign? top,
    ConstraintAlign? right,
    ConstraintAlign? bottom,
    ConstraintAlign? baseline,
    EdgeInsets clickPadding = EdgeInsets.zero,
    CLVisibility visibility = visible,
    bool percentageMargin = false,
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
    ConstraintId? topLeftTo,
    ConstraintId? topCenterTo,
    ConstraintId? topRightTo,
    ConstraintId? centerLeftTo,
    ConstraintId? centerTo,
    ConstraintId? centerRightTo,
    ConstraintId? bottomLeftTo,
    ConstraintId? bottomCenterTo,
    ConstraintId? bottomRightTo,
    ConstraintId? centerHorizontalTo,
    ConstraintId? centerVerticalTo,
    ConstraintId? outTopLeftTo,
    ConstraintId? outTopCenterTo,
    ConstraintId? outTopRightTo,
    ConstraintId? outCenterLeftTo,
    ConstraintId? outCenterRightTo,
    ConstraintId? outBottomLeftTo,
    ConstraintId? outBottomCenterTo,
    ConstraintId? outBottomRightTo,
    ConstraintId? centerTopLeftTo,
    ConstraintId? centerTopCenterTo,
    ConstraintId? centerTopRightTo,
    ConstraintId? centerCenterLeftTo,
    ConstraintId? centerCenterRightTo,
    ConstraintId? centerBottomLeftTo,
    ConstraintId? centerBottomCenterTo,
    ConstraintId? centerBottomRightTo,
    OnLayoutCallback? layoutCallback,
    OnPaintCallback? paintCallback,
    double chainWeight = 1,
    bool percentageTranslate = false,
    double minWidth = 0,
    double maxWidth = matchParent,
    double minHeight = 0,
    double maxHeight = matchParent,
    double? widthHeightRatio,
    bool? ratioBaseOnWidth,
    int? eIndex,
    PinnedInfo? pinnedInfo,
    List<ConstraintId>? anchors,
    CalcSizeCallback? calcSizeCallback,
    CalcOffsetCallback? calcOffsetCallback,
  }) {
    return Constrained(
      key: key,
      constraint: Constraint(
        id: id,
        width: width,
        height: height,
        size: size,
        left: left,
        top: top,
        right: right,
        bottom: bottom,
        baseline: baseline,
        clickPadding: clickPadding,
        visibility: visibility,
        percentageMargin: percentageMargin,
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
        layoutCallback: layoutCallback,
        paintCallback: paintCallback,
        percentageTranslate: percentageTranslate,
        minWidth: minWidth,
        maxWidth: maxWidth,
        minHeight: minHeight,
        maxHeight: maxHeight,
        widthHeightRatio: widthHeightRatio,
        ratioBaseOnWidth: ratioBaseOnWidth,
        outTopLeftTo: outTopLeftTo,
        outTopCenterTo: outTopCenterTo,
        outTopRightTo: outTopRightTo,
        outCenterLeftTo: outCenterLeftTo,
        outCenterRightTo: outCenterRightTo,
        outBottomLeftTo: outBottomLeftTo,
        outBottomCenterTo: outBottomCenterTo,
        outBottomRightTo: outBottomRightTo,
        centerTopLeftTo: centerTopLeftTo,
        centerTopCenterTo: centerTopCenterTo,
        centerTopRightTo: centerTopRightTo,
        centerCenterLeftTo: centerCenterLeftTo,
        centerCenterRightTo: centerCenterRightTo,
        centerBottomLeftTo: centerBottomLeftTo,
        centerBottomCenterTo: centerBottomCenterTo,
        centerBottomRightTo: centerBottomRightTo,
        eIndex: eIndex,
        pinnedInfo: pinnedInfo,
        anchors: anchors,
        calcSizeCallback: calcSizeCallback,
        calcOffsetCallback: calcOffsetCallback,
      ),
      child: this,
    );
  }

  Constrained apply({
    required Constraint constraint,
  }) {
    return Constrained(
      key: key,
      constraint: constraint,
      child: this,
    );
  }

  UnConstrained applyConstraintId({
    required ConstraintId id,
  }) {
    return UnConstrained(
      key: key,
      id: id,
      child: this,
    );
  }

  /// When the layout is complex, if the child elements need to be repainted frequently, it
  /// is recommended to use RepaintBoundary to improve performance.
  RepaintBoundary offPaint() {
    return RepaintBoundary(
      key: key,
      child: this,
    );
  }

  /// If you can't declare a child element as const and it won't change, you can use OffBuildWidget
  /// to avoid the rebuilding of the child element.
  OffBuildWidget offBuild({
    required String id,
  }) {
    return OffBuildWidget(
      key: key,
      id: id,
      child: this,
    );
  }

  Widget debugWrap([Color? color]) {
    return Center(
      child: Container(
        color: color ?? Colors.black,
        child: this,
      ),
    );
  }
}

/// For circle position
Offset circleTranslate({
  required double radius,

  /// [0.0,360.0]
  required double angle,
}) {
  assert(radius >= 0 && radius != double.infinity);
  double xTranslate = sin((angle / 180) * pi) * radius;
  double yTranslate = -cos((angle / 180) * pi) * radius;
  return Offset(xTranslate, yTranslate);
}

/// For list、grid、staggered grid
List<Widget> constraintGrid({
  required ConstraintId id,
  required ConstraintAlign left,
  required ConstraintAlign top,
  required int itemCount,
  required int columnCount,
  double? itemWidth,
  double? itemHeight,
  double? itemSize,
  Size Function(int index, int rowIndex, int columnIndex)? itemSizeBuilder,
  required Widget Function(int index, int rowIndex, int columnIndex)
      itemBuilder,
  EdgeInsets Function(int index, int rowIndex, int columnIndex)?
      itemMarginBuilder,
  int Function(int index)? itemSpanBuilder,
  EdgeInsets margin = EdgeInsets.zero,
  CLVisibility visibility = visible,
  Offset translate = Offset.zero,
  bool translateConstraint = false,
  int? zIndex,
}) {
  assert(itemCount > 0);
  assert(columnCount > 0);
  assert(itemWidth == null || (itemWidth >= 0 || itemWidth != matchConstraint));
  assert(
      itemHeight == null || (itemHeight >= 0 || itemHeight != matchConstraint));
  assert(itemSize == null || (itemSize >= 0 || itemSize != matchConstraint));
  if (itemSize != null) {
    itemWidth = itemSize;
    itemHeight = itemSize;
  }
  assert((itemSizeBuilder == null && itemWidth != null && itemHeight != null) ||
      (itemSizeBuilder != null && itemWidth == null && itemHeight == null));
  List<Widget> widgets = [];
  ConstraintAlign leftAnchor = left;
  ConstraintAlign topAnchor = top;

  EdgeInsets leftMargin = EdgeInsets.only(
    left: margin.left,
  );
  EdgeInsets topMargin = EdgeInsets.only(
    top: margin.top,
  );

  List<ConstraintId> allChildIds = [];
  List<ConstraintId> leftChildIds = [];
  List<ConstraintId> topChildIds = [];
  List<ConstraintId> rightChildIds = [];
  List<ConstraintId> bottomChildIds = [];
  int totalAvailableSpanCount = (itemCount / columnCount).ceil() * columnCount;
  int currentRowIndex = -1;
  int currentRowUsedSpanCount = columnCount + 1;
  int totalUsedSpanCount = 0;
  late int currentRowBarrierCount;
  List<ConstraintId?> currentSpanSlot = List.filled(columnCount + 1, null);
  for (int i = 0; i < itemCount; i++) {
    ConstraintId itemId = ConstraintId(id.id + '_grid_item_$i');
    allChildIds.add(itemId);

    int itemSpan = itemSpanBuilder?.call(i) ?? 1;
    assert(itemSpan >= 1 && itemSpan <= columnCount);
    currentRowUsedSpanCount += itemSpan;
    totalUsedSpanCount += itemSpan;

    late EdgeInsets childMargin;

    /// New row start
    if (currentRowUsedSpanCount > columnCount) {
      currentRowIndex++;
      currentRowUsedSpanCount = itemSpan;
      currentRowBarrierCount = 0;
      if (i > 0) {
        if (!rightChildIds.contains(allChildIds[i - 1])) {
          /// Last column
          rightChildIds.add(allChildIds[i - 1]);
        }
      } else {
        if (itemSpan == columnCount) {
          /// Last column
          rightChildIds.add(itemId);
        }
      }

      /// First column
      leftAnchor = left;
      leftChildIds.add(itemId);
      childMargin = (itemMarginBuilder?.call(
                  i, currentRowIndex, currentRowUsedSpanCount - 1) ??
              EdgeInsets.zero)
          .add(leftMargin) as EdgeInsets;
    } else {
      childMargin = itemMarginBuilder?.call(
              i, currentRowIndex, currentRowUsedSpanCount - 1) ??
          EdgeInsets.zero;
    }

    // First row
    if (currentRowIndex == 0) {
      childMargin = childMargin.add(topMargin) as EdgeInsets;
      topChildIds.add(itemId);
    }

    // Last row
    if (totalAvailableSpanCount - totalUsedSpanCount < columnCount) {
      bottomChildIds.add(itemId);
    }

    if (currentRowIndex > 0) {
      if (itemSpan == 1) {
        topAnchor = currentSpanSlot[currentRowUsedSpanCount]!.bottom;
      } else {
        List<ConstraintId> referencedIds = [];
        for (int i = 0; i < itemSpan; i++) {
          ConstraintId id = currentSpanSlot[currentRowUsedSpanCount - i]!;
          if (!referencedIds.contains(id)) {
            referencedIds.add(id);
          }
        }
        ConstraintId rowBarrierId = ConstraintId(id.id +
            '_row_${currentRowIndex}_bottom_barrier_$currentRowBarrierCount');
        Barrier rowBottomBarrier = Barrier(
          id: rowBarrierId,
          direction: BarrierDirection.bottom,
          referencedIds: referencedIds,
        );
        widgets.add(rowBottomBarrier);
        topAnchor = rowBarrierId.bottom;
        currentRowBarrierCount++;
      }
    }

    Widget widget =
        itemBuilder(i, currentRowIndex, currentRowUsedSpanCount - 1);
    Size? itemSize =
        itemSizeBuilder?.call(i, currentRowIndex, currentRowUsedSpanCount - 1);
    double width = itemWidth ?? itemSize!.width;
    double height = itemHeight ?? itemSize!.height;

    widgets.add(Constrained(
      child: widget,
      constraint: Constraint(
        id: itemId,
        width: width,
        height: height,
        left: width == matchParent ? null : leftAnchor,
        top: height == matchParent ? null : topAnchor,
        zIndex: zIndex,
        translate: translate,
        visibility: visibility,
        margin: childMargin,
        goneMargin: childMargin,
      ),
    ));

    leftAnchor = itemId.right;
    for (int i = 0; i < itemSpan; i++) {
      currentSpanSlot[currentRowUsedSpanCount - i] = itemId;
    }
  }

  if (!rightChildIds.contains(allChildIds.last)) {
    rightChildIds.add(allChildIds.last);
  }

  Barrier leftBarrier = Barrier(
    id: ConstraintId(id.id + '_left_barrier'),
    direction: BarrierDirection.left,
    referencedIds: leftChildIds,
  );

  Barrier topBarrier = Barrier(
    id: ConstraintId(id.id + '_top_barrier'),
    direction: BarrierDirection.top,
    referencedIds: topChildIds,
  );

  Barrier rightBarrier = Barrier(
    id: ConstraintId(id.id + '_right_barrier'),
    direction: BarrierDirection.right,
    referencedIds: rightChildIds,
  );

  Barrier bottomBarrier = Barrier(
    id: ConstraintId(id.id + '_bottom_barrier'),
    direction: BarrierDirection.bottom,
    referencedIds: bottomChildIds,
  );

  widgets.add(leftBarrier);
  widgets.add(topBarrier);
  widgets.add(rightBarrier);
  widgets.add(bottomBarrier);

  widgets.add(const SizedBox().applyConstraint(
    id: id,
    size: matchConstraint,
    left: leftBarrier.id.left,
    top: topBarrier.id.top,
    right: rightBarrier.id.right,
    bottom: bottomBarrier.id.bottom,
    zIndex: -1,
    translate: translate,
    translateConstraint: translateConstraint,
    visibility: invisible,
  ));

  return widgets;
}
