# Shared-code inventory (closing review)

Re-verified on `refactor/organized-widgets-pages` after `88a49d0` (history + floating snackbars) plus widget tests for snackbar replacement. Extractable track/details leftovers and track/support snackbar duplication are **assembled and verified**. No unresolved extractable candidate remains. Do not merge to `main` or publish.

Previous candidate tables at `50393fb` are historical.

## Scope of this closing pass

- Confirmed each extracted unit lives under `lib/app/widgets/` or `lib/app/utils/` and is **called** from the listed screens (not only exported).
- Confirmed old full trees for those units are gone from the pages; **short adapters remain** (colors, l10n, `setState`, navigation).
- Compared `origin/main...HEAD`: Dart/docs/test files only. No `lib/l10n`, `lib/locale_controller.dart`, `l10n.yaml`, Android, or iOS changes.
- Did not merge or publish. APK/device work is the owner-ordered final step after this freeze, not extra extraction.

**Limits:** not an exhaustive AST clone scan. Similar layout is not automatically duplication.

## Already shared and actually called

| Shared unit | Path | Called from (adapters OK) |
| --- | --- | --- |
| `ShippingFormHeader` | `lib/app/widgets/shipping/form_header.dart` | Air, car, land, parcel, international, sea |
| `ShippingSectionTitle` | `lib/app/widgets/shipping/section_title.dart` | Same six forms |
| `ShippingTrustBar` / `ShippingTrustItem` / `ShippingTrustDivider` | `trust_bar.dart`, `trust_item.dart`, `dividers.dart` | Same six forms |
| `ShippingContactDivider` | `dividers.dart` | Forms that show contact rows, including air |
| `ShippingNotesField` | `notes_field.dart` | Car, land, parcel, international, sea (**not air**) |
| `ShippingCustomerDetails` | `customer_details.dart` | Car, land, parcel, international, sea, **air**. Air `verifiedMessageHeight: null` and `labelFontWeight: null`. |
| `ShippingPremiumCard` | `premium_card.dart` | Six forms (section cards) |
| `shippingTextField` / `shippingInputDecoration` | `form_fields.dart` | Six forms; air: `labelWeight: null`, `focusedErrorBorderEnabled: false` |
| `shippingDropdown` | `form_controls.dart` | Six forms |
| `shippingDimensionField` | `form_controls.dart` | Air, land, parcel |
| `shippingOptionSwitch` | `form_controls.dart` | Six forms; default subtitle `height: 1.35`; air `subtitleHeight: null` |
| `ShippingServicesSection` | `services_section.dart` | Car, air, land, parcel, sea, international additional services. Special items stay separate (`_deepBlue`, `fontSize: 9.3`) |
| `ShippingSubmitButton` | `submit_button.dart` | Six forms |
| `ShippingQuoteSuccessDialog` | `quote_success_dialog.dart` | Car, land, parcel, international, air (`unstyledDoneButton: true`), sea (`myQuotesLetterSpacing: .35`). Close / My Quotes navigation stays on each page |
| `ActionSuccessDialog` | `lib/app/widgets/action_success_dialog.dart` | Create booking, get-quote, request-quote, support. Shared shell only. Padding, radius, shadow, icon, gaps, type, and one Done button stay on page adapters. Middles stay page-owned (booking reference + pending chip; get-quote reference; request-quote pickup→delivery; support category). Booking/get-quote still pop dialog then page; request-quote/support pop dialog only. Get-quote unused `requestId` kept. Not folded into `ShippingQuoteSuccessDialog`. |
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
| `shipmentTimelineIcon` | `shipment_status_info.dart` | Track + details `_timelineIcon`. Same `normalizeStatus` then contains order (`deliver` before `custom`, etc.) |
| `prettyShipmentStatus` | `shipment_status_info.dart` | Track + details `_prettyStatus`. Same trim, known-set, `statusLabel` / `optionLabel`. Details `mapShipmentCreated: true` → `notifShipmentCreatedTitle`. Track leaves `shipment_created` as option/fallback text |
| `shipmentCurrentLocation` | `shipment_status_info.dart` | Track + details `_currentLocation`. Uses `stringFromKeys` then status pickup/delivery fallbacks. Track default keys omit `currentLocationName`. Details passes `shipmentDetailsLocationKeys`. `_liveLocation` still chosen on the details page before the helper |
| `shipmentHistoryItems` / `ShipmentHistoryItem` | `shipment_status_info.dart` | Track + details `_historyItems`. Details `historyKeys` include `statusHistory`, `timeKeys` include `changedAt`, `mapShipmentCreated: true` (title + `timelineCreatedDesc`). Firestore load stays on pages |
| `showFloatingRadiusMessage` | `show_shipping_message.dart` | Track + support `_showMessage`. Floating, radius 14, no fill. `mounted` stays on pages. Filled `showShippingMessage` and booking SnackBar stay separate |
| `ShipmentBackHeader` | `lib/app/widgets/shipment_status/back_header.dart` | Track, details, shipments list, support `_buildTopHeader`. Page title + trailing icon. Track/support trailing size **23**; details/shipments **22**. `ShipmentSquareButton` back stays inside the shared header. Home/Profile and booking/quote/calculator headers stay on those pages. |
| `ShipmentRoutePoint` | `lib/app/widgets/shipment_status/route_point.dart` | Track `_buildRouteCard` and details route row. Pickup start / delivery end alignment unchanged. Route **cards** stay page-owned. |
| `LegalDocumentHeader` / `LegalIntroBanner` / `LegalSectionCard` | `lib/app/widgets/legal/document_chrome.dart` | Privacy + terms. Pages keep l10n copy. Privacy section cards still pass `bullets`; terms omit them. |
| `ConnectionErrorPanel` | `lib/app/widgets/connection_error_panel.dart` | My bookings + my quotes `_buildError`. Page titles, border/title/body colors, and bookings body `FontWeight.w500` stay on adapters. Retry still `setState`. Unused bookings error string is still accepted by `_buildError`. |
| `CountedSectionHeader` | `lib/app/widgets/counted_section_header.dart` | Shipments `_buildListHeader` and support requests `_buildSectionHeader`. Title/subtitle stay on pages; count is the list length. |
| `SoftBackHeader` | `lib/app/widgets/soft_back_header.dart` | Get-quote, create-booking, my quotes, my bookings, volume calculator, my support requests. Height, shadow, colors, title/subtitle metrics, icon sizes, and leading gap stay on page adapters. `ShipmentBackHeader` stays for track/details/shipments/support. |
| `authInputDecoration` | `lib/app/widgets/auth_field_decoration.dart` | Login, register, forgot password. Shared chrome (radius 17, fill `0xFFF7F8FA`, focus `0xFF07569E` 1.7). Login default padding **20** and **no** error borders. Register adapter padding **19** + both error borders. Forgot padding **20** + `errorBorder` only (no `focusedErrorBorder`). Prefix/suffix icons stay on pages. Email **validators stay on pages** (`contains('@')` vs `'@'`+`'.'` vs quote/support regex). Not mixed with `shippingInputDecoration`. |
| `ListEmptyCard` | `lib/app/widgets/list_empty_card.dart` | My bookings, my quotes, my support requests. White card radius **22**, bare icon (no tile). Bookings `width: infinity`, padding 48/20, icon 45, title **w900**, body 11 no height. Quotes margin top **12**, padding 22/38, icon **42**, title **w800**, body height **1.4**. Support padding 26/42, icon grey `0xFF9BA6B4`, body **10.5**. Copy and colors stay on adapters. Shipments (shadow, 72 tile, filter button), notifications, and documents stay separate. |
| `ListFilterBar` | `lib/app/widgets/list_filter_bar.dart` | Bookings (row + `right: 8`, 160ms, padding 17/10, w700). Quotes (`ListView` height **39**, 180ms, padding 15, `Alignment.center`, w700). Support (`ListView` height **40**, 180ms, padding 16/9, font **10.3**, w800). Shipments (`ListView` height **40**, 200ms, padding 16/9, w800, unselected `0xFF748090`, selected shadow). Keys, labels, and `setState` stay on pages. Notifications (icons + navy + always-on shadows) and international `FilterChip` stay separate. |
| `ShipmentSquareButton` / `ShipmentLiveDot` / `ShipmentHeroFeature` | `lib/app/widgets/shipment_status/` | Track, details, shipments list, support; live-dot also on my-support-requests |
| `ShipmentTimelineRow` / `shipmentFallbackTimeline` | `lib/app/widgets/shipment_status/timeline_row.dart` | Track + details `_TimelineRow` / `_fallbackTimeline`. `showLine` and `contentBottomPadding` stay separate. Track last-row padding `0`; details **always** `18` via `lastRowBottomPadding`. History-empty still chooses fallback on each page |

Barrel: `lib/app/widgets/shipping_form_widgets.dart`. Tests: `test/shipping_*.dart`, `test/value_formatters_test.dart`, `test/numbered_section_heading_test.dart`, `test/language_picker_sheet_test.dart`, `test/shipment_status_info_test.dart`, `test/pretty_shipment_status_test.dart`, `test/shipment_current_location_test.dart`, `test/shipment_history_items_test.dart`, `test/shipment_timeline_row_test.dart`, `test/shipment_fallback_timeline_test.dart`, `test/shipment_back_header_test.dart`, `test/shipment_route_point_test.dart`, `test/legal_document_chrome_test.dart`, `test/connection_error_panel_test.dart`, `test/counted_section_header_test.dart`, `test/soft_back_header_test.dart`, `test/action_success_dialog_test.dart`, `test/auth_field_decoration_test.dart`, `test/list_empty_card_test.dart`, `test/list_filter_bar_test.dart`.

## Adapters kept (not leftover duplication)

Private methods that only pass page values into the shared unit: `_buildHeader`, `_buildTrustBar`, `_sectionTitle`, `_buildCustomerSection` / `_buildNotesSection` (five forms), `_textField` / `_dropdown` / `_inputDecoration` / `_dimensionField`, `_optionSwitch` (air `subtitleHeight: null`), `_buildServicesSection` (five forms), international `_buildAdditionalServicesSection`, `_dateSelector`, `_summaryBadge`, `_calculationItem`, `_buildSubmitButton`, `_showSuccessDialog` (six shipping forms + create-booking, get-quote, request-quote, support), `_formatDate` (shipping/booking/get-quote), details/tracking `_firstValue` / `_stringValue` / `_formatDate` / `_formatDateTime`, details/tracking `_statusInfo` / `_currentLocation` / `_historyItems` / `_TimelineRow` / `_fallbackTimeline`, booking/calculator `_sectionHeading`, Home/Profile `_languageLabel`, Home/Profile `_selectLanguage` (sheet UI shared; Home skips `setState`; Profile updates `_selectedLanguage` first), air/parcel/international `_formatNumber`, land/sea `_quantityValidator`, request-quote/support `_requiredValidator` / `_emailValidator`, six-form and get-quote `_showMessage`, track/support `_showMessage` (`showFloatingRadiusMessage`), six-form `_loadCustomerProfile` (unsigned-in `setState` before `await`), `_optionLabel`, `_selectReadyDate` / `_selectMovingDate`, register `_fieldDecoration` (padding 19 + both error borders), bookings `_buildEmptyState` / quotes `_buildEmpty` / support requests `_buildEmpty`, bookings/quotes/support/shipments `_buildFilters`.

## Unresolved candidates (not done)

None. Do not merge to `main` or publish until the owner orders it.

| Candidate | Classification |
| --- | --- |
| `_historyItems` track vs details | Assembled and verified: `shipmentHistoryItems`. Track default keys omit `statusHistory` / `changedAt`. Details adapters pass `shipmentDetailsHistoryKeys`, `shipmentDetailsHistoryTimeKeys`, `mapShipmentCreated: true`. Event order, title/description/time keys, empty/non-list skip, and fallbacks match `main`. Firestore load and history-vs-fallback choice stay on pages. |
| Track vs support `_showMessage` | Assembled and verified: `showFloatingRadiusMessage`. Floating, radius 14, no fill, hide previous, default duration. Pages keep `mounted` and the same call sites/copy. Filled `showShippingMessage` and booking `0xFF9D2732` stay separate. |

## Reviewed and left separate

| Candidate | Files | Why not extracted |
| --- | --- | --- |
| Auth field decoration | — | Extracted as `authInputDecoration` with padding and error-border flags. Email validators stay on pages. |
| Legal section cards | — | Extracted as `LegalSectionCard` with optional bullets. |
| Details `_InfoCard` | `shipment_details_screen.dart` | Details-only. Track `_InformationCard` is similar but minHeight **106 vs 107**. Not extracted. |
| Shipments / notifications / documents empty | `shipments_screen.dart`, `notifications_screen.dart`, `shipping_documents_screen.dart` | Not `ListEmptyCard`. Shipments: radius 24, shadow, 72 rounded tile, title 18, optional clear-filters button. Notifications: circle 74, extra hint chip. Documents: no bordered card, icon 70. |
| Notifications / international filters | `notifications_screen.dart`, `international_moving_screen.dart` | Notifications chips have icons, navy selected fill, curve, and shadows on and off. International uses Material `FilterChip` for extra services. Not `ListFilterBar`. |

Booking / get-quote / request-quote / support success dialogs share `ActionSuccessDialog` chrome; page-owned metrics and middle widgets stay separate from each other and from `ShippingQuoteSuccessDialog`. Booking SnackBar `0xFF9D2732` remains separate.

## Kept separate on purpose

Air notes chrome (not `ShippingNotesField`; air omits prefix icon); international special-item chips; air unstyled Done and sea `letterSpacing: .35` **via dialog parameters**; six-form quote success vs action success dialogs (different buttons/layout); booking/get-quote/calculator cards and date rows; booking profile load (`TAWAM Customer`, extra keys, phone controller); support heading vs numbered heading; field decorations across support/quote/search (not auth); list date fallbacks (`-` / `notProvided` / `notSpecified`); request-quote quantity vs land/sea; booking SnackBar (`0xFF9D2732`); filled shipping snackbars vs unfilled track/support snackbars; documents viewer and documents empty state; notifications list, notifications empty, and notifications filter chips; shipments empty (tile + filter button); Home vs Profile headers/logout; details `_InfoCard` vs track `_InformationCard` (minHeight 107 vs 106); login vs forgot vs quote/support **email validators**.

## Diff vs `main` (scope)

**In scope:** new shared widgets/helpers; six shipping screens plus booking, get-quote (`formatLocalizedDate`, `showShippingMessage`), home/profile (`languageLabel`, language picker sheet), request-quote/support (`requiredFieldError`, `emailFieldError`), details/tracking (value/date helpers, `shipmentStatusInfo`); tests; this inventory.

**Protected files unchanged** vs `main`: `lib/l10n`, `lib/locale_controller.dart`, `l10n.yaml`, Android/iOS.

**Report, not reverted:** `shipment_status_widgets.dart` became a barrel exporting `square_button.dart`, `live_dot.dart`, `hero_feature.dart`, `timeline_row.dart`. Same widgets, file split for organization. Call sites still use them.

No evidence in the file list of submit/navigation/validator-message/formula/Firestore-collection changes as a *goal* of this branch. Adapters still pass the same page callbacks, l10n keys, and stored status strings. This review did not re-run every calculation by hand.

## Delivery summary

**Done (agreed batches)**

- Shipping form chrome: header, section title, trust bar, premium card, fields, dropdowns, dimensions, option switches (air height preserved), services (six forms; international additional only), date selector chrome, submit, summary badges, calculation rows.
- Notes + customer details on five forms; air now also calls `ShippingCustomerDetails` with `verifiedMessageHeight: null` and `labelFontWeight: null` so air type stays as before.
- Quote success dialog on all six shipping forms (air unstyled Done; sea My Quotes letterSpacing `.35`).
- Action success dialog on create-booking, get-quote, request-quote, and support (page-owned chrome and middle content).
- Auth field decoration on login, register, and forgot password (padding 20 vs 19; error borders via flags; validators stay on pages).
- List empty card on bookings, quotes, and support requests (page-owned padding, icon, title weight, body metrics). Shipments/notifications/documents empty stay separate.
- List filter bar on bookings, quotes, support requests, and shipments (row vs ListView, durations, padding, title weight, shipments selected shadow). Notifications chips and international FilterChip stay separate.
- Helpers: dates/values, display numbers, land/sea quantity, required field, quote/support email field, language labels, shipping snackbars (six forms + get-quote), shipping customer profile load (`users/{uid}`).
- Numbered heading for booking + calculator. Home/Profile language picker sheet (apply/save remains on each page).
- Tracking/details keyed values, optional local dates, status badge map (`shipmentStatusInfo`), timeline history icons (`shipmentTimelineIcon`), pretty status labels (`prettyShipmentStatus`; details-only `shipment_created`), stored current location (`shipmentCurrentLocation`; details keys and `_liveLocation` stay page-owned), timeline history rows (`shipmentHistoryItems`; details `statusHistory` / `changedAt` / created copy stay page-owned flags), timeline row chrome (`ShipmentTimelineRow`), fallback stages (`shipmentFallbackTimeline`; last-row padding stays page-owned), and track/support unfilled floating snackbars (`showFloatingRadiusMessage`).
- Inventory of leftovers after a full `lib` scan (named methods and `build` trees).

**Not done**

- Merge to `main`, store listing, production publish.
- Owner device confirmation of submit/track/documents with real accounts (CI and local tests are not that proof).

**Checks**

- Extraction through `88a49d0` (`protect-and-test` success on GitHub for that SHA). Local analyze/test re-run on the closing freeze. Visual parity and full device flows are **not** covered by CI.

## Suggested PR #4 description

Use the following body for the draft PR (title may stay or become: `Share duplicate shipping and form helpers`). GitHub CLI was not authenticated in this environment, so apply this on GitHub if the API update did not run.

```
## Summary
- Extract duplicate shipping-form UI and small helpers into `lib/app/widgets/shipping/` and `lib/app/utils/`, with page adapters for colors, copy, and callbacks.
- Share quote success on all six shipping forms; air keeps unstyled Done and sea keeps My Quotes `letterSpacing: .35`. Close/navigation stay on each page.
- Share tracking/details value and date helpers, booking/calculator numbered headings, Home/Profile language labels and picker sheet, and request-quote/support required-field and email validation.
- This does **not** merge to `main` or publish. Track/details history and track/support floating snackbars are shared. Intentionally separate chrome (auth fields, legal cards, booking snackbar, filled shipping snackbars) stays on pages.

## Intentional non-goals
- No merge to `main`, no store publish.
- No `locale_controller` / l10n / platform config edits.
- Design, translation keys, navigation, validators’ messages, calculations, Firestore collections, and submit payloads were not meant to change; adapters keep page-owned values.

## Test plan
- [x] `flutter analyze` / `flutter test` (local + GitHub `protect-and-test` on extraction SHAs)
- [ ] English / Arabic (and French) on shipping forms, booking, quotes, tracking, support — owner device
- [ ] Phone and tablet layouts — owner device
- [ ] Submit quote / booking, success dialogs (including air/sea vs shared), profile autofill signed-in / signed-out — owner, test data only
- [ ] Owner approval before merge
```

## Verification status

Call sites were re-checked: shared units still live in `lib/app/widgets` / `lib/app/utils` and are invoked from the pages listed above; short adapters remain. Draft PR #4 on GitHub still has the older customer-details summary; `gh` is not logged in here so the description could not be patched via API. Paste the suggested body on the PR. Listed extractable leftovers are closed. `main` is unchanged.
