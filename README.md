# Flutter ConstraintLayout

Build flexible layouts with constraints, Similar to Android ConstraintLayout.

No matter how complex the layout is and how deep the dependencies are, each child element of
ConstraintLayout will only be measured once, This results in extremely high layout performance.

# Feature

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
    12. width、height can be set: CL.matchParent、CL.wrapContent、CL.matchConstraint、fixed size
    13. center、centerHorizontal、centerVertical
2. margin and goneMargin
3. clickPadding (quickly expand the click area of child elements without changing their actual size)
4. visibility control
5. constraint integrity hint
6. bias
7. z-index
8. translate
9. percentage layout
10. guideline

Coming soon:

1. barrier
2. constraints visualization
3. chain
4. more...

Support platform:

1. Android
2. iOS
3. Mac
4. Windows
5. Linux
6. Web

# Import

Null-safety

```yaml
dependencies:
  flutter_constraintlayout:
    git:
      url: 'https://github.com/hackware1993/Flutter-ConstraintLayout.git'
      ref: 'v0.2-alpha2'
```

# Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/constrait_layout/constraint_layout.dart';

class Example extends StatefulWidget {
  const Example({Key? key}) : super(key: key);

  @override
  State createState() => ExampleState();
}

class ExampleState extends State<Example> {
  double x = 0;
  double y = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: ConstraintLayout(
          children: [
            Constrained(
              id: 'box1',
              width: 200,
              height: 200,
              topToTop: CL.parent,
              rightToRight: CL.parent,
              child: Container(
                color: Colors.redAccent,
                alignment: Alignment.center,
                child: const Text('box1'),
              ),
            ),
            Constrained(
              id: 'box2',
              width: CL.matchConstraint,
              height: CL.matchConstraint,
              leftToLeft: 'box3',
              rightToRight: 'box3',
              topToBottom: 'box3',
              bottomToBottom: CL.parent,
              child: Container(
                color: Colors.blue,
                alignment: Alignment.center,
                child: const Text('box2'),
              ),
            ),
            Constrained(
              id: 'box3',
              width: CL.wrapContent,
              height: CL.wrapContent,
              rightToLeft: 'box1',
              topToBottom: 'box1',
              child: Container(
                color: Colors.orange,
                width: 200,
                height: 300,
                alignment: Alignment.center,
                child: const Text('box3'),
              ),
            ),
            Constrained(
              id: 'box4',
              width: 50,
              height: 50,
              rightToRight: CL.parent,
              bottomToBottom: CL.parent,
              child: Container(
                color: Colors.redAccent,
                alignment: Alignment.center,
                child: const Text('box4'),
              ),
            ),
            Constrained(
              id: 'box5',
              width: 120,
              height: 100,
              center: CL.parent,
              zIndex: 100,
              translate: Offset(x, y),
              clickPadding: const EdgeInsets.all(30),
              translateConstraint: true,
              child: GestureDetector(
                child: Container(
                  color: Colors.pink,
                  alignment: Alignment.center,
                  child: const Text('box5 draggable'),
                ),
                onPanUpdate: (details) {
                  setState(() {
                    x += details.delta.dx;
                    y += details.delta.dy;
                  });
                },
              ),
            ),
            Constrained(
              id: 'box6',
              width: 120,
              height: 120,
              centerVertical: 'box2',
              verticalBias: 0.8,
              leftToRight: 'box3',
              rightToRight: CL.parent,
              child: Container(
                color: Colors.lightGreen,
                alignment: Alignment.center,
                child: const Text('box6'),
              ),
            ),
            Constrained(
              id: 'box7',
              width: CL.matchConstraint,
              height: CL.matchConstraint,
              topToTop: 'box1',
              leftToLeft: CL.parent,
              rightToLeft: 'box3',
              bottomToBottom: CL.parent,
              margin: const EdgeInsets.all(50),
              child: Container(
                color: Colors.lightGreen,
                alignment: Alignment.center,
                child: const Text('box7'),
              ),
            ),
            Constrained(
              width: 200,
              height: 100,
              leftToRight: 'box5',
              bottomToTop: 'box5',
              child: Container(
                color: Colors.cyan,
                alignment: Alignment.center,
                child: const Text('child[7] pinned to the top right'),
              ),
            ),
            const Constrained(
              id: 'box9',
              width: CL.wrapContent,
              height: CL.wrapContent,
              baselineToBaseline: 'box7',

              /// when setting baseline alignment, height must be wrap_content or fixed size
              /// other vertical constraints will be ignored
              /// Warning:
              /// Due to a bug in the flutter framework, baseline alignment may not take effect in debug mode
              /// See https://github.com/flutter/flutter/issues/101179

              leftToLeft: 'box7',
              child: Text(
                'box9 baseline to box7',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
```

![example.webp](https://github.com/hackware1993/flutter-constraintlayout/blob/master/effect.gif?raw=true)

# Support me

If it helps you a lot, consider sponsoring me a cup of milk tea.
<br/>
[Paypal](https://www.paypal.com/paypalme/hackware1993)
<br/>
![support.webp](https://github.com/hackware1993/flutter-constraintlayout/blob/master/support.webp?raw=true)

# License

```
MIT License

Copyright (c) 2022 hackware1993

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
