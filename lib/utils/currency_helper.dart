import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CurrencyHelper {
  static Future<String> detectCurrency() async {
    try {
      // 🔐 Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return "USD"; // fallback
      }

      // 📍 Get location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      // 🌍 Get country
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String country = placemarks.first.country ?? "";

      // 🔥 Map country → currency
      switch (country) {
        case "Sri Lanka":
          return "LKR";
        case "India":
          return "INR";
        case "United States":
          return "USD";
        case "United Kingdom":
          return "GBP";
        case "Germany":
        case "France":
        case "Italy":
          return "EUR";
        default:
          return "USD";
      }
    } catch (e) {
      return "USD"; // fallback
    }
  }
}
