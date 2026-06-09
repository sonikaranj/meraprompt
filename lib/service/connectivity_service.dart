import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  late Connectivity _connectivity;
  final isConnected = true.obs;

  @override
  void onInit() {
    super.onInit();
    _connectivity = Connectivity();
    _checkConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectivity);
  }

  Future<void> _checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateConnectivity(results);
  }

  void _updateConnectivity(List<ConnectivityResult> results) {
    isConnected.value = !results.contains(ConnectivityResult.none);
  }
}
