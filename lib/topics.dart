// lib/enums/topics.dart

enum Topics {
  decentralizationProcess,
  economicStructure,
}

extension TopicsExtension on Topics {
  String get value {
    switch (this) {
      case Topics.decentralizationProcess:
        return 'descentralization-process';
      case Topics.economicStructure:
        return 'economic-structure';
    }
  }

  static Topics? fromString(String topic) {
    switch (topic) {
      case 'descentralization-process':
        return Topics.decentralizationProcess;
      case 'economic-structure':
        return Topics.economicStructure;
      default:
        return null;
    }
  }

  String get displayName {
    switch (this) {
      case Topics.decentralizationProcess:
        return 'Proceso de Descentralización';
      case Topics.economicStructure:
        return 'Estructura Económica';
    }
  }
}
