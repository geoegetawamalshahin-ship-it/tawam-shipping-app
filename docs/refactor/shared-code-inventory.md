# Shared-code inventory (closing review)

Re-verified on `refactor/organized-widgets-pages` after track/details `shipmentStatusInfo`. Remaining track/details trees are **not** complete. Do not announce closure.

**This topic is not complete.** Agreed batches are in shared files and called from the intended pages. Do not treat this branch as finished duplication work.

Previous candidate tables at `50393fb` are historical.

## Scope of this closing pass

- Confirmed each extracted unit lives under `lib/app/widgets/` or `lib/app/utils/` and is **called** from the listed screens (not only exported).
- Confirmed old full trees for those units are gone from the pages; **short adapters remain** (colors, l10n, `setState`, navigation).
- Compared `origin/main...HEAD`: Dart/docs/test files only. No `lib/l10n`, `lib/locale_controller.dart`, `l10n.yaml`, Android, or iOS changes.
- Did not merge, publish, or start APK/device work.

**Limits:** not an exhaustive AST clone scan. Similar layout is not automatically duplication.

## Already shared and actually called

| Shared unit | Path | Called from (adapters OK) |
| --- | --- | --- |
| `ShippingFormHeader` | `lib/app/widgets/shipping/form_header.dart` | Air, car, land, parcel, international, sea |
| `ShippingSectionTitle` | `lib/app/widgets/shipping/section_title.dart` | Same six forms |
| `ShippingTrustBar` / `ShippingTrustItem` / `ShippingTrustDivider` | `trust_bar.dart`, `trust_item.dart`, `dividers.dart` | Same six forms |
| `ShippingContactDivider` | `dividers.dart` | Forms that show contact rows, including air |
| `ShippingNotesField` | `notes_field.dart` | Car, land, parcel, international, sea (**not air**) |
| `ShippingCustomerDetails` | `customer_details.dart` | Car, land, parcel, international, sea (**not air**) |
| `ShippingPremiumCard` | `premium_card.dart` | Six forms (section cards) |
| `shippingTextField` / `shippingInputDecoration` | `form_fields.dart` | Six forms; air: `labelWeight: null`, `focusedErrorBorderEnabled: false` |
| `shippingDropdown` | `form_controls.dart` | Six forms |
| `shippingDimensionField` | `form_controls.dart` | Air, land, parcel |
| `shippingOptionSwitch` | `form_controls.dart` | Six forms; default subtitle `height: 1.35`; air `subtitleHeight: null` |
| `ShippingServicesSection` | `services_section.dart` | Car, air, land, parcel, sea, international additional services. Special items stay separate (`_deepBlue`, `fontSize: 9.3`) |
| `ShippingSubmitButton` | `submit_button.dart` | Six forms |
| `ShippingQuoteSuccessDialog` | `quote_success_dialog.dart` | Car, land, parcel, international, air (`unstyledDoneButton: true`), sea (`myQuotesLetterSpacing: .35`). Close / My Quotes navigation stays on each page |
| `ShippingDateSelector` | `date_selector.dart` | Six forms; each page still owns `showDatePicker` |
| `ShippingSummaryBadge` | `summary_badge.dart` | Six forms; sea `showBorder: true`; air omits icon |
| `ShippingCalculationItem` | `calculation_item.dart` | Air, parcel |
| `showShippingMessage` | `show_shipping_message.dart` | Six forms via `_showMessage`; get-quote `_showMessage` (`isError` → `error`, `successColor: deepBlue`). Booking stays separate (`0xFF9D2732`) |
| `twoDigits` / `parseOptionalDouble` / `firstNonEmpty` / `formatLocalizedDate` | `lib/app/utils/value_formatters.dart` | Six forms; booking and get-quote `_formatDate`; booking/get-quote still use `firstNonEmpty` locally for profile fields |
| `firstKeyedValue` / `stringFromKeys` / `toLocalDateTime` / `formatOptionalLocalizedDate` / `formatOptionalLocalizedDateTime` | `value_formatters.dart` | Details + tracking adapters. Fallback `'-'`; dates `notSpecified` / `awaitingUpdate`; `.toLocal()` |
| `formatDisplayNumber` | `value_formatters.dart` | Air, parcel (`nonPositiveAsZero: true`); international without that flag |
| `positiveIntegerQuantityError` | `value_formatters.dart` | Land, sea. Request-quote quantity stays separate |
| `requiredFieldError` | `value_formatters.dart` | Request-quote + support `_requiredValidator` |
| `emailFieldError` | `value_formatters.dart` | Request-quote + support `_emailValidator`. Same trim + regex. Auth pages stay separate |
| `languageLabel` | `value_formatters.dart` | Home + Profile adapters. Stored `Arabic` / `French` / default English |
| `LanguagePickerSheet` / `showLanguagePickerSheet` | `lib/app/widgets/language_picker_sheet.dart` | Home (`LocaleController.languageName`) + Profile (`_selectedLanguage`). Languages still `LocaleController.languageNames`. Apply/save stays on each page |
| `NumberedSectionHeading` | `lib/app/widgets/numbered_section_heading.dart` | Booking + volume calculator (page `textDark` / `textGrey`) |
| `loadShippingCustomerProfile` / `FromAuth` | `lib/app/utils/shipping_customer_profile.dart` | Six shipping forms. Booking loader stays separate. Firestore still `users/{uid}` |
| `shipmentStatusInfo` / `ShipmentStatusInfo` | `lib/app/utils/shipment_status_info.dart` | Track + details `_statusInfo`. Backend status strings unchanged. Details still uses `description` (stage fallback). Track ignores description in the badge UI |
| `ShipmentSquareButton` / `ShipmentLiveDot` / `ShipmentHeroFeature` | `lib/app/widgets/shipment_status/` | Track, details, shipments list, support; live-dot also on my-support-requests |

Barrel: `lib/app/widgets/shipping_form_widgets.dart`. Tests: `test/shipping_*.dart`, `test/value_formatters_test.dart`, `test/numbered_section_heading_test.dart`, `test/language_picker_sheet_test.dart`, `test/shipment_status_info_test.dart`.

## Adapters kept (not leftover duplication)

Private methods that only pass page values into the shared unit: `_buildHeader`, `_buildTrustBar`, `_sectionTitle`, `_buildCustomerSection` / `_buildNotesSection` (five forms), `_textField` / `_dropdown` / `_inputDecoration` / `_dimensionField`, `_optionSwitch` (air `subtitleHeight: null`), `_buildServicesSection` (five forms), international `_buildAdditionalServicesSection`, `_dateSelector`, `_summaryBadge`, `_calculationItem`, `_buildSubmitButton`, `_showSuccessDialog` (six shipping forms), `_formatDate` (shipping/booking/get-quote), details/tracking `_firstValue` / `_stringValue` / `_formatDate` / `_formatDateTime`, details/tracking `_statusInfo`, booking/calculator `_sectionHeading`, Home/Profile `_languageLabel`, Home/Profile `_selectLanguage` (sheet UI shared; Home skips `setState`; Profile updates `_selectedLanguage` first), air/parcel/international `_formatNumber`, land/sea `_quantityValidator`, request-quote/support `_requiredValidator` / `_emailValidator`, six-form and get-quote `_showMessage`, six-form `_loadCustomerProfile` (unsigned-in `setState` before `await`), `_optionLabel`, `_selectReadyDate` / `_selectMovingDate`.

## Unresolved candidates (not done)

Do not announce completion while these remain.

| Candidate | Status |
| --- | --- |
| Track / details `_TimelineRow` | Open. Track `isLast` also zeros last-row bottom padding; details `showLine` with **always** `bottom: 18`. Do not force one API. |
| Track / details `_fallbackTimeline` | Open. Stage list and cancelled row match; line flag mapping differs (`isLast` vs `showLine: !isLast`). Depends on row API. |
| Track / details `_timelineIcon` | Open. Identical contains-rules; not extracted this batch. |
| Track / details `_prettyStatus` | Open. Details extra `shipment_created` → `notifShipmentCreatedTitle`. Do not merge that into Track. |
| Track / details `_currentLocation` | Open. Details live keys include `currentLocationName`; Track omits it. Details also prefers `_liveLocation` before the helper. |
| Track / details `_historyItems` | Open. Details extra `statusHistory` key. Firestore load stays on pages. |
| Details `_RoutePoint` / `_InfoCard` | Details-only chrome; **not** duplicated on Track. Not a two-screen extract. |
| Track + support SnackBar | **Open for later review.** Floating, radius 14, no fill. Not extracted. |

## Reviewed and left separate

| Candidate | Files | Why not extracted |
| --- | --- | --- |
| Auth field decoration | `login_screen.dart` inline `InputDecoration`; `register_screen.dart` `_fieldDecoration`; `forgot_password_screen.dart` inline | Shared chrome (radius 17, fill `0xFFF7F8FA`, focus `0xFF07569E` 1.7) but padding **20 vs 19**, login **omits error borders**, register has them, forgot has them + email icon vs login person icon. Email **rules stay different** (`contains('@')` vs `'@'`+`'.'` vs quote/support regex). Not unified. |
| Legal section cards | `privacy_policy_screen.dart` `_PrivacySectionCard`; `terms_conditions_screen.dart` `_TermsCard` | Header chrome is similar (46 icon tile, number chip). Privacy has **bullets** and bullet `margin: EdgeInsets.only(top: 6, right: 10)`. Terms is body text only. Copy/translation stay on each page. Not extracted this batch (would be a later chrome-only widget, not legal text). |

Booking / get-quote / request-quote / support success dialogs remain separate (different chrome). Booking SnackBar `0xFF9D2732` remains separate.

## Kept separate on purpose

Air customer/notes chrome; international special-item chips; air unstyled Done and sea `letterSpacing: .35` **via dialog parameters**; booking/get-quote/request-quote/support success dialogs; booking/get-quote/calculator cards and date rows; booking profile load (`TAWAM Customer`, extra keys, phone controller); support heading vs numbered heading; field decorations across auth/support/quote/search; list date fallbacks (`-` / `notProvided` / `notSpecified`); request-quote quantity vs land/sea; booking SnackBar (`0xFF9D2732`); track/support SnackBars; documents viewer; notifications list; Home vs Profile headers/logout.

## Diff vs `main` (scope)

**In scope:** new shared widgets/helpers; six shipping screens plus booking, get-quote (`formatLocalizedDate`, `showShippingMessage`), home/profile (`languageLabel`, language picker sheet), request-quote/support (`requiredFieldError`, `emailFieldError`), details/tracking (value/date helpers, `shipmentStatusInfo`); tests; this inventory.

**Protected files unchanged** vs `main`: `lib/l10n`, `lib/locale_controller.dart`, `l10n.yaml`, Android/iOS.

**Report, not reverted:** `shipment_status_widgets.dart` became a barrel exporting `square_button.dart`, `live_dot.dart`, `hero_feature.dart`. Same widgets, file split for organization. Call sites still use them.

No evidence in the file list of submit/navigation/validator-message/formula/Firestore-collection changes as a *goal* of this branch. Adapters still pass the same page callbacks, l10n keys, and stored status strings. This review did not re-run every calculation by hand.

## Delivery summary

**Done (agreed batches)**

- Shipping form chrome: header, section title, trust bar, premium card, fields, dropdowns, dimensions, option switches (air height preserved), services (six forms; international additional only), date selector chrome, submit, summary badges, calculation rows.
- Notes + customer details on five forms (air kept different).
- Quote success dialog on all six shipping forms (air unstyled Done; sea My Quotes letterSpacing `.35`).
- Helpers: dates/values, display numbers, land/sea quantity, required field, quote/support email field, language labels, shipping snackbars (six forms + get-quote), shipping customer profile load (`users/{uid}`).
- Numbered heading for booking + calculator. Home/Profile language picker sheet (apply/save remains on each page).
- Tracking/details keyed values, optional local dates, and status badge map (`shipmentStatusInfo`).
- Inventory of leftovers after a full `lib` scan (named methods and `build` trees).

**Not done**

- Track / details `_TimelineRow` / `_fallbackTimeline` (`isLast` vs `showLine` + last-row padding), `_timelineIcon`, `_prettyStatus`, `_currentLocation`, `_historyItems`.
- Track + support SnackBar (open for later review).
- Merge to `main`, store listing, APK, phone/tablet, English/Arabic/French walkthroughs of submit/track/documents.

**Checks**

- Extraction commits through `cbacdb4` had `protect-and-test` **success**. Docs commit `9a8eaa2` failed in `subosito/flutter-action@v2` (protect step passed; analyze/test skipped). Visual parity and device flows are **not** covered by CI.

## Suggested PR #4 description

Use the following body for the draft PR (title may stay or become: `Share duplicate shipping and form helpers`). GitHub CLI was not authenticated in this environment, so apply this on GitHub if the API update did not run.

```
## Summary
- Extract duplicate shipping-form UI and small helpers into `lib/app/widgets/shipping/` and `lib/app/utils/`, with page adapters for colors, copy, and callbacks.
- Share quote success on all six shipping forms; air keeps unstyled Done and sea keeps My Quotes `letterSpacing: .35`. Close/navigation stay on each page.
- Share tracking/details value and date helpers, booking/calculator numbered headings, Home/Profile language labels and picker sheet, and request-quote/support required-field and email validation.
- This does **not** finish all duplication. Track/details timeline row and fallback remain open (`isLast` vs `showLine`). Track/support SnackBar is open for later review.

## Intentional non-goals
- No merge to `main`, no store publish, no APK in this work.
- No `locale_controller` / l10n / platform config edits.
- Design, translation keys, navigation, validators’ messages, calculations, Firestore collections, and submit payloads were not meant to change; adapters keep page-owned values.

## Test plan
- [x] `flutter analyze` / `flutter test` via GitHub Actions `protect-and-test`
- [ ] English / Arabic (and French) on shipping forms, booking, quotes, tracking, support
- [ ] Phone and tablet layouts
- [ ] Submit quote / booking, success dialogs (including air/sea vs shared), profile autofill signed-in / signed-out
- [ ] Owner approval before merge
```

## Verification status

Call sites were re-checked: shared units still live in `lib/app/widgets` / `lib/app/utils` and are invoked from the pages listed above; short adapters remain. Draft PR #4 on GitHub still has the older customer-details summary; `gh` is not logged in here so the description could not be patched via API. Paste the suggested body on the PR. Duplication work is **open**. `main` is unchanged.
