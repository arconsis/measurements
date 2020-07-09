import 'dart:async';
///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:measurements/measurements.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:measurements/style/magnification_style.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/test_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("Metadata Repository Unit Test", () {
    final viewSize = Size(200, 300);
    final methodChannel = MethodChannel("measurements");
    final pixelPerInch = 10.0;

    final expectedMeasurement = true;
    final expectedShowDistance = true;
    final MeasurementController expectedController = MeasurementController();
    final expectedMeasurementInformation = MeasurementInformation(documentWidthInLengthUnits: Inch(200), documentHeightInLengthUnits: Inch(200), scale: 4.0, targetLengthUnit: Inch.asUnit());
    final expectedViewCenter = Offset(100, 150);
    final Image expectedImage = MockedImage.mock;
    final expectedMagnificationStyle = MagnificationStyle();

    final expectedImageScaleFactor = 3.0;
    final expectedTransformationFactor = Inch(1 / 4);
    final expectedZoomFactor = 5 / 6;
    final expectedImageToDocumentFactor = expectedMeasurementInformation.documentWidthInLengthUnits.value.toDouble() / viewSize.width;

    MetadataRepository metadataRepository;

    setUpAll(() {
      methodChannel.setMockMethodCallHandler((call) async {
        if (call.method == "getPhysicalPixelsPerInch") {
          return pixelPerInch;
        } else {
          return -1.0;
        }
      });
    });

    setUp(() {
      metadataRepository = MetadataRepository();
    });

    tearDown(() {
      metadataRepository.dispose();
    });

    tearDownAll(() {
      methodChannel.setMockMethodCallHandler(null);
    });

    test("started", () {
      when((expectedImage as MockedImage).width).thenReturn(600);

      metadataRepository.registerStartupValuesChange(
        measurementInformation: expectedMeasurementInformation,
        measure: expectedMeasurement,
        showDistance: expectedShowDistance,
        magnificationStyle: expectedMagnificationStyle,
        controller: expectedController,
      );

      metadataRepository.registerBackgroundChange(expectedImage, viewSize);

      metadataRepository.measurement.listen((actual) => expect(actual, expectedMeasurement));
      metadataRepository.showDistances.listen((actual) => expect(actual, expectedShowDistance));
      metadataRepository.controller.listen((actual) => expect(actual, expectedController));
      metadataRepository.viewCenter.listen((actual) => expect(actual, expectedViewCenter));
      metadataRepository.backgroundImage.listen((actual) => expect(actual, expectedImage));

      metadataRepository.imageScaleFactor.listen((actual) => expect(actual, expectedImageScaleFactor));
      metadataRepository.transformationFactor.listen((actual) => expect(actual, expectedTransformationFactor));
      metadataRepository.imageToDocumentScaleFactor.listen((actual) => expect(actual, expectedImageToDocumentFactor));
    });

    test("started and updated view size", () {
      final updatedViewSize = Size(400, 100);

      when((expectedImage as MockedImage).width).thenReturn(600);

      metadataRepository.registerStartupValuesChange(
        measurementInformation: expectedMeasurementInformation,
        measure: expectedMeasurement,
        showDistance: expectedShowDistance,
        magnificationStyle: expectedMagnificationStyle,
        controller: expectedController,
      );

      metadataRepository.registerBackgroundChange(expectedImage, viewSize);

      StreamSubscription<double> subscription;
      subscription = metadataRepository.imageToDocumentScaleFactor.listen((actual) {
        expect(actual, expectedImageToDocumentFactor);
        subscription.cancel();
      });

      metadataRepository.registerBackgroundChange(expectedImage, updatedViewSize);
      metadataRepository.imageToDocumentScaleFactor.listen((actual) => expect(actual, expectedMeasurementInformation.documentHeightInLengthUnits.value.toDouble() / updatedViewSize.height));
    });

    group("original zoom factor", () {
      test("started without background and get zoom factor for original size", () async {
        metadataRepository.registerStartupValuesChange(
          measurementInformation: expectedMeasurementInformation,
          measure: expectedMeasurement,
          showDistance: expectedShowDistance,
          magnificationStyle: expectedMagnificationStyle,
          controller: expectedController,
        );

        expect(await metadataRepository.zoomFactorForOriginalSize, equals(1.0));
      });

      test("started and retrieve zoom factor for original size", () async {
        when((expectedImage as MockedImage).width).thenReturn(600);

        metadataRepository.registerStartupValuesChange(
          measurementInformation: expectedMeasurementInformation,
          measure: expectedMeasurement,
          showDistance: expectedShowDistance,
          magnificationStyle: expectedMagnificationStyle,
          controller: expectedController,
        );

        metadataRepository.registerBackgroundChange(expectedImage, viewSize);
        metadataRepository.registerScreenSize(Size(200, 300));

        expect(await metadataRepository.zoomFactorForOriginalSize, equals(expectedZoomFactor));
      });
    });
  });
}
