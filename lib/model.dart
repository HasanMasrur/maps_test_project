class Person {
  final String firstName;
  final String lastName;
  final String avater;
  final String email;

  Person({this.firstName, this.lastName, this.avater, this.email});

  factory Person.fromJson(Map map) {
    return Person(
      firstName: map['first_name'],
      lastName: map['last_name'],
      avater: map['avatar'],
      email: map['email'],
    );
  }
}
