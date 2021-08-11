import 'dart:async';

import 'package:flutter/material.dart';

import '../Model.dart';

typedef Builder<M> = Widget Function(BuildContext, M, Widget);

class ModelView<M extends Model> extends StatefulWidget {
  final Builder<M> builder;
  final M model;
  final Widget child;

  ModelView({Key key, this.builder, this.model, this.child}): super(key: key);
  
  @override
  State<StatefulWidget> createState() => ModelViewStateController<M>();
}

class ModelViewStateController<M extends Model> extends State<ModelView<M>> {
  M model;
  StreamSubscription<M> subscription;

  @override 
  void initState() {
    model = widget.model;
    subscription = model.stream.listen((event) { 
      if(event == model)
        setState(() {
          model.copy(event);
        });
    });
    super.initState();
  }

  @override 
  void didUpdateWidget(Widget oldWidget) {
    setState(() {
      model = widget.model;
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override 
  Widget build(BuildContext context) => widget.builder(context, model, widget.child);
}