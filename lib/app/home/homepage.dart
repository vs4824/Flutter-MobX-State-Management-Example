import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../components/home_controller.dart';
import '../model/item_model.dart';
import '../widget/item_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = HomeController();

  _dialog() {
    var model = ItemModel();

    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text("Add item"),
            content: TextField(
              onChanged: model.setTitle,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Item Name',
              ),
            ),
            actions: <Widget>[
              GestureDetector(
                onTap: () {
                  controller.addItem(model);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: controller.setFilter,
          decoration: const InputDecoration(hintText: "Search..."),
        ),
        actions: <Widget>[
          Observer(builder: (_) {
            return IconButton(
              icon: Text(controller.totalChecked.toString()),
              onPressed: () {},
            );
          }),
        ],
      ),
      body: Observer(
        builder: (_) {
          return ListView.builder(
            itemCount: controller.listFiltered.length,
            itemBuilder: (_, index) {
              var item = controller.listFiltered[index];
              return ItemWidget(
                item: item,
                removeClicked: () {
                  controller.removeItem(item);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _dialog();
        },
      ),
    );
  }
}