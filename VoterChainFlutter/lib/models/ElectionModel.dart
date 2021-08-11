import "package:VoterChainFlutter/utils/models/Model.dart";

class ElectionModel extends Model {
  String name;
  String address;

  ElectionModel({
    this.name,
    this.address
  });

  @override
  void copy(Model m) {
    var election = m as ElectionModel;
    name = election.name;
    address = election.address;
  }

  @override
  get primaryKey => address;

  @override
  String get primaryKeyName => "address";

  @override
  Stream<Model> get stream => manager.streamController.stream;

  @override
  Map<String, dynamic> get toMap => {
    "name": encode(name),
    "address": encode(address),
  };

  static final manager = ElectionModelManager();

  static final schema = """CREATE TABLE Election(
    name TEXT,
    address TEXT PRIMARY KEY
  );""";

}

class ElectionModelManager extends ModelManager<ElectionModel> {
  ElectionModelManager() : super("Election");

  @override
  ElectionModel fromMap(Map<String, dynamic> map) => ElectionModel(
    name: decode(map["name"], String),
    address: decode(map["address"], String),
  );

}