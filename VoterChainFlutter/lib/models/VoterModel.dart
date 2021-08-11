import "package:VoterChainFlutter/utils/models/Model.dart";

class VoterModel extends Model {
  String name;
  bool hasVoted;
  bool registered;
  String address;

  VoterModel({
    this.name,
    this.hasVoted,
    this.registered,
    this.address
  });

  @override
  void copy(Model m) {
    var voter = m as VoterModel;
    name = voter.name;
    hasVoted = voter.hasVoted;
    registered = voter.registered;
    address = voter.address;
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
    "hasVoted": encode(hasVoted),
    "registered": encode(registered),
    "address": encode(address)
  };

  static final manager = VoterModelManager();

  static final schema = """CREATE TABLE Voter(
    name TEXT,
    hasVoted BOOLEAN,
    registered BOOLEAN,
    address TEXT PRIMARY KEY
  );""";

}

class VoterModelManager extends ModelManager<VoterModel> {
  VoterModelManager() : super("Voter");

  @override
  VoterModel fromMap(Map<String, dynamic> map) => VoterModel(
    address: decode(map["address"], String),
    name: decode(map["name"], String),
    hasVoted: decode(map["hasVoted"], bool),
    registered: decode(map["registered"], bool),
  );

}