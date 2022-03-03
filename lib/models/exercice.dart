class Exercice {
  int? id;
  String? name;
  int? serie;
  int? repetition;
  int? resttime;

  exerciceMap() {
    var mapping = Map<String, dynamic>();
    mapping['id'] = id;
    mapping['name'] = name;
    mapping['serie'] = serie;
    mapping['repetition'] = repetition;
    mapping['resttime'] = resttime;


    return mapping;
  }
}
