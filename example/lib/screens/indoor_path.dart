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
      //_addPath(augmentedImage);
      _addChildrenTest(augmentedImage);
    }
  }

  Future _addPath(ArCoreAugmentedImage augmentedImage) async {
    print(
        "_addPath ${augmentedImage.centerPose.translation.toString()} ${augmentedImage.centerPose.rotation.toString()}");

    // Debug Spheres
    _addCubeToPos(augmentedImage, vector.Vector3(0, 0, 0),
        Color.fromARGB(255, 255, 255, 255)); // Gray Centers

    _addSphereToPos(augmentedImage, vector.Vector3(.1, 0, 0),
        Color.fromARGB(255, 255, 0, 0)); // R (X) <-
    _addSphereToPos(augmentedImage, vector.Vector3(0, .1, 0),
        Color.fromARGB(255, 0, 255, 0)); // G (Y) versus me
    _addSphereToPos(augmentedImage, vector.Vector3(0, 0, .1),
        Color.fromARGB(255, 0, 0, 255)); // B (Z) ^

    for (double i = 0; i < 2; i = i + 0.1) {
      final x = i * -1;
      _addSphereToPos(augmentedImage, vector.Vector3(x, 0, -.5),
          Color.fromARGB(255, 0, 255, 0)); // G
    }
  }

  Future _addChildrenTest(ArCoreAugmentedImage augmentedImage) {
    final material = ArCoreMaterial(color: Color.fromARGB(255, 255, 255, 0));
    final sphere = ArCoreSphere(
      materials: [material],
      radius: augmentedImage.extentX / 10,
    );
    List<ArCoreNode> acn = [];
    for (double i = 0; i < 2; i = i + 0.1) {
      final x = i * -1;
      vector.Vector3 v3 = vector.Vector3(x, 0, 0);
      final node = ArCoreNode(
        shape: sphere,
        position: v3,
      );
      acn.add(node);
    }

    

    /*
    var value: Float = 5.0

    override fun onLeft(value: Float) {
        cubeNode.apply {
            Log.d("left", value.toString())
            localRotationCCW = Quaternion.axisAngle(Vector3(0.0f, 1.0f, 0.0f), value)
        }
    } 


    https://proandroiddev.com/arcore-cupcakes-4-understanding-quaternion-rotations-f90703f3966e

    */

    final double theta = 0; //acos(directionA.dot(directionB));
    final vector.Vector3 rotationAxis = vector.Vector3(0, 0, 1);
    vector.Quaternion quaternion =
        vector.Quaternion.axisAngle(rotationAxis, theta);
    vector.Vector4 v4rot =
        vector.Vector4(quaternion.x, quaternion.y, quaternion.z, quaternion.w);

    //vector.Vector4 v4rot = vector.Vector4(0,0,1,-87);

    final w = augmentedImage.extentX / 10;
    final h = w * 2;
    final l = w * 4;

    vector.Vector3 v3 = vector.Vector3(0, 0, 0);

    final cube = ArCoreCube(
      materials: [material],
      size: vector.Vector3(w, h, l),
    );
    final node = ArCoreNode(
      shape: cube,
      position: v3,
      rotation: v4rot,
      children: acn
    );

    print("ArCoreCube ${node.rotation.toString()}");
    arCoreController.addArCoreNodeToAugmentedImage(node, augmentedImage.index);

  }

  Future _addSphereToPos(augmentedImage, vector.Vector3 v3, Color color) async {
    final material = ArCoreMaterial(color: color);
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

  Future _addCubeToPos(ArCoreAugmentedImage augmentedImage, vector.Vector3 v3, Color color) async {
    final material = ArCoreMaterial(color: color);

    /*
    var value: Float = 5.0

    override fun onLeft(value: Float) {
        cubeNode.apply {
            Log.d("left", value.toString())
            localRotationCCW = Quaternion.axisAngle(Vector3(0.0f, 1.0f, 0.0f), value)
        }
    } 


    https://proandroiddev.com/arcore-cupcakes-4-understanding-quaternion-rotations-f90703f3966e

    */

    final double theta = 0; //acos(directionA.dot(directionB));
    final vector.Vector3 rotationAxis = vector.Vector3(0, 0, 1);
    vector.Quaternion quaternion =
        vector.Quaternion.axisAngle(rotationAxis, theta);
    vector.Vector4 v4rot =
        vector.Vector4(quaternion.x, quaternion.y, quaternion.z, quaternion.w);

    //vector.Vector4 v4rot = vector.Vector4(0,0,1,-87);

    final xw = augmentedImage.extentX;
    final yw = augmentedImage.extentZ;
    final zw = augmentedImage.extentX / 10;

    final cube = ArCoreCube(
      materials: [material],
      size: vector.Vector3(xw, yw, zw),
    );
    final node = ArCoreNode(
      shape: cube,
      position: v3,
      rotation: v4rot,
    );

    print("ArCoreCube ${node.rotation.toString()}");
    arCoreController.addArCoreNodeToAugmentedImage(node, augmentedImage.index);
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}
