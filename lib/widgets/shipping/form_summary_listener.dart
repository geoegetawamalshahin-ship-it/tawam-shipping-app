import 'package:flutter/material.dart';

class FormSummaryListener extends StatelessWidget {
  const FormSummaryListener({
    super.key,
    required this.listenables,
    required this.builder,
  });

  final List<Listenable> listenables;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(listenables),
      builder: (context, _) => builder(context),
    );
  }
}
