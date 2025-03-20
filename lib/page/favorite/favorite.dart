import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sway/page/favorite/locationcard.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Map<String, dynamic>> _favoriteLocations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteLocations();
  }

  Future<void> _fetchFavoriteLocations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    String? customerId = prefs.getString("customer_id");

    if (token == null || customerId == null) {
      debugPrint("🚨 Lỗi: Chưa đăng nhập hoặc thiếu thông tin người dùng.");
      setState(() => _isLoading = false);
      return;
    }

    var url = Uri.parse("http://10.0.2.2:8080/api/FavoriteManagement/get-favorite-locations?customer_id=$customerId");
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

        setState(() {
          _favoriteLocations = data.map((item) {
            return {
              "id": item["id"], // Thêm ID để xử lý xóa
              "title": item["location_name"],
              "address": item["address"],
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        debugPrint("❌ Lỗi khi tải dữ liệu: ${response.body}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("❌ Lỗi khi gửi yêu cầu API: $e");
      setState(() => _isLoading = false);
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
    "?customer_id=$customerId&location_id=$locationId"
  );

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
      debugPrint("✅ Xóa địa điểm yêu thích thành công!");
    } else {
      debugPrint("❌ Lỗi khi xóa địa điểm: ${response.body}");
    }
  } catch (e) {
    debugPrint("❌ Lỗi khi gửi yêu cầu xóa: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchFavoriteLocations,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _favoriteLocations.isEmpty
                  ? const Center(child: Text("Chưa có địa điểm yêu thích", style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
                      itemCount: _favoriteLocations.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            LocationCard(
                              title: _favoriteLocations[index]["title"],
                              address: _favoriteLocations[index]["address"],
                             onRemove: () {
                                    debugPrint("🔥 Button Remove Clicked! ID: ${_favoriteLocations[index]["id"]}");
                                   removeFavorite(_favoriteLocations[index]["id"]);
                                           }  , // Truyền ID vào hàm xóa
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
