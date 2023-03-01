import 'package:flutter/material.dart';

class DayButtonWidget extends StatefulWidget {
  final void Function(bool value) selectChanged;

  final String letter;
  bool selected;
  final bool enableInteraction;
  final Size size;
  final bool activated;

  DayButtonWidget({
    Key? key,
    required this.size,
    required this.letter,
    required this.selected,
    required this.selectChanged,
    required this.activated,
    required this.enableInteraction,
  }) : super(key: key);

  @override
  DayButtonWidgetState createState() => DayButtonWidgetState();
}

class DayButtonWidgetState extends State<DayButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size.height,
      width: widget.size.width,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: RawMaterialButton(
          onPressed: widget.enableInteraction == false
              ? null
              : () {
                  widget.selected = !widget.selected;
                  widget.selectChanged.call(widget.selected);
                },
          elevation: 1,
          fillColor: widget.activated == false
              ? Theme.of(context).colorScheme.onInverseSurface
              : widget.selected
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).primaryColor,
          shape: CircleBorder(
            side: BorderSide(
              width: 1.0,
              color: widget.activated == false
                  ? (widget.selected != true
                      ? Theme.of(context).colorScheme.onInverseSurface
                      : Theme.of(context).primaryColorLight)
                  : widget.selected
                      ? Theme.of(context).primaryColorDark
                      : Theme.of(context).primaryColorLight,
            ),
          ),
          child: Text(
            widget.letter,
            style: TextStyle(
              color: widget.activated == false
                  ? Theme.of(context).colorScheme.onTertiary
                  : widget.selected
                      ? Theme.of(context).primaryColorDark
                      : Theme.of(context).primaryColorLight,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
