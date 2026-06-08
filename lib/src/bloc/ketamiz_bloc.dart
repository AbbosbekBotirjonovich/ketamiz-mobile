import 'package:ketamiz/src/model/api/driver_trips_list_model.dart';
import 'package:rxdart/rxdart.dart';

import '../resources/repository.dart';
import 'bloc_errors.dart';

class KetamizBloc {
  final Repository _repository = Repository();

  final _infoTripsFetcher = BehaviorSubject<List<DriverTripModel>>();
  final _errorFetcher = PublishSubject<String>();

  Stream<List<DriverTripModel>> get getTrips => _infoTripsFetcher.stream;
  Stream<String> get getError => _errorFetcher.stream;

  Future<void> fetchDriverTripList(String status) async {
    _infoTripsFetcher.sink.add([]);
    try {
      var response = await _repository.fetchDriverTripsList(status);
      if (response.isSuccess) {
        if (response.result is Map<String, dynamic>) {
          var dataList = DriverTripsListModel.fromJson(response.result);
          _infoTripsFetcher.sink.add(dataList.data);
        } else {
          _errorFetcher.sink.add(BlocErrors.unexpectedFormat);
        }
      } else if (response.status == -1) {
        _errorFetcher.sink.add(BlocErrors.noInternet);
      } else {
        _errorFetcher.sink.add(BlocErrors.serverError);
      }
    } catch (e) {
      _errorFetcher.sink.add(BlocErrors.somethingWentWrong);
    }
  }

  // The generic /driver/trips endpoint omits nested vehicle/location data.
  // Fetch all three status endpoints in parallel so every trip has full detail.
  Future<void> fetchAllDriverTrips() async {
    _infoTripsFetcher.sink.add([]);
    try {
      final responses = await Future.wait([
        _repository.fetchDriverTripsList('active'),
        _repository.fetchDriverTripsList('completed'),
        _repository.fetchDriverTripsList('canceled'),
      ]);
      final merged = <DriverTripModel>[];
      for (final r in responses) {
        if (r.isSuccess && r.result is Map<String, dynamic>) {
          merged.addAll(DriverTripsListModel.fromJson(r.result).data);
        }
      }
      merged.sort((a, b) => b.startTime.compareTo(a.startTime));
      _infoTripsFetcher.sink.add(merged);
    } catch (e) {
      _errorFetcher.sink.add(BlocErrors.somethingWentWrong);
    }
  }

  void dispose() {
    _infoTripsFetcher.close();
    _errorFetcher.close();
  }
}

KetamizBloc _blocKetamiz = KetamizBloc();
KetamizBloc get blocKetamiz => _blocKetamiz;

void resetKetamizBloc() {
  _blocKetamiz.dispose();
  _blocKetamiz = KetamizBloc();
}
