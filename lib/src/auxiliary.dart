import 'dart:collection';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'core.dart';

double getLeftInsets(
  EdgeInsets insets, [
  bool percentageMargin = false,
  double anchorWidth = 0,
]) {
  if (percentageMargin) {
    return anchorWidth * insets.left;
  } else {
    return insets.left;
  }
}

double getTopInsets(
  EdgeInsets insets, [
  bool percentageMargin = false,
  double anchorHeight = 0,
]) {
  if (percentageMargin) {
    return anchorHeight * insets.top;
  } else {
    return insets.top;
  }
}

double getRightInsets(
  EdgeInsets insets, [
  bool percentageMargin = false,
  double anchorWidth = 0,
]) {
  if (percentageMargin) {
    return anchorWidth * insets.right;
  } else {
    return insets.right;
  }
}

double getBottomInsets(
  EdgeInsets insets, [
  bool percentageMargin = false,
  double anchorHeight = 0,
]) {
  if (percentageMargin) {
    return anchorHeight * insets.bottom;
  } else {
    return insets.bottom;
  }
}

double getHorizontalInsets(
  EdgeInsets insets, [
  bool percentageMargin = false,
  double anchorWidth = 0,
]) {
  return getLeftInsets(insets, percentageMargin, anchorWidth) +
      getRightInsets(insets, percentageMargin, anchorWidth);
}

double getVerticalInsets(
  EdgeInsets insets, [
  bool percentageMargin = false,
  double anchorHeight = 0,
]) {
  return getTopInsets(insets, percentageMargin, anchorHeight) +
      getBottomInsets(insets, percentageMargin, anchorHeight);
}

bool debugEnsureNotEmptyString(String name, String? value) {
  if (value != null && value.trim().isEmpty) {
    throw ConstraintLayoutException(
        '$name can be null, but not an empty string.');
  }
  return true;
}

bool debugEnsurePercent(String name, double? percent) {
  if (percent == null || percent < 0 || percent > 1) {
    throw ConstraintLayoutException('$name is between [0.0,1.0].');
  }
  return true;
}

bool debugEnsureNegativePercent(String name, double? percent) {
  if (percent == null || percent < -1 || percent > 1) {
    throw ConstraintLayoutException('$name is between [-1.0,1.0].');
  }
  return true;
}

bool debugCheckSize(double size) {
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

/// Beyond the border, it can't be pinned
void debugCheckAnchorBounds(double value, AnchorType anchorType, double size) {
  if (anchorType == AnchorType.absolute) {
    assert(value >= 0 && value <= size);
  } else {
    debugEnsurePercent('xOffset or yOffset', value);
  }
}

int getMinimalConstraintCount(double size) {
  if (size == matchParent) {
    return 0;
  } else if (size == wrapContent || size >= 0) {
    return 1;
  } else {
    return 2;
  }
}

/// There should be no loop constraints
void debugCheckLoopConstraints(List<ConstrainedNode> nodeList,
    bool selfSizeConfirmed, double resolvedWidth, double resolvedHeight) {
  for (final element in nodeList) {
    try {
      element.getDepth(selfSizeConfirmed, resolvedWidth, resolvedHeight);
    } on StackOverflowError catch (_) {
      throw ConstraintLayoutException(
          'There are some loop constraints, please check the code. For layout performance considerations, constraints are always one-way, and there should be no two child elements directly or indirectly restrain each other. Each constraint should describe exactly where the child elements are located. Use Guideline to break loop constraints.');
    }
  }
}

/// Each child element must have complete constraints both horizontally and vertically
void debugCheckConstraintsIntegrity(List<ConstrainedNode> nodeList) {
  for (final element in nodeList) {
    if (element.pinnedInfo != null) {
      if (element.width != wrapContent && element.width < 0) {
        throw ConstraintLayoutException(
            'When setting pinnedInfo, width and height must be wrapContent or fixed size.');
      }
      if (element.height != wrapContent && element.height < 0) {
        throw ConstraintLayoutException(
            'When setting pinnedInfo, width and height must be wrapContent or fixed size.');
      }
      if (element.pinnedInfo!.targetId == null) {
        throw ConstraintLayoutException(
            'When setting pinnedInfo, targetId can not be null.');
      }
      if (element.pinnedInfo!.targetAnchor == null) {
        throw ConstraintLayoutException(
            'When setting pinnedInfo, targetAnchor can not be null.');
      }
      if (element.translate is PinnedTranslate) {
        throw ConstraintLayoutException(
            'When setting pinnedInfo, pinned translate can not be set.');
      }
      continue;
    }

    if (element.anchors != null) {
      if (element.width != matchConstraint ||
          element.height != matchConstraint) {
        throw ConstraintLayoutException(
            'When setting anchors, width and height must be matchConstraint.');
      }
      if (element.calcSizeCallback == null ||
          element.calcOffsetCallback == null) {
        throw ConstraintLayoutException(
            'When setting anchors, calcSizeCallback and calcOffsetCallback must provide.');
      }
      continue;
    }

    /// Check constraint integrity in the horizontal direction
    if (element.width == wrapContent || element.width >= 0) {
      if (element.leftConstraint == null && element.rightConstraint == null) {
        throw ConstraintLayoutException(
            'Need to set a left or right constraint for ${element.nodeId}.');
      }
    } else if (element.width == matchConstraint) {
      if (element.widthHeightRatio == null) {
        if (element.widthPercentageAnchor == PercentageAnchor.constraint) {
          if (element.leftConstraint == null ||
              element.rightConstraint == null) {
            throw ConstraintLayoutException(
                'Need to set left and right constraints for ${element.nodeId}.');
          }
        } else {
          if (element.leftConstraint == null &&
              element.rightConstraint == null) {
            throw ConstraintLayoutException(
                'Need to set a left or right constraint for ${element.nodeId}.');
          }
        }
      } else {
        if (element.leftConstraint == null && element.rightConstraint == null) {
          throw ConstraintLayoutException(
              'Need to set a left or right constraint for ${element.nodeId}.');
        }
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
      if (element.widthHeightRatio == null) {
        if (element.heightPercentageAnchor == PercentageAnchor.constraint) {
          if (element.topConstraint == null ||
              element.bottomConstraint == null) {
            throw ConstraintLayoutException(
                'Need to set both top and bottom constraints for ${element.nodeId}.');
          }
        } else {
          if (element.topConstraint == null &&
              element.bottomConstraint == null) {
            throw ConstraintLayoutException(
                'Need to set a top or bottom constraints for ${element.nodeId}.');
          }
        }
      } else {
        if (element.topConstraint == null && element.bottomConstraint == null) {
          throw ConstraintLayoutException(
              'Need to set a top or bottom constraints for ${element.nodeId}.');
        }
      }
    } else {
      /// match_parent
      if (element.baselineConstraint != null) {
        throw ConstraintLayoutException(
            'When setting a baseline constraint for ${element.nodeId}, its height must be fixed or wrap_content.');
      }
    }

    if (element.widthHeightRatio != null) {
      if (element.widthIsExact && element.heightIsExact) {
        if (element.width == matchConstraint &&
            element.height == matchConstraint) {
          if (element.ratioBaseOnWidth == null) {
            throw ConstraintLayoutException(
                'When setting widthHeightRatio for ${element.nodeId}, ratioBaseOnWidth is required.');
          }
        }
      } else if (!element.widthIsExact && !element.heightIsExact) {
        throw ConstraintLayoutException(
            'When setting widthHeightRatio for ${element.nodeId}, one side needs full constraints.');
      } else if (element.widthIsExact) {
        if (element.height != matchConstraint) {
          throw ConstraintLayoutException(
              'When setting widthHeightRatio for ${element.nodeId}, width is exact, height must be matchConstraint.');
        }
      } else {
        if (element.width != matchConstraint) {
          throw ConstraintLayoutException(
              'When setting widthHeightRatio for ${element.nodeId}, height is exact, width must be matchConstraint.');
        }
      }
    }
  }
}

void insertionSort<E>(List<E> a, int Function(E a, E b) compare) {
  for (int i = 1, lastIndex = a.length - 1; i <= lastIndex; i++) {
    var el = a[i];
    int j = i;
    while ((j > 0) && (compare(a[j - 1], el) > 0)) {
      a[j] = a[j - 1];
      j--;
    }
    a[j] = el;
  }
}

void drawClickArea(
    ConstrainedNode node, PaintingContext context, Offset offset) {
  Paint paint = Paint();
  paint.color = Colors.yellow.withAlpha(192);
  EdgeInsets clickPadding = node.clickPadding;
  Rect rect = Rect.fromLTRB(
      node.getX() - getLeftInsets(clickPadding),
      node.getY() - getTopInsets(clickPadding),
      node.getX() + node.getMeasuredWidth() + getRightInsets(clickPadding),
      node.getY() + node.getMeasuredHeight() + getBottomInsets(clickPadding));
  rect = rect.shift(offset);
  context.canvas.drawRect(rect, paint);
  ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
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

void drawZIndex(ConstrainedNode node, PaintingContext context, Offset offset) {
  ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
    textAlign: TextAlign.center,
    fontSize: 10,
  ));
  paragraphBuilder.addText("z-index ${node.zIndex}");
  ui.Paragraph paragraph = paragraphBuilder.build();
  paragraph.layout(ui.ParagraphConstraints(
    width: node.getMeasuredWidth(),
  ));
  context.canvas.drawParagraph(paragraph, node.offset + offset);
}

void drawChildDepth(
    ConstrainedNode node, PaintingContext context, Offset offset) {
  ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
    textAlign: TextAlign.center,
    fontSize: 10,
  ));
  paragraphBuilder.pushStyle(ui.TextStyle(
    color: Colors.black,
  ));
  paragraphBuilder.addText("depth ${node.getDepth(null, null, null)}");
  ui.Paragraph paragraph = paragraphBuilder.build();
  paragraph.layout(ui.ParagraphConstraints(
    width: node.getMeasuredWidth(),
  ));
  context.canvas.drawParagraph(
      paragraph,
      node.offset +
          offset +
          Offset(0, node.getMeasuredHeight() - paragraph.height));
}

void drawHelperNodes(
    ConstrainedNode element, PaintingContext context, Offset offset) {
  if (element.isGuideline || element.isBarrier) {
    Paint paint = Paint();
    if (element.isGuideline) {
      paint.color = Colors.green;
    } else {
      paint.color = Colors.purple;
    }
    paint.strokeWidth = 5;
    context.canvas.drawLine(element.offset + offset,
        Offset(element.getRight(), element.getBottom()) + offset, paint);
  }
}

void debugShowPerformance(
  PaintingContext context,
  Offset offset,
  Queue<int> constraintCalculationTimeUsage,
  Queue<int> layoutTimeUsage,
  Queue<int> paintTimeUsage,
) {
  Paint paint = Paint()..color = Colors.white;
  Iterator<int> constraintCalculateIterator =
      constraintCalculationTimeUsage.iterator;
  double heightOffset = 0;
  while (constraintCalculateIterator.moveNext()) {
    int calculateTime = constraintCalculateIterator.current;
    ui.ParagraphBuilder paragraphBuilder =
        ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.left,
      fontSize: 8,
    ));
    if (calculateTime > 1000) {
      paragraphBuilder.pushStyle(ui.TextStyle(
        color: Colors.red,
        background: paint,
      ));
    } else {
      paragraphBuilder.pushStyle(ui.TextStyle(
        color: Colors.green,
        background: paint,
      ));
    }
    paragraphBuilder.addText("calculate $calculateTime us");
    ui.Paragraph paragraph = paragraphBuilder.build();
    paragraph.layout(const ui.ParagraphConstraints(
      width: 80,
    ));
    context.canvas.drawParagraph(paragraph, Offset(0, heightOffset) + offset);
    heightOffset += 10;
  }

  Iterator<int> layoutIterator = layoutTimeUsage.iterator;
  heightOffset = 0;
  while (layoutIterator.moveNext()) {
    int layoutTime = layoutIterator.current;
    ui.ParagraphBuilder paragraphBuilder =
        ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.left,
      fontSize: 8,
    ));
    if (layoutTime > 5000) {
      paragraphBuilder.pushStyle(ui.TextStyle(
        color: Colors.red,
        background: paint,
      ));
    } else {
      paragraphBuilder.pushStyle(ui.TextStyle(
        color: Colors.green,
        background: paint,
      ));
    }
    paragraphBuilder.addText("layout $layoutTime us");
    ui.Paragraph paragraph = paragraphBuilder.build();
    paragraph.layout(const ui.ParagraphConstraints(
      width: 80,
    ));
    context.canvas.drawParagraph(paragraph, Offset(80, heightOffset) + offset);
    heightOffset += 10;
  }

  Iterator<int> paintIterator = paintTimeUsage.iterator;
  heightOffset = 0;
  while (paintIterator.moveNext()) {
    int paintTime = paintIterator.current;
    ui.ParagraphBuilder paragraphBuilder =
        ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.left,
      fontSize: 8,
    ));
    if (paintTime > 5000) {
      paragraphBuilder.pushStyle(ui.TextStyle(
        color: Colors.red,
        background: paint,
      ));
    } else {
      paragraphBuilder.pushStyle(ui.TextStyle(
        color: Colors.green,
        background: paint,
      ));
    }
    paragraphBuilder.addText("paint $paintTime us");
    ui.Paragraph paragraph = paragraphBuilder.build();
    paragraph.layout(const ui.ParagraphConstraints(
      width: 80,
    ));
    context.canvas.drawParagraph(paragraph, Offset(160, heightOffset) + offset);
    heightOffset += 10;
  }

  ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
    textAlign: TextAlign.center,
    fontSize: 8,
  ));
  paragraphBuilder.pushStyle(ui.TextStyle(
    color: Colors.green,
    background: paint,
  ));
  paragraphBuilder.addText('The bottom one is the latest');
  ui.Paragraph paragraph = paragraphBuilder.build();
  paragraph.layout(const ui.ParagraphConstraints(
    width: 240,
  ));
  context.canvas.drawParagraph(paragraph, Offset(0, heightOffset) + offset);
}

int getMaxInt(List<int> list) {
  int max = 1 << 63;
  for (final element in list) {
    if (element > max) {
      max = element;
    }
  }
  return max;
}

double getMaxDouble(List<double> list) {
  double max = double.minPositive;
  for (final element in list) {
    if (element > max) {
      max = element;
    }
  }
  return max;
}

double getMinDouble(List<double> list) {
  double min = double.maxFinite;
  for (final element in list) {
    if (element < min) {
      min = element;
    }
  }
  return min;
}

/// For debug message print
Map<String, dynamic> toJson(ConstrainedNode node) {
  final map = <String, dynamic>{};
  if (node.nodeId == parent) {
    map['nodeId'] = 'parent';
  } else {
    map['nodeId'] = node.nodeId.id;
    if (node.leftConstraint != null) {
      if (node.leftAlignType == ConstraintAlignType.left) {
        map['leftAlignType'] = 'toLeft';
      } else if (node.leftAlignType == ConstraintAlignType.center) {
        map['leftAlignType'] = 'toCenter';
      } else {
        map['leftAlignType'] = 'toRight';
      }
      if (node.leftConstraint!.isParent()) {
        map['leftConstraint'] = 'parent';
      } else {
        map['leftConstraint'] = toJson(node.leftConstraint!);
      }
    }
    if (node.topConstraint != null) {
      if (node.topAlignType == ConstraintAlignType.top) {
        map['topAlignType'] = 'toTop';
      } else if (node.topAlignType == ConstraintAlignType.center) {
        map['topAlignType'] = 'toCenter';
      } else {
        map['topAlignType'] = 'toBottom';
      }
      if (node.topConstraint!.isParent()) {
        map['topConstraint'] = 'parent';
      } else {
        map['topConstraint'] = toJson(node.topConstraint!);
      }
    }
    if (node.rightConstraint != null) {
      if (node.rightAlignType == ConstraintAlignType.left) {
        map['rightAlignType'] = 'toLeft';
      } else if (node.rightAlignType == ConstraintAlignType.center) {
        map['rightAlignType'] = 'toCenter';
      } else {
        map['rightAlignType'] = 'toRight';
      }
      if (node.rightConstraint!.isParent()) {
        map['rightConstraint'] = 'parent';
      } else {
        map['rightConstraint'] = toJson(node.rightConstraint!);
      }
    }
    if (node.bottomConstraint != null) {
      if (node.bottomAlignType == ConstraintAlignType.top) {
        map['bottomAlignType'] = 'toTop';
      } else if (node.bottomAlignType == ConstraintAlignType.center) {
        map['bottomAlignType'] = 'toCenter';
      } else {
        map['bottomAlignType'] = 'toBottom';
      }
      if (node.bottomConstraint!.isParent()) {
        map['bottomConstraint'] = 'parent';
      } else {
        map['bottomConstraint'] = toJson(node.bottomConstraint!);
      }
    }
    if (node.baselineConstraint != null) {
      if (node.baselineAlignType == ConstraintAlignType.top) {
        map['baselineAlignType'] = 'toTop';
      } else if (node.baselineAlignType == ConstraintAlignType.center) {
        map['baselineAlignType'] = 'toCenter';
      } else if (node.baselineAlignType == ConstraintAlignType.bottom) {
        map['baselineAlignType'] = 'toBottom';
      } else {
        map['baselineAlignType'] = 'toBaseline';
      }
      if (node.baselineConstraint!.isParent()) {
        map['baselineConstraint'] = 'parent';
      } else {
        map['baselineConstraint'] = toJson(node.baselineConstraint!);
      }
    }
    if (node.pinnedConstraint != null) {
      if (node.pinnedConstraint!.isParent()) {
        map['pinnedConstraint'] = 'parent';
      } else {
        map['pinnedConstraint'] = toJson(node.pinnedConstraint!);
      }
    }
    if (node.anchors != null) {
      List<Map<String, dynamic>> anchorsJson = [];
      for (final element in node.anchors!) {
        anchorsJson.add(toJson(element));
      }
      map['anchors'] = anchorsJson;
    }
  }
  map['depth'] = node.getDepth(null, null, null);
  return map;
}

String toJsonList(List<ConstrainedNode> list) {
  return jsonEncode(list.map((e) => toJson(e)).toList());
}

class ConstraintLayoutException implements Exception {
  final String msg;

  ConstraintLayoutException(this.msg);

  @override
  String toString() {
    return 'ConstraintLayoutException throw: $msg';
  }
}
