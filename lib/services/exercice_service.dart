import 'package:sport_timer/models/exercice.dart';
import 'package:sport_timer/repositories/repository.dart';

class ExerciceService {
  late Repository _repository;

  ExerciceService() {
    _repository = Repository();
  }

  //Create data
  saveExercice(Exercice exercice) async {
    return await _repository.insertData('exercices', exercice.exerciceMap());
  }

  //Update data
  updateExercice(Exercice exercice) async {
    return await _repository.updateData('exercices', exercice.exerciceMap());
  }

  // Read data from table
  readExercices() async {
    return await _repository.readData('exercices');
  }

  //Read data from table by Id
  readExerciceById(exerciceId) async {
    return await _repository.readDataById('exercices', exerciceId);
  }

  // Delete data from table
  deleteExercice(exerciceId) async{
    return await _repository.deleteData('exercices', exerciceId);
  }
}
