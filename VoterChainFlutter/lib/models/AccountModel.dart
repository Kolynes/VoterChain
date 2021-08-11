import "package:VoterChainFlutter/utils/models/Model.dart";

class AccountModel extends Model {
  int id;
  Map wallets;
  String password;

  AccountModel({
    this.password,
    this.id,
    this.wallets
  });

  @override
  void copy(Model m) {
    var account = m as AccountModel;
    password = account.password;
    wallets = account.wallets;
  }

  @override
  get primaryKey => id;

  @override
  String get primaryKeyName => "id";

  @override
  Stream<Model> get stream => manager.streamController.stream;

  @override
  Map<String, dynamic> get toMap => {
    "id": encode(id),
    "password": encode(password),
    "wallets": encode(wallets),
  };

  static final manager = AccountModelManager();

  static final schema = """CREATE TABLE Account(
    id INTEGER AUTOINCREMENT PRIMARY KEY,
    pasword TEXT,
    wallets TEXT
  );""";

}

class AccountModelManager extends ModelManager<AccountModel> {
  AccountModelManager() : super("Account");

  @override
  AccountModel fromMap(Map<String, dynamic> map) => AccountModel(
    id: decode(map["id"], int),
    wallets: decode(map["wallets"], Map),
    password: decode(map["password"], String)
  );

}