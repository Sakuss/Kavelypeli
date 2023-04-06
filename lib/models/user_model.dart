class AppUser {
  String? username, password, uid, email, steps, points;

  AppUser({
    this.username,
    this.password,
    this.uid,
    this.email,
    this.steps,
    this.points,
  });

  factory AppUser.fromJson(Map<String, dynamic> parsedJson) {
    return AppUser(
      username: parsedJson['name'] ?? "",
      password: parsedJson['password'] ?? "",
      uid: parsedJson['uid'] ?? "",
      email: parsedJson['email'] ?? "",
      steps: parsedJson['steps'] ?? "",
      points: parsedJson['points'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "password": password,
      "uid": uid,
      "email": email,
      "steps": steps,
      "points": points,
    };
  }
}
