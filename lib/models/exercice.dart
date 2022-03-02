class Exercice {
  int? id;
  String? name;

  exerciceMap() {
    var mapping = Map<String, dynamic>();
    mapping['id'] = id;
    mapping['name'] = name;

    return mapping;
  }
}
