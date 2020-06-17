import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';

class IndoorPath extends StatefulWidget {
  @override
  _IndoorIndoorPath createState() => _IndoorIndoorPath();
}

class _IndoorIndoorPath extends State<IndoorPath> {
  ArCoreController arCoreController;
  Map<int, ArCoreAugmentedImage> augmentedImagesMap = Map();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Indoor Path'),
        ),
        body: ArCoreView(
          onArCoreViewCreated: _onArCoreViewCreated,
          enableTapRecognizer: false,
          enableUpdateListener: false,
          type: ArCoreViewType.AUGMENTEDIMAGES,
        ),
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) async {
    arCoreController = controller;
    arCoreController.onTrackingImage = _handleOnTrackingImage;
    loadSingleImage();
    //OR
    //loadImagesDatabase();
  }

  loadSingleImage() async {
    /*final ByteData bytes =
        await rootBundle.load('assets/earth_augmented_image.jpg');*/
    final ByteData bytes = await rootBundle.load('assets/marker-02.png');
    arCoreController.loadSingleAugmentedImage(
        bytes: bytes.buffer.asUint8List());
  }

  loadImagesDatabase() async {
    final ByteData bytes = await rootBundle.load('assets/myimages.imgdb');
    arCoreController.loadAugmentedImagesDatabase(
        bytes: bytes.buffer.asUint8List());
  }

  _handleOnTrackingImage(ArCoreAugmentedImage augmentedImage) {
    if (!augmentedImagesMap.containsKey(augmentedImage.index)) {
      augmentedImagesMap[augmentedImage.index] = augmentedImage;
      _addPath(augmentedImage);
    }
  }

  Future _addPath(ArCoreAugmentedImage augmentedImage) async {

    print(
        "_addPath ${augmentedImage.centerPose.translation.toString()} ${augmentedImage.centerPose.rotation.toString()}");

    // Debug Spheres
    _addCubeToPos(augmentedImage, vector.Vector3(0, 0, 0), Color.fromARGB(255, 255, 255, 255)); // Gray Centers
    _addSphereToPos(augmentedImage, vector.Vector3(.1, 0, 0), Color.fromARGB(255, 255, 0, 0)); // R (X) <-
    _addSphereToPos(augmentedImage, vector.Vector3(0, .1, 0), Color.fromARGB(255, 0, 255, 0)); // G (Y) versus me
    _addSphereToPos(augmentedImage, vector.Vector3(0, 0, .1), Color.fromARGB(255, 0, 0, 255)); // B (Z) ^

    for (double i=0;i<2;i=i+0.1) {
      final x = i*-1;
      _addSphereToPos(augmentedImage, vector.Vector3(x, 0, -.5), Color.fromARGB(255, 0, 255, 0)); // G
    }

  }

  Future _addSphereToPos(augmentedImage, vector.Vector3 v3, Color color) async {

    final material = ArCoreMaterial(
      color: color
    );
    final sphere = ArCoreSphere(
      materials: [material],
      radius: augmentedImage.extentX / 10,
    );
    final node = ArCoreNode(
      shape: sphere,
      position: v3,
    );
    arCoreController.addArCoreNodeToAugmentedImage(node, augmentedImage.index);
  }

  Future _addCubeToPos(augmentedImage, vector.Vector3 v3, Color color) async {

    final material = ArCoreMaterial(
      color: color
    );

    final s = augmentedImage.extentX / 10;
    final cube = ArCoreCube(
      materials: [material],
      size: vector.Vector3(s,s,s),
    );
    final node = ArCoreNode(
      shape: cube,
      position: v3,
    );
    arCoreController.addArCoreNodeToAugmentedImage(node, augmentedImage.index);
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}
