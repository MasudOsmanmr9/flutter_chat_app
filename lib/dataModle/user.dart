class User {
  String _name;
  String _email;

  String get name => _name;
  String get email => _email;

  User(this._name, this._email);

  void addUserInfo(name, email) {
    _name = name;
    _email = email;
  }
}
