class UserModel {
  String _name = '';
  String _email = '';
  String _uid = '';

  String get name => _name;
  String get email => _email;
  String get uid => _uid;

  // UserModel(this._name, this._email);

  void addUserInfo(name, email, uid) {
    _name = name;
    _email = email;
    _uid = uid;
  }
}

class UserConverter {
  final String? name;
  final String? email;
  final String? uid;

  UserConverter({this.name, this.email, this.uid});

  factory UserConverter.fromMap(dynamic data) {
    return UserConverter(
        name: data['name'], email: data['email'], uid: data['uuid']);
  }
}

class pairedUserModel {
  String _name = '';
  String _email = '';
  String _uid = "";

  String get uid => _uid;
  String get name => _name;
  String get email => _email;

  // UserModel(this._name, this._email);

  void addUserInfo(name, email, uid) {
    _name = name;
    _email = email;
    _uid = uid;
  }
}
