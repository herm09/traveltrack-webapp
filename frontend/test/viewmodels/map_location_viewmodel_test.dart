import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:traveltrack/src/models/user_location.dart';
import 'package:traveltrack/src/services/location_service.dart';
import 'package:traveltrack/src/services/permission_service.dart';
import 'package:traveltrack/src/viewmodels/map_location_viewmodel.dart';

class FakeLocationService implements LocationService {
  bool isServiceEnabled = true;
  int watchCallCount = 0;
  final StreamController<UserLocation> userLocationController =
      StreamController<UserLocation>.broadcast();

  @override
  Future<bool> isLocationServiceEnabled() async => isServiceEnabled;

  @override
  Stream<UserLocation> watchUserLocation() {
    watchCallCount++;
    return userLocationController.stream;
  }
}

class FakePermissionService implements PermissionService {
  FakePermissionService({
    required this.locationPermissionStatus,
    this.statusAfterRequest = AppPermissionStatus.granted,
  });

  AppPermissionStatus locationPermissionStatus;
  AppPermissionStatus statusAfterRequest;
  int requestCallCount = 0;

  @override
  Future<AppPermissionStatus> checkLocationPermission() async =>
      locationPermissionStatus;

  @override
  Future<bool> requestLocationPermission() async {
    requestCallCount++;
    locationPermissionStatus = statusAfterRequest;
    return statusAfterRequest == AppPermissionStatus.granted;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const parisLocation = UserLocation(
  latitude: 48.8566,
  longitude: 2.3522,
  accuracyInMeters: 10,
);
const austerlitzLocation = UserLocation(
  latitude: 48.8422,
  longitude: 2.3655,
  accuracyInMeters: 10,
);

void main() {
  late FakeLocationService fakeLocationService;

  setUp(() => fakeLocationService = FakeLocationService());

  MapLocationViewModel buildViewModel(FakePermissionService permissions) {
    return MapLocationViewModel(
      locationService: fakeLocationService,
      permissionService: permissions,
    );
  }

  test(
    "à l'ouverture, ne demande rien si l'accès n'a jamais été accordé",
    () async {
      final permissions = FakePermissionService(
        locationPermissionStatus: AppPermissionStatus.prompt,
      );
      final viewModel = buildViewModel(permissions);

      await viewModel.startTrackingIfAlreadyAllowed();

      expect(permissions.requestCallCount, 0);
      expect(fakeLocationService.watchCallCount, 0);
      expect(viewModel.status, UserLocationStatus.notStarted);
    },
  );

  test(
    "à l'ouverture, suit et centre la carte si l'accès est déjà accordé",
    () async {
      final permissions = FakePermissionService(
        locationPermissionStatus: AppPermissionStatus.granted,
      );
      final viewModel = buildViewModel(permissions);
      final recenterRequests = <MapRecenterRequest>[];
      viewModel.recenterRequests.listen(recenterRequests.add);

      await viewModel.startTrackingIfAlreadyAllowed();
      fakeLocationService.userLocationController.add(parisLocation);
      await pumpEventQueue();

      expect(permissions.requestCallCount, 0);
      expect(viewModel.status, UserLocationStatus.tracking);
      expect(viewModel.currentLocation, parisLocation);
      expect(recenterRequests, hasLength(1));
    },
  );

  test('le bouton demande l\'autorisation puis recentre la carte', () async {
    final permissions = FakePermissionService(
      locationPermissionStatus: AppPermissionStatus.prompt,
    );
    final viewModel = buildViewModel(permissions);
    final recenterRequests = <MapRecenterRequest>[];
    viewModel.recenterRequests.listen(recenterRequests.add);

    await viewModel.onRecenterButtonPressed();
    fakeLocationService.userLocationController.add(parisLocation);
    await pumpEventQueue();

    expect(permissions.requestCallCount, 1);
    expect(viewModel.status, UserLocationStatus.tracking);
    expect(recenterRequests.single.isRequestedByUser, isTrue);
  });

  test('un refus définitif bloque sans redemander', () async {
    final permissions = FakePermissionService(
      locationPermissionStatus: AppPermissionStatus.prompt,
      statusAfterRequest: AppPermissionStatus.denied,
    );
    final viewModel = buildViewModel(permissions);

    await viewModel.onRecenterButtonPressed();
    expect(viewModel.status, UserLocationStatus.permissionBlocked);
    expect(viewModel.isErrorMessageVisible, isTrue);

    await viewModel.onRecenterButtonPressed();
    expect(permissions.requestCallCount, 1);
  });

  test('une demande fermée sans réponse peut être reproposée', () async {
    final permissions = FakePermissionService(
      locationPermissionStatus: AppPermissionStatus.prompt,
      statusAfterRequest: AppPermissionStatus.prompt,
    );
    final viewModel = buildViewModel(permissions);

    await viewModel.onRecenterButtonPressed();
    expect(viewModel.status, UserLocationStatus.permissionDismissed);

    await viewModel.onRecenterButtonPressed();
    expect(permissions.requestCallCount, 2);
  });

  test('géolocalisation indisponible dans le navigateur', () async {
    fakeLocationService.isServiceEnabled = false;
    final viewModel = buildViewModel(
      FakePermissionService(
        locationPermissionStatus: AppPermissionStatus.granted,
      ),
    );

    await viewModel.onRecenterButtonPressed();

    expect(viewModel.status, UserLocationStatus.serviceUnavailable);
  });

  test(
    "déplacer la carte au doigt arrête le suivi jusqu'au prochain appui",
    () async {
      final viewModel = buildViewModel(
        FakePermissionService(
          locationPermissionStatus: AppPermissionStatus.granted,
        ),
      );
      final recenterRequests = <MapRecenterRequest>[];
      viewModel.recenterRequests.listen(recenterRequests.add);

      await viewModel.startTrackingIfAlreadyAllowed();
      fakeLocationService.userLocationController.add(parisLocation);
      await pumpEventQueue();

      viewModel.onMapMovedByUser();
      fakeLocationService.userLocationController.add(austerlitzLocation);
      await pumpEventQueue();
      expect(viewModel.isFollowingUser, isFalse);
      expect(recenterRequests, hasLength(1));
      expect(viewModel.currentLocation, austerlitzLocation);

      await viewModel.onRecenterButtonPressed();
      await pumpEventQueue();
      expect(viewModel.isFollowingUser, isTrue);
      expect(recenterRequests, hasLength(2));
      expect(recenterRequests.last.location, austerlitzLocation);
    },
  );

  test('une erreur passagère garde la dernière position et le suivi', () async {
    final viewModel = buildViewModel(
      FakePermissionService(
        locationPermissionStatus: AppPermissionStatus.granted,
      ),
    );

    await viewModel.startTrackingIfAlreadyAllowed();
    fakeLocationService.userLocationController.add(parisLocation);
    fakeLocationService.userLocationController.addError(
      const LocationUnavailableException('timeout'),
    );
    await pumpEventQueue();
    expect(viewModel.status, UserLocationStatus.positionUnavailable);
    expect(viewModel.currentLocation, parisLocation);

    fakeLocationService.userLocationController.add(austerlitzLocation);
    await pumpEventQueue();
    expect(viewModel.status, UserLocationStatus.tracking);
  });

  test("le retrait de l'autorisation pendant le suivi est signalé", () async {
    final viewModel = buildViewModel(
      FakePermissionService(
        locationPermissionStatus: AppPermissionStatus.granted,
      ),
    );

    await viewModel.startTrackingIfAlreadyAllowed();
    fakeLocationService.userLocationController.add(parisLocation);
    fakeLocationService.userLocationController.addError(
      const LocationPermissionRevokedException(),
    );
    await pumpEventQueue();

    expect(viewModel.status, UserLocationStatus.permissionBlocked);
    expect(viewModel.currentLocation, isNull);
  });
}
