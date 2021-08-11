import "package:VoterChainFlutter/utils/models/Model.dart";

class CandidateModel extends Model {
  String name;
  String address;
  int numberOfVotes;

  CandidateModel({
    this.name,
    this.address,
    this.numberOfVotes
  });

  @override
  void copy(Model m) {
    var candidate = m as CandidateModel;
    name = candidate.name;
    address = candidate.address;
    numberOfVotes = candidate.numberOfVotes;
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
    "numberOfVotes": encode(numberOfVotes)
  };

  static final manager = CandidateModelManager();

  static final schema = """CREATE TABLE Candidate(
    name TEXT,
    numberOfVotes INTEGER,
    address TEXT PRIMARY KEY
  );""";

}

class CandidateModelManager extends ModelManager<CandidateModel> {
  CandidateModelManager() : super("Candidate");

  @override
  CandidateModel fromMap(Map<String, dynamic> map) => CandidateModel(
    name: decode(map["name"], String),
    address: decode(map["address"], String),
    numberOfVotes: decode(map["numberOfVotes"], int)
  );

}