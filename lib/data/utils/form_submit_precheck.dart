import '../models/form_submit_outcome.dart';

FormSubmitOutcome? formSubmitPrecheck({
  required bool alreadySubmitting,
  required bool formValid,
  required bool signedIn,
  bool requireDate = false,
  DateTime? date,
  bool dimensionsOk = true,
}) {
  if (alreadySubmitting) {
    return const FormSubmitOutcome.failure(FormSubmitError.submitting);
  }
  if (!formValid) {
    return const FormSubmitOutcome.failure(FormSubmitError.invalidForm);
  }
  if (requireDate && date == null) {
    return const FormSubmitOutcome.failure(FormSubmitError.missingDate);
  }
  if (!dimensionsOk) {
    return const FormSubmitOutcome.failure(FormSubmitError.missingDimensions);
  }
  if (!signedIn) {
    return const FormSubmitOutcome.failure(FormSubmitError.unsigned);
  }
  return null;
}
