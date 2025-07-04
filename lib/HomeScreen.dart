import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:city_lens/utils/appbar.dart';
import 'package:city_lens/utils/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'dart:io';
import 'package:flutter/services.dart';


class Homescreen extends StatefulWidget {
  const Homescreen({Key? key}) : super(key: key);

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int _selectedIndex = 0;

  LatLng mylatlong = LatLng(31.405983, 73.123463);
  String landTypePrediction = 'N/A';
  String populationDensityPrediction = 'N/A';
  String developmentSprawlPrediction = 'N/A';
  String landvalue = 'N/A';





  String polygonModelPrediction = 'N/A';
  Interpreter? interpreterLand,
      interpreterPop,
      interpreterDev,
      interpreterPolygon;
  Map<String, dynamic>? idEncoder, labelEncoder;
  GoogleMapController? _controller;
  String? selectedPolygonId;

  MapType _currentMapType = MapType.hybrid;

  @override
  void initState() {
    super.initState();
    _initializePolygonsAndMarkers();
    loadModelsAndEncoders();
  }

  // Function to toggle map type
  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.satellite
          ? MapType.normal
          : _currentMapType == MapType.normal
          ? MapType.hybrid
          : _currentMapType == MapType.hybrid
          ? MapType.terrain
          : MapType.satellite;
    });
  }

  final Map<String, List<LatLng>> polygonsData = {
    'sitaragold': [
      LatLng(31.389384, 73.133357),
      LatLng(31.391614, 73.135679),
      LatLng(31.393651, 73.132909),
      LatLng(31.392270, 73.131609),
      LatLng(31.391072, 73.130869),
      LatLng(31.389384, 73.133357),
    ],
    'satelite_town': [
      LatLng(31.385983, 73.127463),
      LatLng(31.389496, 73.129672),
      LatLng(31.390829, 73.126992),
      LatLng(31.388198, 73.124186),
      LatLng(31.385983, 73.127463),
    ],
    'extra': [
      LatLng(31.389496, 73.129672),
      LatLng(31.391428, 73.130716),
      LatLng(31.392375, 73.129380),
      LatLng(31.390829, 73.126992),
      LatLng(31.389496, 73.129672),
    ],
    'nurpura': [
      LatLng(31.388198, 73.124186),
      LatLng(31.390829, 73.126992),
      LatLng(31.392375, 73.129380),
      LatLng(31.395572, 73.125288),
      LatLng(31.390997, 73.120622),
      LatLng(31.388198, 73.124186),
    ],
    'gulzar_colony': [
      LatLng(31.390997, 73.120622),
      LatLng(31.395572, 73.125288),
      LatLng(31.398480, 73.121558),
      LatLng(31.393950, 73.116777),
      LatLng(31.390997, 73.120622),
    ],
    'mnagar': [
      LatLng(31.393950, 73.116777),
      LatLng(31.398480, 73.121558),
      LatLng(31.400483, 73.119013),
      LatLng(31.395918, 73.114196),
      LatLng(31.393950, 73.116777),
    ],
    'shadman_colony': [
      LatLng(31.395918, 73.114196),
      LatLng(31.401369, 73.119828),
      LatLng(31.403610, 73.116725),
      LatLng(31.398314, 73.111141),
      LatLng(31.395918, 73.114196),
    ],
    'dground1': [
      LatLng(31.398314, 73.111141),
      LatLng(31.403610, 73.116725),
      LatLng(31.407887, 73.111141),
      LatLng(31.402612, 73.105389),
      LatLng(31.398314, 73.111141),
    ],
    'dground2': [
      LatLng(31.402612, 73.105389),
      LatLng(31.407887, 73.111141),
      LatLng(31.411757, 73.106034),
      LatLng(31.406665, 73.100187),
      LatLng(31.402612, 73.105389),
    ],
    'dground3': [
      LatLng(31.406665, 73.100187),
      LatLng(31.411757, 73.106034),
      LatLng(31.415423, 73.101237),
      LatLng(31.410841, 73.094769),
      LatLng(31.406665, 73.100187),
    ],
    'pcA1': [
      LatLng(31.415423, 73.101237),
      LatLng(31.411757, 73.106034),
      LatLng(31.415936, 73.109518),
      LatLng(31.418961, 73.105595),
      LatLng(31.415423, 73.101237),
    ],
    'pcA2': [
      LatLng(31.411757, 73.106034),
      LatLng(31.409054, 73.109742),
      LatLng(31.412787, 73.113391),
      LatLng(31.415936, 73.109518),
      LatLng(31.411757, 73.106034),
    ],
    'pcC1': [
      LatLng(31.409054, 73.109742),
      LatLng(31.406288, 73.113305),
      LatLng(31.409913, 73.117154),
      LatLng(31.412787, 73.113391),
      LatLng(31.409054, 73.109742),
    ],
    'pcC2': [
      LatLng(31.406288, 73.113305),
      LatLng(31.403610, 73.116725),
      LatLng(31.407247, 73.120570),
      LatLng(31.409913, 73.117154),
      LatLng(31.406288, 73.113305),
    ],
    'najaf_colony': [
      LatLng(31.403610, 73.116725),
      LatLng(31.401369, 73.119828),
      LatLng(31.405021, 73.123681),
      LatLng(31.407247, 73.120570),
      LatLng(31.403610, 73.116725),
    ],
    'dhudivala': [
      LatLng(31.400483, 73.119013),
      LatLng(31.398480, 73.121558),
      LatLng(31.402937, 73.126024),
      LatLng(31.404770, 73.123459),
      LatLng(31.400483, 73.119013),
    ],
    'rnagar': [
      LatLng(31.398480, 73.121558),
      LatLng(31.396471, 73.124088),
      LatLng(31.400972, 73.128713),
      LatLng(31.402937, 73.126024),
      LatLng(31.398480, 73.121558),
    ],
    'zubaircolony': [
      LatLng(31.396471, 73.124088),
      LatLng(31.394046, 73.127299),
      LatLng(31.398539, 73.131978),
      LatLng(31.400972, 73.128713),
      LatLng(31.396471, 73.124088),
    ],
    'officercolony_L': [
      LatLng(31.419052, 73.105728),
      LatLng(31.413300, 73.113074),
      LatLng(31.417802, 73.117567),
      LatLng(31.422972, 73.110701),
      LatLng(31.419052, 73.105728),
    ],
    'officercolony1': [
      LatLng(31.423027, 73.110752),
      LatLng(31.417858, 73.117607),
      LatLng(31.421176, 73.120902),
      LatLng(31.426111, 73.115109),
      LatLng(31.423027, 73.110752),
    ],
    'NEMAT_COLONOY2': [
      LatLng(31.411584, 73.125740),
      LatLng(31.407205, 73.120758),
      LatLng(31.405026, 73.123732),
      LatLng(31.409278, 73.128516),
      LatLng(31.411584, 73.125740),
    ],
    'street_3': [
      LatLng(31.409219, 73.128629),
      LatLng(31.404809, 73.123599),
      LatLng(31.401026, 73.128820),
      LatLng(31.405134, 73.133551),
      LatLng(31.409219, 73.128629),
    ],
    'street_3_L': [
      LatLng(31.411981, 73.131649),
      LatLng(31.409266, 73.128685),
      LatLng(31.405158, 73.133553),
      LatLng(31.407919, 73.136327),
      LatLng(31.411981, 73.131649),
    ],
    'Akbar_Colony': [
      LatLng(31.400969, 73.128948),
      LatLng(31.398588, 73.131965),
      LatLng(31.402819, 73.136507),
      LatLng(31.405130, 73.133623),
      LatLng(31.400969, 73.128948),
    ],
    'Akbar_Colony_L': [
      LatLng(31.405202, 73.133684),
      LatLng(31.402868, 73.136527),
      LatLng(31.405304, 73.139369),
      LatLng(31.407815, 73.136356),
      LatLng(31.405202, 73.133684),
    ],
    'ALI_Town': [
      LatLng(31.398564, 73.132035),
      LatLng(31.396171, 73.135173),
      LatLng(31.400169, 73.139491),
      LatLng(31.402739, 73.136543),
      LatLng(31.398564, 73.132035),
    ],
    'st_6': [
      LatLng(31.394039, 73.127384),
      LatLng(31.391510, 73.130778),
      LatLng(31.396106, 73.135127),
      LatLng(31.398445, 73.132036),
      LatLng(31.394039, 73.127384),
    ],
    'NEMAT_COLONOY1': [
      LatLng(31.409441, 73.118233),
      LatLng(31.407402, 73.120794),
      LatLng(31.411594, 73.125629),
      LatLng(31.413714, 73.122667),
      LatLng(31.409441, 73.118233),
    ],
    'sitaragold1': [
      LatLng(31.393663, 73.132898),
      LatLng(31.391614, 73.135681),
      LatLng(31.393923, 73.138180),
      LatLng(31.396102, 73.135169),
      LatLng(31.393663, 73.132898),
    ],
    'L_CANAL_R': [
      LatLng(31.396156, 73.135187),
      LatLng(31.393921, 73.138176),
      LatLng(31.397951, 73.142424),
      LatLng(31.400186, 73.139496),
      LatLng(31.396156, 73.135187),
    ],
    'L_CANAL_R2': [
      LatLng(31.402846, 73.136547),
      LatLng(31.397901, 73.142443),
      LatLng(31.400558, 73.145062),
      LatLng(31.405309, 73.139371),
      LatLng(31.402846, 73.136547),
    ],
    'NEMAT_COLONOY2_L': [
      LatLng(31.413754, 73.122714),
      LatLng(31.409283, 73.128666),
      LatLng(31.411996, 73.131616),
      LatLng(31.416554, 73.125868),
      LatLng(31.413754, 73.122714),
    ],
    'kohinoor1_L': [
      LatLng(31.417748, 73.117602),
      LatLng(31.413776, 73.122714),
      LatLng(31.416597, 73.125843),
      LatLng(31.421134, 73.120858),
      LatLng(31.417748, 73.117602),
    ],
    'kohinoor1': [
      LatLng(31.413279, 73.113111),
      LatLng(31.409409, 73.118195),
      LatLng(31.413748, 73.122683),
      LatLng(31.417813, 73.117576),
      LatLng(31.413279, 73.113111),
    ],

  };


  final Map<String, String> markerNames = {
    'edengardenE': 'Eden Garden',
    'edengardenW': 'Eden Garden West',
    'satelite_town': 'Satellite Town 1',
    'extra': 'Satellite Town 2',
    'satelite_town3': 'Satellite Town 3',
    'rehman_garden': 'Rehman Garden',
    'nurpura': 'Nurpura ',
    'gulzar_colony': 'Gulzar Colony ',
    'mnagar': 'Muhammad Nagar ',
    'shadman_colony': 'Shadman Colony',
    'dground1': 'D-Ground  1 ',
    'dground2': 'D-Ground  2 ',
    'dground3': 'D-Ground  3 ',
    'pcA1': 'People Colony A',
    'pcA2': 'People Colony A',
    'pcB': 'People Colony B',
    'pcC1': 'People Colony C',
    'pcC2': 'People Colony C',
    'najaf_colony': 'Najaf Colony',
    'jinnah_colony': 'Jinnah Colony',
    'madina_town': 'Madina Town',
    'dhudivala': 'Dhudi Wala',
    'rnagar': 'Rasool Nagar ',
    'zubaircolony': 'Zubair Colony',
    'akbarcolony': 'Akbar Colony',
    'kohinoor': 'Kohinoor',
    'kohinoor1': 'Kohinoor 1',
    'nematcolony1': 'Nemat Colony  1 ',
    'nematcolony2': 'Nemat Colony  2 ',
    'sitaragold': 'Sitara Gold',
    'extra1': 'Sitara Gold 1',
  };

  Set<Polygon> _polygons = {};
  Set<Marker> _markers = {};

  Future<BitmapDescriptor> _createCustomMarker(String title) async {
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final size = Size(200, 80); // Size of the marker

    final paint = Paint()..color = Colors.transparent;

    // Draw marker rectangle
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(10)),
      paint,
    );

    // Draw the marker text
    TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.text = TextSpan(
      text: title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(canvas, Offset(10, 20));

    // Convert canvas to an image
    final image = await pictureRecorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(bytes);
  }

//polygon ko initialize or map pa show krta ha ya method
  void _initializePolygonsAndMarkers() async {
    // Clear the previous data
    _polygons.clear();
    // Removed markers initialization as requested

    for (var entry in polygonsData.entries) {
      final polygonId = entry.key;
      final points = entry.value;

      // Add Polygon with dynamic color based on selection
      _polygons.add(
        Polygon(
          polygonId: PolygonId(polygonId),
          points: points,
          strokeColor: Colors.blue,
          strokeWidth: 3,
          fillColor: selectedPolygonId == polygonId
              ? Colors.blue.withOpacity(0.5) // Selected polygon color
              : Colors.transparent,         // Unselected polygon color
          consumeTapEvents: true,
          onTap: () => _onPolygonTap(polygonId),
        ),
      );

      // Calculate the center of the polygon
      final center = _calculatePolygonCenter(points);

    }

    // Update the state to reflect changes
    setState(() {});
  }
  Future<void> _onPolygonTap(String polygonId) async {
    // Update the selected polygon and show prediction placeholders
    setState(() {
      selectedPolygonId = polygonId;
      landTypePrediction = 'Predicting...';
      populationDensityPrediction = 'Predicting...';
      developmentSprawlPrediction = 'Predicting...';
      landvalue = 'Predicting...';
    });

    _initializePolygonsAndMarkers();

    LatLngBounds? bounds = polygonBounds[polygonId];
    if (bounds == null) {
      print("Polygon bounds not found.");
      return;
    }

    // Animate the camera to the selected polygon
    await _controller?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );

    await Future.delayed(Duration(seconds: 4)); // Allow time for map to render

    // Take a snapshot of the polygon
    Uint8List? capturedImage = await _controller?.takeSnapshot();
    if (capturedImage == null) {
      print("Snapshot is null.");
      return;
    }

    // Decode and crop the snapshot
    img.Image? fullImage = img.decodeImage(capturedImage);
    if (fullImage == null) {
      print("Error decoding snapshot.");
      return;
    }

    img.Image croppedImage = cropPolygon(fullImage, bounds);

    // Process predictions
    bool errorClass = idEncoder == null ||
        !idEncoder!.containsKey('classes') ||
        !(idEncoder!['classes'] as List<dynamic>).contains(polygonId);

    if (errorClass) {
      await processImageForPrediction(capturedImage);
      setState(() {
        landvalue = 'Increasing';
      });
    } else {
      await processpolygon(polygonId);
      setState(() {
        landvalue = 'Increasing';
      });
    }

    // Save prediction history with the cropped snapshot
    String landType = landTypePrediction;
    String populationDensity = populationDensityPrediction;
    String developmentSprawl = developmentSprawlPrediction;

    await savePredictionHistory(
      landType,
      populationDensity,
      developmentSprawl,
      Uint8List.fromList(img.encodePng(croppedImage)),
    );

    setState(() {
      print("All predictions updated in UI and saved in Firebase.");
    });
  }


  LatLng _calculatePolygonCenter(List<LatLng> points) {
    double latitude = 0;
    double longitude = 0;

    for (LatLng point in points) {
      latitude += point.latitude;
      longitude += point.longitude;
    }

    return LatLng(latitude / points.length, longitude / points.length);
  }

  Future<void> loadModelsAndEncoders() async {
    final conditions = FirebaseModelDownloadConditions();
    try {
      final customModelLand = await FirebaseModelDownloader.instance.getModel(
          'LandType', FirebaseModelDownloadType.localModel, conditions);
      interpreterLand = await Interpreter.fromFile(customModelLand.file);

      final customModelPop = await FirebaseModelDownloader.instance.getModel(
          'PopDenisty', FirebaseModelDownloadType.localModel, conditions);
      interpreterPop = await Interpreter.fromFile(customModelPop.file);

      final customModelDev = await FirebaseModelDownloader.instance.getModel(
          'DevSprawl', FirebaseModelDownloadType.localModel, conditions);
      interpreterDev = await Interpreter.fromFile(customModelDev.file);

      final polygonModel = await FirebaseModelDownloader.instance.getModel(
          'combine', FirebaseModelDownloadType.localModel, conditions);
      interpreterPolygon = await Interpreter.fromFile(polygonModel.file);

      final idEncoderData =
      await rootBundle.loadString('assets/id_encoder.json');
      idEncoder = json.decode(idEncoderData);

      final labelEncoderData =
      await rootBundle.loadString('assets/label_encoder.json');
      labelEncoder = json.decode(labelEncoderData);

      print("\x1B[32mAll models and encoders loaded successfully\x1B[0m");
    } catch (error) {
      print("Error downloading/loading models or encoders: $error");
      interpreterLand =
          interpreterPop = interpreterDev = interpreterPolygon = null;
      idEncoder = labelEncoder = null;
    }
  }

  Future<void> _predictLandType(List<List<List<List<double>>>> input) async {
    var outputTensor = List.filled(1, List.filled(2, 0.0));
    interpreterLand!.allocateTensors();
    interpreterLand!.run(input, outputTensor);

    int classIdx = outputTensor[0].indexWhere(
            (e) => e == outputTensor[0].reduce((a, b) => a > b ? a : b));
    setState(() {
      landTypePrediction = ['Urban', 'Rural'][classIdx];
    });
  }

  Future<void> _predictPopulationDensity(
      List<List<List<List<double>>>> input) async {
    var outputTensor = List.filled(1, List.filled(3, 0.0));
    interpreterPop!.allocateTensors();
    interpreterPop!.run(input, outputTensor);

    int classIdx = outputTensor[0].indexWhere(
            (e) => e == outputTensor[0].reduce((a, b) => a > b ? a : b));
    setState(() {
      populationDensityPrediction = ['Low', 'Medium', 'High'][classIdx];
    });
  }

  Future<void> _predictDevelopmentSprawl(
      List<List<List<List<double>>>> input) async {
    var outputTensor = List.filled(1, List.filled(2, 0.0));
    interpreterDev!.allocateTensors();
    interpreterDev!.run(input, outputTensor);

    int classIdx = outputTensor[0].indexWhere(
            (e) => e == outputTensor[0].reduce((a, b) => a > b ? a : b));
    setState(() {
      developmentSprawlPrediction = ['Agricultural', 'Developing'][classIdx];
    });
  }

// Cropping the image to bounds with an adjustable margin for zoom
  img.Image cropPolygon(img.Image image, LatLngBounds bounds) {
    double lngMin = bounds.southwest.longitude;
    double lngMax = bounds.northeast.longitude;
    double latMin = bounds.southwest.latitude;
    double latMax = bounds.northeast.latitude;

    int mapWidth = image.width;
    int mapHeight = image.height;

    // Define a zoom scale factor
    double scaleFactor = 0.8; // Adjust this value for desired zoom (e.g., 0.8 for 20% tighter crop)

    // Adjust bounds based on the scale factor
    double lngCenter = (lngMin + lngMax) / 2;
    double latCenter = (latMin + latMax) / 2;

    double newLngHalfRange = (lngMax - lngMin) / 2 * scaleFactor;
    double newLatHalfRange = (latMax - latMin) / 2 * scaleFactor;

    double newLngMin = lngCenter - newLngHalfRange;
    double newLngMax = lngCenter + newLngHalfRange;
    double newLatMin = latCenter - newLatHalfRange;
    double newLatMax = latCenter + newLatHalfRange;

    // Use the helper methods to calculate pixel coordinates
    int xStart = latLngToPixelX(newLngMin, mapWidth, lngMin, lngMax);
    int yStart = latLngToPixelY(newLatMax, mapHeight, latMin, latMax);
    int xEnd = latLngToPixelX(newLngMax, mapWidth, lngMin, lngMax);
    int yEnd = latLngToPixelY(newLatMin, mapHeight, latMin, latMax);

    int width = xEnd - xStart;
    int height = yEnd - yStart;

    // Ensure dimensions are valid
    width = width > 0 ? width : 1;
    height = height > 0 ? height : 1;

    // Crop and return the image
    return img.copyCrop(image, xStart, yStart, width, height);
  }

// Helper methods remain unchanged
  int latLngToPixelX(
      double longitude, int mapWidth, double lngMin, double lngMax) {
    return ((longitude - lngMin) / (lngMax - lngMin) * mapWidth).round();
  }

  int latLngToPixelY(
      double latitude, int mapHeight, double latMin, double latMax) {
    return ((1 - (latitude - latMin) / (latMax - latMin)) * mapHeight).round();
  }

// Legacy cropToBounds function (not used directly in this case but can be updated similarly)
  img.Image cropToBounds(img.Image image, LatLngBounds bounds) {
    // Calculate pixel coordinates corresponding to bounds with a margin
    int xStart = 100;
    int yStart = 100;
    int xEnd = 300;
    int yEnd = 300;

    // Add margin to the crop for a tighter zoom (adjust hardcoded values if needed)
    int margin = 10; // Example margin in pixels
    xStart -= margin;
    yStart -= margin;
    xEnd += margin;
    yEnd += margin;

    int width = xEnd - xStart;
    int height = yEnd - yStart;

    // Crop and return the image
    return img.copyCrop(image, xStart, yStart, width, height);
  }


  Future<void> processImageForPrediction(Uint8List capturedImage) async {
    if (interpreterLand == null ||
        interpreterPop == null ||
        interpreterDev == null) {
      print("\x1B[31mOne or more interpreters are null.\x1B[0m");
      return;
    }

    try {
      img.Image? image = img.decodeImage(Uint8List.fromList(capturedImage));
      if (image == null) {
        print("\x1B[31mDecoded image is null.\x1B[0m");
        return;
      }
      img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

      var input = List.generate(
        1,
            (_) => List.generate(
          224,
              (i) => List.generate(
            224,
                (j) {
              int pixel = resizedImage.getPixel(j, i);
              return [
                img.getRed(pixel) / 255.0,
                img.getGreen(pixel) / 255.0,
                img.getBlue(pixel) / 255.0
              ];
            },
          ),
        ),
      );

      await _predictLandType(input);
      await _predictPopulationDensity(input);
      await _predictDevelopmentSprawl(input);

      print("\x1B[32mPredictions updated in UI.\x1B[0m");

      savePredictionHistory(landTypePrediction, populationDensityPrediction,
          developmentSprawlPrediction, capturedImage);
    } catch (e) {
      print("\x1B[31mError during prediction: $e\x1B[0m");
    }
  }

  Future<void> processpolygon(String imag) async {
    if (interpreterPolygon == null ||
        idEncoder == null ||
        labelEncoder == null) {
      print("Polygon model or encoders are null.");
      return;
    }

    try {
      if (!idEncoder!.containsKey('classes')) {
        return;
      }

      final classes = idEncoder!['classes'] as List<dynamic>;
      if (!classes.contains(imag)) {
        return;
      }

      final encodedId = classes.indexOf(imag);

      var input = [encodedId];

      var output =
      List.filled(1, List.filled(labelEncoder!['classes'].length, 0.0));

      // Run inference
      interpreterPolygon!.allocateTensors();
      interpreterPolygon!.run(input, output);

      int classIdx = output[0]
          .indexWhere((e) => e == output[0].reduce((a, b) => a > b ? a : b));
      polygonModelPrediction = labelEncoder!['classes'][classIdx];

      List<String> predictions = polygonModelPrediction.split(',');
      setState(() {
        landTypePrediction = predictions.isNotEmpty ? predictions[0] : 'N/A';
        populationDensityPrediction =
        predictions.length > 1 ? predictions[1] : 'N/A';
        developmentSprawlPrediction =
        predictions.length > 2 ? predictions[2] : 'N/A';
        landvalue = 'Increasing';
      });

      print(
          "Prediction Result -> Land: $landTypePrediction, Population: $populationDensityPrediction, Development: $developmentSprawlPrediction");
    } catch (e) {
      print("Error during polygon model prediction: $e");
    }
  }


  Future<void> savePredictionHistory(
      String landType,
      String populationDensity,
      String developmentSprawl,
      Uint8List snapshotImage,
      ) async {
    try {
      String? userEmail = FirebaseAuth.instance.currentUser?.email;

      if (userEmail != null) {
        String imageUrl = await uploadSnapshotToFirebase(snapshotImage);

        if (imageUrl.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userEmail)
              .collection('history')
              .doc()
              .set({
            'landType': landType,
            'populationDensity': populationDensity,
            'developmentSprawl': developmentSprawl,
            'snapshotUrl': imageUrl,
            'timestamp': FieldValue.serverTimestamp(),
          });

          print('Prediction history saved successfully for user: $userEmail.');
        } else {
          print("Failed to upload snapshot, skipping history save.");
        }
      } else {
        print('No user is logged in.');
      }
    } catch (e) {
      print('Failed to save prediction history: $e');
    }
  }

  Future<String> uploadSnapshotToFirebase(Uint8List snapshotImage) async {
    try {
      // Generate a unique file path
      String filePath =
          'snapshots/${DateTime.now().millisecondsSinceEpoch}.png';

      // Upload the snapshot to Firebase Storage
      TaskSnapshot snapshot =
      await FirebaseStorage.instance.ref(filePath).putData(snapshotImage);

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Snapshot uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading snapshot: $e');
      return '';
    }
  }

  final Map<String, LatLngBounds> polygonBounds = {
    'sitaragold': LatLngBounds(
      southwest: LatLng(31.389384, 73.130869),
      northeast: LatLng(31.393651, 73.135679),
    ),
    'satelite_town': LatLngBounds(
      southwest: LatLng(31.385983, 73.124186),
      northeast: LatLng(31.390829, 73.129672),
    ),
    'extra': LatLngBounds(
      southwest: LatLng(31.389496, 73.126992),
      northeast: LatLng(31.392375, 73.130716),
    ),
    'nurpura': LatLngBounds(
      southwest: LatLng(31.388198, 73.120622),
      northeast: LatLng(31.395572, 73.129380),
    ),
    'gulzar_colony': LatLngBounds(
      southwest: LatLng(31.390997, 73.116777),
      northeast: LatLng(31.398480, 73.125288),
    ),
    'mnagar': LatLngBounds(
      southwest: LatLng(31.393950, 73.114196),
      northeast: LatLng(31.400483, 73.121558),
    ),
    'shadman_colony': LatLngBounds(
      southwest: LatLng(31.395918, 73.111141),
      northeast: LatLng(31.403610, 73.119828),
    ),
    'dground1': LatLngBounds(
      southwest: LatLng(31.398314, 73.105389),
      northeast: LatLng(31.407887, 73.116725),
    ),
    'dground2': LatLngBounds(
      southwest: LatLng(31.402612, 73.100187),
      northeast: LatLng(31.411757, 73.111141),
    ),
    'dground3': LatLngBounds(
      southwest: LatLng(31.406665, 73.094769),
      northeast: LatLng(31.415423, 73.106034),
    ),
    'pcA1': LatLngBounds(
      southwest: LatLng(31.411757, 73.101237),
      northeast: LatLng(31.418961, 73.109518),
    ),
    'pcA2': LatLngBounds(
      southwest: LatLng(31.409054, 73.106034),
      northeast: LatLng(31.415936, 73.113391),
    ),
    'pcC1': LatLngBounds(
      southwest: LatLng(31.406288, 73.109742),
      northeast: LatLng(31.412787, 73.117154),
    ),
    'pcC2': LatLngBounds(
      southwest: LatLng(31.403610, 73.113305),
      northeast: LatLng(31.409913, 73.120570),
    ),
    'najaf_colony': LatLngBounds(
      southwest: LatLng(31.401369, 73.116725),
      northeast: LatLng(31.407247, 73.123681),
    ),
    'dhudivala': LatLngBounds(
      southwest: LatLng(31.398480, 73.119013),
      northeast: LatLng(31.404770, 73.126024),
    ),
    'rnagar': LatLngBounds(
      southwest: LatLng(31.396471, 73.121558),
      northeast: LatLng(31.402937, 73.128713),
    ),
    'zubaircolony': LatLngBounds(
      southwest: LatLng(31.394046, 73.124088),
      northeast: LatLng(31.400972, 73.131978),
    ),
    'officercolony_L': LatLngBounds(
      southwest: LatLng(31.413300, 73.105728),
      northeast: LatLng(31.422972, 73.117567),
    ),
    'officercolony1': LatLngBounds(
      southwest: LatLng(31.417858, 73.110752),
      northeast: LatLng(31.426111, 73.120902),
    ),
    'NEMAT_COLONOY2': LatLngBounds(
      southwest: LatLng(31.405026, 73.120758),
      northeast: LatLng(31.411584, 73.128516),
    ),
    'street_3': LatLngBounds(
      southwest: LatLng(31.401026, 73.123599),
      northeast: LatLng(31.409219, 73.133551),
    ),
    'street_3_L': LatLngBounds(
      southwest: LatLng(31.405158, 73.128685),
      northeast: LatLng(31.411981, 73.136327),
    ),
    'Akbar_Colony': LatLngBounds(
      southwest: LatLng(31.398588, 73.128948),
      northeast: LatLng(31.405130, 73.136507),
    ),
    'Akbar_Colony_L': LatLngBounds(
      southwest: LatLng(31.402868, 73.133684),
      northeast: LatLng(31.407815, 73.139369),
    ),
    'ALI_Town': LatLngBounds(
      southwest: LatLng(31.396171, 73.132035),
      northeast: LatLng(31.402739, 73.139491),
    ),
    'st_6': LatLngBounds(
      southwest: LatLng(31.391510, 73.127384),
      northeast: LatLng(31.398445, 73.135127),
    ),
    'NEMAT_COLONOY1': LatLngBounds(
      southwest: LatLng(31.407402, 73.118233),
      northeast: LatLng(31.413714, 73.125629),
    ),
    'sitaragold1': LatLngBounds(
      southwest: LatLng(31.391614, 73.132898),
      northeast: LatLng(31.396102, 73.138180),
    ),
    'L_CANAL_R': LatLngBounds(
      southwest: LatLng(31.393921, 73.135187),
      northeast: LatLng(31.400186, 73.142424),
    ),
    'L_CANAL_R2': LatLngBounds(
      southwest: LatLng(31.397901, 73.136547),
      northeast: LatLng(31.405309, 73.145062),
    ),
    'NEMAT_COLONOY2_L': LatLngBounds(
      southwest: LatLng(31.409283, 73.122714),
      northeast: LatLng(31.416554, 73.131616),
    ),
    'kohinoor1_L': LatLngBounds(
      southwest: LatLng(31.413776, 73.117602),
      northeast: LatLng(31.421134, 73.125843),
    ),
    'kohinoor1': LatLngBounds(
      southwest: LatLng(31.409409, 73.113111),
      northeast: LatLng(31.417813, 73.122683),
    ),

  };




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade400,
      appBar: CustomAppBar(title: 'City Lens'),
      endDrawer: CustomDrawer(),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 420,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: mylatlong,
                      zoom: 15,
                    ),
                    myLocationEnabled: true,
                    zoomControlsEnabled: true,
                    zoomGesturesEnabled: true,
                    mapType: _currentMapType, // Use the toggle variable
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                              () => EagerGestureRecognizer()),
                    },
                    polygons: _polygons,
                    markers: _markers,

                    onMapCreated: (GoogleMapController controller) {
                      _controller = controller;
                    },
                  ),
                  // Add map type toggle button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: FloatingActionButton(
                      onPressed: _onMapTypeButtonPressed,
                      mini: true,
                      backgroundColor: Colors.white.withOpacity(0.8),
                      child: Icon(
                        Icons.layers,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    blurRadius: 2,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, color: Colors.black, size: 24),
                      SizedBox(width: 5),
                      Text(
                        'Future Insights',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                    ],
                  ),
                  Divider(color: Colors.black,),
                  buildInfoRow('Land Type', landTypePrediction),
                  Divider(),
                  buildInfoRow(
                      'Population Density', populationDensityPrediction),
                  Divider(),
                  buildInfoRow('Land Value', landvalue),
                  Divider(),
                  buildInfoRow(
                      'Development Sprawl', developmentSprawlPrediction),
                  Divider(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget buildInfoRow(String label, String value) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$label: ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                if (value == 'Predicting...')
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(color: Colors.lightBlue,strokeWidth: 2),
                    ),
                  ),
                Text(
                  value,
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
