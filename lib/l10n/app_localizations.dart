import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// **"My Profile"**
  String get myProfile;

  /// **"Verified Tawam Customer"**
  String get verifiedCustomer;

  /// **"Shipments"**
  String get shipments;

  /// **"In Transit"**
  String get inTransit;

  /// **"Quotes"**
  String get quotes;

  /// **"Account Information"**
  String get accountInformation;

  /// **"Email Address"**
  String get emailAddress;

  /// **"Phone Number"**
  String get phoneNumber;

  /// **"Company"**
  String get company;

  /// **"Default Address"**
  String get defaultAddress;

  /// **"Not provided"**
  String get notProvided;

  /// **"Preferences"**
  String get preferences;

  /// **"Push Notifications"**
  String get pushNotifications;

  /// **"General application notifications"**
  String get pushNotificationsSubtitle;

  /// **"Shipment Updates"**
  String get shipmentUpdates;

  /// **"Status and delivery notifications"**
  String get shipmentUpdatesSubtitle;

  /// **"Language"**
  String get language;

  /// **"Security & Account"**
  String get securityAccount;

  /// **"Biometric Sign In"**
  String get biometricSignIn;

  /// **"Use fingerprint or Face ID"**
  String get biometricSubtitle;

  /// **"Change Password"**
  String get changePassword;

  /// **"Update your account password"**
  String get changePasswordSubtitle;

  /// **"Shipping Documents"**
  String get shippingDocuments;

  /// **"View invoices and shipment files"**
  String get shippingDocumentsSubtitle;

  /// **"Support & Legal"**
  String get supportLegal;

  /// **"Help Center"**
  String get helpCenter;

  /// **"Privacy Policy"**
  String get privacyPolicy;

  /// **"Terms & Conditions"**
  String get termsConditions;

  /// **"Sign Out"**
  String get signOut;

  /// **"Cancel"**
  String get cancel;

  /// **"Update"**
  String get update;

  /// **"Done"**
  String get done;

  /// **"Try Again"**
  String get tryAgain;

  /// **"Try again"**
  String get tryAgainLower;

  /// **"Delete"**
  String get delete;

  /// **"Confirm"**
  String get confirm;

  /// **"Save"**
  String get save;

  /// **"Next"**
  String get next;

  /// **"Submit"**
  String get submit;

  /// **"Loading..."**
  String get loading;

  /// **"Optional"**
  String get optional;

  /// **"Not specified"**
  String get notSpecified;

  /// **"Verified"**
  String get verified;

  /// **"Home"**
  String get home;

  /// **"Track"**
  String get track;

  /// **"Support"**
  String get support;

  /// **"Profile"**
  String get profile;

  /// **"Documents"**
  String get documents;

  /// **"Phone"**
  String get phone;

  /// **"Address"**
  String get address;

  /// **"Origin"**
  String get origin;

  /// **"Destination"**
  String get destination;

  /// **"Pickup"**
  String get pickup;

  /// **"Delivery"**
  String get delivery;

  /// **"Cargo"**
  String get cargo;

  /// **"Weight"**
  String get weight;

  /// **"Quantity"**
  String get quantity;

  /// **"Length"**
  String get length;

  /// **"Width"**
  String get width;

  /// **"Height"**
  String get height;

  /// **"From"**
  String get from;

  /// **"To"**
  String get to;

  /// **"All"**
  String get all;

  /// **"Unread"**
  String get unread;

  /// **"Today"**
  String get today;

  /// **"Yesterday"**
  String get yesterday;

  /// **"Earlier"**
  String get earlier;

  /// **"LIVE"**
  String get live;

  /// **"NEW"**
  String get newBadge;

  /// **"Secure"**
  String get secure;

  /// **"Global"**
  String get global;

  /// **"Expert Team"**
  String get expertTeam;

  /// **"Tawam Customer"**
  String get tawamCustomer;

  /// **"TAWAM AL-SHAHIN TRANSPORT"**
  String get tawamAlShahinTransport;

  /// **"Customer Account"**
  String get customerAccount;

  /// **"CUSTOMER ID"**
  String get customerId;

  /// **"ACTIVE CUSTOMER"**
  String get activeCustomer;

  /// **"Signed-in customer"**
  String get signedInCustomer;

  /// **"Contact Phone"**
  String get contactPhone;

  /// **"Full name"**
  String get fullName;

  /// **"Email address"**
  String get emailAddressHint;

  /// **"Something went wrong. Please try again."**
  String get somethingWentWrong;

  /// **"Please sign in again."**
  String get pleaseSignInAgain;

  /// **"Please check your internet connection."**
  String get pleaseCheckConnection;

  /// **"Please check your connection and try again."**
  String get pleaseCheckConnectionTryAgain;

  /// **"Could not open this link."**
  String get couldNotOpenLink;

  /// **"Could not open our website."**
  String get couldNotOpenWebsite;

  /// **"Could not open Google reviews."**
  String get couldNotOpenReviews;

  /// **"Too many attempts. Please try again later"**
  String get tooManyAttempts;

  /// **"Please enter a valid email address"**
  String get pleaseEnterValidEmail;

  /// **"Please enter your email address"**
  String get pleaseEnterEmail;

  /// **"Please enter your full name"**
  String get pleaseEnterFullName;

  /// **"Please enter a valid name"**
  String get pleaseEnterValidName;

  /// **"Please enter your phone number"**
  String get pleaseEnterPhone;

  /// **"Please enter a valid phone number"**
  String get pleaseEnterValidPhone;

  /// **"Please create a password"**
  String get pleaseCreatePassword;

  /// **"Please confirm your password"**
  String get pleaseConfirmPassword;

  /// **"Please enter your password"**
  String get pleaseEnterPassword;

  /// **"Please enter origin"**
  String get pleaseEnterOrigin;

  /// **"Please enter destination"**
  String get pleaseEnterDestination;

  /// **"Please enter pickup location"**
  String get pleaseEnterPickupLocation;

  /// **"Please enter delivery location"**
  String get pleaseEnterDeliveryLocation;

  /// **"Please enter cargo type"**
  String get pleaseEnterCargoType;

  /// **"Please enter phone number"**
  String get pleaseEnterPhoneNumber;

  /// **"Please complete the required information."**
  String get pleaseCompleteRequired;

  /// **"Please sign in before requesting a quote."**
  String get pleaseSignInBeforeQuote;

  /// **"Please sign in before creating a booking."**
  String get pleaseSignInBeforeBooking;

  /// **"Please sign in before sending a support request."**
  String get pleaseSignInBeforeSupport;

  /// **"Please sign in before submitting a quote request"**
  String get pleaseSignInBeforeQuoteShort;

  /// **"Please select your preferred pickup date."**
  String get pleaseSelectPickupDate;

  /// **"City, Country"**
  String get cityCountry;

  /// **"Select date"**
  String get selectDate;

  /// **"Select a date"**
  String get selectADate;

  /// **"Enter weight"**
  String get enterWeight;

  /// **"Enter quantity"**
  String get enterQuantity;

  /// **"Cargo Type"**
  String get cargoType;

  /// **"Pickup Location"**
  String get pickupLocation;

  /// **"Delivery Location"**
  String get deliveryLocation;

  /// **"Special Instructions"**
  String get specialInstructions;

  /// **"Additional Notes"**
  String get additionalNotes;

  /// **"Additional Services"**
  String get additionalServices;

  /// **"Contact Details"**
  String get contactDetails;

  /// **"Automatically filled from your account."**
  String get contactFilledFromAccount;

  /// **"Service Mode"**
  String get serviceMode;

  /// **"Door to Door"**
  String get doorToDoor;

  /// **"Standard"**
  String get standard;

  /// **"Express"**
  String get express;

  /// **"Priority"**
  String get priority;

  /// **"Customs Clearance"**
  String get customsClearance;

  /// **"Export Documentation"**
  String get exportDocumentation;

  /// **"Packing"**
  String get packing;

  /// **"Boxes"**
  String get boxes;

  /// **"Pallets"**
  String get pallets;

  /// **"Select ready date"**
  String get selectReadyDate;

  /// **"Gross Weight"**
  String get grossWeight;

  /// **"Number of Pieces"**
  String get numberOfPieces;

  /// **"Package Type"**
  String get packageType;

  /// **"Dangerous Goods"**
  String get dangerousGoods;

  /// **"Cargo Insurance"**
  String get cargoInsurance;

  /// **"Select services"**
  String get selectServices;

  /// **"You can choose more than one."**
  String get youCanChooseMoreThanOne;

  /// **"Dimensions & Weight"**
  String get dimensionsWeight;

  /// **"Actual"**
  String get actual;

  /// **"Volumetric"**
  String get volumetric;

  /// **"Chargeable Weight"**
  String get chargeableWeight;

  /// **"CBM"**
  String get cbm;

  /// **"Reset"**
  String get reset;

  /// **"Clear Search & Filters"**
  String get clearSearchFilters;

  /// **"Mark as read"**
  String get markAsRead;

  /// **"Mark as unread"**
  String get markAsUnread;

  /// **"Delete notification"**
  String get deleteNotification;

  /// **"Read all"**
  String get readAll;

  /// **"Just now"**
  String get justNow;

  /// **"{count} minutes ago"**
  String minutesAgo(int count);

  /// **"{count} hours ago"**
  String hoursAgo(int count);

  /// **"{count} days ago"**
  String daysAgo(int count);

  /// **"Last update: {time}"**
  String lastUpdatePrefix(String time);

  /// **"Awaiting update"**
  String get awaitingUpdate;

  /// **"Location update pending"**
  String get locationUpdatePending;

  /// **"Latest update"**
  String get latestUpdate;

  /// **"Completed"**
  String get completed;

  /// **"Waiting"**
  String get waiting;

  /// **"CURRENT LOCATION"**
  String get currentLocation;

  /// **"EST. DELIVERY"**
  String get estDelivery;

  /// **"Tracking Number"**
  String get trackingNumber;

  /// **"TRACKING NUMBER"**
  String get trackingNumberUpper;

  /// **"PICKUP"**
  String get pickupUpper;

  /// **"DELIVERY"**
  String get deliveryUpper;

  /// **"CARGO"**
  String get cargoUpper;

  /// **"WEIGHT"**
  String get weightUpper;

  /// **"QUANTITY"**
  String get quantityUpper;

  /// **"DIMENSIONS"**
  String get dimensionsUpper;

  /// **"Route Overview"**
  String get routeOverview;

  /// **"Shipment Progress"**
  String get shipmentProgress;

  /// **"TOTAL"**
  String get total;

  /// **"IN TRANSIT"**
  String get inTransitUpper;

  /// **"DELIVERED"**
  String get deliveredUpper;

  /// **"CONFIRMED"**
  String get confirmedUpper;

  /// **"PREPARED"**
  String get preparedUpper;

  /// **"CUSTOMS"**
  String get customsUpper;

  /// **"OUT FOR DELIVERY"**
  String get outForDeliveryUpper;

  /// **"CANCELLED"**
  String get cancelledUpper;

  /// **"PENDING"**
  String get pendingUpper;

  /// **"Application Language"**
  String get applicationLanguage;

  /// **"English"**
  String get languageEnglish;

  /// **"Arabic"**
  String get languageArabic;

  /// **"French"**
  String get languageFrench;

  /// **"Pending"**
  String get statusPending;

  /// **"Confirmed"**
  String get statusConfirmed;

  /// **"Prepared"**
  String get statusPrepared;

  /// **"In Transit"**
  String get statusInTransit;

  /// **"Customs"**
  String get statusCustoms;

  /// **"Out for Delivery"**
  String get statusOutForDelivery;

  /// **"Delivered"**
  String get statusDelivered;

  /// **"Cancelled"**
  String get statusCancelled;

  /// **"New"**
  String get statusNew;

  /// **"In Progress"**
  String get statusInProgress;

  /// **"Resolved"**
  String get statusResolved;

  /// **"Shipment Created"**
  String get timelineCreatedTitle;

  /// **"Shipment information has been registered."**
  String get timelineCreatedDesc;

  /// **"Booking Confirmed"**
  String get timelineConfirmedTitle;

  /// **"Shipment has been confirmed by our operations team."**
  String get timelineConfirmedDesc;

  /// **"Prepared"**
  String get timelinePreparedTitle;

  /// **"Shipment is prepared and ready for movement."**
  String get timelinePreparedDesc;

  /// **"In Transit"**
  String get timelineInTransitTitle;

  /// **"Shipment is moving toward the destination."**
  String get timelineInTransitDesc;

  /// **"Customs Clearance"**
  String get timelineCustomsTitle;

  /// **"Shipment is undergoing border or customs processing."**
  String get timelineCustomsDesc;

  /// **"Out for Delivery"**
  String get timelineOutForDeliveryTitle;

  /// **"Shipment is on the final delivery route."**
  String get timelineOutForDeliveryDesc;

  /// **"Delivered"**
  String get timelineDeliveredTitle;

  /// **"Shipment has been delivered successfully."**
  String get timelineDeliveredDesc;

  /// **"Shipment Cancelled"**
  String get timelineCancelledTitle;

  /// **"This shipment has been cancelled."**
  String get timelineCancelledDesc;

  /// **"Shipment confirmed by operations"**
  String get statusDescConfirmed;

  /// **"Shipment prepared for movement"**
  String get statusDescPrepared;

  /// **"Shipment moving toward destination"**
  String get statusDescInTransit;

  /// **"Shipment under customs processing"**
  String get statusDescCustoms;

  /// **"Shipment on final delivery route"**
  String get statusDescOutForDelivery;

  /// **"Shipment delivered successfully"**
  String get statusDescDelivered;

  /// **"Shipment has been cancelled"**
  String get statusDescCancelled;

  /// **"Shipment awaiting processing"**
  String get statusDescPending;

  /// **"Sea Freight"**
  String get serviceSeaFreight;

  /// **"Air Freight"**
  String get serviceAirFreight;

  /// **"Land Freight"**
  String get serviceLandFreight;

  /// **"Car Shipping"**
  String get serviceCarShipping;

  /// **"International Moving"**
  String get serviceInternationalMoving;

  /// **"Parcel Shipping"**
  String get serviceParcelShipping;

  /// **"Fast & Reliable"**
  String get serviceSeaFreightSubtitle;

  /// **"Global Coverage"**
  String get serviceAirFreightSubtitle;

  /// **"Flexible Solutions"**
  String get serviceLandFreightSubtitle;

  /// **"Safe & Secure"**
  String get serviceCarShippingSubtitle;

  /// **"Door-to-Door"**
  String get serviceMovingSubtitle;

  /// **"Easy Delivery"**
  String get serviceParcelSubtitle;

  /// **"Jan"**
  String get monthJan;

  /// **"Feb"**
  String get monthFeb;

  /// **"Mar"**
  String get monthMar;

  /// **"Apr"**
  String get monthApr;

  /// **"May"**
  String get monthMay;

  /// **"Jun"**
  String get monthJun;

  /// **"Jul"**
  String get monthJul;

  /// **"Aug"**
  String get monthAug;

  /// **"Sep"**
  String get monthSep;

  /// **"Oct"**
  String get monthOct;

  /// **"Nov"**
  String get monthNov;

  /// **"Dec"**
  String get monthDec;

  /// **"SIGN IN"**
  String get signIn;

  /// **"Welcome back"**
  String get welcomeBack;

  /// **"Sign in to manage your shipments, track deliveries and receive important updates."**
  String get signInSubtitle;

  /// **"Password"**
  String get password;

  /// **"Forgot password?"**
  String get forgotPassword;

  /// **"Create account"**
  String get createAccount;

  /// **"Email or password is incorrect"**
  String get emailOrPasswordIncorrect;

  /// **"This account has been disabled"**
  String get accountDisabled;

  /// **"Account created successfully"**
  String get accountCreated;

  /// **"Could not create account"**
  String get couldNotCreateAccount;

  /// **"Create your account"**
  String get registerTitle;

  /// **"Join TAWAM to manage shipments, quotes and deliveries from one place."**
  String get registerSubtitle;

  /// **"Confirm password"**
  String get confirmPassword;

  /// **"Passwords do not match"**
  String get passwordsDoNotMatch;

  /// **"Password must be at least 6 characters"**
  String get passwordTooShort;

  /// **"Already have an account? Sign in"**
  String get alreadyHaveAccount;

  /// **"RESET PASSWORD"**
  String get resetPassword;

  /// **"Forgot your password?"**
  String get forgotYourPassword;

  /// **"Enter your email address and we will send you a link to reset your password."**
  String get forgotPasswordSubtitle;

  /// **"Send Reset Link"**
  String get sendResetLink;

  /// **"Back to Sign In"**
  String get backToSignIn;

  /// **"Password reset link sent. Please check your email."**
  String get resetLinkSent;

  /// **"Unable to send reset link. Please try again."**
  String get unableToSendReset;

  /// **"If an account exists for this email, a reset link has been sent."**
  String get resetLinkIfExists;

  /// **"Quick Actions"**
  String get quickActions;

  /// **"Manage your shipments and requests"**
  String get quickActionsSubtitle;

  /// **"Get a Quote"**
  String get getAQuote;

  /// **"Create a Booking"**
  String get createABooking;

  /// **"Volume Calculator"**
  String get volumeCalculator;

  /// **"Shipment Tracking"**
  String get shipmentTracking;

  /// **"My Quotes"**
  String get myQuotes;

  /// **"My Bookings"**
  String get myBookings;

  /// **"Shipping Services"**
  String get shippingServices;

  /// **"Request a new shipping quotation"**
  String get requestNewQuotation;

  /// **"View your quotation history"**
  String get viewQuotationHistory;

  /// **"Create a new shipment booking"**
  String get createNewBooking;

  /// **"Manage previous bookings"**
  String get managePreviousBookings;

  /// **"Shipment Management"**
  String get shipmentManagement;

  /// **"Calculate cargo volume"**
  String get calculateCargoVolume;

  /// **"Track your shipment status"**
  String get trackShipmentStatus;

  /// **"My Shipments"**
  String get myShipments;

  /// **"View all active shipments"**
  String get viewAllActiveShipments;

  /// **"Shipping and account documents"**
  String get shippingAndAccountDocuments;

  /// **"Customer Reviews"**
  String get customerReviews;

  /// **"See what our customers say"**
  String get seeWhatCustomersSay;

  /// **"Our Website"**
  String get ourWebsite;

  /// **"Visit TAWAM AL-SHAHIN online"**
  String get visitTawamOnline;

  /// **"Account & Support"**
  String get accountAndSupport;

  /// **"Contact our logistics support team"**
  String get contactLogisticsSupport;

  /// **"My Account"**
  String get myAccount;

  /// **"Profile and account settings"**
  String get profileAndSettings;

  /// **"Log Out"**
  String get logOut;

  /// **"Are you sure you want to log out?"**
  String get logOutConfirm;

  /// **"LOG OUT"**
  String get logOutUpper;

  /// **"CANCEL"**
  String get cancelUpper;

  /// **"SOCIAL MEDIA"**
  String get socialMedia;

  /// **"Rate Request"**
  String get rateRequest;

  /// **"Get an instant quote for your shipment"**
  String get rateRequestSubtitle;

  /// **"Request Rate"**
  String get requestRate;

  /// **"Request a shipping rate for this service."**
  String get requestRateForService;

  /// **"{service} rate request will be connected next."**
  String rateRequestWillConnect(String service);

  /// **"Edit Profile"**
  String get editProfile;

  /// **"CUSTOMER PROFILE"**
  String get customerProfile;

  /// **"Customer Details"**
  String get customerDetails;

  /// **"ACCOUNT CONTROL"**
  String get accountControl;

  /// **"Account"**
  String get account;

  /// **"CUSTOMER SERVICES"**
  String get customerServices;

  /// **"Assistance"**
  String get assistance;

  /// **"Shipping files"**
  String get shippingFiles;

  /// **"Customer help"**
  String get customerHelp;

  /// **"Account & Legal"**
  String get accountAndLegal;

  /// **"Privacy, terms and account management"**
  String get accountLegalSubtitle;

  /// **"How we protect your information"**
  String get privacySubtitle;

  /// **"TAWAM application terms"**
  String get termsSubtitle;

  /// **"Delete Account"**
  String get deleteAccount;

  /// **"Permanently remove your customer account"**
  String get deleteAccountSubtitle;

  /// **"Notifications"**
  String get notifications;

  /// **"Account and service updates"**
  String get accountServiceUpdates;

  /// **"Update account security"**
  String get updateAccountSecurity;

  /// **"Securely end your current session"**
  String get signOutSubtitle;

  /// **"Unable to load profile"**
  String get unableToLoadProfile;

  /// **"Unable to load profile information."**
  String get unableToLoadProfileInfo;

  /// **"Could not update profile"**
  String get couldNotUpdateProfile;

  /// **"Change profile photo"**
  String get changeProfilePhoto;

  /// **"Take a photo or choose from gallery"**
  String get changeProfilePhotoHint;

  /// **"Take photo"**
  String get takePhoto;

  /// **"Use your camera"**
  String get takePhotoHint;

  /// **"Choose from gallery"**
  String get chooseFromGallery;

  /// **"Select an existing photo"**
  String get chooseFromGalleryHint;

  /// **"Remove photo"**
  String get removePhoto;

  /// **"Return to the default avatar"**
  String get removePhotoHint;

  /// **"Profile photo updated"**
  String get profilePhotoUpdated;

  /// **"Profile photo removed"**
  String get profilePhotoRemoved;

  /// **"Could not update profile photo"**
  String get couldNotUpdatePhoto;

  /// **"Could not access the camera"**
  String get couldNotAccessCamera;

  /// **"Could not access your photos"**
  String get couldNotAccessPhotos;

  /// **"Could not verify your account"**
  String get couldNotVerifyAccount;

  /// **"Sign Out?"**
  String get signOutQuestion;

  /// **"You will need to sign in again to access your shipments."**
  String get signOutConfirmBody;

  /// **"Notification Center"**
  String get notificationCenter;

  /// **"Notification"**
  String get notificationDefault;

  /// **"Notification deleted"**
  String get notificationDeleted;

  /// **"No unread notifications"**
  String get noUnreadNotifications;

  /// **"All notifications marked as read"**
  String get allMarkedAsRead;

  /// **"Shipment could not be found."**
  String get shipmentNotFoundShort;

  /// **"Could not open shipment details."**
  String get couldNotOpenShipmentDetails;

  /// **"Unable to load notifications"**
  String get unableToLoadNotifications;

  /// **"We couldn't load your notifications. Please check your connection and try again."**
  String get couldNotLoadNotifications;

  /// **"No notifications yet"**
  String get noNotificationsYet;

  /// **"Live notification status"**
  String get liveNotificationStatus;

  /// **"Shipment update"**
  String get notifShipmentInTransitTitle;

  /// **"Shipment {trackingNumber} is now in transit."**
  String notifShipmentInTransitBody(String trackingNumber);

  /// **"Shipment delivered"**
  String get notifShipmentDeliveredTitle;

  /// **"Shipment {trackingNumber} has been delivered."**
  String notifShipmentDeliveredBody(String trackingNumber);

  /// **"Out for delivery"**
  String get notifShipmentOutForDeliveryTitle;

  /// **"Shipment {trackingNumber} is out for delivery."**
  String notifShipmentOutForDeliveryBody(String trackingNumber);

  /// **"Quote ready"**
  String get notifQuoteReadyTitle;

  /// **"Your quotation is ready to review."**
  String get notifQuoteReadyBody;

  /// **"Support reply"**
  String get notifSupportReplyTitle;

  /// **"You have a new reply on your support request."**
  String get notifSupportReplyBody;

  /// **"Shipment confirmed"**
  String get notifShipmentConfirmedTitle;

  /// **"Shipment {trackingNumber} has been confirmed."**
  String notifShipmentConfirmedBody(String trackingNumber);

  /// **"Customs update"**
  String get notifShipmentCustomsTitle;

  /// **"Shipment {trackingNumber} is in customs clearance."**
  String notifShipmentCustomsBody(String trackingNumber);

  /// **"Update"**
  String get notifGenericTitle;

  /// **"Unable to load shipments"**
  String get unableToLoadShipments;

  /// **"LIVE CUSTOMER SHIPMENT PORTAL"**
  String get liveCustomerShipmentPortal;

  /// **"Your Shipping Network"**
  String get yourShippingNetwork;

  /// **"Monitor every active and completed shipment from one secure place."**
  String get monitorShipmentsSubtitle;

  /// **"Search tracking number, route or cargo"**
  String get searchTrackingRouteCargo;

  /// **"Shipment Portfolio"**
  String get shipmentPortfolio;

  /// **"Select a shipment to view full details."**
  String get selectShipmentDetails;

  /// **"No matching shipments"**
  String get noMatchingShipments;

  /// **"No shipments yet"**
  String get noShipmentsYet;

  /// **"We could not find any shipments matching your current search or filter."**
  String get noMatchingShipmentsBody;

  /// **"Your shipments will appear here as soon as they are created by our operations team."**
  String get noShipmentsYetBody;

  /// **"Shipment"**
  String get shipment;

  /// **"We couldn't load your shipments. Please check your connection and try again."**
  String get couldNotLoadShipments;

  /// **"Shipment Details"**
  String get shipmentDetails;

  /// **"LIVE SHIPMENT RECORD"**
  String get liveShipmentRecord;

  /// **"Live Shipment Map"**
  String get liveShipmentMap;

  /// **"LAST KNOWN LOCATION"**
  String get lastKnownLocation;

  /// **"Updating live location..."**
  String get updatingLiveLocation;

  /// **"Location temporarily unavailable"**
  String get locationTemporarilyUnavailable;

  /// **"Complete logistics details for this shipment."**
  String get completeLogisticsDetails;

  /// **"Shipment Journey"**
  String get shipmentJourney;

  /// **"Live milestones and status history."**
  String get liveMilestones;

  /// **"Need shipment support?"**
  String get needShipmentSupport;

  /// **"Our logistics team is ready to assist you."**
  String get logisticsTeamReady;

  /// **"Shipment Update"**
  String get shipmentUpdate;

  /// **"Shipment status updated."**
  String get shipmentStatusUpdated;

  /// **"Please enter your tracking number."**
  String get pleaseEnterTrackingNumber;

  /// **"Please sign in to track your shipment."**
  String get pleaseSignInToTrack;

  /// **"Shipment not found. Please check the tracking number."**
  String get shipmentNotFoundCheck;

  /// **"This shipment is no longer available."**
  String get shipmentNoLongerAvailable;

  /// **"Live tracking connection was interrupted."**
  String get liveTrackingInterrupted;

  /// **"Could not track shipment. Please try again."**
  String get couldNotTrackShipment;

  /// **"QR code scanning will be available soon."**
  String get qrScanningSoon;

  /// **"LIVE SHIPMENT VISIBILITY"**
  String get liveShipmentVisibility;

  /// **"Track Every Move"**
  String get trackEveryMove;

  /// **"Enter your tracking number to view the latest status, location and shipment journey."**
  String get trackEveryMoveSubtitle;

  /// **"Private"**
  String get private;

  /// **"Live Updates"**
  String get liveUpdates;

  /// **"Only shipments assigned to your account can be displayed."**
  String get onlyAssignedShipments;

  /// **"Enter tracking number"**
  String get enterTrackingNumber;

  /// **"TRACKING..."**
  String get trackingInProgress;

  /// **"TRACK SHIPMENT"**
  String get trackShipment;

  /// **"Professional Shipment Visibility"**
  String get professionalVisibility;

  /// **"Your tracking view is protected and connected directly to your shipment record."**
  String get trackingViewProtected;

  /// **"Location"**
  String get location;

  /// **"Timeline"**
  String get timeline;

  /// **"Shipment journey"**
  String get shipmentJourneyShort;

  /// **"ETA details"**
  String get etaDetails;

  /// **"LIVE TRACKING"**
  String get liveTracking;

  /// **"Shipment Timeline"**
  String get shipmentTimeline;

  /// **"Latest milestones from your shipment journey."**
  String get latestMilestones;

  /// **"VIEW FULL SHIPMENT DETAILS"**
  String get viewFullShipmentDetails;

  /// **"Get a Quote"**
  String get getAQuoteTitle;

  /// **"Request Your Best Rate"**
  String get requestYourBestRate;

  /// **"Tell us about your shipment and our logistics team will prepare a tailored quotation."**
  String get quoteHeroSubtitle;

  /// **"Shipping Service"**
  String get shippingService;

  /// **"Choose the service that fits your shipment"**
  String get chooseServiceFits;

  /// **"Route"**
  String get route;

  /// **"Where is your shipment moving from and to?"**
  String get whereShipmentMoving;

  /// **"Shipment Details"**
  String get shipmentDetailsSection;

  /// **"Tell us about your cargo"**
  String get tellUsAboutCargo;

  /// **"Select your preferred pickup date"**
  String get selectPreferredPickup;

  /// **"Add any special instructions for our team"**
  String get addSpecialInstructions;

  /// **"Our team will review your request and send you the best available rate."**
  String get teamWillReviewRate;

  /// **"Preferred Pickup Date"**
  String get preferredPickupDate;

  /// **"Dimensions (optional)"**
  String get dimensionsOptional;

  /// **"Dimensions are recorded in centimeters (CM)."**
  String get dimensionsInCm;

  /// **"Special handling, customs information, vehicle details, packing notes, or anything else we should know..."**
  String get specialHandlingHint;

  /// **"Secure Request"**
  String get secureRequest;

  /// **"Best Rate"**
  String get bestRate;

  /// **"Expert Support"**
  String get expertSupport;

  /// **"SUBMIT QUOTE REQUEST"**
  String get submitQuoteRequest;

  /// **"Please complete the required shipment information."**
  String get pleaseCompleteShipmentInfo;

  /// **"Could not submit your quote request."**
  String get couldNotSubmitQuote;

  /// **"Could not submit quote request. Please try again."**
  String get couldNotSubmitQuoteRetry;

  /// **"Quote Request Submitted"**
  String get quoteRequestSubmitted;

  /// **"Your request has been sent to TAWAM AL-SHAHIN TRANSPORT."**
  String get quoteSentToTawam;

  /// **"REFERENCE"**
  String get reference;

  /// **"SELECT PICKUP DATE"**
  String get selectPickupDate;

  /// **"Create a Booking"**
  String get createBookingTitle;

  /// **"GLOBAL BOOKING DESK"**
  String get globalBookingDesk;

  /// **"Schedule Your Shipment"**
  String get scheduleYourShipment;

  /// **"Book with our logistics team and let TAWAM coordinate your shipment from pickup to delivery."**
  String get bookingHeroSubtitle;

  /// **"Select Service"**
  String get selectService;

  /// **"Choose how you would like us to move your shipment."**
  String get chooseHowToMove;

  /// **"Route & Schedule"**
  String get routeAndSchedule;

  /// **"Tell our operations team where and when to collect your cargo."**
  String get tellOperationsWhereWhen;

  /// **"Provide the cargo information needed to prepare your booking."**
  String get provideCargoForBooking;

  /// **"Contact & Instructions"**
  String get contactAndInstructions;

  /// **"Your account details are securely attached to this booking."**
  String get accountAttachedToBooking;

  /// **"Your request will be reviewed by the TAWAM operations team."**
  String get bookingReviewedByOps;

  /// **"Morning"**
  String get morning;

  /// **"Afternoon"**
  String get afternoon;

  /// **"Evening"**
  String get evening;

  /// **"Flexible"**
  String get flexible;

  /// **"Pickup Date"**
  String get pickupDate;

  /// **"Vehicle, General Cargo, Furniture..."**
  String get vehicleGeneralCargoHint;

  /// **"Pickup access, packing notes, customs information or anything our team should know..."**
  String get pickupAccessHint;

  /// **"Secure Booking"**
  String get secureBooking;

  /// **"Professional Care"**
  String get professionalCare;

  /// **"CONFIRM BOOKING"**
  String get confirmBooking;

  /// **"Please complete the required booking information."**
  String get pleaseCompleteBooking;

  /// **"Unable to submit your booking."**
  String get unableToSubmitBooking;

  /// **"Booking Request Submitted"**
  String get bookingRequestSubmitted;

  /// **"Your booking has been sent securely to TAWAM AL-SHAHIN TRANSPORT for review."**
  String get bookingSentToTawam;

  /// **"BOOKING REFERENCE"**
  String get bookingReference;

  /// **"PENDING CONFIRMATION"**
  String get pendingConfirmation;

  /// **"Document"**
  String get document;

  /// **"Document path is missing."**
  String get documentPathMissing;

  /// **"Could not open document: {error}"**
  String couldNotOpenDocument(String error);

  /// **"Could not load documents"**
  String get couldNotLoadDocuments;

  /// **"No documents yet"**
  String get noDocumentsYet;

  /// **"Your invoices, shipment documents and delivery files will appear here."**
  String get documentsEmptyBody;

  /// **"Could not load image"**
  String get couldNotLoadImage;

  /// **"Customer Support"**
  String get customerSupport;

  /// **"LOGISTICS SUPPORT CENTER"**
  String get logisticsSupportCenter;

  /// **"How Can We Help?"**
  String get howCanWeHelp;

  /// **"Professional assistance for shipments, quotations, customs and delivery requests."**
  String get supportHeroSubtitle;

  /// **"Connected"**
  String get connected;

  /// **"Protected request"**
  String get protectedRequest;

  /// **"Specialists"**
  String get specialists;

  /// **"Logistics team"**
  String get logisticsTeam;

  /// **"Tracked"**
  String get tracked;

  /// **"Case submitted"**
  String get caseSubmitted;

  /// **"Instant Assistance"**
  String get instantAssistance;

  /// **"Choose the fastest channel for your request."**
  String get chooseFastestChannel;

  /// **"WhatsApp"**
  String get whatsapp;

  /// **"Start chat"**
  String get startChat;

  /// **"Call"**
  String get call;

  /// **"Call support"**
  String get callSupport;

  /// **"Email"**
  String get email;

  /// **"Send email"**
  String get sendEmail;

  /// **"Open a Support Case"**
  String get openSupportCase;

  /// **"Send your request directly to our operations team."**
  String get sendRequestToOps;

  /// **"Frequently Asked Questions"**
  String get faq;

  /// **"Quick answers to common logistics questions."**
  String get faqSubtitle;

  /// **"Where can I find my tracking number?"**
  String get faqTrackingQ;

  /// **"Your tracking number is included in your shipment confirmation and can also be found in My Shipments."**
  String get faqTrackingA;

  /// **"Why has my shipment status not changed?"**
  String get faqStatusQ;

  /// **"Tracking updates may appear after your shipment reaches the next logistics checkpoint or after an operations update."**
  String get faqStatusA;

  /// **"How do I request a shipping quotation?"**
  String get faqQuoteQ;

  /// **"Open Get a Quote from the home page and submit your shipment details."**
  String get faqQuoteA;

  /// **"Can I update my delivery information?"**
  String get faqDeliveryQ;

  /// **"Contact support and include your tracking number together with the new delivery information."**
  String get faqDeliveryA;

  /// **"My Support Requests"**
  String get mySupportRequests;

  /// **"View your cases and latest updates"**
  String get viewCasesAndUpdates;

  /// **"Support Request"**
  String get supportRequest;

  /// **"Provide the details below."**
  String get provideDetailsBelow;

  /// **"Support category"**
  String get supportCategory;

  /// **"Tracking / shipment number — optional"**
  String get trackingOptional;

  /// **"Please describe your request"**
  String get pleaseDescribeRequest;

  /// **"Please add more details"**
  String get pleaseAddMoreDetails;

  /// **"Describe the issue or assistance you need..."**
  String get describeIssueHint;

  /// **"For shipment-related requests, include the tracking number to help our team review the case faster."**
  String get includeTrackingHint;

  /// **"SUBMITTING..."**
  String get submitting;

  /// **"SUBMIT SUPPORT REQUEST"**
  String get submitSupportRequest;

  /// **"Support Hours"**
  String get supportHours;

  /// **"Monday – Friday"**
  String get mondayFriday;

  /// **"Saturday"**
  String get saturday;

  /// **"Sunday"**
  String get sunday;

  /// **"Emergency support"**
  String get emergencySupport;

  /// **"Times shown in UAE local time."**
  String get timesUae;

  /// **"Could not open WhatsApp."**
  String get couldNotOpenWhatsapp;

  /// **"Could not open the phone app."**
  String get couldNotOpenPhone;

  /// **"Could not open the email app."**
  String get couldNotOpenEmail;

  /// **"Could not send your support request. Please try again."**
  String get couldNotSendSupport;

  /// **"Request Successfully Sent"**
  String get requestSuccessfullySent;

  /// **"Your support case has been securely submitted to the TAWAM operations team."**
  String get supportCaseSubmitted;

  /// **"REQUEST CATEGORY"**
  String get requestCategory;

  /// **"Shipment Tracking"**
  String get catShipmentTracking;

  /// **"Delivery Delay"**
  String get catDeliveryDelay;

  /// **"Request a Quote"**
  String get catRequestQuote;

  /// **"Customs Clearance"**
  String get catCustoms;

  /// **"Payment & Invoice"**
  String get catPaymentInvoice;

  /// **"Damaged Shipment"**
  String get catDamagedShipment;

  /// **"General Inquiry"**
  String get catGeneralInquiry;

  /// **"Hello TAWAM AL-SHAHIN TRANSPORT, I need assistance."**
  String get whatsappPrefill;

  /// **"TAWAM AL-SHAHIN TRANSPORT Support Request"**
  String get supportEmailSubject;

  /// **"Request Shipment"**
  String get requestShipment;

  /// **"New Shipment Request"**
  String get newShipmentRequest;

  /// **"Send your shipment details for review by our logistics team."**
  String get sendShipmentForReview;

  /// **"Example: Dubai, UAE"**
  String get exampleDubai;

  /// **"Enter pickup location"**
  String get enterPickupLocation;

  /// **"Example: Amman, Jordan"**
  String get exampleAmman;

  /// **"Enter delivery location"**
  String get enterDeliveryLocation;

  /// **"Describe the shipment"**
  String get describeShipment;

  /// **"Enter cargo details"**
  String get enterCargoDetails;

  /// **"Expected Delivery"**
  String get expectedDelivery;

  /// **"Select preferred date"**
  String get selectPreferredDate;

  /// **"Special handling, dimensions, vehicle type..."**
  String get specialHandlingDimensions;

  /// **"Your request will be reviewed by Tawam logistics. A shipment and tracking number will only be created after approval."**
  String get requestReviewedAfterApproval;

  /// **"Submit Shipment Request"**
  String get submitShipmentRequest;

  /// **"Shipment request submitted successfully."**
  String get shipmentRequestSubmitted;

  /// **"Could not submit shipment request: {error}"**
  String couldNotSubmitShipmentRequest(String error);

  /// **"Customer"**
  String get customer;

  /// **"Please enter the cargo dimensions first."**
  String get pleaseEnterDimensionsFirst;

  /// **"Cargo Dimensions"**
  String get cargoDimensions;

  /// **"Enter one package size in centimeters and the total quantity."**
  String get enterPackageSizeQty;

  /// **"Calculation Results"**
  String get calculationResults;

  /// **"Instant logistics measurements for planning your shipment."**
  String get instantMeasurements;

  /// **"REQUEST A QUOTE"**
  String get requestAQuote;

  /// **"LOGISTICS CALCULATION TOOL"**
  String get logisticsCalculationTool;

  /// **"Plan Your Cargo Smarter"**
  String get planCargoSmarter;

  /// **"Calculate CBM and volumetric weight instantly before requesting your shipping quotation."**
  String get volumeHeroSubtitle;

  /// **"Instant"**
  String get instant;

  /// **"Accurate"**
  String get accurate;

  /// **"Logistics Ready"**
  String get logisticsReady;

  /// **"Actual Total Weight"**
  String get actualTotalWeight;

  /// **"Enter the dimensions of one package. Quantity is applied automatically to the total calculation."**
  String get enterOnePackageHint;

  /// **"Enter your cargo dimensions"**
  String get enterCargoDimensions;

  /// **"Your shipping calculation will appear here instantly."**
  String get calculationAppearsHere;

  /// **"TOTAL SHIPMENT VOLUME"**
  String get totalShipmentVolume;

  /// **"Cubic volume based on the entered dimensions and quantity."**
  String get cubicVolumeBased;

  /// **"Air Vol. Weight"**
  String get airVolWeight;

  /// **"Divisor 6000"**
  String get divisor6000;

  /// **"Courier Vol. Weight"**
  String get courierVolWeight;

  /// **"Divisor 5000"**
  String get divisor5000;

  /// **"Estimated Air Chargeable Weight"**
  String get estimatedAirChargeable;

  /// **"Higher of actual total weight and air volumetric weight"**
  String get higherOfActualAir;

  /// **"RESET CALCULATOR"**
  String get resetCalculator;

  /// **"OFFICIAL RATE REQUEST"**
  String get officialRateRequest;

  /// **"Shipment Route"**
  String get shipmentRoute;

  /// **"Tell us where your cargo is moving."**
  String get tellUsWhereMoving;

  /// **"Cargo Information"**
  String get cargoInformation;

  /// **"Provide your cargo specifications."**
  String get provideCargoSpecs;

  /// **"Anything our team should know?"**
  String get anythingTeamShouldKnow;

  /// **"Your shipment information is securely submitted to our logistics team."**
  String get infoSubmittedSecurely;

  /// **"SUBMIT QUOTE"**
  String get submitQuote;

  /// **"DONE"**
  String get doneUpper;

  /// **"Air Freight Quote"**
  String get airFreightQuote;

  /// **"GLOBAL AIR CARGO"**
  String get globalAirCargo;

  /// **"Fast Cargo.\nGlobal Reach."**
  String get fastCargoGlobalReach;

  /// **"Professional air freight solutions for urgent, commercial and international cargo."**
  String get airHeroSubtitle;

  /// **"Air Freight Service"**
  String get airFreightService;

  /// **"Choose the service level for your shipment."**
  String get chooseServiceLevel;

  /// **"We calculate volumetric and chargeable weight automatically."**
  String get weCalculateVolumetric;

  /// **"Add optional logistics services if required."**
  String get addOptionalLogistics;

  /// **"Anything our air freight team should know?"**
  String get anythingAirTeam;

  /// **"Airport to Airport"**
  String get airportToAirport;

  /// **"Door to Airport"**
  String get doorToAirport;

  /// **"Airport to Door"**
  String get airportToDoor;

  /// **"Loose Cargo"**
  String get looseCargo;

  /// **"Crates"**
  String get crates;

  /// **"Airport, city or pickup location"**
  String get airportCityPickup;

  /// **"Airport, city or delivery location"**
  String get airportCityDelivery;

  /// **"Cargo Ready Date"**
  String get cargoReadyDate;

  /// **"Standard Air Freight"**
  String get standardAirFreight;

  /// **"Reliable international air cargo for regular shipments."**
  String get standardAirDesc;

  /// **"Express Air Freight"**
  String get expressAirFreight;

  /// **"Faster handling for urgent and time-sensitive cargo."**
  String get expressAirDesc;

  /// **"Priority / Time Critical"**
  String get priorityTimeCritical;

  /// **"Priority handling for highly urgent shipments."**
  String get priorityAirDesc;

  /// **"Please enter gross weight"**
  String get pleaseEnterGrossWeight;

  /// **"Enter number of pieces"**
  String get enterNumberOfPieces;

  /// **"Average Piece Dimensions"**
  String get averagePieceDimensions;

  /// **"Enter dimensions in centimeters."**
  String get enterDimensionsCm;

  /// **"AUTOMATIC AIR FREIGHT CALCULATION"**
  String get automaticAirCalc;

  /// **"Cargo volume: {volume} CBM"**
  String cargoVolumeCbm(String volume);

  /// **"Cargo classified as hazardous / DG."**
  String get dgHint;

  /// **"Request cargo insurance with the quotation."**
  String get requestInsuranceHint;

  /// **"Priority Cargo"**
  String get priorityCargo;

  /// **"Sea Freight Quote"**
  String get seaFreightQuote;

  /// **"Land Freight Quote"**
  String get landFreightQuote;

  /// **"Car Shipping Quote"**
  String get carShippingQuote;

  /// **"Moving Quote"**
  String get movingQuote;

  /// **"Parcel Quote"**
  String get parcelQuote;

  /// **"Port to Port"**
  String get portToPort;

  /// **"Door to Port"**
  String get doorToPort;

  /// **"Port to Door"**
  String get portToDoor;

  /// **"Open Carrier"**
  String get openCarrier;

  /// **"Select ready date"**
  String get selectReadyDateShort;

  /// **"Terms of Service"**
  String get termsOfService;

  /// **"Please review the terms governing your use of the TAWAM AL-SHAHIN TRANSPORT mobile application and services."**
  String get reviewTermsSubtitle;

  /// **"About Our Services"**
  String get aboutOurServices;

  /// **"Customer Accounts"**
  String get customerAccounts;

  /// **"Account Security"**
  String get accountSecurity;

  /// **"Shipment Services"**
  String get shipmentServices;

  /// **"Quotations"**
  String get quotations;

  /// **"Restricted or Prohibited Items"**
  String get restrictedItems;

  /// **"Transit & Delivery"**
  String get transitDelivery;

  /// **"Charges & Payments"**
  String get chargesPayments;

  /// **"Acceptable Use"**
  String get acceptableUse;

  /// **"Application Availability"**
  String get applicationAvailability;

  /// **"Changes to These Terms"**
  String get changesToTerms;

  /// **"Contact Us"**
  String get contactUs;

  /// **"Transportation • Logistics • Shipment Services"**
  String get transportLogisticsServices;

  /// **"Last updated: August 2026"**
  String get lastUpdatedAugust2026;

  /// **"Learn how TAWAM AL-SHAHIN TRANSPORT collects, uses and protects your information."**
  String get privacyHeroSubtitle;

  /// **"Information We Collect"**
  String get informationWeCollect;

  /// **"How We Use Information"**
  String get howWeUseInformation;

  /// **"Service Communications"**
  String get serviceCommunications;

  /// **"Data Sharing"**
  String get dataSharing;

  /// **"Data Retention"**
  String get dataRetention;

  /// **"Your Rights"**
  String get yourRights;

  /// **"Security Measures"**
  String get securityMeasures;

  /// **"Children’s Privacy"**
  String get childrenPrivacy;

  /// **"Changes to This Policy"**
  String get changesToPolicy;

  /// **"Priced"**
  String get hasPrice;

  /// **"Awaiting price"**
  String get awaitingPrice;

  /// **"Quoted"**
  String get quoted;

  /// **"Accepted"**
  String get accepted;

  /// **"Declined"**
  String get declined;

  /// **"Rejected"**
  String get rejected;

  /// **"REJECTED"**
  String get rejectedUpper;

  /// **"Quote Ready"**
  String get quoteReady;

  /// **"Under Review"**
  String get underReview;

  /// **"Your Quotations"**
  String get yourQuotations;

  /// **"Your Bookings"**
  String get yourBookings;

  /// **"Close"**
  String get close;

  /// **"CLOSE"**
  String get closeUpper;

  /// **"View Details"**
  String get viewDetails;

  /// **"VIEW DETAILS"**
  String get viewDetailsUpper;

  /// **"SHIPMENT NUMBER"**
  String get shipmentNumber;

  /// **"YOUR MESSAGE"**
  String get yourMessage;

  /// **"LATEST STATUS UPDATE"**
  String get latestStatusUpdate;

  /// **"OCEAN FREIGHT"**
  String get oceanFreight;

  /// **"Don’t have an account?"**
  String get dontHaveAccount;

  /// **"Sign In"**
  String get signInButton;

  /// **"Profile updated successfully"**
  String get profileUpdated;

  /// **"Password updated successfully"**
  String get passwordUpdated;

  /// **"Stay informed about your logistics activity"**
  String get stayInformed;

  /// **"Shipment updates, quotations and important account alerts will appear here automatically."**
  String get notificationEmptyHint;

  /// **"Vehicle Information"**
  String get vehicleInformation;

  /// **"Provide the vehicle details required for accurate transport planning."**
  String get vehicleInfoSubtitle;

  /// **"Shipping Method"**
  String get shippingMethod;

  /// **"Vehicle Protection"**
  String get vehicleProtection;

  /// **"Vehicle Type"**
  String get vehicleType;

  /// **"Number of Vehicles"**
  String get numberOfVehicles;

  /// **"Enter number of vehicles"**
  String get enterNumberOfVehicles;

  /// **"Model Year"**
  String get modelYear;

  /// **"Vehicle Condition"**
  String get vehicleCondition;

  /// **"VIN / Chassis Number"**
  String get vinChassis;

  /// **"Vehicle Value"**
  String get vehicleValue;

  /// **"Invalid value"**
  String get invalidValue;

  /// **"Currency"**
  String get currency;

  /// **"Enclosed Carrier"**
  String get enclosedCarrier;

  /// **"RoRo Shipping"**
  String get roroShipping;

  /// **"Container Shipping"**
  String get containerShipping;

  /// **"Move Profile"**
  String get moveProfile;

  /// **"Inventory Estimate"**
  String get inventoryEstimate;

  /// **"Special Items"**
  String get specialItems;

  /// **"Moving Services"**
  String get movingServices;

  /// **"Professional Packing"**
  String get professionalPacking;

  /// **"Property Type"**
  String get propertyType;

  /// **"Elevator"**
  String get elevator;

  /// **"Estimated Boxes"**
  String get estimatedBoxes;

  /// **"Large Items"**
  String get largeItems;

  /// **"Estimated Volume"**
  String get estimatedVolume;

  /// **"Unpacking Service"**
  String get unpackingService;

  /// **"Furniture Disassembly"**
  String get furnitureDisassembly;

  /// **"Temporary Storage"**
  String get temporaryStorage;

  /// **"Transport Type"**
  String get transportType;

  /// **"Cargo Requirements"**
  String get cargoRequirements;

  /// **"Full Truck Load"**
  String get fullTruckLoad;

  /// **"Partial Load"**
  String get partialLoad;

  /// **"Truck / Trailer Type"**
  String get truckTrailerType;

  /// **"Required Temperature"**
  String get requiredTemperature;

  /// **"Oversized / Out-of-Gauge Cargo"**
  String get oversizedCargo;

  /// **"Delivery Service"**
  String get deliveryService;

  /// **"Protection & Delivery"**
  String get protectionAndDelivery;

  /// **"Pickup Method"**
  String get pickupMethod;

  /// **"Number of Parcels"**
  String get numberOfParcels;

  /// **"Parcel Contents"**
  String get parcelContents;

  /// **"Please describe the parcel contents"**
  String get pleaseDescribeParcel;

  /// **"Declared Value"**
  String get declaredValue;

  /// **"Weight per Parcel"**
  String get weightPerParcel;

  /// **"Signature on Delivery"**
  String get signatureOnDelivery;

  /// **"Full Container"**
  String get fullContainer;

  /// **"Shared Cargo"**
  String get sharedCargo;

  /// **"Full Container Load"**
  String get fullContainerLoad;

  /// **"Less Container Load"**
  String get lessContainerLoad;

  /// **"Container Type"**
  String get containerType;

  /// **"Number of Containers"**
  String get numberOfContainers;

  /// **"Enter cargo volume"**
  String get enterCargoVolume;

  /// **"Route Details"**
  String get routeDetails;

  /// **"Please enter the cargo weight"**
  String get pleaseEnterCargoWeight;

  /// **"Please enter a valid weight"**
  String get pleaseEnterValidWeight;

  /// **"Please enter the number of items"**
  String get pleaseEnterNumberOfItems;

  /// **"Please enter a valid quantity"**
  String get pleaseEnterValidQuantity;

  /// **"Cargo description"**
  String get cargoDescription;

  /// **"Weight (kg)"**
  String get weightKg;

  /// **"Pickup Schedule"**
  String get pickupSchedule;

  /// **"Please select a pickup date"**
  String get pleaseSelectAPickupDate;

  /// **"Contact Information"**
  String get contactInformation;

  /// **"Tailored"**
  String get tailored;

  /// **"Supported"**
  String get supported;

  /// **"Shipment Information"**
  String get shipmentInformation;

  /// **"Data Storage"**
  String get dataStorage;

  /// **"Your Account Information"**
  String get yourAccountInformation;

  /// **"Password & Account Protection"**
  String get passwordAccountProtection;

  /// **"Accept"**
  String get accept;

  /// **"Decline"**
  String get decline;

  /// **"GLOBAL LOGISTICS CUSTOMER PORTAL"**
  String get globalLogisticsPortal;

  /// **"Secure • Reliable • Connected"**
  String get secureReliableConnected;

  /// **"REQUEST SUMMARY"**
  String get requestSummary;

  /// **"Please sign in to view your quotations."**
  String get pleaseSignInToViewQuotes;

  /// **"Review rates, shipment details and respond to quotations."**
  String get reviewRatesSubtitle;

  /// **"SECURE CUSTOMER PORTAL"**
  String get secureCustomerPortal;

  /// **"Your Shipping Quotations"**
  String get yourShippingQuotations;

  /// **"Track every quotation from request to final decision in one secure place."**
  String get trackEveryQuotation;

  /// **"QUOTED PRICE"**
  String get quotedPrice;

  /// **"RATE STATUS"**
  String get rateStatus;

  /// **"Quotation"**
  String get quotation;

  /// **"MESSAGE FROM OUR TEAM"**
  String get messageFromOurTeam;

  /// **"Our quotation team is reviewing your shipment. Your final rate will appear here once ready."**
  String get quoteTeamReviewing;

  /// **"Dimensions"**
  String get dimensions;

  /// **"Requested On"**
  String get requestedOn;

  /// **"No additional notes"**
  String get noAdditionalNotes;

  /// **"ACCEPT QUOTE"**
  String get acceptQuote;

  /// **"DECLINE QUOTE"**
  String get declineQuote;

  /// **"Accept Quotation?"**
  String get acceptQuotationQuestion;

  /// **"Decline Quotation?"**
  String get declineQuotationQuestion;

  /// **"Confirm that you would like to accept this quotation."**
  String get confirmAcceptQuotation;

  /// **"Confirm that you would like to decline this quotation."**
  String get confirmDeclineQuotation;

  /// **"Quotation accepted successfully."**
  String get quotationAccepted;

  /// **"Quotation declined."**
  String get quotationDeclined;

  /// **"Unable to update your quotation decision."**
  String get unableToUpdateQuoteDecision;

  /// **"You accepted this quotation."**
  String get youAcceptedQuotation;

  /// **"You declined this quotation."**
  String get youDeclinedQuotation;

  /// **"No quotations here yet"**
  String get noQuotationsYet;

  /// **"Your quotation requests and received rates will appear here automatically."**
  String get quotationsEmptyBody;

  /// **"Unable to load quotations"**
  String get unableToLoadQuotations;

  /// **"Please sign in to view your bookings."**
  String get pleaseSignInToViewBookings;

  /// **"Track every booking request and its latest status."**
  String get trackEveryBooking;

  /// **"Your Shipping Bookings"**
  String get yourShippingBookings;

  /// **"Follow your booking requests from submission to final confirmation."**
  String get followBookingRequests;

  /// **"VIEW BOOKING DETAILS"**
  String get viewBookingDetails;

  /// **"Preferred Time"**
  String get preferredTime;

  /// **"Customer Notes"**
  String get customerNotes;

  /// **"No bookings found"**
  String get noBookingsFound;

  /// **"Your booking requests will appear here."**
  String get bookingsEmptyBody;

  /// **"Unable to load bookings"**
  String get unableToLoadBookings;

  /// **"LIVE SUPPORT PORTAL"**
  String get liveSupportPortal;

  /// **"Your Support Cases"**
  String get yourSupportCases;

  /// **"Follow every request and its latest status from one secure place."**
  String get followEveryRequest;

  /// **"Support History"**
  String get supportHistory;

  /// **"Tap any case to view complete details."**
  String get tapAnyCase;

  /// **"General support case"**
  String get generalSupportCase;

  /// **"No message provided."**
  String get noMessageProvided;

  /// **"TAWAM SUPPORT RESPONSE"**
  String get tawamSupportResponse;

  /// **"Our support team has not added a response yet."**
  String get noSupportResponseYet;

  /// **"No support requests found"**
  String get noSupportRequestsFound;

  /// **"Your support requests and their latest status will appear here."**
  String get supportRequestsEmptyBody;

  /// **"Could not load support requests."**
  String get couldNotLoadSupportRequests;

  /// **"Please sign in to view your support requests."**
  String get pleaseSignInToViewSupport;

  /// **"Shipment updates, quotations and important account alerts."**
  String get notificationHeaderSubtitle;

  /// **"Updates appear automatically"**
  String get updatesAppearAutomatically;

  /// **"General Cargo"**
  String get cargoGeneral;

  /// **"Heavy Equipment"**
  String get cargoHeavyEquipment;

  /// **"Furniture"**
  String get cargoFurniture;

  /// **"Electronics"**
  String get cargoElectronics;

  /// **"Food Products"**
  String get cargoFoodProducts;

  /// **"Medical Supplies"**
  String get cargoMedicalSupplies;

  /// **"Road Freight"**
  String get roadFreight;

  /// **"Select preferred pickup date"**
  String get selectPreferredPickupDate;

  /// **"Your shipping request has been prepared successfully. Our logistics team will review the details and contact you."**
  String get quotePreparedSuccess;

  /// **"Tell us where your shipment will be collected and delivered."**
  String get tellUsCollectedDelivered;

  /// **"Choose the transportation service that fits your shipment."**
  String get chooseTransportService;

  /// **"Provide the cargo details so we can prepare an accurate quote."**
  String get provideCargoForQuote;

  /// **"Please describe your cargo"**
  String get pleaseDescribeCargo;

  /// **"Choose your preferred date for cargo collection."**
  String get choosePreferredCollectionDate;

  /// **"Enter the details our logistics team can use to contact you."**
  String get enterContactForLogistics;

  /// **"Add any instructions or special requirements for your shipment."**
  String get addInstructionsOrRequirements;

  /// **"Special handling, cargo dimensions, customs notes..."**
  String get specialHandlingHintShort;

  /// **"Your shipment information will be reviewed securely by the Tawam logistics team before the final quotation is prepared."**
  String get reviewedBeforeFinalQuote;

  /// **"Share your shipment details and receive a tailored transportation quotation."**
  String get shareDetailsTailoredQuote;

  /// **"Flat Rack"**
  String get flatRack;

  /// **"Packing List Review"**
  String get packingListReview;

  /// **"Submit your sea freight requirements and receive a tailored quotation from our logistics team."**
  String get seaHeroSubmitSubtitle;

  /// **"Port, city or pickup location"**
  String get portCityPickup;

  /// **"Port, city or delivery location"**
  String get portCityDelivery;

  /// **"Shipment Load"**
  String get shipmentLoad;

  /// **"Number of Packages / Pallets"**
  String get numberOfPackagesPallets;

  /// **"Package Dimensions"**
  String get packageDimensions;

  /// **"Calculated automatically"**
  String get calculatedAutomatically;

  /// **"Your request will be reviewed by our logistics team before an official rate is issued."**
  String get reviewedBeforeOfficialRate;

  /// **"Recommend for Me"**
  String get recommendForMe;

  /// **"Depot to Depot"**
  String get depotToDepot;

  /// **"Door to Depot"**
  String get doorToDepot;

  /// **"Depot to Door"**
  String get depotToDoor;

  /// **"Curtain Side"**
  String get curtainSide;

  /// **"Box Truck"**
  String get boxTruck;

  /// **"Border Documentation"**
  String get borderDocumentation;

  /// **"Loading / Unloading"**
  String get loadingUnloading;

  /// **"Choose full-truck or partial-load transportation."**
  String get chooseFtlLtl;

  /// **"REGIONAL ROAD FREIGHT"**
  String get regionalRoadFreight;

  /// **"Professional FTL, LTL and cross-border transport for commercial and project cargo."**
  String get landHeroSubtitle;

  /// **"Regional Routes"**
  String get regionalRoutes;

  /// **"Load Type"**
  String get loadType;

  /// **"Less Than Truck Load"**
  String get lessThanTruckLoad;

  /// **"Number of Trucks"**
  String get numberOfTrucks;

  /// **"Enter required temperature"**
  String get enterRequiredTemperature;

  /// **"Preferred Vehicle"**
  String get preferredVehicle;

  /// **"Total Volume"**
  String get totalVolume;

  /// **"Average Package Dimensions"**
  String get averagePackageDimensions;

  /// **"AUTOMATIC VOLUME"**
  String get automaticVolume;

  /// **"Calculated from dimensions × quantity"**
  String get calculatedFromDimensionsQty;

  /// **"Cargo may require special trailer planning."**
  String get oversizedMayNeedTrailer;

  /// **"Motorcycle"**
  String get motorcycle;

  /// **"Luxury / Classic"**
  String get luxuryClassic;

  /// **"Commercial Vehicle"**
  String get commercialVehicle;

  /// **"Non-Running"**
  String get nonRunning;

  /// **"Damaged / Accident"**
  String get damagedAccident;

  /// **"Vehicle Inspection"**
  String get vehicleInspection;

  /// **"Add insurance or priority handling to your quotation request."**
  String get addInsuranceOrPriority;

  /// **"SECURE VEHICLE LOGISTICS"**
  String get secureVehicleLogistics;

  /// **"Premium regional and international vehicle transport with flexible shipping options."**
  String get carHeroSubtitle;

  /// **"Carrier Transport"**
  String get carrierTransport;

  /// **"Port Shipping"**
  String get portShipping;

  /// **"CONTAINER"**
  String get containerUpper;

  /// **"Protected Shipping"**
  String get protectedShipping;

  /// **"City, address, showroom or port"**
  String get cityShowroomPort;

  /// **"City, address, warehouse or port"**
  String get cityWarehousePort;

  /// **"Enter make"**
  String get enterMake;

  /// **"Enter model"**
  String get enterModel;

  /// **"Enter a valid model year"**
  String get enterValidModelYear;

  /// **"Special loading equipment may be required for non-running or damaged vehicles."**
  String get specialLoadingMayBeRequired;

  /// **"If the vehicles are different models or conditions, add the remaining vehicle details under Special Instructions."**
  String get differentVehiclesHint;

  /// **"Transport Method"**
  String get transportMethod;

  /// **"Choose the option that best fits your route and vehicle."**
  String get chooseBestRouteVehicle;

  /// **"Cost-effective road transport for standard vehicles."**
  String get openCarrierDesc;

  /// **"Enhanced protection for luxury, classic or high-value vehicles."**
  String get enclosedCarrierDesc;

  /// **"Roll-on / roll-off international port shipping."**
  String get roroDesc;

  /// **"Containerized international vehicle transportation."**
  String get containerShippingDesc;

  /// **"Request priority coordination for a time-sensitive vehicle movement."**
  String get requestPriorityVehicle;

  /// **"Special loading requirement flagged automatically."**
  String get specialLoadingFlagged;

  /// **"SELECT VEHICLE READY DATE"**
  String get selectVehicleReadyDate;

  /// **"Sedan"**
  String get sedan;

  /// **"SUV"**
  String get suv;

  /// **"Van"**
  String get van;

  /// **"Running"**
  String get running;

  /// **"Home Move"**
  String get homeMove;

  /// **"Apartment"**
  String get apartment;

  /// **"Townhouse"**
  String get townhouse;

  /// **"Warehouse"**
  String get warehouse;

  /// **"Large Appliances"**
  String get largeAppliances;

  /// **"Fragile Items"**
  String get fragileItems;

  /// **"High-Value Items"**
  String get highValueItems;

  /// **"Packing Materials"**
  String get packingMaterials;

  /// **"Furniture Reassembly"**
  String get furnitureReassembly;

  /// **"Debris Removal"**
  String get debrisRemoval;

  /// **"Help us understand the size and type of your relocation."**
  String get moveProfileHelp;

  /// **"Provide a simple estimate. Final volume can be confirmed by our team."**
  String get inventoryEstimateHelp;

  /// **"Select items that may require special packing or handling."**
  String get selectSpecialPackingItems;

  /// **"Build the moving package that fits your relocation."**
  String get buildMovingPackage;

  /// **"GLOBAL RELOCATION"**
  String get globalRelocation;

  /// **"Premium relocation planning for homes, offices and personal effects — from collection to final delivery."**
  String get movingHeroSubtitle;

  /// **"City, building or current address"**
  String get cityBuildingCurrent;

  /// **"City, building or destination address"**
  String get cityBuildingDestination;

  /// **"Move Type"**
  String get moveType;

  /// **"Household move"**
  String get householdMove;

  /// **"Office Move"**
  String get officeMove;

  /// **"Business move"**
  String get businessMove;

  /// **"Personal Effects"**
  String get personalEffects;

  /// **"Personal effects"**
  String get personalEffectsLower;

  /// **"Rooms / Work Areas"**
  String get roomsWorkAreas;

  /// **"Bedrooms / Rooms"**
  String get bedroomsRooms;

  /// **"Enter number of rooms"**
  String get enterNumberOfRooms;

  /// **"Origin Access"**
  String get originAccess;

  /// **"Destination Access"**
  String get destinationAccess;

  /// **"Optional — our team can confirm it"**
  String get optionalTeamCanConfirm;

  /// **"Enter a valid volume"**
  String get enterValidVolume;

  /// **"Items requiring extra care"**
  String get itemsRequiringExtraCare;

  /// **"Select all that apply."**
  String get selectAllThatApply;

  /// **"Our moving team packs household or office items."**
  String get movingTeamPacksItems;

  /// **"Request unpacking support at destination."**
  String get requestUnpacking;

  /// **"Dismantling support for large furniture before transport."**
  String get dismantlingSupport;

  /// **"Request storage options before final delivery."**
  String get requestStorageBeforeDelivery;

  /// **"MOVE SUMMARY"**
  String get moveSummary;

  /// **"Final survey can confirm volume, access and packing requirements."**
  String get finalSurveyCanConfirm;

  /// **"Our relocation team can confirm final volume and access requirements before issuing the rate."**
  String get relocationTeamConfirmVolume;

  /// **"Office Relocation"**
  String get officeRelocation;

  /// **"Household Goods & Personal Effects"**
  String get householdGoodsPersonalEffects;

  /// **"Large move profile detected. A pre-move survey may help confirm volume, access and packing requirements."**
  String get largeMoveProfile;

  /// **"Medium move profile. Final CBM can be confirmed by our relocation team before quotation."**
  String get mediumMoveProfile;

  /// **"Compact move profile. You can leave CBM blank if you do not know it — our team can confirm it."**
  String get compactMoveProfile;

  /// **"Unpacking"**
  String get unpacking;

  /// **"Moving Insurance"**
  String get movingInsurance;

  /// **"Standard relocation coordination"**
  String get standardRelocationCoordination;

  /// **"Enter 0 or more"**
  String get enterZeroOrMore;

  /// **"SELECT MOVING DATE"**
  String get selectMovingDate;

  /// **"Villa"**
  String get villa;

  /// **"Studio"**
  String get studio;

  /// **"Office"**
  String get office;

  /// **"Piano"**
  String get piano;

  /// **"Safe"**
  String get safe;

  /// **"Artwork"**
  String get artwork;

  /// **"Door Pickup"**
  String get doorPickup;

  /// **"Envelope / Document"**
  String get envelopeDocument;

  /// **"Padded Bag"**
  String get paddedBag;

  /// **"Proof of Delivery"**
  String get proofOfDelivery;

  /// **"Add insurance, fragile handling or signature confirmation."**
  String get addInsuranceFragileSignature;

  /// **"EXPRESS PARCEL LOGISTICS"**
  String get expressParcelLogistics;

  /// **"Professional domestic and international parcel solutions for personal and business shipments."**
  String get parcelHeroSubtitle;

  /// **"Global Parcels"**
  String get globalParcels;

  /// **"City, pickup address or drop-off location"**
  String get cityPickupDropoff;

  /// **"City or delivery address"**
  String get cityOrDeliveryAddress;

  /// **"Service Level"**
  String get serviceLevel;

  /// **"Cost-effective delivery for non-urgent parcels."**
  String get economyParcelDesc;

  /// **"Fast delivery for important and time-sensitive parcels."**
  String get expressParcelDesc;

  /// **"Priority handling for urgent business or valuable shipments."**
  String get priorityParcelDesc;

  /// **"Enter number of parcels"**
  String get enterNumberOfParcels;

  /// **"Enter parcel weight"**
  String get enterParcelWeight;

  /// **"Average Parcel Dimensions"**
  String get averageParcelDimensions;

  /// **"AUTOMATIC PARCEL CALCULATION"**
  String get automaticParcelCalculation;

  /// **"Parcel requires extra-care handling."**
  String get parcelExtraCare;

  /// **"Require recipient confirmation at delivery."**
  String get requireRecipientConfirmation;

  /// **"Our team will confirm routing, final chargeable weight and carrier availability before issuing the official rate."**
  String get parcelRateConfirmHint;

  /// **"SELECT PARCEL READY DATE"**
  String get selectParcelReadyDate;

  /// **"Economy"**
  String get economy;

  /// **"Fragile"**
  String get fragile;

  /// **"Volumetric-weight rules can vary by carrier, service and route. Final chargeable weight is confirmed by TAWAM AL-SHAHIN TRANSPORT."**
  String get volumetricRulesDisclaimer;

  /// **"When you create or use a Tawam account, we may process information that you provide to us, including:"**
  String get privacyAccountIntro;

  /// **"Phone number"**
  String get privacyPhoneNumber;

  /// **"Company information, when provided"**
  String get privacyCompanyWhenProvided;

  /// **"Delivery or account address, when provided"**
  String get privacyAddressWhenProvided;

  /// **"Account and customer identification information"**
  String get privacyAccountIdInfo;

  /// **"When you use our transportation and logistics services, information related to your shipments may be processed to provide and manage the requested service."**
  String get privacyShipmentIntro;

  /// **"Shipment and tracking numbers"**
  String get privacyTrackingNumbers;

  /// **"Origin and destination information"**
  String get privacyOriginDestination;

  /// **"Shipment status and delivery updates"**
  String get privacyStatusUpdates;

  /// **"Transportation service details"**
  String get privacyServiceDetails;

  /// **"Shipment-related documents"**
  String get privacyRelatedDocuments;

  /// **"Information submitted with quotation requests"**
  String get privacyQuoteInfo;

  /// **"TAWAM AL-SHAHIN TRANSPORT may use information collected through the application to:"**
  String get privacyUseIntro;

  /// **"Create and manage customer accounts"**
  String get privacyUseAccounts;

  /// **"Authenticate users and protect account access"**
  String get privacyUseAuth;

  /// **"Process transportation and shipment requests"**
  String get privacyUseRequests;

  /// **"Provide shipment tracking and status updates"**
  String get privacyUseTracking;

  /// **"Manage quotation requests"**
  String get privacyUseQuotes;

  /// **"Provide invoices and shipment documents"**
  String get privacyUseInvoices;

  /// **"Respond to customer support requests"**
  String get privacyUseSupport;

  /// **"Maintain and improve application functionality"**
  String get privacyUseImprove;

  /// **"Privacy • Security • Trust"**
  String get privacySecurityTrust;

  /// **"Authentication token unavailable"**
  String get authenticationTokenUnavailable;

  /// **"Move Your Cargo\nAcross The World"**
  String get seaHeroTitle;

  /// **"Road Freight.\nBuilt Around Your Cargo."**
  String get landHeroTitle;

  /// **"Your Vehicle.\nHandled Professionally."**
  String get carHeroTitle;

  /// **"Move Worldwide.\nFeel At Home."**
  String get movingHeroTitle;

  /// **"Send Faster.\nDeliver Smarter."**
  String get parcelHeroTitle;

  /// **"Country"**
  String get country;

  /// **"Make"**
  String get vehicleMake;

  /// **"Model"**
  String get vehicleModel;

  /// **"Floor"**
  String get floor;

  /// **"Unit"**
  String get unit;

  /// **"Home"**
  String get homeMoveShort;

  /// **"Personal"**
  String get personalShort;

  /// **"CURRENT"**
  String get currentBadge;

  /// **"e.g. Machinery, Furniture, General Cargo"**
  String get hintCargoSea;

  /// **"e.g. Electronics, Machinery, General Cargo"**
  String get hintCargoAir;

  /// **"e.g. Machinery, Food, Furniture, General Cargo"**
  String get hintCargoLand;

  /// **"e.g. General Cargo, Steel, Furniture"**
  String get hintCargoQuote;

  /// **"e.g. Documents, Clothing, Samples, Electronics"**
  String get hintParcelContents;

  /// **"e.g. +5"**
  String get hintTemperature;

  /// **"Drop-off"**
  String get dropOff;

  /// **"Reefer"**
  String get reefer;

  /// **"Flatbed"**
  String get flatbed;

  /// **"Lowbed"**
  String get lowbed;

  /// **"Bags"**
  String get bags;

  /// **"Open Top"**
  String get openTop;

  /// **"Container"**
  String get container;

  /// **"20FT Standard"**
  String get ft20Standard;

  /// **"40FT Standard"**
  String get ft40Standard;

  /// **"40FT HC"**
  String get ft40Hc;

  /// **"20FT Reefer"**
  String get ft20Reefer;

  /// **"40FT Reefer"**
  String get ft40Reefer;

  /// **"Other"**
  String get otherOption;

  /// **"Vehicles"**
  String get vehicles;

  /// **"Household Goods & Personal Effects"**
  String get householdGoodsPersonalEffects;

  /// **"PACK"**
  String get badgePack;

  /// **"GLOBAL"**
  String get badgeGlobal;

  /// **"EXPRESS"**
  String get badgeExpress;

  /// **"INTL"**
  String get badgeIntl;

  /// **"ROAD"**
  String get badgeRoad;

  /// **"X-BORDER"**
  String get badgeXBorder;

  /// **"This Privacy Policy explains how TAWAM AL-SHAHIN TRANSPORT handles information when customers use the Tawam mobile application and related transportation services."**
  String get privacyIntro;

  /// **"Account access is protected using authentication services. Customers should keep their login credentials confidential and should not share passwords or password-reset links with other persons."**
  String get privacyAccountSecurityBody;

  /// **"Invoices, transportation documents, proof-of-delivery files and other shipment-related documents may be made available through a customer account when those documents are associated with that customer or shipment."**
  String get privacyShippingDocumentsBody;

  /// **"We may use your contact information to provide service-related communications such as shipment updates, quotation information, account notices, security messages and customer-support responses."**
  String get privacyServiceCommunicationsBody;

  /// **"Information may be shared when reasonably necessary to provide transportation or logistics services, process a customer request, support application operations, comply with applicable legal requirements, or protect the security of our services. We do not intend customer accounts to provide public access to private shipment information."**
  String get privacyDataSharingBody;

  /// **"Account and application data may be stored using cloud infrastructure and service providers used by TAWAM AL-SHAHIN TRANSPORT to operate the application. Access to customer information should be limited according to account permissions and operational requirements."**
  String get privacyDataStorageBody;

  /// **"We use technical and organizational safeguards designed to reduce unauthorized access, disclosure, alteration or misuse of customer and shipment information. No electronic system can guarantee absolute security, so customers should also protect their account credentials and devices."**
  String get privacySecurityMeasuresBody;

  /// **"Information may be retained for as long as reasonably necessary to provide transportation services, maintain customer and shipment records, support business operations, resolve disputes, meet contractual requirements and comply with applicable obligations."**
  String get privacyDataRetentionBody;

  /// **"Customers may review and update certain account information through the Profile section of the Tawam application. Security-sensitive changes may require additional authentication or verification."**
  String get privacyYourAccountInfoBody;

  /// **"Customers can use the available account-security features to reset or change their password. Passwords should be strong, unique and kept confidential. If you believe your account has been accessed without authorization, contact us promptly."**
  String get privacyPasswordProtectionBody;

  /// **"If you have questions regarding your account, shipment information, privacy or this Privacy Policy, please contact TAWAM AL-SHAHIN TRANSPORT through the Help Center available in the application."**
  String get privacyContactBody;

  /// **"TAWAM AL-SHAHIN TRANSPORT may update this Privacy Policy when the application, our services or applicable requirements change. The latest version will be made available through the application."**
  String get privacyChangesBody;

  /// **"By using the Tawam mobile application, you agree to use the application and its transportation services responsibly and in accordance with these Terms & Conditions."**
  String get termsIntro;

  /// **"TAWAM AL-SHAHIN TRANSPORT provides transportation, logistics and shipment-related services. The Tawam mobile application provides customers with digital access to selected account, shipment, quotation, tracking, document and support services."**
  String get termsAboutServicesBody;

  /// **"Customers may be required to create an account to access certain application features. Information provided during registration should be accurate and kept reasonably up to date."**
  String get termsCustomerAccountsBody;

  /// **"Customers are responsible for protecting their account credentials and for activity performed through their account. Passwords and password-reset links should not be shared with unauthorized persons."**
  String get termsAccountSecurityBody;

  /// **"Shipment availability, routes, schedules, transportation methods, documentation requirements and service conditions may vary according to shipment characteristics, origin, destination and applicable operational requirements."**
  String get termsShipmentServicesBody;

  /// **"Quotation requests submitted through the application may require review by TAWAM AL-SHAHIN TRANSPORT. A displayed or requested quotation is not necessarily a confirmed booking until the required details and service arrangements have been accepted."**
  String get termsQuotationsBody;

  /// **"Tracking information is provided to assist customers in following shipment progress. Status information may depend on operational updates and may not always reflect events instantly."**
  String get termsShipmentTrackingBody;

  /// **"Invoices, shipment records and other transportation documents made available through the application are associated with the relevant customer or shipment account. Customers should not attempt to access documents belonging to another account."**
  String get termsShippingDocumentsBody;

  /// **"Customers are responsible for providing accurate information about shipments, including descriptions, quantities, dimensions, weight, origin, destination and other information reasonably required to arrange transportation services."**
  String get termsShipmentInformationBody;

  /// **"Customers must not use the application or transportation services to request shipment of goods that are unlawful or prohibited under applicable requirements. Additional restrictions may apply depending on the shipment, route and destination."**
  String get termsRestrictedItemsBody;

  /// **"Estimated transit and delivery times are provided for planning purposes. Actual timing may be affected by customs procedures, border processing, inspections, operational conditions, weather, traffic or other circumstances affecting transportation."**
  String get termsTransitDeliveryBody;

  /// **"Transportation charges and applicable fees depend on the service provided and agreed quotation or arrangement. Additional charges may apply where services or requirements change after confirmation."**
  String get termsChargesPaymentsBody;

  /// **"Customers may contact TAWAM AL-SHAHIN TRANSPORT through the Help Center for assistance relating to accounts, shipment services, quotations, documents or other application-related matters."**
  String get termsCustomerSupportBody;

  /// **"The application must not be used to interfere with its operation, attempt unauthorized access to customer or company information, misuse another person's account, or engage in activity that may compromise application security."**
  String get termsAcceptableUseBody;

  /// **"We aim to provide reliable access to the application, but availability may occasionally be affected by maintenance, updates, network conditions, third-party services or technical issues."**
  String get termsApplicationAvailabilityBody;

  /// **"TAWAM AL-SHAHIN TRANSPORT may update these Terms & Conditions when application features, services or applicable requirements change. The latest version may be made available through the application."**
  String get termsChangesBody;

  /// **"If you have questions regarding these Terms & Conditions or a transportation service, please contact TAWAM AL-SHAHIN TRANSPORT through the Help Center in the application."**
  String get termsContactBody;

  /// **"Box"**
  String get packageBox;

  /// **"Tube"**
  String get packageTube;

  /// **"AM"**
  String get periodAm;

  /// **"PM"**
  String get periodPm;

  /// **"Temperature Controlled"**
  String get temperatureControlled;

  /// **"Select"**
  String get select;

  /// **"+{count} more"**
  String plusNMore(int count);

  /// **"{count} Room"**
  String roomSingular(int count);

  /// **"{count} Rooms"**
  String roomPlural(int count);

  /// **"Estimated volume entered: {volume} CBM. Our team can confirm the final volume before the rate is issued."**
  String estimatedVolumeEntered(String volume);

  /// **"Total volume: {volume} CBM • Final carrier formula may vary."**
  String totalVolumeCarrierNote(String volume);

  /// **"{count} Truck"**
  String truckSingular(int count);

  /// **"{count} Trucks"**
  String truckPlural(int count);

  /// **"{count} Package"**
  String packageSingular(int count);

  /// **"{count} Packages"**
  String packagePlural(int count);


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
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale".',
  );
}
