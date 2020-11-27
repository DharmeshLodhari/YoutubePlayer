import 'package:flutter/material.dart';

/// Property

class PropertyDashboardBloc extends ChangeNotifier {
  static int _index = 0;
  PageController _pageController = PageController(initialPage: _index);

  int get index => _index;

  PageController get pageController => _pageController;

  set index(int value) {
    _index = value;
    _pageController.animateToPage(_index,
        duration: Duration(milliseconds: 500), curve: Curves.linear);
    notifyListeners();
  }
}

/// Property Filter

class PropertyFilterBloc extends ChangeNotifier {
  List<bool> _isForBuyOrRent = [true, false];

  /// type of property filter variables
  bool _typeIsAny = true;
  bool _typeIsApartment = false;
  bool _typeIsCondo = false;
  bool _typeIsDuplex = false;
  bool _typeIsHouse = false;
  bool _typeIsTownHouse = false;

  Map<String, bool> propertyType = {
    "Any": true,
    "Apartment": false,
    "Condo": false,
    "House": false,
    "Town House": false
  };

  /// duration of property filter variables
  bool _durationAtLeastAYear = true;
  bool _durationAtFewMonths = false;
  bool _durationAtFewWeeks = false;
  bool _durationAtFewDays = false;
  DateTime _checkInDate = DateTime.now();
  DateTime _checkOutDate = DateTime.now();
  int _selectedGuestCount = 1;

  Map<String, bool> propertyRentDuration = {
    "At Least A Year": true,
    "At Few Months": false,
    "At Few Weeks": false,
    "At Few Days": false,
  };

  /// Roommates property filter variables
  bool _roommatesNeeded = false;
  bool _roommatesDoesNotNeeded = true;

  /// Bedrooms property filter variables
  bool _bedroomIsStudio = true;
  bool _bedroomIs1 = false;
  bool _bedroomIs2 = false;
  bool _bedroomIs3 = false;
  bool _bedroomIs4Plus = false;

  Map<String, bool> propertyBedroom = {
    "Studio": true,
    "1": false,
    "2": false,
    "3": false,
    "4+": false,
  };

  /// Bathroom property filter variables
  bool _bathroomIs1 = true;
  bool _bathroomIs2 = false;
  bool _bathroomIs3 = false;
  bool _bathroomIs4 = false;
  bool _bathroomIs5Plus = false;

  Map<String, bool> propertyBathroom = {
    "1": true,
    "2": false,
    "3": false,
    "4": false,
    "5+": false,
  };

  /// Pet Policy property filter variables
  bool _isDogAllowed = false;
  bool _isCatAllowed = false;

  Map<String, bool> propertyPetPolicy = {
    "Dog allowed": true,
    "Cat allowed": false
  };

  /// Furniture property filter variables
  bool _isFurnished = false;
  bool _isUnfurnished = true;

  /// Amenities property filter variables
  bool _amenityIsAny = true;
  bool _amenityIsLaundryAvailable = false;
  bool _amenityIsACAvailable = false;
  bool _amenityIsHeatingAvailable = false;
  bool _amenityIsParkingAvailable = false;
  bool _amenityIsGatedEntryAvailable = false;
  bool _amenityIsDoormanAvailable = false;
  bool _amenityIsGymAvailable = false;
  bool _amenityIsPoolAvailable = false;
  bool _amenityIsDishwasherAvailable = false;

  Map<String, bool> propertyAmenity = {
    "Any": true,
    "Laundry": false,
    "A/C": false,
    "Heating": false,
    "Parking": false,
    "Gated entry": false,
    "Doorman": false,
    "Gym": false,
    "Pool": false,
    "Dishwasher": false,
  };

  /// Price filter
  int _minPrice = 0;
  int _maxPrice = 100;
  int _selectedMinPrice = 0;
  int _selectedMaxPrice = 50;

  List<bool> get isForBuyOrRent => _isForBuyOrRent;

  set isForBuyOrRent(List<bool> value) {
    _isForBuyOrRent = value;
    notifyListeners();
  }

  bool get typeIsAny => _typeIsAny;

  set typeIsAny(bool value) {
    _typeIsAny = value;
    notifyListeners();
  }

  bool get typeIsApartment => _typeIsApartment;

  set typeIsApartment(bool value) {
    _typeIsApartment = value;
    notifyListeners();
  }

  bool get typeIsCondo => _typeIsCondo;

  set typeIsCondo(bool value) {
    _typeIsCondo = value;
    notifyListeners();
  }

  bool get typeIsDuplex => _typeIsDuplex;

  set typeIsDuplex(bool value) {
    _typeIsDuplex = value;
    notifyListeners();
  }

  bool get typeIsHouse => _typeIsHouse;

  set typeIsHouse(bool value) {
    _typeIsHouse = value;
    notifyListeners();
  }

  bool get typeIsTownHouse => _typeIsTownHouse;

  set typeIsTownHouse(bool value) {
    _typeIsTownHouse = value;
    notifyListeners();
  }

  bool get durationAtLeastAYear => _durationAtLeastAYear;

  set durationAtLeastAYear(bool value) {
    _durationAtLeastAYear = value;
    notifyListeners();
  }

  bool get durationAtFewMonths => _durationAtFewMonths;

  set durationAtFewMonths(bool value) {
    _durationAtFewMonths = value;
    notifyListeners();
  }

  bool get durationAtFewWeeks => _durationAtFewWeeks;

  set durationAtFewWeeks(bool value) {
    _durationAtFewWeeks = value;
    notifyListeners();
  }

  bool get durationAtFewDays => _durationAtFewDays;

  set durationAtFewDays(bool value) {
    _durationAtFewDays = value;
    notifyListeners();
  }

  bool get roommatesNeeded => _roommatesNeeded;

  set roommatesNeeded(bool value) {
    _roommatesNeeded = value;
    notifyListeners();
  }

  bool get roommatesDoesNotNeeded => _roommatesDoesNotNeeded;

  set roommatesDoesNotNeeded(bool value) {
    _roommatesDoesNotNeeded = value;
    notifyListeners();
  }

  bool get bedroomIsStudio => _bedroomIsStudio;

  set bedroomIsStudio(bool value) {
    _bedroomIsStudio = value;
    notifyListeners();
  }

  bool get bedroomIs1 => _bedroomIs1;

  set bedroomIs1(bool value) {
    _bedroomIs1 = value;
    notifyListeners();
  }

  bool get bedroomIs2 => _bedroomIs2;

  set bedroomIs2(bool value) {
    _bedroomIs2 = value;
    notifyListeners();
  }

  bool get bedroomIs3 => _bedroomIs3;

  set bedroomIs3(bool value) {
    _bedroomIs3 = value;
    notifyListeners();
  }

  bool get bedroomIs4Plus => _bedroomIs4Plus;

  set bedroomIs4Plus(bool value) {
    _bedroomIs4Plus = value;
    notifyListeners();
  }

  bool get bathroomIs1 => _bathroomIs1;

  set bathroomIs1(bool value) {
    _bathroomIs1 = value;
    notifyListeners();
  }

  bool get bathroomIs2 => _bathroomIs2;

  set bathroomIs2(bool value) {
    _bathroomIs2 = value;
    notifyListeners();
  }

  bool get bathroomIs3 => _bathroomIs3;

  set bathroomIs3(bool value) {
    _bathroomIs3 = value;
    notifyListeners();
  }

  bool get bathroomIs4 => _bathroomIs4;

  set bathroomIs4(bool value) {
    _bathroomIs4 = value;
    notifyListeners();
  }

  bool get bathroomIs5Plus => _bathroomIs5Plus;

  set bathroomIs5Plus(bool value) {
    _bathroomIs5Plus = value;
    notifyListeners();
  }

  bool get isDogAllowed => _isDogAllowed;

  set isDogAllowed(bool value) {
    _isDogAllowed = value;
    notifyListeners();
  }

  bool get isCatAllowed => _isCatAllowed;

  set isCatAllowed(bool value) {
    _isCatAllowed = value;
    notifyListeners();
  }

  bool get isFurnished => _isFurnished;

  set isFurnished(bool value) {
    _isFurnished = value;
    notifyListeners();
  }

  bool get isUnfurnished => _isUnfurnished;

  set isUnfurnished(bool value) {
    _isUnfurnished = value;
    notifyListeners();
  }

  bool get amenityIsAny => _amenityIsAny;

  set amenityIsAny(bool value) {
    _amenityIsAny = value;
    notifyListeners();
  }

  bool get amenityIsLaundryAvailable => _amenityIsLaundryAvailable;

  set amenityIsLaundryAvailable(bool value) {
    _amenityIsLaundryAvailable = value;
    notifyListeners();
  }

  bool get amenityIsACAvailable => _amenityIsACAvailable;

  set amenityIsACAvailable(bool value) {
    _amenityIsACAvailable = value;
    notifyListeners();
  }

  bool get amenityIsHeatingAvailable => _amenityIsHeatingAvailable;

  set amenityIsHeatingAvailable(bool value) {
    _amenityIsHeatingAvailable = value;
    notifyListeners();
  }

  bool get amenityIsParkingAvailable => _amenityIsParkingAvailable;

  set amenityIsParkingAvailable(bool value) {
    _amenityIsParkingAvailable = value;
    notifyListeners();
  }

  bool get amenityIsGatedEntryAvailable => _amenityIsGatedEntryAvailable;

  set amenityIsGatedEntryAvailable(bool value) {
    _amenityIsGatedEntryAvailable = value;
    notifyListeners();
  }

  bool get amenityIsDoormanAvailable => _amenityIsDoormanAvailable;

  set amenityIsDoormanAvailable(bool value) {
    _amenityIsDoormanAvailable = value;
    notifyListeners();
  }

  bool get amenityIsGymAvailable => _amenityIsGymAvailable;

  set amenityIsGymAvailable(bool value) {
    _amenityIsGymAvailable = value;
    notifyListeners();
  }

  bool get amenityIsPoolAvailable => _amenityIsPoolAvailable;

  set amenityIsPoolAvailable(bool value) {
    _amenityIsPoolAvailable = value;
    notifyListeners();
  }

  bool get amenityIsDishwasherAvailable => _amenityIsDishwasherAvailable;

  set amenityIsDishwasherAvailable(bool value) {
    _amenityIsDishwasherAvailable = value;
    notifyListeners();
  }

  int get minPrice => _minPrice;

  set minPrice(int value) {
    _minPrice = value;
    notifyListeners();
  }

  int get maxPrice => _maxPrice;

  set maxPrice(int value) {
    _maxPrice = value;
    notifyListeners();
  }

  int get selectedMinPrice => _selectedMinPrice;

  set selectedMinPrice(int value) {
    _selectedMinPrice = value;
    notifyListeners();
  }

  int get selectedMaxPrice => _selectedMaxPrice;

  set selectedMaxPrice(int value) {
    _selectedMaxPrice = value;
    notifyListeners();
  }

  DateTime get checkInDate => _checkInDate;

  set checkInDate(DateTime value) {
    _checkInDate = value;
    notifyListeners();
  }

  DateTime get checkOutDate => _checkOutDate;

  set checkOutDate(DateTime value) {
    _checkOutDate = value;
    notifyListeners();
  }

  int get selectedGuestCount => _selectedGuestCount;

  set selectedGuestCount(int value) {
    _selectedGuestCount = value;
    notifyListeners();
  }

  void resetFilter() {
    _typeIsAny = true;
    _typeIsApartment = false;
    _typeIsCondo = false;
    _typeIsDuplex = false;
    _typeIsHouse = false;
    _typeIsTownHouse = false;
    _durationAtLeastAYear = true;
    _durationAtFewMonths = false;
    _durationAtFewWeeks = false;
    _durationAtFewDays = false;
    _checkInDate = DateTime.now();
    _checkOutDate = DateTime.now();
    _selectedGuestCount = 1;

    _roommatesNeeded = false;
    _roommatesDoesNotNeeded = true;

    _bedroomIsStudio = true;
    _bedroomIs1 = false;
    _bedroomIs2 = false;
    _bedroomIs3 = false;
    _bedroomIs4Plus = false;
    _bathroomIs1 = true;
    _bathroomIs2 = false;
    _bathroomIs3 = false;
    _bathroomIs4 = false;
    _bathroomIs5Plus = false;
    _isDogAllowed = false;
    _isCatAllowed = false;
    _isFurnished = false;
    _isUnfurnished = true;
    _amenityIsAny = true;
    _amenityIsLaundryAvailable = false;
    _amenityIsACAvailable = false;
    _amenityIsHeatingAvailable = false;
    _amenityIsParkingAvailable = false;
    _amenityIsGatedEntryAvailable = false;
    _amenityIsDoormanAvailable = false;
    _amenityIsGymAvailable = false;
    _amenityIsPoolAvailable = false;
    _amenityIsDishwasherAvailable = false;
  }
}
