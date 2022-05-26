abstract class Item{
  String id;

  Item({
    this.id,
  });

  Item.fromJson(Map<String, dynamic> json) {
    id = json['id'];
  }
}