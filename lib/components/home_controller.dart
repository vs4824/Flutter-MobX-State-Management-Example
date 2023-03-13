import 'package:mobx/mobx.dart';
import '../app/model/item_model.dart';
part 'home_controller.g.dart';

class HomeController = _HomeControllerBase with _$HomeController;

abstract class _HomeControllerBase with Store {
  @observable
  ObservableList<ItemModel> listItens = [
    ItemModel(title: 'item 1', check: true),
    ItemModel(title: 'item 2', check: false),
    ItemModel(title: 'item 3', check: false),
  ].asObservable();

  @computed
  int get totalChecked => listItens.where((element) => element.check).length;

  @computed
  List<ItemModel> get listFiltered {
    if (filter.isEmpty) {
      return listItens;
    } else {
      return listItens
          .where((element) =>
          element.title.toLowerCase().contains(filter.toLowerCase()))
          .toList();
    }
  }

  @observable
  String filter = "";

  @action
  setFilter(String value) => filter = value;

  @action
  addItem(ItemModel model) {
    listItens.add(model);
  }

  @action
  removeItem(ItemModel model) {
    listItens.removeWhere((item) => item.title == model.title);
  }
}