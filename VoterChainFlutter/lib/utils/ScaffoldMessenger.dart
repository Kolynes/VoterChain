import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

mixin ScaffoldMessenger<K extends StatefulWidget> on State<K> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  set error(String error) {
    if(error != null && error != "")
      scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: Color(0xff303030),
          content: Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
              error, 
              style: Theme.of(context).textTheme.caption.copyWith(
                color: Colors.white
              ),
              overflow: TextOverflow.ellipsis,
            )
          ),
        )
      );
  }
  
  set success(String message) {
    if(message != null && message != "")
      scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: Color(0xff303030),
          content: Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
              message, 
              style: Theme.of(context).textTheme.caption.copyWith(
                color: Colors.white
              ),
              overflow: TextOverflow.ellipsis,
            )
          ),
        )
      );
  }

  set loading(bool showLoading) {
    if(showLoading)
      scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: Color(0xff303030),
          content: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text("Loading")
              )
            ]
          ),
          duration: Duration(days: 365)
        )
      );
  }

   Future<bool> confirm({String yesText, String noText, ThemeData themeData, IconData icon, String title, String body}) {
    return showDialog(
      context: scaffoldKey.currentState.context,
      builder: (context) {
        return Theme(
          data: themeData,
          child: AlertDialog(
            title: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Icon(icon ?? MdiIcons.information),
                ),
                Text(title ?? "Confirm")
              ]
            ),
            content: Text(body ?? "Please confirm this action."),
            actions: [
              FlatButton(
                child: Text(yesText ?? "Yes"),
                splashColor: Theme.of(context).primaryColor,
                color: Theme.of(context).primaryColor,
                onPressed: () => Navigator.pop(context, true),
              ),
              FlatButton(
                splashColor: Theme.of(context).primaryColor,
                child: Text(
                  noText ?? "Cancel", 
                  style: TextStyle(
                    color: Theme.of(context).primaryColor
                  )
                ),
                onPressed: () => Navigator.pop(context, false),
              )
            ]
          )
        );
      }
    );
  }
}