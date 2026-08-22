abstract interface class BackupDestinationPicker {
  Future<String?> pickDestination({required String suggestedName});
}
