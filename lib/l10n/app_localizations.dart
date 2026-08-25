import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @verifiedCustomer.
  ///
  /// In en, this message translates to:
  /// **'Verified Tawam Customer'**
  String get verifiedCustomer;

  /// No description provided for @shipments.
  ///
  /// In en, this message translates to:
  /// **'Shipments'**
  String get shipments;

  /// No description provided for @inTransit.
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get inTransit;

  /// No description provided for @quotes.
  ///
  /// In en, this message translates to:
  /// **'Quotes'**
  String get quotes;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @defaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Default Address'**
  String get defaultAddress;

  /// No description provided for @notProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'General application notifications'**
  String get pushNotificationsSubtitle;

  /// No description provided for @shipmentUpdates.
  ///
  /// In en, this message translates to:
  /// **'Shipment Updates'**
  String get shipmentUpdates;

  /// No description provided for @shipmentUpdatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Status and delivery notifications'**
  String get shipmentUpdatesSubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @securityAccount.
  ///
  /// In en, this message translates to:
  /// **'Security & Account'**
  String get securityAccount;

  /// No description provided for @biometricSignIn.
  ///
  /// In en, this message translates to:
  /// **'Biometric Sign In'**
  String get biometricSignIn;

  /// No description provided for @biometricSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or Face ID'**
  String get biometricSubtitle;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your account password'**
  String get changePasswordSubtitle;

  /// No description provided for @shippingDocuments.
  ///
  /// In en, this message translates to:
  /// **'Shipping Documents'**
  String get shippingDocuments;

  /// No description provided for @shippingDocumentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View invoices and shipment files'**
  String get shippingDocumentsSubtitle;

  /// No description provided for @supportLegal.
  ///
  /// In en, this message translates to:
  /// **'Support & Legal'**
  String get supportLegal;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @tryAgainLower.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgainLower;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get track;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @origin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get origin;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @pickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @cargo.
  ///
  /// In en, this message translates to:
  /// **'Cargo'**
  String get cargo;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @length.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get length;

  /// No description provided for @width.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get width;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @earlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @newBadge.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newBadge;

  /// No description provided for @secure.
  ///
  /// In en, this message translates to:
  /// **'Secure'**
  String get secure;

  /// No description provided for @global.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get global;

  /// No description provided for @expertTeam.
  ///
  /// In en, this message translates to:
  /// **'Expert Team'**
  String get expertTeam;

  /// No description provided for @tawamCustomer.
  ///
  /// In en, this message translates to:
  /// **'Tawam Customer'**
  String get tawamCustomer;

  /// No description provided for @tawamAlShahinTransport.
  ///
  /// In en, this message translates to:
  /// **'TAWAM AL-SHAHIN TRANSPORT'**
  String get tawamAlShahinTransport;

  /// No description provided for @customerAccount.
  ///
  /// In en, this message translates to:
  /// **'Customer Account'**
  String get customerAccount;

  /// No description provided for @customerId.
  ///
  /// In en, this message translates to:
  /// **'CUSTOMER ID'**
  String get customerId;

  /// No description provided for @activeCustomer.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE CUSTOMER'**
  String get activeCustomer;

  /// No description provided for @signedInCustomer.
  ///
  /// In en, this message translates to:
  /// **'Signed-in customer'**
  String get signedInCustomer;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact Phone'**
  String get contactPhone;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @emailAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddressHint;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @pleaseSignInAgain.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again.'**
  String get pleaseSignInAgain;

  /// No description provided for @pleaseCheckConnection.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection.'**
  String get pleaseCheckConnection;

  /// No description provided for @pleaseCheckConnectionTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get pleaseCheckConnectionTryAgain;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open this link.'**
  String get couldNotOpenLink;

  /// No description provided for @couldNotOpenWebsite.
  ///
  /// In en, this message translates to:
  /// **'Could not open our website.'**
  String get couldNotOpenWebsite;

  /// No description provided for @couldNotOpenReviews.
  ///
  /// In en, this message translates to:
  /// **'Could not open Google reviews.'**
  String get couldNotOpenReviews;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later'**
  String get tooManyAttempts;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterFullName;

  /// No description provided for @pleaseEnterValidName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid name'**
  String get pleaseEnterValidName;

  /// No description provided for @pleaseEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhone;

  /// No description provided for @pleaseEnterValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get pleaseEnterValidPhone;

  /// No description provided for @pleaseCreatePassword.
  ///
  /// In en, this message translates to:
  /// **'Please create a password'**
  String get pleaseCreatePassword;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @pleaseEnterOrigin.
  ///
  /// In en, this message translates to:
  /// **'Please enter origin'**
  String get pleaseEnterOrigin;

  /// No description provided for @pleaseEnterDestination.
  ///
  /// In en, this message translates to:
  /// **'Please enter destination'**
  String get pleaseEnterDestination;

  /// No description provided for @pleaseEnterPickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Please enter pickup location'**
  String get pleaseEnterPickupLocation;

  /// No description provided for @pleaseEnterDeliveryLocation.
  ///
  /// In en, this message translates to:
  /// **'Please enter delivery location'**
  String get pleaseEnterDeliveryLocation;

  /// No description provided for @pleaseEnterCargoType.
  ///
  /// In en, this message translates to:
  /// **'Please enter cargo type'**
  String get pleaseEnterCargoType;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @pleaseCompleteRequired.
  ///
  /// In en, this message translates to:
  /// **'Please complete the required information.'**
  String get pleaseCompleteRequired;

  /// No description provided for @pleaseSignInBeforeQuote.
  ///
  /// In en, this message translates to:
  /// **'Please sign in before requesting a quote.'**
  String get pleaseSignInBeforeQuote;

  /// No description provided for @pleaseSignInBeforeBooking.
  ///
  /// In en, this message translates to:
  /// **'Please sign in before creating a booking.'**
  String get pleaseSignInBeforeBooking;

  /// No description provided for @pleaseSignInBeforeSupport.
  ///
  /// In en, this message translates to:
  /// **'Please sign in before sending a support request.'**
  String get pleaseSignInBeforeSupport;

  /// No description provided for @pleaseSignInBeforeQuoteShort.
  ///
  /// In en, this message translates to:
  /// **'Please sign in before submitting a quote request'**
  String get pleaseSignInBeforeQuoteShort;

  /// No description provided for @pleaseSelectPickupDate.
  ///
  /// In en, this message translates to:
  /// **'Please select your preferred pickup date.'**
  String get pleaseSelectPickupDate;

  /// No description provided for @cityCountry.
  ///
  /// In en, this message translates to:
  /// **'City, Country'**
  String get cityCountry;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selectADate.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get selectADate;

  /// No description provided for @enterWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter weight'**
  String get enterWeight;

  /// No description provided for @enterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get enterQuantity;

  /// No description provided for @cargoType.
  ///
  /// In en, this message translates to:
  /// **'Cargo Type'**
  String get cargoType;

  /// No description provided for @pickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Pickup Location'**
  String get pickupLocation;

  /// No description provided for @deliveryLocation.
  ///
  /// In en, this message translates to:
  /// **'Delivery Location'**
  String get deliveryLocation;

  /// No description provided for @specialInstructions.
  ///
  /// In en, this message translates to:
  /// **'Special Instructions'**
  String get specialInstructions;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get additionalNotes;

  /// No description provided for @additionalServices.
  ///
  /// In en, this message translates to:
  /// **'Additional Services'**
  String get additionalServices;

  /// No description provided for @contactDetails.
  ///
  /// In en, this message translates to:
  /// **'Contact Details'**
  String get contactDetails;

  /// No description provided for @contactFilledFromAccount.
  ///
  /// In en, this message translates to:
  /// **'Automatically filled from your account.'**
  String get contactFilledFromAccount;

  /// No description provided for @serviceMode.
  ///
  /// In en, this message translates to:
  /// **'Service Mode'**
  String get serviceMode;

  /// No description provided for @doorToDoor.
  ///
  /// In en, this message translates to:
  /// **'Door to Door'**
  String get doorToDoor;

  /// No description provided for @standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// No description provided for @express.
  ///
  /// In en, this message translates to:
  /// **'Express'**
  String get express;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @customsClearance.
  ///
  /// In en, this message translates to:
  /// **'Customs Clearance'**
  String get customsClearance;

  /// No description provided for @exportDocumentation.
  ///
  /// In en, this message translates to:
  /// **'Export Documentation'**
  String get exportDocumentation;

  /// No description provided for @packing.
  ///
  /// In en, this message translates to:
  /// **'Packing'**
  String get packing;

  /// No description provided for @boxes.
  ///
  /// In en, this message translates to:
  /// **'Boxes'**
  String get boxes;

  /// No description provided for @pallets.
  ///
  /// In en, this message translates to:
  /// **'Pallets'**
  String get pallets;

  /// No description provided for @selectReadyDate.
  ///
  /// In en, this message translates to:
  /// **'Select ready date'**
  String get selectReadyDate;

  /// No description provided for @grossWeight.
  ///
  /// In en, this message translates to:
  /// **'Gross Weight'**
  String get grossWeight;

  /// No description provided for @numberOfPieces.
  ///
  /// In en, this message translates to:
  /// **'Number of Pieces'**
  String get numberOfPieces;

  /// No description provided for @packageType.
  ///
  /// In en, this message translates to:
  /// **'Package Type'**
  String get packageType;

  /// No description provided for @dangerousGoods.
  ///
  /// In en, this message translates to:
  /// **'Dangerous Goods'**
  String get dangerousGoods;

  /// No description provided for @cargoInsurance.
  ///
  /// In en, this message translates to:
  /// **'Cargo Insurance'**
  String get cargoInsurance;

  /// No description provided for @selectServices.
  ///
  /// In en, this message translates to:
  /// **'Select services'**
  String get selectServices;

  /// No description provided for @youCanChooseMoreThanOne.
  ///
  /// In en, this message translates to:
  /// **'You can choose more than one.'**
  String get youCanChooseMoreThanOne;

  /// No description provided for @dimensionsWeight.
  ///
  /// In en, this message translates to:
  /// **'Dimensions & Weight'**
  String get dimensionsWeight;

  /// No description provided for @actual.
  ///
  /// In en, this message translates to:
  /// **'Actual'**
  String get actual;

  /// No description provided for @volumetric.
  ///
  /// In en, this message translates to:
  /// **'Volumetric'**
  String get volumetric;

  /// No description provided for @chargeableWeight.
  ///
  /// In en, this message translates to:
  /// **'Chargeable Weight'**
  String get chargeableWeight;

  /// No description provided for @cbm.
  ///
  /// In en, this message translates to:
  /// **'CBM'**
  String get cbm;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @clearSearchFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Search & Filters'**
  String get clearSearchFilters;

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markAsRead;

  /// No description provided for @markAsUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark as unread'**
  String get markAsUnread;

  /// No description provided for @deleteNotification.
  ///
  /// In en, this message translates to:
  /// **'Delete notification'**
  String get deleteNotification;

  /// No description provided for @readAll.
  ///
  /// In en, this message translates to:
  /// **'Read all'**
  String get readAll;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @lastUpdatePrefix.
  ///
  /// In en, this message translates to:
  /// **'Last update: {time}'**
  String lastUpdatePrefix(String time);

  /// No description provided for @awaitingUpdate.
  ///
  /// In en, this message translates to:
  /// **'Awaiting update'**
  String get awaitingUpdate;

  /// No description provided for @locationUpdatePending.
  ///
  /// In en, this message translates to:
  /// **'Location update pending'**
  String get locationUpdatePending;

  /// No description provided for @latestUpdate.
  ///
  /// In en, this message translates to:
  /// **'Latest update'**
  String get latestUpdate;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get waiting;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'CURRENT LOCATION'**
  String get currentLocation;

  /// No description provided for @estDelivery.
  ///
  /// In en, this message translates to:
  /// **'EST. DELIVERY'**
  String get estDelivery;

  /// No description provided for @trackingNumber.
  ///
  /// In en, this message translates to:
  /// **'Tracking Number'**
  String get trackingNumber;

  /// No description provided for @trackingNumberUpper.
  ///
  /// In en, this message translates to:
  /// **'TRACKING NUMBER'**
  String get trackingNumberUpper;

  /// No description provided for @pickupUpper.
  ///
  /// In en, this message translates to:
  /// **'PICKUP'**
  String get pickupUpper;

  /// No description provided for @deliveryUpper.
  ///
  /// In en, this message translates to:
  /// **'DELIVERY'**
  String get deliveryUpper;

  /// No description provided for @cargoUpper.
  ///
  /// In en, this message translates to:
  /// **'CARGO'**
  String get cargoUpper;

  /// No description provided for @weightUpper.
  ///
  /// In en, this message translates to:
  /// **'WEIGHT'**
  String get weightUpper;

  /// No description provided for @quantityUpper.
  ///
  /// In en, this message translates to:
  /// **'QUANTITY'**
  String get quantityUpper;

  /// No description provided for @dimensionsUpper.
  ///
  /// In en, this message translates to:
  /// **'DIMENSIONS'**
  String get dimensionsUpper;

  /// No description provided for @routeOverview.
  ///
  /// In en, this message translates to:
  /// **'Route Overview'**
  String get routeOverview;

  /// No description provided for @shipmentProgress.
  ///
  /// In en, this message translates to:
  /// **'Shipment Progress'**
  String get shipmentProgress;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get total;

  /// No description provided for @inTransitUpper.
  ///
  /// In en, this message translates to:
  /// **'IN TRANSIT'**
  String get inTransitUpper;

  /// No description provided for @deliveredUpper.
  ///
  /// In en, this message translates to:
  /// **'DELIVERED'**
  String get deliveredUpper;

  /// No description provided for @confirmedUpper.
  ///
  /// In en, this message translates to:
  /// **'CONFIRMED'**
  String get confirmedUpper;

  /// No description provided for @preparedUpper.
  ///
  /// In en, this message translates to:
  /// **'PREPARED'**
  String get preparedUpper;

  /// No description provided for @customsUpper.
  ///
  /// In en, this message translates to:
  /// **'CUSTOMS'**
  String get customsUpper;

  /// No description provided for @outForDeliveryUpper.
  ///
  /// In en, this message translates to:
  /// **'OUT FOR DELIVERY'**
  String get outForDeliveryUpper;

  /// No description provided for @cancelledUpper.
  ///
  /// In en, this message translates to:
  /// **'CANCELLED'**
  String get cancelledUpper;

  /// No description provided for @pendingUpper.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get pendingUpper;

  /// No description provided for @applicationLanguage.
  ///
  /// In en, this message translates to:
  /// **'Application Language'**
  String get applicationLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusPrepared.
  ///
  /// In en, this message translates to:
  /// **'Prepared'**
  String get statusPrepared;

  /// No description provided for @statusInTransit.
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get statusInTransit;

  /// No description provided for @statusCustoms.
  ///
  /// In en, this message translates to:
  /// **'Customs'**
  String get statusCustoms;

  /// No description provided for @statusOutForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Out for Delivery'**
  String get statusOutForDelivery;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get statusNew;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @statusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get statusResolved;

  /// No description provided for @timelineCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipment Created'**
  String get timelineCreatedTitle;

  /// No description provided for @timelineCreatedDesc.
  ///
  /// In en, this message translates to:
  /// **'Shipment information has been registered.'**
  String get timelineCreatedDesc;

  /// No description provided for @timelineConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed'**
  String get timelineConfirmedTitle;

  /// No description provided for @timelineConfirmedDesc.
  ///
  /// In en, this message translates to:
  /// **'Shipment has been confirmed by our operations team.'**
  String get timelineConfirmedDesc;

  /// No description provided for @timelinePreparedTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepared'**
  String get timelinePreparedTitle;

  /// No description provided for @timelinePreparedDesc.
  ///
  /// In en, this message translates to:
  /// **'Shipment is prepared and ready for movement.'**
  String get timelinePreparedDesc;

  /// No description provided for @timelineInTransitTitle.
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get timelineInTransitTitle;

  /// No description provided for @timelineInTransitDesc.
  ///
  /// In en, this message translates to:
  /// **'Shipment is moving toward the destination.'**
  String get timelineInTransitDesc;

  /// No description provided for @timelineCustomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Customs Clearance'**
  String get timelineCustomsTitle;

  /// No description provided for @timelineCustomsDesc.
  ///
  /// In en, this message translates to:
  /// **'Shipment is undergoing border or customs processing.'**
  String get timelineCustomsDesc;

  /// No description provided for @timelineOutForDeliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Out for Delivery'**
  String get timelineOutForDeliveryTitle;

  /// No description provided for @timelineOutForDeliveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Shipment is on the final delivery route.'**
  String get timelineOutForDeliveryDesc;

  /// No description provided for @timelineDeliveredTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get timelineDeliveredTitle;

  /// No description provided for @timelineDeliveredDesc.
  ///
  /// In en, this message translates to:
  /// **'Shipment has been delivered successfully.'**
  String get timelineDeliveredDesc;

  /// No description provided for @timelineCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipment Cancelled'**
  String get timelineCancelledTitle;

  /// No description provided for @timelineCancelledDesc.
  ///
  /// In en, this message translates to:
  /// **'This shipment has been cancelled.'**
  String get timelineCancelledDesc;

  /// No description provided for @statusDescConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Shipment confirmed by operations'**
  String get statusDescConfirmed;

  /// No description provided for @statusDescPrepared.
  ///
  /// In en, this message translates to:
  /// **'Shipment prepared for movement'**
  String get statusDescPrepared;

  /// No description provided for @statusDescInTransit.
  ///
  /// In en, this message translates to:
  /// **'Shipment moving toward destination'**
  String get statusDescInTransit;

  /// No description provided for @statusDescCustoms.
  ///
  /// In en, this message translates to:
  /// **'Shipment under customs processing'**
  String get statusDescCustoms;

  /// No description provided for @statusDescOutForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Shipment on final delivery route'**
  String get statusDescOutForDelivery;

  /// No description provided for @statusDescDelivered.
  ///
  /// In en, this message translates to:
  /// **'Shipment delivered successfully'**
  String get statusDescDelivered;

  /// No description provided for @statusDescCancelled.
  ///
  /// In en, this message translates to:
  /// **'Shipment has been cancelled'**
  String get statusDescCancelled;

  /// No description provided for @statusDescPending.
  ///
  /// In en, this message translates to:
  /// **'Shipment awaiting processing'**
  String get statusDescPending;

  /// No description provided for @serviceSeaFreight.
  ///
  /// In en, this message translates to:
  /// **'Sea Freight'**
  String get serviceSeaFreight;

  /// No description provided for @serviceAirFreight.
  ///
  /// In en, this message translates to:
  /// **'Air Freight'**
  String get serviceAirFreight;

  /// No description provided for @serviceLandFreight.
  ///
  /// In en, this message translates to:
  /// **'Land Freight'**
  String get serviceLandFreight;

  /// No description provided for @serviceCarShipping.
  ///
  /// In en, this message translates to:
  /// **'Car Shipping'**
  String get serviceCarShipping;

  /// No description provided for @serviceInternationalMoving.
  ///
  /// In en, this message translates to:
  /// **'International Moving'**
  String get serviceInternationalMoving;

  /// No description provided for @serviceParcelShipping.
  ///
  /// In en, this message translates to:
  /// **'Parcel Shipping'**
  String get serviceParcelShipping;

  /// No description provided for @serviceSeaFreightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fast & Reliable'**
  String get serviceSeaFreightSubtitle;

  /// No description provided for @serviceAirFreightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Global Coverage'**
  String get serviceAirFreightSubtitle;

  /// No description provided for @serviceLandFreightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Flexible Solutions'**
  String get serviceLandFreightSubtitle;

  /// No description provided for @serviceCarShippingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Safe & Secure'**
  String get serviceCarShippingSubtitle;

  /// No description provided for @serviceMovingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Door-to-Door'**
  String get serviceMovingSubtitle;

  /// No description provided for @serviceParcelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Easy Delivery'**
  String get serviceParcelSubtitle;

  /// No description provided for @monthJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthDec;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get signIn;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your shipments, track deliveries and receive important updates.'**
  String get signInSubtitle;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @emailOrPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect'**
  String get emailOrPasswordIncorrect;

  /// No description provided for @accountDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled'**
  String get accountDisabled;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get accountCreated;

  /// No description provided for @couldNotCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Could not create account'**
  String get couldNotCreateAccount;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join TAWAM to manage shipments, quotes and deliveries from one place.'**
  String get registerSubtitle;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'RESET PASSWORD'**
  String get resetPassword;

  /// No description provided for @forgotYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotYourPassword;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we will send you a link to reset your password.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get backToSignIn;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent. Please check your email.'**
  String get resetLinkSent;

  /// No description provided for @unableToSendReset.
  ///
  /// In en, this message translates to:
  /// **'Unable to send reset link. Please try again.'**
  String get unableToSendReset;

  /// No description provided for @resetLinkIfExists.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for this email, a reset link has been sent.'**
  String get resetLinkIfExists;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @quickActionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your shipments and requests'**
  String get quickActionsSubtitle;

  /// No description provided for @getAQuote.
  ///
  /// In en, this message translates to:
  /// **'Get a Quote'**
  String get getAQuote;

  /// No description provided for @createABooking.
  ///
  /// In en, this message translates to:
  /// **'Create a Booking'**
  String get createABooking;

  /// No description provided for @volumeCalculator.
  ///
  /// In en, this message translates to:
  /// **'Volume Calculator'**
  String get volumeCalculator;

  /// No description provided for @shipmentTracking.
  ///
  /// In en, this message translates to:
  /// **'Shipment Tracking'**
  String get shipmentTracking;

  /// No description provided for @myQuotes.
  ///
  /// In en, this message translates to:
  /// **'My Quotes'**
  String get myQuotes;

  /// No description provided for @myBookings.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookings;

  /// No description provided for @shippingServices.
  ///
  /// In en, this message translates to:
  /// **'Shipping Services'**
  String get shippingServices;

  /// No description provided for @requestNewQuotation.
  ///
  /// In en, this message translates to:
  /// **'Request a new shipping quotation'**
  String get requestNewQuotation;

  /// No description provided for @viewQuotationHistory.
  ///
  /// In en, this message translates to:
  /// **'View your quotation history'**
  String get viewQuotationHistory;

  /// No description provided for @createNewBooking.
  ///
  /// In en, this message translates to:
  /// **'Create a new shipment booking'**
  String get createNewBooking;

  /// No description provided for @managePreviousBookings.
  ///
  /// In en, this message translates to:
  /// **'Manage previous bookings'**
  String get managePreviousBookings;

  /// No description provided for @shipmentManagement.
  ///
  /// In en, this message translates to:
  /// **'Shipment Management'**
  String get shipmentManagement;

  /// No description provided for @calculateCargoVolume.
  ///
  /// In en, this message translates to:
  /// **'Calculate cargo volume'**
  String get calculateCargoVolume;

  /// No description provided for @trackShipmentStatus.
  ///
  /// In en, this message translates to:
  /// **'Track your shipment status'**
  String get trackShipmentStatus;

  /// No description provided for @myShipments.
  ///
  /// In en, this message translates to:
  /// **'My Shipments'**
  String get myShipments;

  /// No description provided for @viewAllActiveShipments.
  ///
  /// In en, this message translates to:
  /// **'View all active shipments'**
  String get viewAllActiveShipments;

  /// No description provided for @shippingAndAccountDocuments.
  ///
  /// In en, this message translates to:
  /// **'Shipping and account documents'**
  String get shippingAndAccountDocuments;

  /// No description provided for @customerReviews.
  ///
  /// In en, this message translates to:
  /// **'Customer Reviews'**
  String get customerReviews;

  /// No description provided for @seeWhatCustomersSay.
  ///
  /// In en, this message translates to:
  /// **'See what our customers say'**
  String get seeWhatCustomersSay;

  /// No description provided for @ourWebsite.
  ///
  /// In en, this message translates to:
  /// **'Our Website'**
  String get ourWebsite;

  /// No description provided for @visitTawamOnline.
  ///
  /// In en, this message translates to:
  /// **'Visit TAWAM AL-SHAHIN online'**
  String get visitTawamOnline;

  /// No description provided for @accountAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Account & Support'**
  String get accountAndSupport;

  /// No description provided for @contactLogisticsSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact our logistics support team'**
  String get contactLogisticsSupport;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get myAccount;

  /// No description provided for @profileAndSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile and account settings'**
  String get profileAndSettings;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @logOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logOutConfirm;

  /// No description provided for @logOutUpper.
  ///
  /// In en, this message translates to:
  /// **'LOG OUT'**
  String get logOutUpper;

  /// No description provided for @cancelUpper.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancelUpper;

  /// No description provided for @socialMedia.
  ///
  /// In en, this message translates to:
  /// **'SOCIAL MEDIA'**
  String get socialMedia;

  /// No description provided for @rateRequest.
  ///
  /// In en, this message translates to:
  /// **'Rate Request'**
  String get rateRequest;

  /// No description provided for @rateRequestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get an instant quote for your shipment'**
  String get rateRequestSubtitle;

  /// No description provided for @requestRate.
  ///
  /// In en, this message translates to:
  /// **'Request Rate'**
  String get requestRate;

  /// No description provided for @requestRateForService.
  ///
  /// In en, this message translates to:
  /// **'Request a shipping rate for this service.'**
  String get requestRateForService;

  /// No description provided for @rateRequestWillConnect.
  ///
  /// In en, this message translates to:
  /// **'{service} rate request will be connected next.'**
  String rateRequestWillConnect(String service);

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @customerProfile.
  ///
  /// In en, this message translates to:
  /// **'CUSTOMER PROFILE'**
  String get customerProfile;

  /// No description provided for @customerDetails.
  ///
  /// In en, this message translates to:
  /// **'Customer Details'**
  String get customerDetails;

  /// No description provided for @accountControl.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT CONTROL'**
  String get accountControl;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @customerServices.
  ///
  /// In en, this message translates to:
  /// **'CUSTOMER SERVICES'**
  String get customerServices;

  /// No description provided for @assistance.
  ///
  /// In en, this message translates to:
  /// **'Assistance'**
  String get assistance;

  /// No description provided for @shippingFiles.
  ///
  /// In en, this message translates to:
  /// **'Shipping files'**
  String get shippingFiles;

  /// No description provided for @customerHelp.
  ///
  /// In en, this message translates to:
  /// **'Customer help'**
  String get customerHelp;

  /// No description provided for @accountAndLegal.
  ///
  /// In en, this message translates to:
  /// **'Account & Legal'**
  String get accountAndLegal;

  /// No description provided for @accountLegalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy, terms and account management'**
  String get accountLegalSubtitle;

  /// No description provided for @privacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'How we protect your information'**
  String get privacySubtitle;

  /// No description provided for @termsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'TAWAM application terms'**
  String get termsSubtitle;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove your customer account'**
  String get deleteAccountSubtitle;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @accountServiceUpdates.
  ///
  /// In en, this message translates to:
  /// **'Account and service updates'**
  String get accountServiceUpdates;

  /// No description provided for @updateAccountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Update account security'**
  String get updateAccountSecurity;

  /// No description provided for @signOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Securely end your current session'**
  String get signOutSubtitle;

  /// No description provided for @unableToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile'**
  String get unableToLoadProfile;

  /// No description provided for @unableToLoadProfileInfo.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile information.'**
  String get unableToLoadProfileInfo;

  /// No description provided for @couldNotUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not update profile'**
  String get couldNotUpdateProfile;

  /// No description provided for @couldNotVerifyAccount.
  ///
  /// In en, this message translates to:
  /// **'Could not verify your account'**
  String get couldNotVerifyAccount;

  /// No description provided for @signOutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Sign Out?'**
  String get signOutQuestion;

  /// No description provided for @signOutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to access your shipments.'**
  String get signOutConfirmBody;

  /// No description provided for @notificationCenter.
  ///
  /// In en, this message translates to:
  /// **'Notification Center'**
  String get notificationCenter;

  /// No description provided for @notificationDefault.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationDefault;

  /// No description provided for @notificationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted'**
  String get notificationDeleted;

  /// No description provided for @noUnreadNotifications.
  ///
  /// In en, this message translates to:
  /// **'No unread notifications'**
  String get noUnreadNotifications;

  /// No description provided for @allMarkedAsRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get allMarkedAsRead;

  /// No description provided for @shipmentNotFoundShort.
  ///
  /// In en, this message translates to:
  /// **'Shipment could not be found.'**
  String get shipmentNotFoundShort;

  /// No description provided for @couldNotOpenShipmentDetails.
  ///
  /// In en, this message translates to:
  /// **'Could not open shipment details.'**
  String get couldNotOpenShipmentDetails;

  /// No description provided for @unableToLoadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Unable to load notifications'**
  String get unableToLoadNotifications;

  /// No description provided for @couldNotLoadNotifications.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your notifications. Please check your connection and try again.'**
  String get couldNotLoadNotifications;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @liveNotificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Live notification status'**
  String get liveNotificationStatus;

  /// No description provided for @notifShipmentInTransitTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipment update'**
  String get notifShipmentInTransitTitle;

  /// No description provided for @notifShipmentInTransitBody.
  ///
  /// In en, this message translates to:
  /// **'Shipment {trackingNumber} is now in transit.'**
  String notifShipmentInTransitBody(String trackingNumber);

  /// No description provided for @notifShipmentDeliveredTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipment delivered'**
  String get notifShipmentDeliveredTitle;

  /// No description provided for @notifShipmentDeliveredBody.
  ///
  /// In en, this message translates to:
  /// **'Shipment {trackingNumber} has been delivered.'**
  String notifShipmentDeliveredBody(String trackingNumber);

  /// No description provided for @notifShipmentOutForDeliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Out for delivery'**
  String get notifShipmentOutForDeliveryTitle;

  /// No description provided for @notifShipmentOutForDeliveryBody.
  ///
  /// In en, this message translates to:
  /// **'Shipment {trackingNumber} is out for delivery.'**
  String notifShipmentOutForDeliveryBody(String trackingNumber);

  /// No description provided for @notifQuoteReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Quote ready'**
  String get notifQuoteReadyTitle;

  /// No description provided for @notifQuoteReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Your quotation is ready to review.'**
  String get notifQuoteReadyBody;

  /// No description provided for @notifSupportReplyTitle.
  ///
  /// In en, this message translates to:
  /// **'Support reply'**
  String get notifSupportReplyTitle;

  /// No description provided for @notifSupportReplyBody.
  ///
  /// In en, this message translates to:
  /// **'You have a new reply on your support request.'**
  String get notifSupportReplyBody;

  /// No description provided for @notifShipmentConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipment confirmed'**
  String get notifShipmentConfirmedTitle;

  /// No description provided for @notifShipmentConfirmedBody.
  ///
  /// In en, this message translates to:
  /// **'Shipment {trackingNumber} has been confirmed.'**
  String notifShipmentConfirmedBody(String trackingNumber);

  /// No description provided for @notifShipmentCustomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Customs update'**
  String get notifShipmentCustomsTitle;

  /// No description provided for @notifShipmentCustomsBody.
  ///
  /// In en, this message translates to:
  /// **'Shipment {trackingNumber} is in customs clearance.'**
  String notifShipmentCustomsBody(String trackingNumber);

  /// No description provided for @notifGenericTitle.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get notifGenericTitle;

  /// No description provided for @unableToLoadShipments.
  ///
  /// In en, this message translates to:
  /// **'Unable to load shipments'**
  String get unableToLoadShipments;

  /// No description provided for @liveCustomerShipmentPortal.
  ///
  /// In en, this message translates to:
  /// **'LIVE CUSTOMER SHIPMENT PORTAL'**
  String get liveCustomerShipmentPortal;

  /// No description provided for @yourShippingNetwork.
  ///
  /// In en, this message translates to:
  /// **'Your Shipping Network'**
  String get yourShippingNetwork;

  /// No description provided for @monitorShipmentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor every active and completed shipment from one secure place.'**
  String get monitorShipmentsSubtitle;

  /// No description provided for @searchTrackingRouteCargo.
  ///
  /// In en, this message translates to:
  /// **'Search tracking number, route or cargo'**
  String get searchTrackingRouteCargo;

  /// No description provided for @shipmentPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Shipment Portfolio'**
  String get shipmentPortfolio;

  /// No description provided for @selectShipmentDetails.
  ///
  /// In en, this message translates to:
  /// **'Select a shipment to view full details.'**
  String get selectShipmentDetails;

  /// No description provided for @noMatchingShipments.
  ///
  /// In en, this message translates to:
  /// **'No matching shipments'**
  String get noMatchingShipments;

  /// No description provided for @noShipmentsYet.
  ///
  /// In en, this message translates to:
  /// **'No shipments yet'**
  String get noShipmentsYet;

  /// No description provided for @noMatchingShipmentsBody.
  ///
  /// In en, this message translates to:
  /// **'We could not find any shipments matching your current search or filter.'**
  String get noMatchingShipmentsBody;

  /// No description provided for @noShipmentsYetBody.
  ///
  /// In en, this message translates to:
  /// **'Your shipments will appear here as soon as they are created by our operations team.'**
  String get noShipmentsYetBody;

  /// No description provided for @shipment.
  ///
  /// In en, this message translates to:
  /// **'Shipment'**
  String get shipment;

  /// No description provided for @couldNotLoadShipments.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your shipments. Please check your connection and try again.'**
  String get couldNotLoadShipments;

  /// No description provided for @shipmentDetails.
  ///
  /// In en, this message translates to:
  /// **'Shipment Details'**
  String get shipmentDetails;

  /// No description provided for @liveShipmentRecord.
  ///
  /// In en, this message translates to:
  /// **'LIVE SHIPMENT RECORD'**
  String get liveShipmentRecord;

  /// No description provided for @liveShipmentMap.
  ///
  /// In en, this message translates to:
  /// **'Live Shipment Map'**
  String get liveShipmentMap;

  /// No description provided for @lastKnownLocation.
  ///
  /// In en, this message translates to:
  /// **'LAST KNOWN LOCATION'**
  String get lastKnownLocation;

  /// No description provided for @updatingLiveLocation.
  ///
  /// In en, this message translates to:
  /// **'Updating live location...'**
  String get updatingLiveLocation;

  /// No description provided for @locationTemporarilyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location temporarily unavailable'**
  String get locationTemporarilyUnavailable;

  /// No description provided for @completeLogisticsDetails.
  ///
  /// In en, this message translates to:
  /// **'Complete logistics details for this shipment.'**
  String get completeLogisticsDetails;

  /// No description provided for @shipmentJourney.
  ///
  /// In en, this message translates to:
  /// **'Shipment Journey'**
  String get shipmentJourney;

  /// No description provided for @liveMilestones.
  ///
  /// In en, this message translates to:
  /// **'Live milestones and status history.'**
  String get liveMilestones;

  /// No description provided for @needShipmentSupport.
  ///
  /// In en, this message translates to:
  /// **'Need shipment support?'**
  String get needShipmentSupport;

  /// No description provided for @logisticsTeamReady.
  ///
  /// In en, this message translates to:
  /// **'Our logistics team is ready to assist you.'**
  String get logisticsTeamReady;

  /// No description provided for @shipmentUpdate.
  ///
  /// In en, this message translates to:
  /// **'Shipment Update'**
  String get shipmentUpdate;

  /// No description provided for @shipmentStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Shipment status updated.'**
  String get shipmentStatusUpdated;

  /// No description provided for @pleaseEnterTrackingNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your tracking number.'**
  String get pleaseEnterTrackingNumber;

  /// No description provided for @pleaseSignInToTrack.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to track your shipment.'**
  String get pleaseSignInToTrack;

  /// No description provided for @shipmentNotFoundCheck.
  ///
  /// In en, this message translates to:
  /// **'Shipment not found. Please check the tracking number.'**
  String get shipmentNotFoundCheck;

  /// No description provided for @shipmentNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'This shipment is no longer available.'**
  String get shipmentNoLongerAvailable;

  /// No description provided for @liveTrackingInterrupted.
  ///
  /// In en, this message translates to:
  /// **'Live tracking connection was interrupted.'**
  String get liveTrackingInterrupted;

  /// No description provided for @couldNotTrackShipment.
  ///
  /// In en, this message translates to:
  /// **'Could not track shipment. Please try again.'**
  String get couldNotTrackShipment;

  /// No description provided for @qrScanningSoon.
  ///
  /// In en, this message translates to:
  /// **'QR code scanning will be available soon.'**
  String get qrScanningSoon;

  /// No description provided for @liveShipmentVisibility.
  ///
  /// In en, this message translates to:
  /// **'LIVE SHIPMENT VISIBILITY'**
  String get liveShipmentVisibility;

  /// No description provided for @trackEveryMove.
  ///
  /// In en, this message translates to:
  /// **'Track Every Move'**
  String get trackEveryMove;

  /// No description provided for @trackEveryMoveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your tracking number to view the latest status, location and shipment journey.'**
  String get trackEveryMoveSubtitle;

  /// No description provided for @private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get private;

  /// No description provided for @liveUpdates.
  ///
  /// In en, this message translates to:
  /// **'Live Updates'**
  String get liveUpdates;

  /// No description provided for @onlyAssignedShipments.
  ///
  /// In en, this message translates to:
  /// **'Only shipments assigned to your account can be displayed.'**
  String get onlyAssignedShipments;

  /// No description provided for @enterTrackingNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter tracking number'**
  String get enterTrackingNumber;

  /// No description provided for @trackingInProgress.
  ///
  /// In en, this message translates to:
  /// **'TRACKING...'**
  String get trackingInProgress;

  /// No description provided for @trackShipment.
  ///
  /// In en, this message translates to:
  /// **'TRACK SHIPMENT'**
  String get trackShipment;

  /// No description provided for @professionalVisibility.
  ///
  /// In en, this message translates to:
  /// **'Professional Shipment Visibility'**
  String get professionalVisibility;

  /// No description provided for @trackingViewProtected.
  ///
  /// In en, this message translates to:
  /// **'Your tracking view is protected and connected directly to your shipment record.'**
  String get trackingViewProtected;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @shipmentJourneyShort.
  ///
  /// In en, this message translates to:
  /// **'Shipment journey'**
  String get shipmentJourneyShort;

  /// No description provided for @etaDetails.
  ///
  /// In en, this message translates to:
  /// **'ETA details'**
  String get etaDetails;

  /// No description provided for @liveTracking.
  ///
  /// In en, this message translates to:
  /// **'LIVE TRACKING'**
  String get liveTracking;

  /// No description provided for @shipmentTimeline.
  ///
  /// In en, this message translates to:
  /// **'Shipment Timeline'**
  String get shipmentTimeline;

  /// No description provided for @latestMilestones.
  ///
  /// In en, this message translates to:
  /// **'Latest milestones from your shipment journey.'**
  String get latestMilestones;

  /// No description provided for @viewFullShipmentDetails.
  ///
  /// In en, this message translates to:
  /// **'VIEW FULL SHIPMENT DETAILS'**
  String get viewFullShipmentDetails;

  /// No description provided for @getAQuoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Get a Quote'**
  String get getAQuoteTitle;

  /// No description provided for @requestYourBestRate.
  ///
  /// In en, this message translates to:
  /// **'Request Your Best Rate'**
  String get requestYourBestRate;

  /// No description provided for @quoteHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your shipment and our logistics team will prepare a tailored quotation.'**
  String get quoteHeroSubtitle;

  /// No description provided for @shippingService.
  ///
  /// In en, this message translates to:
  /// **'Shipping Service'**
  String get shippingService;

  /// No description provided for @chooseServiceFits.
  ///
  /// In en, this message translates to:
  /// **'Choose the service that fits your shipment'**
  String get chooseServiceFits;

  /// No description provided for @route.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get route;

  /// No description provided for @whereShipmentMoving.
  ///
  /// In en, this message translates to:
  /// **'Where is your shipment moving from and to?'**
  String get whereShipmentMoving;

  /// No description provided for @shipmentDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Shipment Details'**
  String get shipmentDetailsSection;

  /// No description provided for @tellUsAboutCargo.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your cargo'**
  String get tellUsAboutCargo;

  /// No description provided for @selectPreferredPickup.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred pickup date'**
  String get selectPreferredPickup;

  /// No description provided for @addSpecialInstructions.
  ///
  /// In en, this message translates to:
  /// **'Add any special instructions for our team'**
  String get addSpecialInstructions;

  /// No description provided for @teamWillReviewRate.
  ///
  /// In en, this message translates to:
  /// **'Our team will review your request and send you the best available rate.'**
  String get teamWillReviewRate;

  /// No description provided for @preferredPickupDate.
  ///
  /// In en, this message translates to:
  /// **'Preferred Pickup Date'**
  String get preferredPickupDate;

  /// No description provided for @dimensionsOptional.
  ///
  /// In en, this message translates to:
  /// **'Dimensions (optional)'**
  String get dimensionsOptional;

  /// No description provided for @dimensionsInCm.
  ///
  /// In en, this message translates to:
  /// **'Dimensions are recorded in centimeters (CM).'**
  String get dimensionsInCm;

  /// No description provided for @specialHandlingHint.
  ///
  /// In en, this message translates to:
  /// **'Special handling, customs information, vehicle details, packing notes, or anything else we should know...'**
  String get specialHandlingHint;

  /// No description provided for @secureRequest.
  ///
  /// In en, this message translates to:
  /// **'Secure Request'**
  String get secureRequest;

  /// No description provided for @bestRate.
  ///
  /// In en, this message translates to:
  /// **'Best Rate'**
  String get bestRate;

  /// No description provided for @expertSupport.
  ///
  /// In en, this message translates to:
  /// **'Expert Support'**
  String get expertSupport;

  /// No description provided for @submitQuoteRequest.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT QUOTE REQUEST'**
  String get submitQuoteRequest;

  /// No description provided for @pleaseCompleteShipmentInfo.
  ///
  /// In en, this message translates to:
  /// **'Please complete the required shipment information.'**
  String get pleaseCompleteShipmentInfo;

  /// No description provided for @couldNotSubmitQuote.
  ///
  /// In en, this message translates to:
  /// **'Could not submit your quote request.'**
  String get couldNotSubmitQuote;

  /// No description provided for @couldNotSubmitQuoteRetry.
  ///
  /// In en, this message translates to:
  /// **'Could not submit quote request. Please try again.'**
  String get couldNotSubmitQuoteRetry;

  /// No description provided for @quoteRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Quote Request Submitted'**
  String get quoteRequestSubmitted;

  /// No description provided for @quoteSentToTawam.
  ///
  /// In en, this message translates to:
  /// **'Your request has been sent to TAWAM AL-SHAHIN TRANSPORT.'**
  String get quoteSentToTawam;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'REFERENCE'**
  String get reference;

  /// No description provided for @selectPickupDate.
  ///
  /// In en, this message translates to:
  /// **'SELECT PICKUP DATE'**
  String get selectPickupDate;

  /// No description provided for @createBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a Booking'**
  String get createBookingTitle;

  /// No description provided for @globalBookingDesk.
  ///
  /// In en, this message translates to:
  /// **'GLOBAL BOOKING DESK'**
  String get globalBookingDesk;

  /// No description provided for @scheduleYourShipment.
  ///
  /// In en, this message translates to:
  /// **'Schedule Your Shipment'**
  String get scheduleYourShipment;

  /// No description provided for @bookingHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Book with our logistics team and let TAWAM coordinate your shipment from pickup to delivery.'**
  String get bookingHeroSubtitle;

  /// No description provided for @selectService.
  ///
  /// In en, this message translates to:
  /// **'Select Service'**
  String get selectService;

  /// No description provided for @chooseHowToMove.
  ///
  /// In en, this message translates to:
  /// **'Choose how you would like us to move your shipment.'**
  String get chooseHowToMove;

  /// No description provided for @routeAndSchedule.
  ///
  /// In en, this message translates to:
  /// **'Route & Schedule'**
  String get routeAndSchedule;

  /// No description provided for @tellOperationsWhereWhen.
  ///
  /// In en, this message translates to:
  /// **'Tell our operations team where and when to collect your cargo.'**
  String get tellOperationsWhereWhen;

  /// No description provided for @provideCargoForBooking.
  ///
  /// In en, this message translates to:
  /// **'Provide the cargo information needed to prepare your booking.'**
  String get provideCargoForBooking;

  /// No description provided for @contactAndInstructions.
  ///
  /// In en, this message translates to:
  /// **'Contact & Instructions'**
  String get contactAndInstructions;

  /// No description provided for @accountAttachedToBooking.
  ///
  /// In en, this message translates to:
  /// **'Your account details are securely attached to this booking.'**
  String get accountAttachedToBooking;

  /// No description provided for @bookingReviewedByOps.
  ///
  /// In en, this message translates to:
  /// **'Your request will be reviewed by the TAWAM operations team.'**
  String get bookingReviewedByOps;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @flexible.
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get flexible;

  /// No description provided for @pickupDate.
  ///
  /// In en, this message translates to:
  /// **'Pickup Date'**
  String get pickupDate;

  /// No description provided for @vehicleGeneralCargoHint.
  ///
  /// In en, this message translates to:
  /// **'Vehicle, General Cargo, Furniture...'**
  String get vehicleGeneralCargoHint;

  /// No description provided for @pickupAccessHint.
  ///
  /// In en, this message translates to:
  /// **'Pickup access, packing notes, customs information or anything our team should know...'**
  String get pickupAccessHint;

  /// No description provided for @secureBooking.
  ///
  /// In en, this message translates to:
  /// **'Secure Booking'**
  String get secureBooking;

  /// No description provided for @professionalCare.
  ///
  /// In en, this message translates to:
  /// **'Professional Care'**
  String get professionalCare;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM BOOKING'**
  String get confirmBooking;

  /// No description provided for @pleaseCompleteBooking.
  ///
  /// In en, this message translates to:
  /// **'Please complete the required booking information.'**
  String get pleaseCompleteBooking;

  /// No description provided for @unableToSubmitBooking.
  ///
  /// In en, this message translates to:
  /// **'Unable to submit your booking.'**
  String get unableToSubmitBooking;

  /// No description provided for @bookingRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Booking Request Submitted'**
  String get bookingRequestSubmitted;

  /// No description provided for @bookingSentToTawam.
  ///
  /// In en, this message translates to:
  /// **'Your booking has been sent securely to TAWAM AL-SHAHIN TRANSPORT for review.'**
  String get bookingSentToTawam;

  /// No description provided for @bookingReference.
  ///
  /// In en, this message translates to:
  /// **'BOOKING REFERENCE'**
  String get bookingReference;

  /// No description provided for @pendingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'PENDING CONFIRMATION'**
  String get pendingConfirmation;

  /// No description provided for @document.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get document;

  /// No description provided for @documentPathMissing.
  ///
  /// In en, this message translates to:
  /// **'Document path is missing.'**
  String get documentPathMissing;

  /// No description provided for @couldNotOpenDocument.
  ///
  /// In en, this message translates to:
  /// **'Could not open document: {error}'**
  String couldNotOpenDocument(String error);

  /// No description provided for @couldNotLoadDocuments.
  ///
  /// In en, this message translates to:
  /// **'Could not load documents'**
  String get couldNotLoadDocuments;

  /// No description provided for @noDocumentsYet.
  ///
  /// In en, this message translates to:
  /// **'No documents yet'**
  String get noDocumentsYet;

  /// No description provided for @documentsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your invoices, shipment documents and delivery files will appear here.'**
  String get documentsEmptyBody;

  /// No description provided for @couldNotLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Could not load image'**
  String get couldNotLoadImage;

  /// No description provided for @customerSupport.
  ///
  /// In en, this message translates to:
  /// **'Customer Support'**
  String get customerSupport;

  /// No description provided for @logisticsSupportCenter.
  ///
  /// In en, this message translates to:
  /// **'LOGISTICS SUPPORT CENTER'**
  String get logisticsSupportCenter;

  /// No description provided for @howCanWeHelp.
  ///
  /// In en, this message translates to:
  /// **'How Can We Help?'**
  String get howCanWeHelp;

  /// No description provided for @supportHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Professional assistance for shipments, quotations, customs and delivery requests.'**
  String get supportHeroSubtitle;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @protectedRequest.
  ///
  /// In en, this message translates to:
  /// **'Protected request'**
  String get protectedRequest;

  /// No description provided for @specialists.
  ///
  /// In en, this message translates to:
  /// **'Specialists'**
  String get specialists;

  /// No description provided for @logisticsTeam.
  ///
  /// In en, this message translates to:
  /// **'Logistics team'**
  String get logisticsTeam;

  /// No description provided for @tracked.
  ///
  /// In en, this message translates to:
  /// **'Tracked'**
  String get tracked;

  /// No description provided for @caseSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Case submitted'**
  String get caseSubmitted;

  /// No description provided for @instantAssistance.
  ///
  /// In en, this message translates to:
  /// **'Instant Assistance'**
  String get instantAssistance;

  /// No description provided for @chooseFastestChannel.
  ///
  /// In en, this message translates to:
  /// **'Choose the fastest channel for your request.'**
  String get chooseFastestChannel;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @startChat.
  ///
  /// In en, this message translates to:
  /// **'Start chat'**
  String get startChat;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @callSupport.
  ///
  /// In en, this message translates to:
  /// **'Call support'**
  String get callSupport;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send email'**
  String get sendEmail;

  /// No description provided for @openSupportCase.
  ///
  /// In en, this message translates to:
  /// **'Open a Support Case'**
  String get openSupportCase;

  /// No description provided for @sendRequestToOps.
  ///
  /// In en, this message translates to:
  /// **'Send your request directly to our operations team.'**
  String get sendRequestToOps;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faq;

  /// No description provided for @faqSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick answers to common logistics questions.'**
  String get faqSubtitle;

  /// No description provided for @faqTrackingQ.
  ///
  /// In en, this message translates to:
  /// **'Where can I find my tracking number?'**
  String get faqTrackingQ;

  /// No description provided for @faqTrackingA.
  ///
  /// In en, this message translates to:
  /// **'Your tracking number is included in your shipment confirmation and can also be found in My Shipments.'**
  String get faqTrackingA;

  /// No description provided for @faqStatusQ.
  ///
  /// In en, this message translates to:
  /// **'Why has my shipment status not changed?'**
  String get faqStatusQ;

  /// No description provided for @faqStatusA.
  ///
  /// In en, this message translates to:
  /// **'Tracking updates may appear after your shipment reaches the next logistics checkpoint or after an operations update.'**
  String get faqStatusA;

  /// No description provided for @faqQuoteQ.
  ///
  /// In en, this message translates to:
  /// **'How do I request a shipping quotation?'**
  String get faqQuoteQ;

  /// No description provided for @faqQuoteA.
  ///
  /// In en, this message translates to:
  /// **'Open Get a Quote from the home page and submit your shipment details.'**
  String get faqQuoteA;

  /// No description provided for @faqDeliveryQ.
  ///
  /// In en, this message translates to:
  /// **'Can I update my delivery information?'**
  String get faqDeliveryQ;

  /// No description provided for @faqDeliveryA.
  ///
  /// In en, this message translates to:
  /// **'Contact support and include your tracking number together with the new delivery information.'**
  String get faqDeliveryA;

  /// No description provided for @mySupportRequests.
  ///
  /// In en, this message translates to:
  /// **'My Support Requests'**
  String get mySupportRequests;

  /// No description provided for @viewCasesAndUpdates.
  ///
  /// In en, this message translates to:
  /// **'View your cases and latest updates'**
  String get viewCasesAndUpdates;

  /// No description provided for @supportRequest.
  ///
  /// In en, this message translates to:
  /// **'Support Request'**
  String get supportRequest;

  /// No description provided for @provideDetailsBelow.
  ///
  /// In en, this message translates to:
  /// **'Provide the details below.'**
  String get provideDetailsBelow;

  /// No description provided for @supportCategory.
  ///
  /// In en, this message translates to:
  /// **'Support category'**
  String get supportCategory;

  /// No description provided for @trackingOptional.
  ///
  /// In en, this message translates to:
  /// **'Tracking / shipment number — optional'**
  String get trackingOptional;

  /// No description provided for @pleaseDescribeRequest.
  ///
  /// In en, this message translates to:
  /// **'Please describe your request'**
  String get pleaseDescribeRequest;

  /// No description provided for @pleaseAddMoreDetails.
  ///
  /// In en, this message translates to:
  /// **'Please add more details'**
  String get pleaseAddMoreDetails;

  /// No description provided for @describeIssueHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue or assistance you need...'**
  String get describeIssueHint;

  /// No description provided for @includeTrackingHint.
  ///
  /// In en, this message translates to:
  /// **'For shipment-related requests, include the tracking number to help our team review the case faster.'**
  String get includeTrackingHint;

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'SUBMITTING...'**
  String get submitting;

  /// No description provided for @submitSupportRequest.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT SUPPORT REQUEST'**
  String get submitSupportRequest;

  /// No description provided for @supportHours.
  ///
  /// In en, this message translates to:
  /// **'Support Hours'**
  String get supportHours;

  /// No description provided for @mondayFriday.
  ///
  /// In en, this message translates to:
  /// **'Monday – Friday'**
  String get mondayFriday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @emergencySupport.
  ///
  /// In en, this message translates to:
  /// **'Emergency support'**
  String get emergencySupport;

  /// No description provided for @timesUae.
  ///
  /// In en, this message translates to:
  /// **'Times shown in UAE local time.'**
  String get timesUae;

  /// No description provided for @couldNotOpenWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp.'**
  String get couldNotOpenWhatsapp;

  /// No description provided for @couldNotOpenPhone.
  ///
  /// In en, this message translates to:
  /// **'Could not open the phone app.'**
  String get couldNotOpenPhone;

  /// No description provided for @couldNotOpenEmail.
  ///
  /// In en, this message translates to:
  /// **'Could not open the email app.'**
  String get couldNotOpenEmail;

  /// No description provided for @couldNotSendSupport.
  ///
  /// In en, this message translates to:
  /// **'Could not send your support request. Please try again.'**
  String get couldNotSendSupport;

  /// No description provided for @requestSuccessfullySent.
  ///
  /// In en, this message translates to:
  /// **'Request Successfully Sent'**
  String get requestSuccessfullySent;

  /// No description provided for @supportCaseSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your support case has been securely submitted to the TAWAM operations team.'**
  String get supportCaseSubmitted;

  /// No description provided for @requestCategory.
  ///
  /// In en, this message translates to:
  /// **'REQUEST CATEGORY'**
  String get requestCategory;

  /// No description provided for @catShipmentTracking.
  ///
  /// In en, this message translates to:
  /// **'Shipment Tracking'**
  String get catShipmentTracking;

  /// No description provided for @catDeliveryDelay.
  ///
  /// In en, this message translates to:
  /// **'Delivery Delay'**
  String get catDeliveryDelay;

  /// No description provided for @catRequestQuote.
  ///
  /// In en, this message translates to:
  /// **'Request a Quote'**
  String get catRequestQuote;

  /// No description provided for @catCustoms.
  ///
  /// In en, this message translates to:
  /// **'Customs Clearance'**
  String get catCustoms;

  /// No description provided for @catPaymentInvoice.
  ///
  /// In en, this message translates to:
  /// **'Payment & Invoice'**
  String get catPaymentInvoice;

  /// No description provided for @catDamagedShipment.
  ///
  /// In en, this message translates to:
  /// **'Damaged Shipment'**
  String get catDamagedShipment;

  /// No description provided for @catGeneralInquiry.
  ///
  /// In en, this message translates to:
  /// **'General Inquiry'**
  String get catGeneralInquiry;

  /// No description provided for @whatsappPrefill.
  ///
  /// In en, this message translates to:
  /// **'Hello TAWAM AL-SHAHIN TRANSPORT, I need assistance.'**
  String get whatsappPrefill;

  /// No description provided for @supportEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'TAWAM AL-SHAHIN TRANSPORT Support Request'**
  String get supportEmailSubject;

  /// No description provided for @requestShipment.
  ///
  /// In en, this message translates to:
  /// **'Request Shipment'**
  String get requestShipment;

  /// No description provided for @newShipmentRequest.
  ///
  /// In en, this message translates to:
  /// **'New Shipment Request'**
  String get newShipmentRequest;

  /// No description provided for @sendShipmentForReview.
  ///
  /// In en, this message translates to:
  /// **'Send your shipment details for review by our logistics team.'**
  String get sendShipmentForReview;

  /// No description provided for @exampleDubai.
  ///
  /// In en, this message translates to:
  /// **'Example: Dubai, UAE'**
  String get exampleDubai;

  /// No description provided for @enterPickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter pickup location'**
  String get enterPickupLocation;

  /// No description provided for @exampleAmman.
  ///
  /// In en, this message translates to:
  /// **'Example: Amman, Jordan'**
  String get exampleAmman;

  /// No description provided for @enterDeliveryLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter delivery location'**
  String get enterDeliveryLocation;

  /// No description provided for @describeShipment.
  ///
  /// In en, this message translates to:
  /// **'Describe the shipment'**
  String get describeShipment;

  /// No description provided for @enterCargoDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter cargo details'**
  String get enterCargoDetails;

  /// No description provided for @expectedDelivery.
  ///
  /// In en, this message translates to:
  /// **'Expected Delivery'**
  String get expectedDelivery;

  /// No description provided for @selectPreferredDate.
  ///
  /// In en, this message translates to:
  /// **'Select preferred date'**
  String get selectPreferredDate;

  /// No description provided for @specialHandlingDimensions.
  ///
  /// In en, this message translates to:
  /// **'Special handling, dimensions, vehicle type...'**
  String get specialHandlingDimensions;

  /// No description provided for @requestReviewedAfterApproval.
  ///
  /// In en, this message translates to:
  /// **'Your request will be reviewed by Tawam logistics. A shipment and tracking number will only be created after approval.'**
  String get requestReviewedAfterApproval;

  /// No description provided for @submitShipmentRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Shipment Request'**
  String get submitShipmentRequest;

  /// No description provided for @shipmentRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Shipment request submitted successfully.'**
  String get shipmentRequestSubmitted;

  /// No description provided for @couldNotSubmitShipmentRequest.
  ///
  /// In en, this message translates to:
  /// **'Could not submit shipment request: {error}'**
  String couldNotSubmitShipmentRequest(String error);

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @pleaseEnterDimensionsFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter the cargo dimensions first.'**
  String get pleaseEnterDimensionsFirst;

  /// No description provided for @cargoDimensions.
  ///
  /// In en, this message translates to:
  /// **'Cargo Dimensions'**
  String get cargoDimensions;

  /// No description provided for @enterPackageSizeQty.
  ///
  /// In en, this message translates to:
  /// **'Enter one package size in centimeters and the total quantity.'**
  String get enterPackageSizeQty;

  /// No description provided for @calculationResults.
  ///
  /// In en, this message translates to:
  /// **'Calculation Results'**
  String get calculationResults;

  /// No description provided for @instantMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Instant logistics measurements for planning your shipment.'**
  String get instantMeasurements;

  /// No description provided for @requestAQuote.
  ///
  /// In en, this message translates to:
  /// **'REQUEST A QUOTE'**
  String get requestAQuote;

  /// No description provided for @logisticsCalculationTool.
  ///
  /// In en, this message translates to:
  /// **'LOGISTICS CALCULATION TOOL'**
  String get logisticsCalculationTool;

  /// No description provided for @planCargoSmarter.
  ///
  /// In en, this message translates to:
  /// **'Plan Your Cargo Smarter'**
  String get planCargoSmarter;

  /// No description provided for @volumeHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Calculate CBM and volumetric weight instantly before requesting your shipping quotation.'**
  String get volumeHeroSubtitle;

  /// No description provided for @instant.
  ///
  /// In en, this message translates to:
  /// **'Instant'**
  String get instant;

  /// No description provided for @accurate.
  ///
  /// In en, this message translates to:
  /// **'Accurate'**
  String get accurate;

  /// No description provided for @logisticsReady.
  ///
  /// In en, this message translates to:
  /// **'Logistics Ready'**
  String get logisticsReady;

  /// No description provided for @actualTotalWeight.
  ///
  /// In en, this message translates to:
  /// **'Actual Total Weight'**
  String get actualTotalWeight;

  /// No description provided for @enterOnePackageHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the dimensions of one package. Quantity is applied automatically to the total calculation.'**
  String get enterOnePackageHint;

  /// No description provided for @enterCargoDimensions.
  ///
  /// In en, this message translates to:
  /// **'Enter your cargo dimensions'**
  String get enterCargoDimensions;

  /// No description provided for @calculationAppearsHere.
  ///
  /// In en, this message translates to:
  /// **'Your shipping calculation will appear here instantly.'**
  String get calculationAppearsHere;

  /// No description provided for @totalShipmentVolume.
  ///
  /// In en, this message translates to:
  /// **'TOTAL SHIPMENT VOLUME'**
  String get totalShipmentVolume;

  /// No description provided for @cubicVolumeBased.
  ///
  /// In en, this message translates to:
  /// **'Cubic volume based on the entered dimensions and quantity.'**
  String get cubicVolumeBased;

  /// No description provided for @airVolWeight.
  ///
  /// In en, this message translates to:
  /// **'Air Vol. Weight'**
  String get airVolWeight;

  /// No description provided for @divisor6000.
  ///
  /// In en, this message translates to:
  /// **'Divisor 6000'**
  String get divisor6000;

  /// No description provided for @courierVolWeight.
  ///
  /// In en, this message translates to:
  /// **'Courier Vol. Weight'**
  String get courierVolWeight;

  /// No description provided for @divisor5000.
  ///
  /// In en, this message translates to:
  /// **'Divisor 5000'**
  String get divisor5000;

  /// No description provided for @estimatedAirChargeable.
  ///
  /// In en, this message translates to:
  /// **'Estimated Air Chargeable Weight'**
  String get estimatedAirChargeable;

  /// No description provided for @higherOfActualAir.
  ///
  /// In en, this message translates to:
  /// **'Higher of actual total weight and air volumetric weight'**
  String get higherOfActualAir;

  /// No description provided for @resetCalculator.
  ///
  /// In en, this message translates to:
  /// **'RESET CALCULATOR'**
  String get resetCalculator;

  /// No description provided for @officialRateRequest.
  ///
  /// In en, this message translates to:
  /// **'OFFICIAL RATE REQUEST'**
  String get officialRateRequest;

  /// No description provided for @shipmentRoute.
  ///
  /// In en, this message translates to:
  /// **'Shipment Route'**
  String get shipmentRoute;

  /// No description provided for @tellUsWhereMoving.
  ///
  /// In en, this message translates to:
  /// **'Tell us where your cargo is moving.'**
  String get tellUsWhereMoving;

  /// No description provided for @cargoInformation.
  ///
  /// In en, this message translates to:
  /// **'Cargo Information'**
  String get cargoInformation;

  /// No description provided for @provideCargoSpecs.
  ///
  /// In en, this message translates to:
  /// **'Provide your cargo specifications.'**
  String get provideCargoSpecs;

  /// No description provided for @anythingTeamShouldKnow.
  ///
  /// In en, this message translates to:
  /// **'Anything our team should know?'**
  String get anythingTeamShouldKnow;

  /// No description provided for @infoSubmittedSecurely.
  ///
  /// In en, this message translates to:
  /// **'Your shipment information is securely submitted to our logistics team.'**
  String get infoSubmittedSecurely;

  /// No description provided for @submitQuote.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT QUOTE'**
  String get submitQuote;

  /// No description provided for @doneUpper.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get doneUpper;

  /// No description provided for @airFreightQuote.
  ///
  /// In en, this message translates to:
  /// **'Air Freight Quote'**
  String get airFreightQuote;

  /// No description provided for @globalAirCargo.
  ///
  /// In en, this message translates to:
  /// **'GLOBAL AIR CARGO'**
  String get globalAirCargo;

  /// No description provided for @fastCargoGlobalReach.
  ///
  /// In en, this message translates to:
  /// **'Fast Cargo.\nGlobal Reach.'**
  String get fastCargoGlobalReach;

  /// No description provided for @airHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Professional air freight solutions for urgent, commercial and international cargo.'**
  String get airHeroSubtitle;

  /// No description provided for @airFreightService.
  ///
  /// In en, this message translates to:
  /// **'Air Freight Service'**
  String get airFreightService;

  /// No description provided for @chooseServiceLevel.
  ///
  /// In en, this message translates to:
  /// **'Choose the service level for your shipment.'**
  String get chooseServiceLevel;

  /// No description provided for @weCalculateVolumetric.
  ///
  /// In en, this message translates to:
  /// **'We calculate volumetric and chargeable weight automatically.'**
  String get weCalculateVolumetric;

  /// No description provided for @addOptionalLogistics.
  ///
  /// In en, this message translates to:
  /// **'Add optional logistics services if required.'**
  String get addOptionalLogistics;

  /// No description provided for @anythingAirTeam.
  ///
  /// In en, this message translates to:
  /// **'Anything our air freight team should know?'**
  String get anythingAirTeam;

  /// No description provided for @airportToAirport.
  ///
  /// In en, this message translates to:
  /// **'Airport to Airport'**
  String get airportToAirport;

  /// No description provided for @doorToAirport.
  ///
  /// In en, this message translates to:
  /// **'Door to Airport'**
  String get doorToAirport;

  /// No description provided for @airportToDoor.
  ///
  /// In en, this message translates to:
  /// **'Airport to Door'**
  String get airportToDoor;

  /// No description provided for @looseCargo.
  ///
  /// In en, this message translates to:
  /// **'Loose Cargo'**
  String get looseCargo;

  /// No description provided for @crates.
  ///
  /// In en, this message translates to:
  /// **'Crates'**
  String get crates;

  /// No description provided for @airportCityPickup.
  ///
  /// In en, this message translates to:
  /// **'Airport, city or pickup location'**
  String get airportCityPickup;

  /// No description provided for @airportCityDelivery.
  ///
  /// In en, this message translates to:
  /// **'Airport, city or delivery location'**
  String get airportCityDelivery;

  /// No description provided for @cargoReadyDate.
  ///
  /// In en, this message translates to:
  /// **'Cargo Ready Date'**
  String get cargoReadyDate;

  /// No description provided for @standardAirFreight.
  ///
  /// In en, this message translates to:
  /// **'Standard Air Freight'**
  String get standardAirFreight;

  /// No description provided for @standardAirDesc.
  ///
  /// In en, this message translates to:
  /// **'Reliable international air cargo for regular shipments.'**
  String get standardAirDesc;

  /// No description provided for @expressAirFreight.
  ///
  /// In en, this message translates to:
  /// **'Express Air Freight'**
  String get expressAirFreight;

  /// No description provided for @expressAirDesc.
  ///
  /// In en, this message translates to:
  /// **'Faster handling for urgent and time-sensitive cargo.'**
  String get expressAirDesc;

  /// No description provided for @priorityTimeCritical.
  ///
  /// In en, this message translates to:
  /// **'Priority / Time Critical'**
  String get priorityTimeCritical;

  /// No description provided for @priorityAirDesc.
  ///
  /// In en, this message translates to:
  /// **'Priority handling for highly urgent shipments.'**
  String get priorityAirDesc;

  /// No description provided for @pleaseEnterGrossWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter gross weight'**
  String get pleaseEnterGrossWeight;

  /// No description provided for @enterNumberOfPieces.
  ///
  /// In en, this message translates to:
  /// **'Enter number of pieces'**
  String get enterNumberOfPieces;

  /// No description provided for @averagePieceDimensions.
  ///
  /// In en, this message translates to:
  /// **'Average Piece Dimensions'**
  String get averagePieceDimensions;

  /// No description provided for @enterDimensionsCm.
  ///
  /// In en, this message translates to:
  /// **'Enter dimensions in centimeters.'**
  String get enterDimensionsCm;

  /// No description provided for @automaticAirCalc.
  ///
  /// In en, this message translates to:
  /// **'AUTOMATIC AIR FREIGHT CALCULATION'**
  String get automaticAirCalc;

  /// No description provided for @cargoVolumeCbm.
  ///
  /// In en, this message translates to:
  /// **'Cargo volume: {volume} CBM'**
  String cargoVolumeCbm(String volume);

  /// No description provided for @dgHint.
  ///
  /// In en, this message translates to:
  /// **'Cargo classified as hazardous / DG.'**
  String get dgHint;

  /// No description provided for @requestInsuranceHint.
  ///
  /// In en, this message translates to:
  /// **'Request cargo insurance with the quotation.'**
  String get requestInsuranceHint;

  /// No description provided for @priorityCargo.
  ///
  /// In en, this message translates to:
  /// **'Priority Cargo'**
  String get priorityCargo;

  /// No description provided for @seaFreightQuote.
  ///
  /// In en, this message translates to:
  /// **'Sea Freight Quote'**
  String get seaFreightQuote;

  /// No description provided for @landFreightQuote.
  ///
  /// In en, this message translates to:
  /// **'Land Freight Quote'**
  String get landFreightQuote;

  /// No description provided for @carShippingQuote.
  ///
  /// In en, this message translates to:
  /// **'Car Shipping Quote'**
  String get carShippingQuote;

  /// No description provided for @movingQuote.
  ///
  /// In en, this message translates to:
  /// **'Moving Quote'**
  String get movingQuote;

  /// No description provided for @parcelQuote.
  ///
  /// In en, this message translates to:
  /// **'Parcel Quote'**
  String get parcelQuote;

  /// No description provided for @portToPort.
  ///
  /// In en, this message translates to:
  /// **'Port to Port'**
  String get portToPort;

  /// No description provided for @doorToPort.
  ///
  /// In en, this message translates to:
  /// **'Door to Port'**
  String get doorToPort;

  /// No description provided for @portToDoor.
  ///
  /// In en, this message translates to:
  /// **'Port to Door'**
  String get portToDoor;

  /// No description provided for @openCarrier.
  ///
  /// In en, this message translates to:
  /// **'Open Carrier'**
  String get openCarrier;

  /// No description provided for @selectReadyDateShort.
  ///
  /// In en, this message translates to:
  /// **'Select ready date'**
  String get selectReadyDateShort;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @reviewTermsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please review the terms governing your use of the TAWAM AL-SHAHIN TRANSPORT mobile application and services.'**
  String get reviewTermsSubtitle;

  /// No description provided for @aboutOurServices.
  ///
  /// In en, this message translates to:
  /// **'About Our Services'**
  String get aboutOurServices;

  /// No description provided for @customerAccounts.
  ///
  /// In en, this message translates to:
  /// **'Customer Accounts'**
  String get customerAccounts;

  /// No description provided for @accountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account Security'**
  String get accountSecurity;

  /// No description provided for @shipmentServices.
  ///
  /// In en, this message translates to:
  /// **'Shipment Services'**
  String get shipmentServices;

  /// No description provided for @quotations.
  ///
  /// In en, this message translates to:
  /// **'Quotations'**
  String get quotations;

  /// No description provided for @restrictedItems.
  ///
  /// In en, this message translates to:
  /// **'Restricted or Prohibited Items'**
  String get restrictedItems;

  /// No description provided for @transitDelivery.
  ///
  /// In en, this message translates to:
  /// **'Transit & Delivery'**
  String get transitDelivery;

  /// No description provided for @chargesPayments.
  ///
  /// In en, this message translates to:
  /// **'Charges & Payments'**
  String get chargesPayments;

  /// No description provided for @acceptableUse.
  ///
  /// In en, this message translates to:
  /// **'Acceptable Use'**
  String get acceptableUse;

  /// No description provided for @applicationAvailability.
  ///
  /// In en, this message translates to:
  /// **'Application Availability'**
  String get applicationAvailability;

  /// No description provided for @changesToTerms.
  ///
  /// In en, this message translates to:
  /// **'Changes to These Terms'**
  String get changesToTerms;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @transportLogisticsServices.
  ///
  /// In en, this message translates to:
  /// **'Transportation • Logistics • Shipment Services'**
  String get transportLogisticsServices;

  /// No description provided for @lastUpdatedAugust2026.
  ///
  /// In en, this message translates to:
  /// **'Last updated: August 2026'**
  String get lastUpdatedAugust2026;

  /// No description provided for @privacyHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn how TAWAM AL-SHAHIN TRANSPORT collects, uses and protects your information.'**
  String get privacyHeroSubtitle;

  /// No description provided for @informationWeCollect.
  ///
  /// In en, this message translates to:
  /// **'Information We Collect'**
  String get informationWeCollect;

  /// No description provided for @howWeUseInformation.
  ///
  /// In en, this message translates to:
  /// **'How We Use Information'**
  String get howWeUseInformation;

  /// No description provided for @serviceCommunications.
  ///
  /// In en, this message translates to:
  /// **'Service Communications'**
  String get serviceCommunications;

  /// No description provided for @dataSharing.
  ///
  /// In en, this message translates to:
  /// **'Data Sharing'**
  String get dataSharing;

  /// No description provided for @dataRetention.
  ///
  /// In en, this message translates to:
  /// **'Data Retention'**
  String get dataRetention;

  /// No description provided for @yourRights.
  ///
  /// In en, this message translates to:
  /// **'Your Rights'**
  String get yourRights;

  /// No description provided for @securityMeasures.
  ///
  /// In en, this message translates to:
  /// **'Security Measures'**
  String get securityMeasures;

  /// No description provided for @childrenPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Children’s Privacy'**
  String get childrenPrivacy;

  /// No description provided for @changesToPolicy.
  ///
  /// In en, this message translates to:
  /// **'Changes to This Policy'**
  String get changesToPolicy;

  /// No description provided for @hasPrice.
  ///
  /// In en, this message translates to:
  /// **'Priced'**
  String get hasPrice;

  /// No description provided for @awaitingPrice.
  ///
  /// In en, this message translates to:
  /// **'Awaiting price'**
  String get awaitingPrice;

  /// No description provided for @quoted.
  ///
  /// In en, this message translates to:
  /// **'Quoted'**
  String get quoted;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @declined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get declined;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @rejectedUpper.
  ///
  /// In en, this message translates to:
  /// **'REJECTED'**
  String get rejectedUpper;

  /// No description provided for @quoteReady.
  ///
  /// In en, this message translates to:
  /// **'Quote Ready'**
  String get quoteReady;

  /// No description provided for @underReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get underReview;

  /// No description provided for @yourQuotations.
  ///
  /// In en, this message translates to:
  /// **'Your Quotations'**
  String get yourQuotations;

  /// No description provided for @yourBookings.
  ///
  /// In en, this message translates to:
  /// **'Your Bookings'**
  String get yourBookings;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @closeUpper.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get closeUpper;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @viewDetailsUpper.
  ///
  /// In en, this message translates to:
  /// **'VIEW DETAILS'**
  String get viewDetailsUpper;

  /// No description provided for @shipmentNumber.
  ///
  /// In en, this message translates to:
  /// **'SHIPMENT NUMBER'**
  String get shipmentNumber;

  /// No description provided for @yourMessage.
  ///
  /// In en, this message translates to:
  /// **'YOUR MESSAGE'**
  String get yourMessage;

  /// No description provided for @latestStatusUpdate.
  ///
  /// In en, this message translates to:
  /// **'LATEST STATUS UPDATE'**
  String get latestStatusUpdate;

  /// No description provided for @oceanFreight.
  ///
  /// In en, this message translates to:
  /// **'OCEAN FREIGHT'**
  String get oceanFreight;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdated;

  /// No description provided for @stayInformed.
  ///
  /// In en, this message translates to:
  /// **'Stay informed about your logistics activity'**
  String get stayInformed;

  /// No description provided for @notificationEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Shipment updates, quotations and important account alerts will appear here automatically.'**
  String get notificationEmptyHint;

  /// No description provided for @vehicleInformation.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Information'**
  String get vehicleInformation;

  /// No description provided for @vehicleInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provide the vehicle details required for accurate transport planning.'**
  String get vehicleInfoSubtitle;

  /// No description provided for @shippingMethod.
  ///
  /// In en, this message translates to:
  /// **'Shipping Method'**
  String get shippingMethod;

  /// No description provided for @vehicleProtection.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Protection'**
  String get vehicleProtection;

  /// No description provided for @vehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleType;

  /// No description provided for @numberOfVehicles.
  ///
  /// In en, this message translates to:
  /// **'Number of Vehicles'**
  String get numberOfVehicles;

  /// No description provided for @enterNumberOfVehicles.
  ///
  /// In en, this message translates to:
  /// **'Enter number of vehicles'**
  String get enterNumberOfVehicles;

  /// No description provided for @modelYear.
  ///
  /// In en, this message translates to:
  /// **'Model Year'**
  String get modelYear;

  /// No description provided for @vehicleCondition.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Condition'**
  String get vehicleCondition;

  /// No description provided for @vinChassis.
  ///
  /// In en, this message translates to:
  /// **'VIN / Chassis Number'**
  String get vinChassis;

  /// No description provided for @vehicleValue.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Value'**
  String get vehicleValue;

  /// No description provided for @invalidValue.
  ///
  /// In en, this message translates to:
  /// **'Invalid value'**
  String get invalidValue;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @enclosedCarrier.
  ///
  /// In en, this message translates to:
  /// **'Enclosed Carrier'**
  String get enclosedCarrier;

  /// No description provided for @roroShipping.
  ///
  /// In en, this message translates to:
  /// **'RoRo Shipping'**
  String get roroShipping;

  /// No description provided for @containerShipping.
  ///
  /// In en, this message translates to:
  /// **'Container Shipping'**
  String get containerShipping;

  /// No description provided for @moveProfile.
  ///
  /// In en, this message translates to:
  /// **'Move Profile'**
  String get moveProfile;

  /// No description provided for @inventoryEstimate.
  ///
  /// In en, this message translates to:
  /// **'Inventory Estimate'**
  String get inventoryEstimate;

  /// No description provided for @specialItems.
  ///
  /// In en, this message translates to:
  /// **'Special Items'**
  String get specialItems;

  /// No description provided for @movingServices.
  ///
  /// In en, this message translates to:
  /// **'Moving Services'**
  String get movingServices;

  /// No description provided for @professionalPacking.
  ///
  /// In en, this message translates to:
  /// **'Professional Packing'**
  String get professionalPacking;

  /// No description provided for @propertyType.
  ///
  /// In en, this message translates to:
  /// **'Property Type'**
  String get propertyType;

  /// No description provided for @elevator.
  ///
  /// In en, this message translates to:
  /// **'Elevator'**
  String get elevator;

  /// No description provided for @estimatedBoxes.
  ///
  /// In en, this message translates to:
  /// **'Estimated Boxes'**
  String get estimatedBoxes;

  /// No description provided for @largeItems.
  ///
  /// In en, this message translates to:
  /// **'Large Items'**
  String get largeItems;

  /// No description provided for @estimatedVolume.
  ///
  /// In en, this message translates to:
  /// **'Estimated Volume'**
  String get estimatedVolume;

  /// No description provided for @unpackingService.
  ///
  /// In en, this message translates to:
  /// **'Unpacking Service'**
  String get unpackingService;

  /// No description provided for @furnitureDisassembly.
  ///
  /// In en, this message translates to:
  /// **'Furniture Disassembly'**
  String get furnitureDisassembly;

  /// No description provided for @temporaryStorage.
  ///
  /// In en, this message translates to:
  /// **'Temporary Storage'**
  String get temporaryStorage;

  /// No description provided for @transportType.
  ///
  /// In en, this message translates to:
  /// **'Transport Type'**
  String get transportType;

  /// No description provided for @cargoRequirements.
  ///
  /// In en, this message translates to:
  /// **'Cargo Requirements'**
  String get cargoRequirements;

  /// No description provided for @fullTruckLoad.
  ///
  /// In en, this message translates to:
  /// **'Full Truck Load'**
  String get fullTruckLoad;

  /// No description provided for @partialLoad.
  ///
  /// In en, this message translates to:
  /// **'Partial Load'**
  String get partialLoad;

  /// No description provided for @truckTrailerType.
  ///
  /// In en, this message translates to:
  /// **'Truck / Trailer Type'**
  String get truckTrailerType;

  /// No description provided for @requiredTemperature.
  ///
  /// In en, this message translates to:
  /// **'Required Temperature'**
  String get requiredTemperature;

  /// No description provided for @oversizedCargo.
  ///
  /// In en, this message translates to:
  /// **'Oversized / Out-of-Gauge Cargo'**
  String get oversizedCargo;

  /// No description provided for @deliveryService.
  ///
  /// In en, this message translates to:
  /// **'Delivery Service'**
  String get deliveryService;

  /// No description provided for @protectionAndDelivery.
  ///
  /// In en, this message translates to:
  /// **'Protection & Delivery'**
  String get protectionAndDelivery;

  /// No description provided for @pickupMethod.
  ///
  /// In en, this message translates to:
  /// **'Pickup Method'**
  String get pickupMethod;

  /// No description provided for @numberOfParcels.
  ///
  /// In en, this message translates to:
  /// **'Number of Parcels'**
  String get numberOfParcels;

  /// No description provided for @parcelContents.
  ///
  /// In en, this message translates to:
  /// **'Parcel Contents'**
  String get parcelContents;

  /// No description provided for @pleaseDescribeParcel.
  ///
  /// In en, this message translates to:
  /// **'Please describe the parcel contents'**
  String get pleaseDescribeParcel;

  /// No description provided for @declaredValue.
  ///
  /// In en, this message translates to:
  /// **'Declared Value'**
  String get declaredValue;

  /// No description provided for @weightPerParcel.
  ///
  /// In en, this message translates to:
  /// **'Weight per Parcel'**
  String get weightPerParcel;

  /// No description provided for @signatureOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Signature on Delivery'**
  String get signatureOnDelivery;

  /// No description provided for @fullContainer.
  ///
  /// In en, this message translates to:
  /// **'Full Container'**
  String get fullContainer;

  /// No description provided for @sharedCargo.
  ///
  /// In en, this message translates to:
  /// **'Shared Cargo'**
  String get sharedCargo;

  /// No description provided for @fullContainerLoad.
  ///
  /// In en, this message translates to:
  /// **'Full Container Load'**
  String get fullContainerLoad;

  /// No description provided for @lessContainerLoad.
  ///
  /// In en, this message translates to:
  /// **'Less Container Load'**
  String get lessContainerLoad;

  /// No description provided for @containerType.
  ///
  /// In en, this message translates to:
  /// **'Container Type'**
  String get containerType;

  /// No description provided for @numberOfContainers.
  ///
  /// In en, this message translates to:
  /// **'Number of Containers'**
  String get numberOfContainers;

  /// No description provided for @enterCargoVolume.
  ///
  /// In en, this message translates to:
  /// **'Enter cargo volume'**
  String get enterCargoVolume;

  /// No description provided for @routeDetails.
  ///
  /// In en, this message translates to:
  /// **'Route Details'**
  String get routeDetails;

  /// No description provided for @pleaseEnterCargoWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter the cargo weight'**
  String get pleaseEnterCargoWeight;

  /// No description provided for @pleaseEnterValidWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid weight'**
  String get pleaseEnterValidWeight;

  /// No description provided for @pleaseEnterNumberOfItems.
  ///
  /// In en, this message translates to:
  /// **'Please enter the number of items'**
  String get pleaseEnterNumberOfItems;

  /// No description provided for @pleaseEnterValidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity'**
  String get pleaseEnterValidQuantity;

  /// No description provided for @cargoDescription.
  ///
  /// In en, this message translates to:
  /// **'Cargo description'**
  String get cargoDescription;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @pickupSchedule.
  ///
  /// In en, this message translates to:
  /// **'Pickup Schedule'**
  String get pickupSchedule;

  /// No description provided for @pleaseSelectAPickupDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a pickup date'**
  String get pleaseSelectAPickupDate;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @tailored.
  ///
  /// In en, this message translates to:
  /// **'Tailored'**
  String get tailored;

  /// No description provided for @supported.
  ///
  /// In en, this message translates to:
  /// **'Supported'**
  String get supported;

  /// No description provided for @shipmentInformation.
  ///
  /// In en, this message translates to:
  /// **'Shipment Information'**
  String get shipmentInformation;

  /// No description provided for @dataStorage.
  ///
  /// In en, this message translates to:
  /// **'Data Storage'**
  String get dataStorage;

  /// No description provided for @yourAccountInformation.
  ///
  /// In en, this message translates to:
  /// **'Your Account Information'**
  String get yourAccountInformation;

  /// No description provided for @passwordAccountProtection.
  ///
  /// In en, this message translates to:
  /// **'Password & Account Protection'**
  String get passwordAccountProtection;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
