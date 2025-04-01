import 'package:flutter/material.dart';
import 'package:sway/Controller/favorite_controller.dart';
import 'package:sway/page/favorite/locationcard.dart';
import 'package:sway/page/home/trip_picker.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Map<String, dynamic>> _favoriteLocations = [];
  bool _isLoading = true;
  final FavoriteController _favoriteController = FavoriteController();

  @override
  void initState() {
    super.initState();
    _fetchFavoriteLocations();
  }

  Future<void> _fetchFavoriteLocations() async {
    try {
      List<Map<String, dynamic>> locations =
          await _favoriteController.fetchFavoriteLocations();
      setState(() {
        _favoriteLocations = locations;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Lỗi khi tải danh sách địa điểm yêu thích: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFavorite(int locationId) async {
    try {
      await _favoriteController.removeFavorite(locationId);
      debugPrint("✅ Xóa địa điểm yêu thích thành công!");
      _fetchFavoriteLocations(); // Reload the favorite locations after removal
    } catch (e) {
      debugPrint("❌ Lỗi khi xóa địa điểm yêu thích: $e");
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
                  ? const Center(
                      child: Text("Chưa có địa điểm yêu thích",
                          style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 24),
                      itemCount: _favoriteLocations.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            LocationCard(
                              title: _favoriteLocations[index]["title"],
                              address: _favoriteLocations[index]["address"],
                              onTap: () {
                                final location = _favoriteLocations[index];

                                print(
                                    "✅ Đang gửi dữ liệu: $location"); // Kiểm tra dữ liệu trước khi gửi

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TripPicker(),
                                    settings: RouteSettings(
                                      arguments: {
                                        "address": location["address"],
                                        "latitude": location["coordinates"]
                                            ["lat"], // Truy xuất đúng key
                                        "longitude": location["coordinates"]
                                            ["lng"], // Truy xuất đúng key
                                      },
                                    ),
                                  ),
                                );
                              },
                              onRemove: () {
                                debugPrint(
                                    "🔥 Xóa địa điểm: ${_favoriteLocations[index]["id"]}");
                                _removeFavorite(
                                    _favoriteLocations[index]["id"]);
                              },
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
