class UserModel {
  String _name = '';
  String _email = '';

  String get name => _name;
  String get email => _email;

  // UserModel(this._name, this._email);

  void addUserInfo(name, email) {
    _name = name;
    _email = email;
  }
}

class UserConverter {
  final String? name;
  final String? email;

  UserConverter({this.name, this.email});

  factory UserConverter.fromMap(dynamic data) {
    return UserConverter(name: data['name'], email: data['email']);
  }
}
