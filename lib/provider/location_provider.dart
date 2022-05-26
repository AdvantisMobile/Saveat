import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saveat/api.dart';

class GetLocation {
  Geolocator geolocator;
  Position currentLocation;
  Api api;

  GetLocation() {
    geolocator = Geolocator();
    api = Api();
  }

  Future<Position> get() async {
    try {
      Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;
      await geolocator.checkGeolocationPermissionStatus();
      await Permission.location.isGranted;
//      await PermissionHandler().requestPermissions([PermissionGroup.location]);

      currentLocation = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      return currentLocation;
    } catch (e) {
      print('Erro ao conseguir a localização:: $e');
      return null;
    }
  }

  Future<String> getDistance(String destination) async {
    if (currentLocation == null) await get();

    List splitDestination = destination.split(',');
    double distanceInMeters =
        await geolocator.distanceBetween(currentLocation.latitude, currentLocation.longitude, double.parse(splitDestination[0]), double.parse(splitDestination[1]));
    double distanceInKm = (distanceInMeters / 1000);

    return (distanceInMeters < 1000 ? '$distanceInMeters m' : '${distanceInKm.toStringAsFixed(2)} km');
  }

  Future<String> getLatLng(String address) async {
    List<Placemark> placemark = await geolocator.placemarkFromAddress(address, localeIdentifier: 'pt_BR');

    String latlng;

    placemark.forEach((Placemark v) {
      latlng = '${v.position.latitude},${v.position.longitude}';
    });

    return latlng;
  }

  Future<Map> getDistanceEmpresa(String empresa, String destination) async {
    bool getNovaDistancia = distanciasColetadas.indexWhere((f) => f['empresa'] == empresa) == -1;

    if (getNovaDistancia) {
      try {
        if (currentLocation == null) {
          currentLocation = await this.get();
        }

        String origin = '${currentLocation.latitude},${currentLocation.longitude}';

        Map res = await api.getData('/global/?search=distance&origin=$origin&destination=$destination');

        if (res['code'] != '010') {
          return null;
        }

        Map resposta = res['data'];
        resposta['empresa'] = empresa;

        distanciasColetadas.add(resposta);

        return resposta;
      } catch (e) {
        print('Erro ao obter localização: $e');
        return null;
      }
    }

    return distanciasColetadas.firstWhere((f) => f['empresa'] == empresa);
  }
}
