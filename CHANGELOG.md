# v1.6.0-stable

add open grammar support.

# v1.5.2-stable

remove dead code.

# v1.5.1-stable

add paint callback support.

# v1.5.0-stable

1. refactor debug function.
2. add a lot of comments.
3. fix the click problem caused by pinned translate.
4. optimize constraint version implementation.

# v1.4.4-stable

optimize rotate.

# v1.4.3-stable

fix a pinned position bug.

# v1.4.2-stable

fix a rotate bug.

# v1.4.1-stable

add pinned & circle translate support.

# v1.4.0-stable

1. code refactoring, extracting non-core functions.
2. add rotate support.

# v1.3.0-stable

enhance base constraints.

# v1.2.0-stable

add arbitrary position support.

# v1.1.1-stable

add pinned translate support.

# v1.1.0-stable

fix pinned rotate bug.

# v1.1.0-beta

fully support pinned position.

# v1.1.0-alpha

add pinned position support.

# v1.0.7-stable

optimize key set.

# v1.0.6-stable

optimize child wrapContent.

# v1.0.5-stable

optimize constraint calculation performance.

# v1.0.4-stable

shorten package description.

# v1.0.3-stable

reduced constraint computation time to 0.01 ms for normal complexity layouts(10 child elements), 80%
faster performance.

# v1.0.2-stable

optimize layout performance.

# v1.0.1-stable

optimize self wrapContent calculate.

# v1.0.0-stable

simplified id creation.

# v0.9.33-stable

optimize constraints build.

# v0.9.32-stable

fix a margin bug.

# v0.9.31-stable

enhance margin and goneMargin again.

# v0.9.30-stable

1. enhance margin and goneMargin.
2. enhance size set.

# v0.9.29-stable

enhance grid again.

# v0.9.28-beta3

optimize self wrapContent calculate.

# v0.9.28-beta2

fix a self wrapContent bug.

# v0.9.28-beta

fix self wrapContent bugs.

# v0.9.28-alpha2

fix self wrapContent bugs.

# v0.9.28-alpha

add self wrapContent support.

# v0.9.27-stable

add e-index support.

# v0.9.26-stable

enhance relative id.

# v0.9.25-stable

add circle position support.

# v0.9.24-stable

optimize performance overlay.

# v0.9.23-stable

add staggered grid support.

# v0.9.22-stable

add self size set.

# v0.9.21-stable

1. enhance grid again.
2. print child depth.

# v0.9.20-stable

enhance grid.

# v0.9.19-stable

support grid and list.

# v0.9.18-stable

support virtual helper widgets.

# v0.9.17-stable

optimize constraints calculate performance.

# v0.9.16-stable

fix a percentage layout bug.

# v0.9.15-stable

add more wrapper constraints.

# v0.9.14-stable

add relative id.

# v0.9.13-stable

enhance dimension ratio.

# v0.9.12-stable

optimize constraints calculate.

# v0.9.11-stable

remove cache support.

# v0.9.10-stable

cache sharing.

# v0.9.9-stable

optimize code.

# v0.9.8-stable

enhance constraints cache.

# v0.9.7-stable

fix guideline offset.

# v0.9.6-stable

preprocess constraints for performance improve.

# v0.9.5-stable

fix constraints print bug.

# v0.9.4-stable

optimize code.

# v0.9.3-stable

optimize layout performance.

# v0.9.2-stable

fix a bug.

# v0.9.1-stable

fix a bug.

# v0.9.0-stable

support dimension ratio.

# v.0.8.9-stable

support min、max size set.

# v.0.8.8-stable

make parent final.

# v.0.8.7-stable:

just update readme.

# v0.8.6-stable:

The first version published to pub.dev.

The following functions are supported:

1. build flexible layouts with constraints
    1. leftToLeft
    2. leftToRight
    3. rightToLeft
    4. rightToRight
    5. topToTop
    6. topToBottom
    7. bottomToTop
    8. bottomToBottom
    9. baselineToTop
    10. baselineToBottom
    11. baselineToBaseline
2. margin and goneMargin
3. clickPadding (quickly expand the click area of child elements without changing their actual size.
   This means that the click area can be shared between child elements without increasing nesting.
   Sometimes it may be necessary to combine with z-index)
4. visibility control
5. constraint integrity hint
6. bias
7. z-index
8. translate
9. percentage layout
10. guideline
11. constraints and widgets separation
12. barrier