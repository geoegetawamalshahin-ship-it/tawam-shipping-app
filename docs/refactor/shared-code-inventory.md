# Shared-code inventory

Reviewed on `refactor/organized-widgets-pages` after a remaining-duplication pass (inspection only; no application-code change in this commit). Previous candidate tables at `50393fb` and later batch notes are historical.

This document replaces the earlier inventory. Many rows from those tables were extracted and now exist only as page adapters.

## Scope and limits

**Inspected (this pass)**

- All 28 Dart files under `lib/screens/` (login, register, forgot password, splash, home, profile, six shipping forms, create booking, get-quote, request-quote, volume calculator, my quotes, my bookings, shipments list, shipment details, track shipment, support, my support requests, shipping documents, notifications, privacy, terms, shipment request page).
- `lib/app/widgets/` (shipping form widgets, numbered heading, shipment-status barrel, responsive frame).
- `lib/app/utils/` (`value_formatters.dart`, `shipping_customer_profile.dart`).
- Named private methods **and** unnamed trees inside `build` / sheet / dialog builders (headers, fields, chips, SnackBars, success dialogs, language sheets, timelines).

**Not treated as UI clones**

- Generated `lib/l10n/` (except using keys as page-owned copy).
- `lib/locale_controller.dart` (CI-protected; do not edit in this refactor).
- Firebase/Supabase config, Android/iOS platform files.
- GetX controllers, services, and bindings except where a screen already calls them (do not add empty layers to “organize” clones).

**Limits**

This is not an exhaustive AST clone analysis. Renamed methods and near-duplicates can still exist. Identical source can still depend on different page constants, state, localization, empty-value fallbacks, or date conversion. Similar layout is not automatically duplication.

A short page method that only supplies colors, labels, controllers, or callbacks to a shared widget is an **adapter**, not duplicated presentation code.

Shared UI belongs under `lib/app/widgets/` with existing feature folders. Shared non-UI logic belongs in a helper such as `lib/app/utils/value_formatters.dart`. Do not add empty controllers or bindings only to imitate another project’s folders.

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
| `shippingOptionSwitch` | `form_controls.dart` | Six shipping forms. Default subtitle `height` is `1.35`. Air passes `subtitleHeight: null` |
| `ShippingServicesSection` | `services_section.dart` | Car, air, land, parcel, sea (not international) |
| `ShippingSubmitButton` | `submit_button.dart` | Six shipping forms |
| `ShippingQuoteSuccessDialog` | `quote_success_dialog.dart` | Car, land, parcel, international. Air and sea stay inline |
| `ShippingDateSelector` | `date_selector.dart` | Six shipping forms; each page still owns `showDatePicker` |
| `ShippingSummaryBadge` | `summary_badge.dart` | Six shipping forms; sea passes `showBorder: true`; air omits icon |
| `ShippingCalculationItem` | `calculation_item.dart` | Air, parcel |
| `twoDigits` / `parseOptionalDouble` / `firstNonEmpty` / `formatLocalizedDate` | `lib/app/utils/value_formatters.dart` | Six shipping forms; booking and get-quote use the value helpers |
| `firstKeyedValue` / `stringFromKeys` / `toLocalDateTime` / `formatOptionalLocalizedDate` / `formatOptionalLocalizedDateTime` | `lib/app/utils/value_formatters.dart` | `shipment_details_screen.dart` and `track_shipment_screen.dart` via adapters. Default string fallback `'-'`. Date empty fallbacks remain `notSpecified` and `awaitingUpdate`. Unparsed text is shown as-is. Dates use `.toLocal()` |
| `NumberedSectionHeading` | `lib/app/widgets/numbered_section_heading.dart` | `create_booking_screen.dart` and `volume_calculator_screen.dart` via adapters. Each page still supplies its own `textDark` / `textGrey` (they differ) |
| `languageLabel` | `lib/app/utils/value_formatters.dart` | `home_screen.dart` and `profile_screen.dart` via adapters. Stored values stay `Arabic` / `French` / default English |
| `formatDisplayNumber` | `lib/app/utils/value_formatters.dart` | Air and parcel adapters pass `nonPositiveAsZero: true`. International omits that flag so its previous signed-integer path stays |
| `positiveIntegerQuantityError` | `lib/app/utils/value_formatters.dart` | Land and sea `_quantityValidator` adapters pass `enterQuantity`. `request_quote_screen` stays separate |
| `requiredFieldError` | `lib/app/utils/value_formatters.dart` | `request_quote_screen.dart` and `support_screen.dart` via `_requiredValidator`. Pages still pass their own l10n messages |
| `showShippingMessage` | `lib/app/widgets/shipping/show_shipping_message.dart` | Six shipping forms via `_showMessage`. Error color `0xFF9E2A2A`, success color from each page `_deepBlue`, floating, hide previous, default duration. Get-quote matches this chrome but still inlines it |
| `loadShippingCustomerProfile` | `lib/app/utils/shipping_customer_profile.dart` | Six shipping forms via adapters. Unsigned-in loading flag stays on the page. Pages still apply `tawamCustomer`, `setState`, and `mounted`. Booking stays separate |
| `ShipmentSquareButton` / `ShipmentLiveDot` / `ShipmentHeroFeature` | `lib/app/widgets/shipment_status/` | Track, details, shipments list, support; live-dot also on my-support-requests |

Targeted tests for several of these units live under `test/shipping_*.dart` and `test/value_formatters_test.dart`.

## Remaining adapters (do not count as duplication)

These still exist as private methods but only wrap the shared unit:

- `_buildHeader`, `_buildTrustBar`, `_sectionTitle` on the six shipping forms
- `_buildCustomerSection` / `_buildNotesSection` on the five forms that use the shared widgets (not air)
- `_textField`, `_dropdown`, `_inputDecoration`, `_dimensionField` (air/land/parcel as applicable)
- `_optionSwitch` on the six shipping forms (air passes `subtitleHeight: null`)
- `_buildServicesSection` on the five chip-based forms (not international additional services)
- `_dateSelector` on the six shipping forms
- `_summaryBadge`, `_calculationItem`, `_buildSubmitButton`
- `_showSuccessDialog` on car/land/parcel/international (shows `ShippingQuoteSuccessDialog`; `barrierDismissible: false`; Done pops the form)
- `_formatDate` on shipping forms, booking, and get-quote (calls `formatLocalizedDate`)
- `_firstValue` / `_stringValue` / `_formatDate` / `_formatDateTime` on details and tracking
- `_sectionHeading` on booking and volume calculator (calls `NumberedSectionHeading` with page colors)
- `_languageLabel` on Home and Profile (calls `languageLabel`)
- `_formatNumber` on air, parcel, and international (calls `formatDisplayNumber`)
- `_quantityValidator` on land and sea (calls `positiveIntegerQuantityError`)
- `_requiredValidator` on request-quote and support (calls `requiredFieldError`)
- `_showMessage` on the six shipping forms (calls `showShippingMessage`)
- `_loadCustomerProfile` on the six shipping forms (unsigned-in `setState` before any `await`)
- `_optionLabel` (calls `LocaleController.optionLabel`)
- `_selectReadyDate` / `_selectMovingDate` (page-owned pickers; chrome is shared; help text and which field is set stay on the page)
- `_refreshSummary` / `_refreshCalculations` (one-line `setState`)

## Remaining duplication suitable for extraction

Verify dependencies, empty-value behavior, and visual values before each extraction. Do not change submit, navigation, validators’ messages, or calculation formulas while sharing. Do not force one design onto another screen.

| Item | Copies | Locations | Matching | Differences | Suggested batch | Tests |
| --- | ---: | --- | --- | --- | --- | --- |
| `_emailValidator` | 2 | `request_quote_screen.dart`; `support_screen.dart` | Empty → `pleaseEnterEmail`; regex `^[^@\s]+@[^@\s]+\.[^@\s]+$` → `pleaseEnterValidEmail` | Local variable names only | `emailFieldError` next to `requiredFieldError` in `value_formatters.dart`. Pages keep adapters and l10n keys | Empty, whitespace, invalid, valid; both `pleaseEnterEmail` and `pleaseEnterValidEmail` |
| International additional services | 1 leftover tree | `international_moving_screen.dart` `_buildAdditionalServicesSection` vs `ShippingServicesSection` | Premium card, title/subtitle sizes, `Wrap` `FilterChip` (checkmark, radius 30, `fontSize: 9.5`, `_primaryBlue`) | Special-items section uses `_deepBlue` and `fontSize: 9.3` — leave that section unless those values become parameters | Adapter only: additional services call `ShippingServicesSection`. Do not change special items in the same batch | Existing services-section tests plus select/deselect of international option values |
| Get-quote `_showMessage` | 1 leftover | `get_quote_screen.dart` vs `showShippingMessage` | Hide current, floating, error `0xFF9E2A2A`, success page `deepBlue` | Named `isError` vs `error`; booking uses `0xFF9D2732` — keep booking separate | Get-quote adapter → `showShippingMessage`. Do not include booking, request-quote, calculator | Existing `shipping_show_message_test.dart`; confirm error/success colors |
| Home / Profile language sheet | 2 | `home_screen.dart` `_selectLanguage`; `profile_screen.dart` `_selectLanguage` | Transparent sheet, radius 30, 44×5 handle `0xFFD9DEE5`, `applicationLanguage`, option rows, then `setLanguage` / `Get.updateLocale` / `saveLanguage` | Home current value is `LocaleController.languageName`. Profile uses `_selectedLanguage` and `setState`. Color field names differ (`textDark` vs `_text`) | Shared sheet widget under `lib/app/widgets/` that takes selected language, label builder, and page colors. Keep apply/`setState` on each page | Sheet shows stored names; tap returns original `English`/`Arabic`; Home vs Profile selection sources stay distinct |
| Track / details fallback timeline | 2 | `track_shipment_screen.dart` `_fallbackTimeline`; `shipment_details_screen.dart` `_fallbackTimeline` | Same seven stages, customs key remap, cancelled single row, completed/active/waiting times | Track `_TimelineRow(isLast:)`; details `showLine: !isLast` | Share stage list + index logic first; keep row widgets on pages until a widget batch | Status index (`customs` → clearance, unknown → 0, cancelled) |
| Track / details status map, location, pretty status, timeline icon | 2–3 | Track, details; shipments list has a slimmer status/location map | Same colors/icons/progress for shared statuses; delivered/out_for_delivery → delivery; pending/confirmed/prepared → pickup | Details adds description and extra location keys; list omits progress; history key lists differ | Helpers with injectable keys / optional description. Do not merge search UIs or hero vs status card | Each status color/progress; live location wins; empty fallback |
| Track / details `_TimelineRow`, route endpoint, compact info tile | 2 | Track and details private widgets | Circle colors, CURRENT badge, connector, endpoint column, compact tile | `isLast` vs `showLine`; last-row padding; tile minHeight 106 vs 107; details also has `_WideInfoCard` | After logic batch: one widget in existing `shipment_status/` with `showLine` + padding. Leave wide card on details | Smoke: current badge, last row has no connector |
| Track + support SnackBar chrome | 2 | `track_shipment_screen.dart` `_showMessage`; `support_screen.dart` `_showMessage` | Hide current, floating, radius 14, no background color | None material | Optional tiny helper. Do **not** merge with shipping, profile, notifications, documents | Hide-previous + radius 14; no background |
| Air / sea quote success (optional) | 2 leftover trees | `air_freight_screen.dart`; `sea_freight_screen.dart` vs `ShippingQuoteSuccessDialog` | Same shell, copy keys, reference, My Quotes / Done navigation, `barrierDismissible: false` | Air Done is an unstyled `OutlinedButton`. Sea My Quotes uses `letterSpacing: .35`. Sea unused `documentId` | Only if parameterized: `styleDoneButton` / `myQuotesLetterSpacing` with defaults matching the shared dialog. Do not change car/land/parcel/international | Dialog tests: unstyled Done; letterSpacing; barrier; independent actions |
| Auth field decoration (optional) | 3 | Login (inline), register `_fieldDecoration`, forgot (inline) | Fill `0xFFF7F8FA`, radius 17, focused `0xFF07569E` | Login omits error borders; vertical padding 20 vs 19 | Auth-only helper. Do **not** reuse `shippingInputDecoration` | Focus/error borders; login without error borders if that stays |
| Legal section card (optional) | 2 | `privacy_policy_screen.dart`; `terms_conditions_screen.dart` | Gradient header, back chip, white card, number pill | Privacy supports `bullets`; terms do not | Shared card with `bullets: const []`. Leave page copy | Optional smoke that bullets render only when provided |

## Keep separate (different on purpose or unsafe to merge)

| Item | Why it stays separate |
| --- | --- |
| Air customer block (`_buildCustomerSection` / `_contactRow`) | Labels omit `FontWeight.w600`; verified line omits `height: 1.35`. |
| Air notes field | No prefix icon; hint color `0xFFA1ACB9` without `height: 1.45`. |
| International special items | Same chip family as `ShippingServicesSection` but `selectedColor: _deepBlue` and label `fontSize: 9.3`. |
| Air / sea quote success (until parameterized) | Air Done unstyled; sea `letterSpacing: .35` and unused `documentId`. |
| Booking / get-quote / request-quote / support success dialogs | Different titles, actions, booking vs quote vs support copy; request-quote shows a route row and no reference. |
| Booking `_premiumCard` | Shadow blur `14` / offset `5` vs shipping `18` / `7`. |
| Get-quote `_card` | Radius `20`, blur `12`. Get-quote section title has no numbered badge. Trust items are title-only. |
| Calculator dimension card | Radius `22`, blur `14`. |
| Booking `_dateSelector` | Height `62`, no 39×39 icon well, no trailing chevron, different type sizes. |
| Booking `_loadCustomerProfile` | Booking controller, extra keys (`customerName` / `customerEmail` / `customerPhone`), writes `_phoneController`, hardcoded `'TAWAM Customer'`. |
| Support `_sectionHeading` | Title/subtitle only; no numbered badge. |
| Support / request-quote / profile / auth / track / shipments search field decorations | Near each other but radii, fills, hint sizes, and label vs hint-only differ. Unify chrome only if product asks. |
| `shipment_request_page` `_inputDecoration` | Radius `18`, padding `18`, different fill. |
| Get-quote / booking text and dimension fields | Own capitalization, padding, and radii. |
| Track status card vs details hero | Different layout; do not share as one hero. |
| Track search vs shipments search | Submit + QR vs live filter + clear. |
| Details vs track history keys | Details also reads `statusHistory` / `changedAt` and remaps `shipment_created`. |
| List date formatters | `my_bookings_screen`: Timestamp, no `toLocal()`, else `'-'`. `my_quotes_screen`: no `toLocal()`, epoch-0 → `notProvided`. `shipments_screen`: mix of `toLocal()` / `notSpecified`. Do not merge with details/tracking fallbacks. |
| Request-quote `_formatDate` | Zero-pads the day; `formatLocalizedDate` does not. |
| SnackBars (except the track/support pair above) | Shipping: colored `showShippingMessage`. Booking: error `0xFF9D2732`. Profile: navy, margin `14`, radius `16`, bold. Notifications: radius `16`, often no hide-current; FCM preview has an action. Documents: plain `SnackBar`. Calculator/request-quote: uncolored or non-floating. Home/auth: mixed floating vs default. |
| Login email validator vs register/forgot | Login only checks `contains('@')`. Register/forgot require `@` and `.`. Do not “share” by changing login. |
| Auth vs shipping submit / fields | Auth marketing chrome (logo, pill, height 59, radius 18) is not `ShippingSubmitButton` / `shippingInputDecoration`. |
| Home vs Profile headers, logout dialogs | Same intent, different surfaces, copy, and sign-out API (`AuthController` vs `FirebaseAuth.instance`). |
| Documents viewer | Unique pdfrx / signed-URL path. No second opener to merge. |
| Notifications list | Icon chips, date groups, `Dismissible` — not shipments filters. |
| Land/sea quantity helper vs request-quote quantity | Shared helper uses `int.tryParse` and one `enterQuantity`. Request-quote has empty `pleaseEnterNumberOfItems` and invalid `pleaseEnterValidQuantity`. |
| `firstNonEmpty` vs `firstKeyedValue` | List of values vs map key order. |
| Splash vs auth logos | Splash is an animated entry; auth logos are form branding. |

## Cross-feature review status

- **Six shipping forms:** headers, fields, switches, date row, submit, snackbar, customer profile load, and (except air/sea) success dialog are shared and called. Air customer/notes and air/sea success trees remain page-owned. International additional services still inline a copy of `ShippingServicesSection`.
- **Booking vs volume calculator:** numbered `_sectionHeading` is shared. Cards, inputs, and date rows differ and stay on their pages.
- **Get-quote vs shipping:** `_formatDate` is shared. Cards, trust strip, and success dialog differ. SnackBar chrome matches `showShippingMessage` and is a candidate.
- **Tracking vs shipment details:** map/date helpers are shared. Fallback timeline, status map, and several private widgets remain near-clones and are the largest leftover trees. Search, live map, and hero vs status card stay separate.
- **Home vs profile:** `_languageLabel` is shared. Language **sheet** is still duplicated. Headers, logout, and settings tiles differ.
- **Auth (login / register / forgot):** no shipping-widget reuse. Form chrome and decorations are a family; email rules are **not** identical on login.
- **Support vs request-quote:** required-field helper is shared. Email validators still duplicate. Field decorations and success dialogs differ.
- **Lists, documents, legal, notifications:** no shipping-form widget reuse. Legal cards are an optional pair. Documents and notifications are unique flows.

## Suggested execution order from this baseline

Do not start a batch until the owner asks. One batch at a time.

1. Optional tiny: request-quote/support `_emailValidator` → `emailFieldError`, keep both l10n messages.
2. International additional services → existing `ShippingServicesSection`. Leave special items.
3. Get-quote `_showMessage` → `showShippingMessage`. Leave booking.
4. Home/Profile language sheet widget with page-supplied selection and colors. Keep apply/`setState` on each page.
5. Track/details **logic** (fallback stages, status map, location keys), then **widgets** (`_TimelineRow`, route point, compact info tile) into existing `shipment_status/`.
6. Optional: air/sea success onto `ShippingQuoteSuccessDialog` **only** with Done/`letterSpacing` parameters that default to current shared look.
7. Optional: auth decoration helper; do not change login’s weaker email rule while extracting.
8. Optional: legal section card with empty bullets default; track/support plain floating SnackBar helper.
9. After each future implementation batch: review the diff, run `flutter analyze` and `flutter test`, add behavior tests where callbacks or empty values can regress.
10. APK plus phone/tablet, English/Arabic, and core flows remain pending. Do not merge to `main` without owner approval.

## Verification status

This commit updates the inventory only. Application Dart files were not modified. Local analyze/tests were not re-run for a docs-only change. GitHub Actions still apply to the branch after push. Those checks do not cover visual parity or full device workflows. APK build and manual verification are still pending. `main` is unchanged.
