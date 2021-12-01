import '../ain/ain.dart';
import '../ain/ain_api.dart';
import '../ain/ain_settings.dart';
import '../ain/ain_sensor_param.dart';
import '../plug/plug.dart';
import 'sfp_sensor_param.dart';
import 'sfp_settings.dart';
import 'sfp_snapshot.dart';

class Sfp extends Plug implements Ain {
  //
  final int _noAin;

  Sfp(String address, {int noAin = 9})
      : _noAin = noAin,
        super(address);

  @override
  int get ainCount => _noAin;

  @override
  Future<SfpSnapshot> get snapshot => AinApi.getSnapshot<SfpSnapshot>(address);

  @override
  Future<List<SfpSensorParam>> get sensors =>
      AinApi.getSensors<SfpSensorParam>(address);

  @override
  Future<SfpSettings> get settings => AinApi.getSettings<SfpSettings>(address);

  @override
  Future<void> setSensors(List<AinSensorParam> sensors) =>
      AinApi.setSensors(address, sensors);

  @override
  Future<void> setSettings(AinSettings settings) =>
      AinApi.setSettings(address, settings);
}