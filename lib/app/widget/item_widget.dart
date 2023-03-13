import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../model/item_model.dart';

class ItemWidget extends StatelessWidget {
  const ItemWidget({Key? key, this.item, this.removeClicked}) : super(key: key);

  final ItemModel? item;
  final void Function()? removeClicked;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return ListTile(
          title: Text(item!.title),
          // leading: Checkbox(
          //   value: item?.check ?? false,
          //   onChanged: item?.setCheck,
          // ),
          trailing: IconButton(
            icon: Icon(Icons.remove_circle, color: Colors.red,),
            onPressed: removeClicked,
          ),
        );
      },
    );
  }
}