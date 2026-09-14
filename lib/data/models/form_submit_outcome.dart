enum FormSubmitError {
  submitting,
  invalidForm,
  missingDate,
  missingDimensions,
  unsigned,
  firebase,
  generic,
}

class FormSubmitOutcome {
  const FormSubmitOutcome.success({this.reference, this.documentId})
    : error = null,
      firebaseMessage = null;

  const FormSubmitOutcome.failure(this.error, {this.firebaseMessage})
    : reference = null,
      documentId = null;

  final FormSubmitError? error;
  final String? firebaseMessage;
  final String? reference;
  final String? documentId;

  bool get isSuccess => error == null;
}
