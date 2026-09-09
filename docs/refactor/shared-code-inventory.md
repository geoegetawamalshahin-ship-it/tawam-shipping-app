# Shared-code inventory

Reviewed on `refactor/organized-widgets-pages` after sharing tracking/details value and date helpers. Previous candidate table at `50393fb` is historical.

This document replaces the candidate table taken at `50393fb`. Many rows in that table were later extracted and now exist only as page adapters.

## Scope and limits

Scanned `lib/screens` (28 Dart files), `lib/app/widgets`, and `lib/app/utils/value_formatters.dart`. Compared named methods and confirmed whether remaining methods still contain widget trees or only pass local values into shared implementations.

This is not an exhaustive AST clone analysis. Inline trees, renamed methods, and near-duplicates can still exist. Identical source can still depend on different page constants, state, localization, empty-value fallbacks, or date conversion. Generated localization files are excluded.

A short page method that only supplies colors, labels, controllers, or callbacks to a shared widget is an **adapter**, not duplicated presentation code.

Shared UI belongs under `lib/app/widgets/` with feature subfolders. Shared non-UI logic belongs in a helper such as `lib/app/utils/value_formatters.dart`. Do not add empty controllers or bindings only to imitate another project's folders.

## Already shared and actually called

Callers listed below invoke the shared implementation. Remaining private methods with the same names on those pages are adapters unless noted later.

| Shared unit | Location | Called from |
| --- | --- | --- |
| `ShippingFormHeader` | `lib/app/widgets/shipping/form_header.dart` | Six shipping forms |
| `ShippingSectionTitle` | `lib/app/widgets/shipping/section_title.dart` | Six shipping forms |
| `ShippingTrustBar` / `ShippingTrustItem` / `ShippingTrustDivider` | `trust_bar.dart`, `trust_item.dart`, `dividers.dart` | Six shipping forms |
| `ShippingContactDivider` | `dividers.dart` | Shipping forms that show contact rows (including air) |
| `ShippingNotesField` | `notes_field.dart` | Car, land, parcel, international, sea (not air) |
| `ShippingCustomerDetails` | `customer_details.dart` | Car, land, parcel, international, sea (not air) |
| `ShippingPremiumCard` | `premium_card.dart` | Six shipping forms (many section cards) |
| `shippingTextField` / `shippingInputDecoration` | `form_fields.dart` | Six shipping forms; air passes `labelWeight: null` and `focusedErrorBorderEnabled: false` |
| `shippingDropdown` | `form_controls.dart` | Six shipping forms |
| `shippingDimensionField` | `form_controls.dart` | Air, land, parcel adapters |
| `shippingOptionSwitch` | `form_controls.dart` | Car, land, parcel, international, sea (not air) |
| `ShippingServicesSection` | `services_section.dart` | Car, air, land, parcel, sea (not international) |
| `ShippingSubmitButton` | `submit_button.dart` | Six shipping forms |
| `ShippingQuoteSuccessDialog` | `quote_success_dialog.dart` | Car, parcel, international |
| `ShippingDateSelector` | `date_selector.dart` | Six shipping forms; each page still owns `showDatePicker` |
| `ShippingSummaryBadge` | `summary_badge.dart` | Six shipping forms; sea passes `showBorder: true`; air omits icon |
| `ShippingCalculationItem` | `calculation_item.dart` | Air, parcel |
| `twoDigits` / `parseOptionalDouble` / `firstNonEmpty` / `formatLocalizedDate` | `lib/app/utils/value_formatters.dart` | Six shipping forms; booking and get-quote use the value helpers |
| `firstKeyedValue` / `stringFromKeys` / `toLocalDateTime` / `formatOptionalLocalizedDate` / `formatOptionalLocalizedDateTime` | `lib/app/utils/value_formatters.dart` | `shipment_details_screen.dart` and `track_shipment_screen.dart` via adapters. Default string fallback `'-'`. Date empty fallbacks remain `notSpecified` and `awaitingUpdate`. Unparsed text is shown as-is. Dates use `.toLocal()` |
| `NumberedSectionHeading` | `lib/app/widgets/numbered_section_heading.dart` | `create_booking_screen.dart` and `volume_calculator_screen.dart` via adapters. Each page still supplies its own `textDark` / `textGrey` (they differ) |
| `languageLabel` | `lib/app/utils/value_formatters.dart` | `home_screen.dart` and `profile_screen.dart` via adapters. Stored values stay `Arabic` / `French` / default English |
| `formatDisplayNumber` | `lib/app/utils/value_formatters.dart` | Air and parcel adapters pass `nonPositiveAsZero: true`. International omits that flag so its previous signed-integer path stays |
| Shipment-status widgets | `lib/app/widgets/shipment_status/` | Existing barrel `shipment_status_widgets.dart` |

Targeted tests for several of these units live under `test/shipping_*.dart` and `test/value_formatters_test.dart`.

## Remaining adapters (do not count as duplication)

These still exist as private methods but only wrap the shared unit:

- `_buildHeader`, `_buildTrustBar`, `_sectionTitle`
- `_buildCustomerSection` / `_buildNotesSection` on the five forms that use the shared widgets
- `_premiumCard` is gone from the six shipping forms; they construct `ShippingPremiumCard` directly
- `_textField`, `_dropdown`, `_inputDecoration`, `_dimensionField` (air/land/parcel)
- `_optionSwitch` on car/land/parcel/international/sea
- `_buildServicesSection` on the five chip-based forms
- `_dateSelector` on the six shipping forms
- `_summaryBadge`, `_calculationItem`, `_buildSubmitButton`
- `_showSuccessDialog` on car/parcel/international (shows `ShippingQuoteSuccessDialog`)
- `_formatDate` on shipping forms, booking, and get-quote (calls `formatLocalizedDate`)
- `_firstValue` / `_stringValue` / `_formatDate` / `_formatDateTime` on details and tracking (call the shared helpers; tracking/details `_formatDate` still passes `notSpecified`)
- `_sectionHeading` on booking and volume calculator (calls `NumberedSectionHeading` with page colors)
- `_languageLabel` on Home and Profile (calls `languageLabel`)
- `_formatNumber` on air, parcel, and international (calls `formatDisplayNumber`; air/parcel keep `<= 0` as `'0'`)
- `_optionLabel` (calls `LocaleController.optionLabel`)
- `_selectReadyDate` / `_selectMovingDate` (page-owned pickers; keep bounds and `helpText` on the page)

## Remaining duplication suitable for extraction

Verify dependencies, empty-value behavior, and visual values before each extraction. Do not change submit, navigation, validators' messages, or calculation formulas while sharing.

| Item | Copies | Locations | Notes |
| --- | ---: | --- | --- |
| `_loadCustomerProfile` | 6 | Six shipping forms | Same Firestore `users/{uid}` field order and `tawamCustomer` fallback. Booking's loader is different; do not merge with it. Prefer a small helper that returns values, not a new service layer. |
| `_showMessage` (shipping forms) | 6 | Six shipping forms | Same floating SnackBar; error color `0xFF9E2A2A` vs `_deepBlue`. |
| `_quantityValidator` | 2 | Land, sea | Same `int.tryParse` and `enterQuantity`. Do not merge with `request_quote_screen`'s different messages. |
| Land `_showSuccessDialog` | 1 leftover full tree | `land_freight_screen.dart` | Chrome matches `ShippingQuoteSuccessDialog` (styled Done button, no extra letter-spacing). Candidate to switch to the existing dialog without redesign. |
| Air `_optionSwitch` | 1 leftover full tree | `air_freight_screen.dart` | Same structure as `shippingOptionSwitch` except subtitle has no `height: 1.35`. Extract only if that difference is preserved. |
| `_requiredValidator` | 2 | `request_quote_screen.dart`; `support_screen.dart` | Identical trim/empty check. Tiny; optional. |
| `_emailValidator` | 2 | Same two screens | Same empty and regex checks; keep current messages. Tiny; optional. |

## Keep separate (different on purpose or unsafe to merge)

| Item | Why it stays separate |
| --- | --- |
| Air customer block (`_buildCustomerSection` / `_contactRow`) | Near the shared widget but labels omit `FontWeight.w600` and the verified line omits `height: 1.35`. |
| Air notes field | No prefix icon; hint color `0xFFA1ACB9` without `height: 1.45`. `ShippingNotesField` would change the screen. |
| International additional services | `FilterChip` wrap, not `ShippingServicesSection` chips. |
| Air / sea quote success dialogs | Air Done button is an unstyled `OutlinedButton`. Sea My Quotes label uses `letterSpacing: .35`. Sea also takes unused `documentId`. Do not force them onto `ShippingQuoteSuccessDialog` without preserving those values. |
| Booking / get-quote / support / request-quote success dialogs | Different titles, actions, and booking vs quote copy. |
| Booking `_premiumCard` | Same padding/radius as shipping card but shadow blur `14` / offset `5` vs shipping `18` / `7`. |
| Get-quote `_card` | Radius `20`, blur `12`. |
| Calculator dimension card | Radius `22`, blur `14`. |
| Booking `_dateSelector` | Height `62`, no 39×39 icon well, no trailing chevron, different type sizes/weights than `ShippingDateSelector`. |
| Booking `_loadCustomerProfile` | Uses booking controller, extra keys (`customerName` / `customerEmail` / `customerPhone`), writes `_phoneController`, hardcoded `'TAWAM Customer'`. |
| Support `_sectionHeading` | Title/subtitle only; no numbered badge. Not the booking/calculator heading. |
| `shipment_request_page` `_inputDecoration` | Radius `18`, padding `18`, different fill. |
| Get-quote / booking text and dimension fields | Own capitalization, padding, and radii. |
| `_selectReadyDate` implementations | Shared calendar chrome is already extracted; help text and which field is set stay on the page. |
| `_refreshSummary` / `_refreshCalculations` | One-line `setState` wrappers. |
| List date formatters | `my_bookings_screen` formats Timestamp without `toLocal()` and falls back to `'-'`. `my_quotes_screen` uses epoch-0 → `notProvided`. `shipments_screen` uses `toLocal()` and `notSpecified`. Do not merge these with each other or with details/tracking without preserving those fallbacks. |
| Tracking/support `_showMessage` vs shipping vs profile vs notifications | Tracking/support: rounded `14`, no background color. Profile: navy, margin `14`, radius `16`, bold text. Notifications: radius `16`, no hide-current in the same way. Keep SnackBar chrome per screen. |
| Land/sea `_quantityValidator` vs request-quote quantity validator | Different empty handling and localization keys (`enterQuantity` vs `pleaseEnterNumberOfItems` / `pleaseEnterValidQuantity`). |
| `firstNonEmpty` vs `firstKeyedValue` | List of values vs map key order. Do not combine. |

## Cross-feature review status

- **Booking vs volume calculator:** numbered `_sectionHeading` is shared and called. Cards, inputs, and date rows differ and stay on their pages.
- **Tracking vs shipment details:** map/date helpers are shared and called. Status cards, search, live tracking chrome, and history rendering stay on their pages until a later inline-tree review.
- **Home vs profile:** `_languageLabel` is shared and called. Language pickers, switching, persistence, and layout stay on their pages.
- **Auth, lists, documents, legal, notifications:** no shipping-form widget reuse. SnackBars and date formatters differ as listed. A later pass can still inspect unnamed inline clones.

## Suggested execution order from this baseline

1. Done: details/tracking value and local-date helpers live in `value_formatters.dart`, with fallback arguments, `.toLocal()`, and targeted empty/date-type tests.
2. Done: booking/calculator numbered `_sectionHeading` is `NumberedSectionHeading`, with page-supplied number, icon, copy, and colors.
3. Optional small helpers: shipping `_showMessage`, land/sea quantity validator, shipping profile-field loading helper. Home/Profile `languageLabel` and display `_formatNumber` are done.
4. Switch land success dialog onto the existing shared dialog only after a side-by-side style check. Leave air and sea dialogs separate unless their differences are parameterized.
5. Revisit air `_optionSwitch` only with the subtitle `height` difference preserved.
6. Continue scanning inline trees (auth, lists, support, documents). Record exceptions rather than forcing one design.
7. After each batch: review the diff, run Flutter analysis and tests, add behavior tests where callbacks or empty values can regress.
8. APK plus phone/tablet, English/Arabic, and core flows remain pending. Do not merge to `main` without owner approval.

## Verification status

Local `flutter analyze` and `flutter test` passed after sharing display number formatting. GitHub Actions on this branch still need to be confirmed after each push. Those checks do not cover visual parity or full device workflows. APK build and manual verification are still pending. `main` is unchanged.
