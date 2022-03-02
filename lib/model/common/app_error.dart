enum ESeverityLevel{
  Error,
  Critical
}

class AppError{
  String message;
  String description;
  ESeverityLevel severity;

  AppError({
    this.severity = ESeverityLevel.Critical,
    this.message = "Erreur inconnue",
    this.description = "Désolé, une erreur inconnue nous empêche de donner suite à votre requête veuillez réessayer dans un instant."});

  @override
  String toString() => message;
}