# Flutter ConstraintLayout

Build flexible layouts with constraints, Similar to Android ConstraintLayout.

No matter how complex the layout is and how deep the dependencies are, each child element of
ConstraintLayout will only be measured once, This results in extremely high layout performance.

# Feature

1. build flexible layouts with constraints
2. margin and goneMargin
3. clickPadding(expand the click area of child elements without changing their actual size)
4. visibility control
5. constraint integrity hint
6. bias

Coming soon:

1. guideline
2. barrier
3. constraints visualization
4. chain
5. more...

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
      ref: 'v0.1-alpha'
```

# Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/constrait_layout/constraint_layout.dart';

void main() {
  runApp(MaterialApp(
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
            id: 'box7',
            width: 120,
            height: 120,
            centerVertical: true,
            verticalBias: 0.5,
            leftToRight: 'box3',
            rightToRight: CL.parent,
            horizontalBias: 0.5,
            child: Container(
              color: Colors.lightGreen,
              alignment: Alignment.center,
              child: const Text('box7'),
            ),
          ),
          Constrained(
            id: 'box8',
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
              child: const Text('box8'),
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
            width: 100,
            height: 100,
            center: true,
            child: Container(
              color: Colors.pink,
              alignment: Alignment.center,
              child: const Text('child[6]'),
            ),
          )
        ],
      ),
    ),
  ));
} 
```

![example.webp](https://github.com/hackware1993/flutter-constraintlayout/blob/master/effect.webp?raw=true)

# Support me

If it helps you, consider sponsoring me a cup of milk tea.
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
