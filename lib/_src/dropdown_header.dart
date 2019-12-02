import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

import 'package:dropdown_menu/_src/drapdown_common.dart';

typedef void DropdownMenuHeadTapCallback(int index);

typedef String GetItemLabel(dynamic data);

String defaultGetItemLabel(dynamic data) {
  if (data is String) return data;
  return data["title"];
}

class DropdownHeader extends DropdownWidget {
  final List<dynamic> titles;
  final int activeIndex;
  final DropdownMenuHeadTapCallback onTap;

  /// height of menu
  final double height;

  /// get label callback
  final GetItemLabel getItemLabel;

  /// button show text
  final String bottomString;

  DropdownHeader(
      {@required this.titles,
        this.activeIndex,
        DropdownMenuController controller,
        this.onTap,
        Key key,
        this.height: 46.0,
        this.bottomString,
        GetItemLabel getItemLabel})
      : getItemLabel = getItemLabel ?? defaultGetItemLabel,
        assert(titles != null && titles.length > 0),
        super(key: key, controller: controller);

  @override
  DropdownState<DropdownWidget> createState() {
    return new _DropdownHeaderState();
  }
}

class _DropdownHeaderState extends DropdownState<DropdownHeader> {
  Widget buildItem(BuildContext context, dynamic title, String bottomS,
      bool selected, int index) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color unselectedColor = Theme.of(context).unselectedWidgetColor;
    final GetItemLabel getItemLabel = widget.getItemLabel;

    return new GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: new Padding(
          padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
          child: new DecoratedBox(
              decoration: new BoxDecoration(
                  border: new Border(left: Divider.createBorderSide(context))),
              child: new Center(
                  child: new Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              getItemLabel(title),
                              style: new TextStyle(
                                color: selected ? primaryColor : unselectedColor,
                              ),
                            ),
                            bottomS != null && index == 0
                                ? Text("$bottomS",
                                style: new TextStyle(
                                  fontSize: 10,
                                  color: selected
                                      ? primaryColor
                                      : Color.fromRGBO(139, 137, 151, 1),
                                ))
                                : SizedBox(),
                          ],
                        ),
                        new Icon(
                          selected
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: selected ? primaryColor : unselectedColor,
                        )
                      ])))),
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap(index);

          return;
        }
        if (controller != null) {
          if (_activeIndex == index) {
            controller.hide();
            setState(() {
              _activeIndex = null;
            });
          } else {
            controller.show(index);
          }
        }
        //widget.onTap(index);
      },
    );
  }

  int _activeIndex;
  List<dynamic> _titles;

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    _titles = widget.titles;
    for (int i = 0, c = _titles.length; i < c; ++i) {
      list.add(buildItem(context, _titles[i], widget.bottomString,
          i == _activeIndex, i));
    }

    list = list.map((Widget widget) {
      return Expanded(
        child: widget,
      );
    }).toList();

    final Decoration decoration = BoxDecoration(
      border: Border(
        bottom: Divider.createBorderSide(context),
      ),
    );

    return DecoratedBox(
      decoration: decoration,
      child: new SizedBox(
          child: Row(
            children: list,
          ),
          height: widget.height),
    );
  }

  @override
  void initState() {
    _titles = widget.titles;
    super.initState();
  }

  @override
  void onEvent(DropdownEvent event) {
    switch (event) {
      case DropdownEvent.SELECT:
        {
          if (_activeIndex == null) return;

          setState(() {
            _activeIndex = null;
            String label = widget.getItemLabel(controller.data);
            _titles[controller.menuIndex] = label;
          });
        }
        break;
      case DropdownEvent.HIDE:
        {
          if (_activeIndex == null) return;
          setState(() {
            _activeIndex = null;
          });
        }
        break;
      case DropdownEvent.ACTIVE:
        {
          if (_activeIndex == controller.menuIndex) return;
          setState(() {
            _activeIndex = controller.menuIndex;
          });
        }
        break;
    }
  }
}
