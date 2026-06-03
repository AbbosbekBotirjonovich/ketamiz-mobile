import 'package:ketamiz/src/model/api/book_list_model.dart';
import 'package:ketamiz/src/model/api/book_model.dart';
import 'package:rxdart/rxdart.dart';

import '../model/event_bus/http_result.dart';
import '../resources/repository.dart';
import 'bloc_errors.dart';

class HistoryBloc {
  final Repository _repository = Repository();

  final _infoBookingsFetcher = BehaviorSubject<List<BookModel>>();
  final _loadingFetcher = BehaviorSubject<bool>.seeded(false);
  final _errorFetcher = PublishSubject<String>();

  Stream<List<BookModel>> get getBookings => _infoBookingsFetcher.stream;
  Stream<bool> get getLoading => _loadingFetcher.stream;
  Stream<String> get getError => _errorFetcher.stream;

  String _cacheKey(int status) => 'cache_history_$status';

  List<BookModel> _parseRaw(List<dynamic> raw) => raw
      .whereType<Map>()
      .map((e) => BookModel.fromJson(Map<String, dynamic>.from(e)))
      .toList();

  Future<void> fetchBookingsByStatus(int status) async {
    // Cache-first: show the last known bookings instantly (no spinner) and
    // revalidate from the network in the background.
    final cached = await _repository.getCachedList(_cacheKey(status));
    if (cached.isNotEmpty) {
      _infoBookingsFetcher.sink.add(_parseRaw(cached));
      _loadingFetcher.sink.add(false);
    } else {
      _loadingFetcher.sink.add(true);
    }

    try {
      HttpResult response;
      switch (status) {
        case 0:
          response = await _repository.fetchInProgressTrips();
          break;
        case 1:
          response = await _repository.fetchCompletedTrips();
          break;
        case 2:
          response = await _repository.fetchCanceledTrips();
          break;
        default:
          response = await _repository.fetchInProgressTrips();
      }

      if (response.isSuccess) {
        if (response.result is Map<String, dynamic>) {
          var dataList = BookListModel.fromJson(response.result);
          _infoBookingsFetcher.sink.add(dataList.data);
          final rawData = response.result['data'];
          if (rawData is List) {
            _repository.cacheRawList(_cacheKey(status), rawData);
          }
        } else {
          _infoBookingsFetcher.sink.add([]);
        }
      } else if (response.status == -1) {
        // Keep showing cached data on connectivity errors; only surface the
        // error if we had nothing cached to show.
        if (cached.isEmpty) _errorFetcher.sink.add(BlocErrors.noInternet);
      } else {
        if (cached.isEmpty) _errorFetcher.sink.add(BlocErrors.serverError);
      }
    } catch (e) {
      if (cached.isEmpty) _errorFetcher.sink.add(BlocErrors.somethingWentWrong);
    } finally {
      _loadingFetcher.sink.add(false);
    }
  }

  void dispose() {
    _infoBookingsFetcher.close();
    _loadingFetcher.close();
    _errorFetcher.close();
  }
}

HistoryBloc _blocHistory = HistoryBloc();
HistoryBloc get blocHistory => _blocHistory;

void resetHistoryBloc() {
  _blocHistory.dispose();
  _blocHistory = HistoryBloc();
}
