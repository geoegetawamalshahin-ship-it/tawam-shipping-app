# Shared-code inventory

Reviewed baseline: `50393fb856b732c918057307bcf1728def1a7f7f` on `refactor/organized-widgets-pages`.

## Scope and limits

Scanned all 28 Dart files in `lib/screens` for repeated named block methods, comparing whitespace-normalized source. This is a candidate inventory, not an exhaustive AST clone analysis: inline widgets, renamed methods, arrow functions and near-duplicates require further review. Identical method source can still depend on different page constants, state, localization or callbacks. Each extraction requires checking those dependencies. Generated localization files are excluded from deduplication.

## Already shared

Shipping headers, section titles and trust bars are shared across six shipping forms. Notes and customer details are shared across five forms; the air form retains its differences. Shared dividers and shipment-status widgets already exist. Small page methods that pass local values to these widgets are adapters, not duplicated widget implementations.

## Execution order

1. Extract `_premiumCard` from six shipping forms, preserving each page's border/shadow colors and child tree. This is the next implementation batch.
2. Review input decoration, text fields, dropdowns and dimension fields together. Preserve controllers, validators, keyboard types, callbacks and every style difference; the air form differs in several helpers.
3. Review option switches, summary badges and calculation rows. Keep page state and callbacks with their current owners.
4. Review service sections, date selectors, submit buttons and success dialogs. Preserve date bounds, submission guards and navigation callbacks.
5. Review cross-feature helpers: booking/calculator headings, tracking/detail date and value formatting, Home/Profile language labels, and input validators. Check semantics before sharing.
6. Inspect inline widget trees and similar-but-not-identical methods in all screens, including authentication, Home, Profile, lists, support, legal, documents and notifications. Record deliberate exceptions rather than forcing one design.
7. For each implementation batch, review the diff and run Flutter analysis/tests. Add targeted behavior tests where state or callbacks introduce concrete regression risks.
8. Build APK and manually verify phone/tablet appearance, English/Arabic, authentication, bookings, quotes, shipments, live/manual tracking, notifications and support. Merge only after successful verification and owner approval.

Shared UI belongs under `lib/app/widgets/` with feature subfolders. Shared non-UI logic belongs in a suitable helper/service location, not in widget classes. No empty controllers or bindings are required merely to imitate another project's folder layout.

## Candidate matches

Counts below describe matching method source, not completed or approved extractions. Source locations refer to the reviewed baseline.

| Method | Copies | Lines per method | Locations | Treatment |
| --- | ---: | ---: | --- | --- |
| `_showSuccessDialog` | 3 | 167 | `lib/screens/car_shipping_screen.dart:1831`; `lib/screens/parcel_shipping_screen.dart:2003`; `lib/screens/international_moving_screen.dart:1957` | Candidate; verify dependencies before extraction |
| `_buildServicesSection` | 5 | 63 | `lib/screens/car_shipping_screen.dart:1233`; `lib/screens/air_freight_screen.dart:1254`; `lib/screens/land_freight_screen.dart:1350`; `lib/screens/parcel_shipping_screen.dart:1388`; `lib/screens/sea_freight_screen.dart:1119` | Candidate; verify dependencies before extraction |
| `_optionSwitch` | 5 | 56 | `lib/screens/car_shipping_screen.dart:2129`; `lib/screens/land_freight_screen.dart:2336`; `lib/screens/parcel_shipping_screen.dart:2338`; `lib/screens/international_moving_screen.dart:2255`; `lib/screens/sea_freight_screen.dart:2006` | Candidate; verify dependencies before extraction |
| `_inputDecoration` | 5 | 44 | `lib/screens/car_shipping_screen.dart:2084`; `lib/screens/land_freight_screen.dart:2291`; `lib/screens/parcel_shipping_screen.dart:2293`; `lib/screens/international_moving_screen.dart:2210`; `lib/screens/sea_freight_screen.dart:1961` | Candidate; verify dependencies before extraction |
| `_buildSubmitButton` | 3 | 50 | `lib/screens/car_shipping_screen.dart:1597`; `lib/screens/parcel_shipping_screen.dart:1751`; `lib/screens/international_moving_screen.dart:1701` | Candidate; verify dependencies before extraction |
| `_textField` | 5 | 29 | `lib/screens/car_shipping_screen.dart:2023`; `lib/screens/land_freight_screen.dart:2193`; `lib/screens/parcel_shipping_screen.dart:2195`; `lib/screens/international_moving_screen.dart:2149`; `lib/screens/sea_freight_screen.dart:1868` | Candidate; verify dependencies before extraction |
| `_dateSelector` | 2 | 70 | `lib/screens/car_shipping_screen.dart:682`; `lib/screens/parcel_shipping_screen.dart:760` | Candidate; verify dependencies before extraction |
| `_dateSelector` | 2 | 70 | `lib/screens/land_freight_screen.dart:695`; `lib/screens/sea_freight_screen.dart:663` | Candidate; verify dependencies before extraction |
| `_buildCustomerSection` | 5 | 27 | `lib/screens/car_shipping_screen.dart:1301`; `lib/screens/land_freight_screen.dart:1418`; `lib/screens/parcel_shipping_screen.dart:1456`; `lib/screens/international_moving_screen.dart:1396`; `lib/screens/sea_freight_screen.dart:1187` | Existing shared-widget adapter; review only |
| `_sectionHeading` | 2 | 62 | `lib/screens/volume_calculator_screen.dart:403`; `lib/screens/create_booking_screen.dart:391` | Candidate; verify dependencies before extraction |
| `_loadCustomerProfile` | 2 | 62 | `lib/screens/car_shipping_screen.dart:167`; `lib/screens/parcel_shipping_screen.dart:231` | Candidate; verify dependencies before extraction |
| `_dropdown` | 4 | 30 | `lib/screens/car_shipping_screen.dart:2053`; `lib/screens/land_freight_screen.dart:2260`; `lib/screens/parcel_shipping_screen.dart:2262`; `lib/screens/international_moving_screen.dart:2179` | Candidate; verify dependencies before extraction |
| `_premiumCard` | 6 | 19 | `lib/screens/car_shipping_screen.dart:2003`; `lib/screens/air_freight_screen.dart:2025`; `lib/screens/land_freight_screen.dart:2173`; `lib/screens/parcel_shipping_screen.dart:2175`; `lib/screens/international_moving_screen.dart:2129`; `lib/screens/sea_freight_screen.dart:1848` | Candidate; verify dependencies before extraction |
| `_dimensionField` | 3 | 36 | `lib/screens/air_freight_screen.dart:2073`; `lib/screens/land_freight_screen.dart:2223`; `lib/screens/parcel_shipping_screen.dart:2225` | Candidate; verify dependencies before extraction |
| `_summaryBadge` | 4 | 26 | `lib/screens/car_shipping_screen.dart:1566`; `lib/screens/land_freight_screen.dart:1700`; `lib/screens/parcel_shipping_screen.dart:1720`; `lib/screens/international_moving_screen.dart:1670` | Candidate; verify dependencies before extraction |
| `_sectionTitle` | 5 | 17 | `lib/screens/car_shipping_screen.dart:571`; `lib/screens/land_freight_screen.dart:582`; `lib/screens/parcel_shipping_screen.dart:647`; `lib/screens/international_moving_screen.dart:593`; `lib/screens/sea_freight_screen.dart:554` | Existing shared-widget adapter; review only |
| `_firstNonEmpty` | 6 | 13 | `lib/screens/car_shipping_screen.dart:2253`; `lib/screens/air_freight_screen.dart:2274`; `lib/screens/land_freight_screen.dart:2515`; `lib/screens/parcel_shipping_screen.dart:2448`; `lib/screens/international_moving_screen.dart:2449`; `lib/screens/sea_freight_screen.dart:2151` | Candidate; verify dependencies before extraction |
| `_buildNotesSection` | 5 | 15 | `lib/screens/car_shipping_screen.dart:1333`; `lib/screens/land_freight_screen.dart:1450`; `lib/screens/parcel_shipping_screen.dart:1488`; `lib/screens/international_moving_screen.dart:1428`; `lib/screens/sea_freight_screen.dart:1219` | Existing shared-widget adapter; review only |
| `_showMessage` | 6 | 11 | `lib/screens/car_shipping_screen.dart:2267`; `lib/screens/air_freight_screen.dart:2288`; `lib/screens/land_freight_screen.dart:2529`; `lib/screens/parcel_shipping_screen.dart:2462`; `lib/screens/international_moving_screen.dart:2463`; `lib/screens/sea_freight_screen.dart:2165` | Candidate; verify dependencies before extraction |
| `_formatDateTime` | 2 | 24 | `lib/screens/shipment_details_screen.dart:1700`; `lib/screens/track_shipment_screen.dart:1507` | Candidate; verify dependencies before extraction |
| `_calculationItem` | 2 | 21 | `lib/screens/air_freight_screen.dart:1228`; `lib/screens/parcel_shipping_screen.dart:1308` | Candidate; verify dependencies before extraction |
| `_selectReadyDate` | 2 | 17 | `lib/screens/air_freight_screen.dart:2230`; `lib/screens/land_freight_screen.dart:2397` | Candidate; verify dependencies before extraction |
| `_formatDate` | 6 | 5 | `lib/screens/car_shipping_screen.dart:2237`; `lib/screens/air_freight_screen.dart:2248`; `lib/screens/land_freight_screen.dart:2491`; `lib/screens/parcel_shipping_screen.dart:2420`; `lib/screens/international_moving_screen.dart:2425`; `lib/screens/sea_freight_screen.dart:2127` | Candidate; verify dependencies before extraction |
| `_showMessage` | 2 | 15 | `lib/screens/track_shipment_screen.dart:205`; `lib/screens/support_screen.dart:108` | Candidate; verify dependencies before extraction |
| `_stringValue` | 2 | 13 | `lib/screens/shipment_details_screen.dart:1503`; `lib/screens/track_shipment_screen.dart:1373` | Candidate; verify dependencies before extraction |
| `_formatDate` | 2 | 13 | `lib/screens/shipment_details_screen.dart:1686`; `lib/screens/track_shipment_screen.dart:1493` | Candidate; verify dependencies before extraction |
| `_two` | 7 | 3 | `lib/screens/car_shipping_screen.dart:2249`; `lib/screens/air_freight_screen.dart:2270`; `lib/screens/get_quote_screen.dart:1228`; `lib/screens/land_freight_screen.dart:2503`; `lib/screens/parcel_shipping_screen.dart:2444`; `lib/screens/international_moving_screen.dart:2445`; `lib/screens/sea_freight_screen.dart:2139` | Candidate; verify dependencies before extraction |
| `_parseOptionalDouble` | 4 | 5 | `lib/screens/create_booking_screen.dart:1451`; `lib/screens/get_quote_screen.dart:1232`; `lib/screens/land_freight_screen.dart:2507`; `lib/screens/sea_freight_screen.dart:2143` | Candidate; verify dependencies before extraction |
| `_languageLabel` | 2 | 10 | `lib/screens/home_screen.dart:231`; `lib/screens/profile_screen.dart:613` | Candidate; verify dependencies before extraction |
| `_optionLabel` | 6 | 3 | `lib/screens/car_shipping_screen.dart:2244`; `lib/screens/air_freight_screen.dart:2255`; `lib/screens/land_freight_screen.dart:2498`; `lib/screens/parcel_shipping_screen.dart:2427`; `lib/screens/international_moving_screen.dart:2432`; `lib/screens/sea_freight_screen.dart:2134` | Candidate; verify dependencies before extraction |
| `_quantityValidator` | 2 | 9 | `lib/screens/land_freight_screen.dart:2481`; `lib/screens/sea_freight_screen.dart:2117` | Candidate; verify dependencies before extraction |
| `_firstNonEmpty` | 2 | 8 | `lib/screens/create_booking_screen.dart:1457`; `lib/screens/get_quote_screen.dart:1238` | Candidate; verify dependencies before extraction |
| `_requiredValidator` | 2 | 7 | `lib/screens/request_quote_screen.dart:367`; `lib/screens/support_screen.dart:165` | Candidate; verify dependencies before extraction |
| `_refreshSummary` | 2 | 5 | `lib/screens/car_shipping_screen.dart:157`; `lib/screens/international_moving_screen.dart:170` | Candidate; verify dependencies before extraction |
| `_refreshCalculations` | 2 | 5 | `lib/screens/air_freight_screen.dart:206`; `lib/screens/parcel_shipping_screen.dart:157` | Candidate; verify dependencies before extraction |
| `_formatDate` | 2 | 3 | `lib/screens/create_booking_screen.dart:1445`; `lib/screens/get_quote_screen.dart:1224` | Candidate; verify dependencies before extraction |

## Verification status

The baseline passed the existing GitHub Actions analysis, tests, and protected translation/platform checks in run `34274690110`. These checks do not cover all runtime workflows or visual parity. This inventory changes no runtime code. APK and manual device verification remain pending.
