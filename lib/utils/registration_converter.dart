class RegistrationConverter {
  static String? yearFromAgeIdentifier(String value) {
    final age = int.tryParse(value.trim());
    if (age == null) return null;

    if (age >= 1 && age <= 49) {
      return (2000 + age).toString();
    }

    if (age >= 51 && age <= 99) {
      return (1950 + age).toString();
    }

    return null;
  }

  static List<String> ageIdentifiersForYear(int year) {
    if (year < 2001 || year > 2099) return const [];

    final spring = year - 2000;
    final autumn = spring + 50;

    return [
      spring.toString().padLeft(2, '0'),
      autumn.toString().padLeft(2, '0'),
    ];
  }

  static String registrationPeriod(String value) {
    final age = int.tryParse(value.trim());
    if (age == null) return 'Invalid registration age';

    if (age >= 1 && age <= 49) {
      final year = 2000 + age;
      return 'March $year to August $year';
    }

    if (age >= 51 && age <= 99) {
      final year = 1950 + age;
      return 'September $year to February ${year + 1}';
    }

    return 'Registration age not recognised';
  }
}
