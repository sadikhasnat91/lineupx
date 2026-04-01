import 'package:get/get.dart';
import '../../data/models/player_model.dart';
import '../../data/repositories/player_repository.dart';

class PlayerSelectionController extends GetxController {
  final _repo = Get.find<PlayerRepository>();

  final String positionLabel;

  PlayerSelectionController({required this.positionLabel});

  final isLoading = true.obs;
  final players = <PlayerModel>[].obs;
  final filtered = <PlayerModel>[].obs;

  final searchQuery = ''.obs;
  final selectedClub = ''.obs;
  final selectedCountry = ''.obs;
  final minRating = 0.obs;
  final sortDesc = true.obs;

  final clubs = <String>[].obs;
  final countries = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
    ever(searchQuery, (_) => _filter());
    ever(selectedClub, (_) => _filter());
    ever(selectedCountry, (_) => _filter());
    ever(minRating, (_) => _filter());
    ever(sortDesc, (_) => _filter());
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final label =
          positionLabel == 'ALL' ? null : positionLabel;
      players.value = label == null
          ? await _repo.getAll()
          : await _repo.getForPosition(label);

      // Build filter sets
      clubs.value = players.map((p) => p.club).toSet().toList()..sort();
      countries.value =
          players.map((p) => p.country).toSet().toList()..sort();

      _filter();
    } finally {
      isLoading.value = false;
    }
  }

  void _filter() {
    var result = List<PlayerModel>.from(players);

    final q = searchQuery.value.toLowerCase().trim();
    if (q.isNotEmpty) {
      result = result
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.club.toLowerCase().contains(q) ||
              p.country.toLowerCase().contains(q))
          .toList();
    }

    if (selectedClub.value.isNotEmpty) {
      result =
          result.where((p) => p.club == selectedClub.value).toList();
    }

    if (selectedCountry.value.isNotEmpty) {
      result = result
          .where((p) => p.country == selectedCountry.value)
          .toList();
    }

    if (minRating.value > 0) {
      result =
          result.where((p) => p.rating >= minRating.value).toList();
    }

    result.sort((a, b) => sortDesc.value
        ? b.rating.compareTo(a.rating)
        : a.rating.compareTo(b.rating));

    filtered.value = result;
  }

  void clearFilters() {
    selectedClub.value = '';
    selectedCountry.value = '';
    minRating.value = 0;
    searchQuery.value = '';
  }
}
