// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

const double _kPanelHeaderCollapsedHeight = kMinInteractiveDimension;
const double _kPanelHeaderExpandedHeight = 64.0;

class _SaltedKey<S, V> extends LocalKey {
  const _SaltedKey(this.salt, this.value);

  final S salt;
  final V value;

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final _SaltedKey<S, V> typedOther = other;
    return salt == typedOther.salt && value == typedOther.value;
  }

  @override
  int get hashCode => Object.hash(runtimeType, salt, value);

  @override
  String toString() {
    final String saltString = S == String ? '<\'$salt\'>' : '<$salt>';
    final String valueString = V == String ? '<\'$value\'>' : '<$value>';
    return '[$saltString $valueString]';
  }
}

/// Signature for the callback that's called when an [ExpansionPanel] is
/// expanded or collapsed.
///
/// The position of the panel within an [ExpansionPanelList] is given by
/// [panelIndex].
typedef ExpansionPanelCallback = void Function(int panelIndex, bool isExpanded);

/// Signature for the callback that's called when the header of the
/// [ExpansionPanel] needs to rebuild.
typedef ExpansionPanelHeaderBuilder = Widget Function(
    BuildContext context, bool isExpanded);

/// A material expansion panel. It has a header and a body and can be either
/// expanded or collapsed. The body of the panel is only visible when it is
/// expanded.
///
/// Expansion panels are only intended to be used as children for
/// [ExpansionPanelList].
///
/// See [ExpansionPanelList] for a sample implementation.
///
/// See also:
///
///  * [ExpansionPanelList]
///  * <https://material.io/design/components/lists.html#types>
class ExpansionPanel {
  /// Creates an expansion panel to be used as a child for [ExpansionPanelList].
  /// See [ExpansionPanelList] for an example on how to use this widget.
  ///
  /// The [headerBuilder], [body], and [isExpanded] arguments must not be null.
  ExpansionPanel({
    @required this.headerBuilder,
    @required this.body,
    this.isExpanded = false,
    this.canTapOnHeader = false,
  })  : assert(headerBuilder != null),
        assert(body != null),
        assert(isExpanded != null);

  /// The widget builder that builds the expansion panels' header.
  final ExpansionPanelHeaderBuilder? headerBuilder;

  /// The body of the expansion panel that's displayed below the header.
  ///
  /// This widget is visible only when the panel is expanded.
  final Widget? body;

  /// Whether the panel is expanded.
  ///
  /// Defaults to false.
  final bool? isExpanded;

  /// Whether tapping on the panel's header will expand/collapse it.
  ///
  /// Defaults to false.
  final bool canTapOnHeader;
}

class NFSeeExpansionPanel {
  /// Creates an expansion panel to be used as a child for [ExpansionPanelList].
  /// See [ExpansionPanelList] for an example on how to use this widget.
  ///
  /// The [headerBuilder], [body], and [isExpanded] arguments must not be null.
  NFSeeExpansionPanel({
    @required this.headerBuilder,
    required this.body,
    this.isExpanded = false,
    this.canTapOnHeader = false,
    this.running = false,
  })  : assert(headerBuilder != null);

  final ExpansionPanelHeaderBuilder? headerBuilder;
  final Widget body;
  final bool isExpanded;
  final bool canTapOnHeader;
  final bool running;
}

class NFSeeExpansionPanelRadio extends NFSeeExpansionPanel {
  /// An expansion panel that allows for radio functionality.
  ///
  /// A unique [value] must be passed into the constructor. The
  /// [headerBuilder], [body], [value] must not be null.
  NFSeeExpansionPanelRadio({
    @required this.value,
    @required ExpansionPanelHeaderBuilder? headerBuilder,
    required Widget body,
    bool canTapOnHeader = false,
    bool running = false,
  })  : assert(value != null),
        super(
          body: body,
          headerBuilder: headerBuilder,
          canTapOnHeader: canTapOnHeader,
          running: running,
        );

  /// The value that uniquely identifies a radio panel so that the currently
  /// selected radio panel can be identified.
  final Object? value;
}

class NFSeeExpansionPanelList extends StatefulWidget {
  /// Creates an expansion panel list widget. The [expansionCallback] is
  /// triggered when an expansion panel expand/collapse button is pushed.
  ///
  /// The [children] and [animationDuration] arguments must not be null.
  const NFSeeExpansionPanelList({
    Key? key,
    this.children = const <NFSeeExpansionPanel>[],
    this.expansionCallback,
    this.animationDuration = kThemeAnimationDuration,
    this.elevation = 2,
  })  : _allowOnlyOnePanelOpen = false,
        initialOpenPanelValue = null,
        super(key: key);

  const NFSeeExpansionPanelList.radio({
    Key? key,
    this.children = const <NFSeeExpansionPanelRadio>[],
    this.expansionCallback,
    this.animationDuration = kThemeAnimationDuration,
    this.initialOpenPanelValue,
    this.elevation = 2,
  })  : _allowOnlyOnePanelOpen = true,
        super(key: key);

  /// The children of the expansion panel list. They are laid out in a similar
  /// fashion to [ListBody].
  final List<NFSeeExpansionPanel> children;

  /// The callback that gets called whenever one of the expand/collapse buttons
  /// is pressed. The arguments passed to the callback are the index of the
  /// pressed panel and whether the panel is currently expanded or not.
  ///
  /// If ExpansionPanelList.radio is used, the callback may be called a
  /// second time if a different panel was previously open. The arguments
  /// passed to the second callback are the index of the panel that will close
  /// and false, marking that it will be closed.
  ///
  /// For ExpansionPanelList, the callback needs to setState when it's notified
  /// about the closing/opening panel. On the other hand, the callback for
  /// ExpansionPanelList.radio is simply meant to inform the parent widget of
  /// changes, as the radio panels' open/close states are managed internally.
  ///
  /// This callback is useful in order to keep track of the expanded/collapsed
  /// panels in a parent widget that may need to react to these changes.
  final ExpansionPanelCallback? expansionCallback;

  /// The duration of the expansion animation.
  final Duration animationDuration;

  // Whether multiple panels can be open simultaneously
  final bool _allowOnlyOnePanelOpen;

  /// The value of the panel that initially begins open. (This value is
  /// only used when initializing with the [ExpansionPanelList.radio]
  /// constructor.)
  final Object? initialOpenPanelValue;

  final int elevation;

  @override
  State<StatefulWidget> createState() => _NFSeeExpansionPanelListState();
}

class _NFSeeExpansionPanelListState extends State<NFSeeExpansionPanelList> {
  NFSeeExpansionPanelRadio? _currentOpenPanel;

  @override
  void initState() {
    super.initState();
    if (widget._allowOnlyOnePanelOpen) {
      assert(_allIdentifiersUnique(),
          'All ExpansionPanelRadio identifier values must be unique.');
      if (widget.initialOpenPanelValue != null) {
        _currentOpenPanel =
            searchPanelByValue(widget.children as List<NFSeeExpansionPanelRadio>, widget.initialOpenPanelValue);
      }
    }
  }

  @override
  void didUpdateWidget(NFSeeExpansionPanelList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget._allowOnlyOnePanelOpen) {
      assert(_allIdentifiersUnique(),
          'All ExpansionPanelRadio identifier values must be unique.');
      // If the previous widget was non-radio ExpansionPanelList, initialize the
      // open panel to widget.initialOpenPanelValue
      if (!oldWidget._allowOnlyOnePanelOpen) {
        _currentOpenPanel =
            searchPanelByValue(widget.children as List<NFSeeExpansionPanelRadio>, widget.initialOpenPanelValue);
      }
    } else {
      _currentOpenPanel = null;
    }
  }

  bool _allIdentifiersUnique() {
    final Map<Object?, bool> identifierMap = <Object, bool>{};
    for (NFSeeExpansionPanelRadio child in widget.children as Iterable<NFSeeExpansionPanelRadio>) {
      identifierMap[child.value] = true;
    }
    return identifierMap.length == widget.children.length;
  }

  bool _isChildExpanded(int index) {
    if (widget._allowOnlyOnePanelOpen) {
      final NFSeeExpansionPanelRadio radioWidget = widget.children[index] as NFSeeExpansionPanelRadio;
      return _currentOpenPanel?.value == radioWidget.value;
    }
    return widget.children[index].isExpanded;
  }

  void _handlePressed(bool isExpanded, int index) {
    if (widget.expansionCallback != null)
      widget.expansionCallback!(index, isExpanded);

    if (widget._allowOnlyOnePanelOpen) {
      final NFSeeExpansionPanelRadio pressedChild = widget.children[index] as NFSeeExpansionPanelRadio;

      // If another ExpansionPanelRadio was already open, apply its
      // expansionCallback (if any) to false, because it's closing.
      for (int childIndex = 0;
          childIndex < widget.children.length;
          childIndex += 1) {
        final NFSeeExpansionPanelRadio child = widget.children[childIndex] as NFSeeExpansionPanelRadio;
        if (widget.expansionCallback != null &&
            childIndex != index &&
            child.value == _currentOpenPanel?.value)
          widget.expansionCallback!(childIndex, false);
      }

      setState(() {
        _currentOpenPanel = isExpanded ? null : pressedChild;
      });
    }
  }

  NFSeeExpansionPanelRadio? searchPanelByValue(
      List<NFSeeExpansionPanelRadio> panels, Object? value) {
    for (NFSeeExpansionPanelRadio panel in panels) {
      if (panel.value == value) return panel;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final List<MergeableMaterialItem> items = <MergeableMaterialItem>[];
    const EdgeInsets kExpandedEdgeInsets = EdgeInsets.symmetric(
        vertical: _kPanelHeaderExpandedHeight - _kPanelHeaderCollapsedHeight);

    for (int index = 0; index < widget.children.length; index += 1) {
      if (_isChildExpanded(index) && index != 0 && !_isChildExpanded(index - 1))
        items.add(MaterialGap(
            key: _SaltedKey<BuildContext, int>(context, index * 2 - 1)));

      final NFSeeExpansionPanel child = widget.children[index];
      final Widget headerWidget = child.headerBuilder!(
        context,
        _isChildExpanded(index),
      );

      Widget expandIconContainer = Container(
        margin: const EdgeInsetsDirectional.only(end: 8.0),
        child: ExpandIcon(
          isExpanded: _isChildExpanded(index),
          padding: const EdgeInsets.all(16.0),
          onPressed: !child.canTapOnHeader
              ? (bool isExpanded) => _handlePressed(isExpanded, index)
              : null,
        ),
      );
      if (!child.canTapOnHeader) {
        final MaterialLocalizations localizations =
            MaterialLocalizations.of(context);
        expandIconContainer = Semantics(
          label: _isChildExpanded(index)
              ? localizations.expandedIconTapHint
              : localizations.collapsedIconTapHint,
          container: true,
          child: expandIconContainer,
        );
      }
      Widget header = Row(
        children: <Widget>[
          Expanded(
            child: AnimatedContainer(
              duration: widget.animationDuration,
              curve: Curves.fastOutSlowIn,
              margin: _isChildExpanded(index)
                  ? kExpandedEdgeInsets
                  : EdgeInsets.zero,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                    minHeight: _kPanelHeaderCollapsedHeight),
                child: headerWidget,
              ),
            ),
          ),
          expandIconContainer,
        ],
      );
      if (child.canTapOnHeader) {
        header = MergeSemantics(
          child: InkWell(
            onTap: () => _handlePressed(_isChildExpanded(index), index),
            child: header,
          ),
        );
      }
      items.add(
        MaterialSlice(
          key: _SaltedKey<BuildContext, int>(context, index * 2),
          child: Column(
            children: <Widget>[
              header,
              AnimatedCrossFade(
                firstChild: Container(height: 0.0),
                secondChild: child.body,
                firstCurve:
                    const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
                secondCurve:
                    const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
                sizeCurve: Curves.fastOutSlowIn,
                crossFadeState: _isChildExpanded(index)
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: widget.animationDuration,
              ),
              Container(
                height: 3,
                child: child.running ? LinearProgressIndicator() : null,
              )
            ],
          ),
        ),
      );

      if (_isChildExpanded(index) && index != widget.children.length - 1)
        items.add(MaterialGap(
            key: _SaltedKey<BuildContext, int>(context, index * 2 + 1)));
    }

    return NFSeeMergeableMaterial(
      hasDividers: false,
      children: items,
      elevation: this.widget.elevation,
    );
  }
}

class _NFSeeMergeableMaterialListBody extends ListBody {
  _NFSeeMergeableMaterialListBody({
    required List<Widget> children,
    Axis mainAxis = Axis.vertical,
    this.items,
    this.boxShadows,
  }) : super(children: children, mainAxis: mainAxis);

  final List<MergeableMaterialItem>? items;
  final List<BoxShadow>? boxShadows;

  AxisDirection _getDirection(BuildContext context) {
    return getAxisDirectionFromAxisReverseAndDirectionality(
        context, mainAxis, false);
  }

  @override
  RenderListBody createRenderObject(BuildContext context) {
    return _NFSeeRenderMergeableMaterialListBody(
      axisDirection: _getDirection(context),
      boxShadows: boxShadows,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderListBody renderObject) {
    final _NFSeeRenderMergeableMaterialListBody materialRenderListBody =
        renderObject as _NFSeeRenderMergeableMaterialListBody;
    materialRenderListBody
      ..axisDirection = _getDirection(context)
      ..boxShadows = boxShadows;
  }
}

class _NFSeeRenderMergeableMaterialListBody extends RenderListBody {
  _NFSeeRenderMergeableMaterialListBody({
    List<RenderBox>? children,
    AxisDirection axisDirection = AxisDirection.down,
    this.boxShadows,
  }) : super(children: children, axisDirection: axisDirection);

  List<BoxShadow>? boxShadows;

  void _paintShadows(Canvas canvas, Rect rect) {
    if (boxShadows == null) return;

    for (BoxShadow boxShadow in boxShadows!) {
      final Paint paint = boxShadow.toPaint();
      // TODO(dragostis): Right now, we are only interpolating the border radii
      // of the visible Material slices, not the shadows; they are not getting
      // interpolated and always have the same rounded radii. Once shadow
      // performance is better, shadows should be redrawn every single time the
      // slices' radii get interpolated and use those radii not the defaults.
      canvas.drawRRect(kMaterialEdges[MaterialType.card]!.toRRect(rect), paint);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    int i = 0;

    while (child != null) {
      final ListBodyParentData childParentData = child.parentData as ListBodyParentData;
      final Rect rect = (childParentData.offset + offset) & child.size;
      if (i % 2 == 0) _paintShadows(context.canvas, rect);
      child = childParentData.nextSibling;

      i += 1;
    }

    defaultPaint(context, offset);
  }
}

class NFSeeMergeableMaterial extends StatefulWidget {
  /// Creates a mergeable Material list of items.
  const NFSeeMergeableMaterial({
    Key? key,
    this.mainAxis = Axis.vertical,
    this.elevation = 2,
    this.hasDividers = false,
    this.children = const <MergeableMaterialItem>[],
  }) : super(key: key);

  /// The children of the [MergeableMaterial].
  final List<MergeableMaterialItem> children;

  /// The main layout axis.
  final Axis mainAxis;

  /// The z-coordinate at which to place all the [Material] slices.
  ///
  /// The following elevations have defined shadows: 1, 2, 3, 4, 6, 8, 9, 12, 16, 24
  ///
  /// Defaults to 2, the appropriate elevation for cards.
  ///
  /// This uses [kElevationToShadow] to simulate shadows, it does not use
  /// [Material]'s arbitrary elevation feature.
  final int elevation;

  /// Whether connected pieces of [MaterialSlice] have dividers between them.
  final bool hasDividers;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<Axis>('mainAxis', mainAxis));
    properties.add(DoubleProperty('elevation', elevation.toDouble()));
  }

  @override
  _NFSeeMergeableMaterialState createState() => _NFSeeMergeableMaterialState();
}

class _AnimationTuple {
  _AnimationTuple({
    this.controller,
    this.startAnimation,
    this.endAnimation,
    this.gapAnimation,
    this.gapStart = 0.0,
  });

  final AnimationController? controller;
  final CurvedAnimation? startAnimation;
  final CurvedAnimation? endAnimation;
  final CurvedAnimation? gapAnimation;
  double gapStart;
}

class _MergeableMaterialSliceKey extends GlobalKey {
  const _MergeableMaterialSliceKey(this.value) : super.constructor();

  final LocalKey value;

  @override
  bool operator ==(dynamic other) {
    if (other is! _MergeableMaterialSliceKey) return false;
    final _MergeableMaterialSliceKey typedOther = other;
    return value == typedOther.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return '_MergeableMaterialSliceKey($value)';
  }
}

class _NFSeeMergeableMaterialState extends State<NFSeeMergeableMaterial>
    with TickerProviderStateMixin {
  late List<MergeableMaterialItem> _children;
  final Map<LocalKey, _AnimationTuple?> _animationTuples =
      <LocalKey, _AnimationTuple?>{};

  @override
  void initState() {
    super.initState();
    _children = List<MergeableMaterialItem>.from(widget.children);

    for (int i = 0; i < _children.length; i += 1) {
      if (_children[i] is MaterialGap) {
        _initGap(_children[i] as MaterialGap);
        _animationTuples[_children[i].key]!.controller!.value =
            1.0; // Gaps are initially full-sized.
      }
    }
    assert(_debugGapsAreValid(_children));
  }

  void _initGap(MaterialGap gap) {
    final AnimationController controller = AnimationController(
      duration: kThemeAnimationDuration,
      vsync: this,
    );

    final CurvedAnimation startAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );
    final CurvedAnimation endAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );
    final CurvedAnimation gapAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );

    controller.addListener(_handleTick);

    _animationTuples[gap.key] = _AnimationTuple(
      controller: controller,
      startAnimation: startAnimation,
      endAnimation: endAnimation,
      gapAnimation: gapAnimation,
    );
  }

  @override
  void dispose() {
    for (MergeableMaterialItem child in _children) {
      if (child is MaterialGap)
        _animationTuples[child.key]!.controller!.dispose();
    }
    super.dispose();
  }

  void _handleTick() {
    setState(() {
      // The animation's state is our build state, and it changed already.
    });
  }

  bool _debugHasConsecutiveGaps(List<MergeableMaterialItem> children) {
    for (int i = 0; i < widget.children.length - 1; i += 1) {
      if (widget.children[i] is MaterialGap &&
          widget.children[i + 1] is MaterialGap) return true;
    }
    return false;
  }

  bool _debugGapsAreValid(List<MergeableMaterialItem> children) {
    // Check for consecutive gaps.
    if (_debugHasConsecutiveGaps(children)) return false;

    // First and last children must not be gaps.
    if (children.isNotEmpty) {
      if (children.first is MaterialGap || children.last is MaterialGap)
        return false;
    }

    return true;
  }

  void _insertChild(int index, MergeableMaterialItem child) {
    _children.insert(index, child);

    if (child is MaterialGap) _initGap(child);
  }

  void _removeChild(int index) {
    final MergeableMaterialItem child = _children.removeAt(index);

    if (child is MaterialGap) _animationTuples[child.key] = null;
  }

  bool _isClosingGap(int index) {
    if (index < _children.length - 1 && _children[index] is MaterialGap) {
      return _animationTuples[_children[index].key]!.controller!.status ==
          AnimationStatus.reverse;
    }

    return false;
  }

  void _removeEmptyGaps() {
    int j = 0;

    while (j < _children.length) {
      if (_children[j] is MaterialGap &&
          _animationTuples[_children[j].key]!.controller!.status ==
              AnimationStatus.dismissed) {
        _removeChild(j);
      } else {
        j += 1;
      }
    }
  }

  @override
  void didUpdateWidget(NFSeeMergeableMaterial oldWidget) {
    super.didUpdateWidget(oldWidget);

    final Set<LocalKey> oldKeys = oldWidget.children
        .map<LocalKey>((MergeableMaterialItem child) => child.key)
        .toSet();
    final Set<LocalKey> newKeys = widget.children
        .map<LocalKey>((MergeableMaterialItem child) => child.key)
        .toSet();
    final Set<LocalKey> newOnly = newKeys.difference(oldKeys);
    final Set<LocalKey> oldOnly = oldKeys.difference(newKeys);

    final List<MergeableMaterialItem> newChildren = widget.children;
    int i = 0;
    int j = 0;

    assert(_debugGapsAreValid(newChildren));

    _removeEmptyGaps();

    while (i < newChildren.length && j < _children.length) {
      if (newOnly.contains(newChildren[i].key) ||
          oldOnly.contains(_children[j].key)) {
        final int startNew = i;
        final int startOld = j;

        // Skip new keys.
        while (newOnly.contains(newChildren[i].key)) i += 1;

        // Skip old keys.
        while (oldOnly.contains(_children[j].key) || _isClosingGap(j)) j += 1;

        final int newLength = i - startNew;
        final int oldLength = j - startOld;

        if (newLength > 0) {
          if (oldLength > 1 ||
              oldLength == 1 && _children[startOld] is MaterialSlice) {
            if (newLength == 1 && newChildren[startNew] is MaterialGap) {
              // Shrink all gaps into the size of the new one.
              double gapSizeSum = 0.0;

              while (startOld < j) {
                if (_children[startOld] is MaterialGap) {
                  final MaterialGap gap = _children[startOld] as MaterialGap;
                  gapSizeSum += gap.size;
                }

                _removeChild(startOld);
                j -= 1;
              }

              _insertChild(startOld, newChildren[startNew]);
              _animationTuples[newChildren[startNew].key]!
                ..gapStart = gapSizeSum
                ..controller!.forward();

              j += 1;
            } else {
              // No animation if replaced items are more than one.
              for (int k = 0; k < oldLength; k += 1) _removeChild(startOld);
              for (int k = 0; k < newLength; k += 1)
                _insertChild(startOld + k, newChildren[startNew + k]);

              j += newLength - oldLength;
            }
          } else if (oldLength == 1) {
            if (newLength == 1 &&
                newChildren[startNew] is MaterialGap &&
                _children[startOld].key == newChildren[startNew].key) {
              /// Special case: gap added back.
              _animationTuples[newChildren[startNew].key]!.controller!.forward();
            } else {
              final double? gapSize = _getGapSize(startOld);

              _removeChild(startOld);

              for (int k = 0; k < newLength; k += 1)
                _insertChild(startOld + k, newChildren[startNew + k]);

              j += newLength - 1;
              double gapSizeSum = 0.0;

              for (int k = startNew; k < i; k += 1) {
                if (newChildren[k] is MaterialGap) {
                  final MaterialGap gap = newChildren[k] as MaterialGap;
                  gapSizeSum += gap.size;
                }
              }

              // All gaps get proportional sizes of the original gap and they will
              // animate to their actual size.
              for (int k = startNew; k < i; k += 1) {
                if (newChildren[k] is MaterialGap) {
                  final MaterialGap gap = newChildren[k] as MaterialGap;

                  _animationTuples[gap.key]!.gapStart =
                      gapSize! * gap.size / gapSizeSum;
                  _animationTuples[gap.key]!.controller!
                    ..value = 0.0
                    ..forward();
                }
              }
            }
          } else {
            // Grow gaps.
            for (int k = 0; k < newLength; k += 1) {
              _insertChild(startOld + k, newChildren[startNew + k]);

              if (newChildren[startNew + k] is MaterialGap) {
                final MaterialGap gap = newChildren[startNew + k] as MaterialGap;
                _animationTuples[gap.key]!.controller!.forward();
              }
            }

            j += newLength;
          }
        } else {
          // If more than a gap disappeared, just remove slices and shrink gaps.
          if (oldLength > 1 ||
              oldLength == 1 && _children[startOld] is MaterialSlice) {
            double gapSizeSum = 0.0;

            while (startOld < j) {
              if (_children[startOld] is MaterialGap) {
                final MaterialGap gap = _children[startOld] as MaterialGap;
                gapSizeSum += gap.size;
              }

              _removeChild(startOld);
              j -= 1;
            }

            if (gapSizeSum != 0.0) {
              final MaterialGap gap = MaterialGap(
                key: UniqueKey(),
                size: gapSizeSum,
              );
              _insertChild(startOld, gap);
              _animationTuples[gap.key]!.gapStart = 0.0;
              _animationTuples[gap.key]!.controller!
                ..value = 1.0
                ..reverse();

              j += 1;
            }
          } else if (oldLength == 1) {
            // Shrink gap.
            final MaterialGap gap = _children[startOld] as MaterialGap;
            _animationTuples[gap.key]!.gapStart = 0.0;
            _animationTuples[gap.key]!.controller!.reverse();
          }
        }
      } else {
        // Check whether the items are the same type. If they are, it means that
        // their places have been swaped.
        if ((_children[j] is MaterialGap) == (newChildren[i] is MaterialGap)) {
          _children[j] = newChildren[i];

          i += 1;
          j += 1;
        } else {
          // This is a closing gap which we need to skip.
          assert(_children[j] is MaterialGap);
          j += 1;
        }
      }
    }

    // Handle remaining items.
    while (j < _children.length) _removeChild(j);
    while (i < newChildren.length) {
      _insertChild(j, newChildren[i]);

      i += 1;
      j += 1;
    }
  }

  BorderRadius _borderRadius(int index, bool start, bool end) {
    assert(kMaterialEdges[MaterialType.card]!.topLeft ==
        kMaterialEdges[MaterialType.card]!.topRight);
    assert(kMaterialEdges[MaterialType.card]!.topLeft ==
        kMaterialEdges[MaterialType.card]!.bottomLeft);
    assert(kMaterialEdges[MaterialType.card]!.topLeft ==
        kMaterialEdges[MaterialType.card]!.bottomRight);
    final Radius cardRadius = kMaterialEdges[MaterialType.card]!.topLeft;

    Radius? startRadius = Radius.zero;
    Radius? endRadius = Radius.zero;

    if (index > 0 && _children[index - 1] is MaterialGap) {
      startRadius = Radius.lerp(
        Radius.zero,
        cardRadius,
        _animationTuples[_children[index - 1].key]!.startAnimation!.value,
      );
    }
    if (index < _children.length - 2 && _children[index + 1] is MaterialGap) {
      endRadius = Radius.lerp(
        Radius.zero,
        cardRadius,
        _animationTuples[_children[index + 1].key]!.endAnimation!.value,
      );
    }

    if (widget.mainAxis == Axis.vertical) {
      return BorderRadius.vertical(
        top: start ? cardRadius : startRadius!,
        bottom: end ? cardRadius : endRadius!,
      );
    } else {
      return BorderRadius.horizontal(
        left: start ? cardRadius : startRadius!,
        right: end ? cardRadius : endRadius!,
      );
    }
  }

  double? _getGapSize(int index) {
    final MaterialGap gap = _children[index] as MaterialGap;

    return lerpDouble(
      _animationTuples[gap.key]!.gapStart,
      gap.size,
      _animationTuples[gap.key]!.gapAnimation!.value,
    );
  }

/*
  bool _willNeedDivider(int index) {
    if (index < 0)
      return false;
    if (index >= _children.length)
      return false;
    return _children[index] is MaterialSlice || _isClosingGap(index);
  }
  */

  @override
  Widget build(BuildContext context) {
    _removeEmptyGaps();

    final List<Widget> widgets = <Widget>[];
    List<Widget> slices = <Widget>[];
    int i;

    for (i = 0; i < _children.length; i += 1) {
      if (_children[i] is MaterialGap) {
        assert(slices.isNotEmpty);
        widgets.add(
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: _borderRadius(i - 1, widgets.isEmpty, false),
              shape: BoxShape.rectangle,
            ),
            child: ListBody(
              mainAxis: widget.mainAxis,
              children: slices,
            ),
          ),
        );
        slices = <Widget>[];

        widgets.add(
          SizedBox(
            width: widget.mainAxis == Axis.horizontal ? _getGapSize(i) : null,
            height: widget.mainAxis == Axis.vertical ? _getGapSize(i) : null,
          ),
        );
      } else {
        final MaterialSlice slice = _children[i] as MaterialSlice;
        Widget child = slice.child;

        if (widget.hasDividers) {
          final bool isMaterialSlice = child is MaterialSlice;
          final bool hasTopDivider = isMaterialSlice;
          final bool hasBottomDivider = isMaterialSlice;

          Border border;
          final BorderSide divider = Divider.createBorderSide(
            context,
            width:
                0.5, // TODO(ianh): This probably looks terrible when the dpr isn't a power of two.
          );

          if (i == 0) {
            border = Border(
              top: divider,
              bottom: hasBottomDivider ? divider : BorderSide.none,
            );
          } else if (i == _children.length - 1) {
            border = Border(
              top: hasTopDivider ? divider : BorderSide.none,
              bottom: divider,
            );
          } else {
            border = Border(
              top: hasTopDivider ? divider : BorderSide.none,
              bottom: hasBottomDivider ? divider : BorderSide.none,
            );
          }


          child = AnimatedContainer(
            key: _MergeableMaterialSliceKey(_children[i].key),
            decoration: BoxDecoration(border: border),
            duration: kThemeAnimationDuration,
            curve: Curves.fastOutSlowIn,
            child: child,
          );
        }

        slices.add(
          Material(
            type: MaterialType.transparency,
            child: child,
          ),
        );
      }
    }

    if (slices.isNotEmpty) {
      widgets.add(
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: _borderRadius(i - 1, widgets.isEmpty, true),
            shape: BoxShape.rectangle,
          ),
          child: ListBody(
            mainAxis: widget.mainAxis,
            children: slices,
          ),
        ),
      );
      slices = <Widget>[];
    }

    return _NFSeeMergeableMaterialListBody(
      mainAxis: widget.mainAxis,
      boxShadows: kElevationToShadow[widget.elevation],
      items: _children,
      children: widgets,
    );
  }
}
