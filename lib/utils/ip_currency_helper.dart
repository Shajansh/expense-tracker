import 'dart:convert';
import 'package:http/http.dart' as http;

class IpCurrencyHelper {
  static Future<String> detectCurrency() async {
    try {
      // 🌐 Get IP info
      final response = await http.get(Uri.parse('https://ipapi.co/json/'));

      if (response.statusCode != 200) {
        return "USD";
      }

      final data = jsonDecode(response.body);

      String country = data["country_name"] ?? "";

      // 🌍 Map country → currency
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
        case "Spain":
          return "EUR";
        case "Canada":
          return "CAD";
        case "Australia":
          return "AUD";
        default:
          return "USD";
      }
    } catch (e) {
      return "USD";
    }
  }
}
