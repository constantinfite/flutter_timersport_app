class Exercice {
  int? id;
  String? name;
  int? serie;
  int? repetition;
  int? resttime;
  int? exercicetime;
  String? mode;
  int? color;

  exerciceMap() {
    var mapping = Map<String, dynamic>();
    mapping['id'] = id;
    mapping['name'] = name;
    mapping['serie'] = serie;
    mapping['repetition'] = repetition;
    mapping['resttime'] = resttime;
    mapping['exercicetime'] = exercicetime;
    mapping['mode'] = mode;
    mapping['color'] = color;

    return mapping;
  }
}

