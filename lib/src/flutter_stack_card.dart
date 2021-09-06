import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_stack_card/flutter_stack_card.dart';
// import 'package:flutter_stack_card/src/indicator_model.dart';
import 'package:flutter_stack_card/src/stack_dimension.dart';

class StackCard extends StatefulWidget {
  StackCard.builder({
    this.stackType = StackType.middle,
    required this.itemBuilder,
    required this.itemCount,
    this.dimension,
    this.stackOffset = const Offset(15, 30),
    this.onSwap,
    this.displayIndicator = false,
    // this.displayIndicatorBuilder,
    required this.indicatorWidget,
    this.shadow = const [
      BoxShadow(
        color: Colors.black38,
        spreadRadius: 0.7,
        blurRadius: 1,
      )
    ],
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ValueChanged<int>? onSwap;
  final bool displayIndicator;
  final List<BoxShadow> shadow;
  final indicatorWidget;
  // final IndicatorBuilder? displayIndicatorBuilder;
  final StackDimension? dimension;
  final StackType stackType;
  final Offset stackOffset;

  @override
  _StackCardState createState() => _StackCardState();
}

class _StackCardState extends State<StackCard> {
  var _pageController = PageController();
  var _currentPage = 0.0;
  var _width, _height;

  @override
  Widget build(BuildContext context) {
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });

    if (widget.dimension == null) {
      _height = MediaQuery.of(context).size.height;
      _width = MediaQuery.of(context).size.width;
    } else {
      assert(widget.dimension!.width > 0);
      assert(widget.dimension!.height > 0);
      _width = widget.dimension!.width;
      _height = widget.dimension!.height;
    }

    return Stack(fit: StackFit.expand, children: <Widget>[
      _cardStack(),
      widget.displayIndicator ? _cardIndicator() : Container(),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: PageView.builder(
          onPageChanged: widget.onSwap,
          physics: BouncingScrollPhysics(),
          controller: _pageController,
          itemCount: widget.itemCount,
          itemBuilder: (context, index) {
            return Container();
          },
        ),
      )
    ]);
  }

  Widget _cardStack() {
    List<Widget> _cards = [];

    for (int i = widget.itemCount - 1; i >= 0; i--) {
      var sizeOffsetx =
          (widget.stackOffset.dx * i) - (_currentPage * widget.stackOffset.dx);
      var sizeOffsety =
          (widget.stackOffset.dy * i) - (_currentPage * widget.stackOffset.dy);

      var leftOffset =
          (widget.stackOffset.dx * i) - (_currentPage * widget.stackOffset.dx);
      var topOffset =
          (widget.stackOffset.dy * i) - (_currentPage * widget.stackOffset.dy);

      // print("we got topOffset $topOffset and sizeOffsety is $sizeOffsety");
      _cards.add(Positioned.fill(
        child: cardBuilder(
            i,
            widget.stackType == StackType.middle
                ? _width - sizeOffsetx
                : _width,
            _height - sizeOffsety),
        top: topOffset / 2,
        bottom: topOffset / 2,
        left: widget.stackType == StackType.middle
            ? (_currentPage > (i) ? -(_currentPage - i) * (_width * 4) : 0)
            : (_currentPage > (i)
                ? -(_currentPage - i) * (_width * 4)
                : leftOffset),
      ));
    }

    return Stack(fit: StackFit.expand, children: _cards);
  }

  Widget cardBuilder(int index, double width, double height) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: width * .8,
        height: height * .8,
        decoration: BoxDecoration(
          boxShadow: widget.shadow,
          borderRadius: BorderRadius.all(
            Radius.circular(60),
          ),
        ),
        child: widget.itemBuilder(context, index),
      ),
    );
  }

  Widget _cardIndicator() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: widget.indicatorWidget),
    );
  }
}
