import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteController {
  bool isLoading = false;
  List<Map<String, dynamic>> favoriteLocations = [];

  Future<List<Map<String, dynamic>>> fetchFavoriteLocations() async {
    isLoading = true;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    String? customerId = prefs.getString("customer_id");

    if (token == null || customerId == null) {
      debugPrint("🚨 Lỗi: Chưa đăng nhập hoặc thiếu thông tin người dùng.");
      isLoading = false;
      return []; // Trả về danh sách rỗng khi không có dữ liệu
    }

    var url = Uri.parse(
        "http://10.0.2.2:8080/api/FavoriteManagement/get-favorite-locations?customer_id=$customerId");
    var headers = {
      "Content-Type": "application/json",
      "Authorization": " $token",
    };

    try {
      var response = await http.get(url, headers: headers);
      debugPrint("📥 Phản hồi API: ${response.statusCode}");
      debugPrint("📄 Nội dung: ${response.body}");

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        List<dynamic> data = responseData["data"];

        // Chuyển đổi dữ liệu trả về thành danh sách và trả về
        return data.map((item) {
          return {
            "id": item["id"],
            "title": item["location_name"],
            "address": item["address"],
            "coordinates": item["coordinates"],
          };
        }).toList();
      } else {
        debugPrint("❌ Lỗi khi tải dữ liệu: ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("❌ Lỗi khi gửi yêu cầu API: $e");
      return [];
    } finally {
      isLoading = false;
    }
  }

  Future<void> removeFavorite(int locationId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    String? customerId = prefs.getString("customer_id");

    if (token == null || customerId == null) {
      debugPrint("🚨 Lỗi: Chưa đăng nhập hoặc thiếu thông tin người dùng.");
      return;
    }

    var url = Uri.parse(
        "http://10.0.2.2:8080/api/FavoriteManagement/remove-favorite-location"
        "?customer_id=$customerId&location_id=$locationId");

    var headers = {
      "Content-Type": "application/json",
      "Authorization": " $token",
    };

    debugPrint("📤 Gửi request DELETE: $url");

    try {
      var response = await http.delete(url, headers: headers);
      debugPrint("🗑️ Xóa địa điểm yêu thích: ${response.statusCode}");
      debugPrint("📄 Nội dung: ${response.body}");

      if (response.statusCode == 200) {
        favoriteLocations.removeWhere((item) => item["id"] == locationId);
        debugPrint("✅ Xóa địa điểm yêu thích thành công!");
      } else {
        debugPrint("❌ Lỗi khi xóa địa điểm: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Lỗi khi gửi yêu cầu xóa: $e");
    }
  }

  Future<void> addToFavorite(Map<String, dynamic> placeData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    String? customerId = prefs.getString("customer_id");

    if (token == null || customerId == null) {
      debugPrint("🚨 Lỗi: Chưa đăng nhập hoặc thiếu thông tin người dùng.");
      return;
    }

    var url = Uri.parse(
        "http://10.0.2.2:8080/api/FavoriteManagement/add-favorite-location");
    var headers = {
      "Content-Type": "application/json",
      "Authorization": " $token",
    };

    var body = jsonEncode({
      "location_name": placeData['location_name'],
      "address": placeData['address'],
      "coordinates": {
        "lat": placeData['latitude'],
        "lng": placeData['longitude']
      }
    });

    debugPrint("📡 Gửi yêu cầu đến API: $url");
    debugPrint("🔐 Headers: $headers");
    debugPrint("📦 Body: $body");

    try {
      var response = await http.post(url, headers: headers, body: body);
      debugPrint("📩 Phản hồi từ API: ${response.statusCode}");
      debugPrint("📜 Nội dung phản hồi: ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("✅ Đã thêm vào danh sách yêu thích!");
      } else {
        debugPrint("❌ Lỗi khi thêm vào danh sách yêu thích: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Lỗi khi gửi yêu cầu: $e");
    }
  }
}
