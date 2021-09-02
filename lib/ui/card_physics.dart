import 'package:flutter/cupertino.dart';

const double CARD_WIDTH = (240 - 20) * (86.0 / 54) + 20;

class CardPhysics extends ScrollPhysics {
  final int? cardCount;

  const CardPhysics({this.cardCount, parent}) : super(parent: parent);

  @override
  CardPhysics applyTo(ScrollPhysics? parent) {
    return CardPhysics(parent: buildParent(parent));
  }

  double _posToItem(ScrollPosition pos) {
    return pos.pixels / CARD_WIDTH;
  }

  int getItemIdx(ScrollPosition pos) {
    return _posToItem(pos).round();
  }

  double _itemToPix(int page) {
    return page * CARD_WIDTH;
  }

  double _getTargetPixels(ScrollPosition pos, Tolerance tol, double v) {
    double page = _posToItem(pos);
    if (v < -tol.velocity)
      page -= 0.5;
    else if (v > tol.velocity) page += 0.5;

    // TODO: why is cardCount always null?
    // if(page > cardCount - 1.0) page = cardCount - 1.0;
    if (page < 0) page = 0;

    return _itemToPix(page.round());
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if ((velocity <= 0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0 && position.pixels >= position.maxScrollExtent))
      return super.createBallisticSimulation(position, velocity);

    final Tolerance tol = this.tolerance;
    final double target = this._getTargetPixels(position as ScrollPosition, tol, velocity);

    if (target != position.pixels)
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tol);
    return null;
  }
}
