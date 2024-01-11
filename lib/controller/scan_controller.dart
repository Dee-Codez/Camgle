import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite/tflite.dart';

class ScanController extends GetxController {

  @override
  void onInit(){
    super.onInit();
    initCamera();
    initTFLite();
  }

  @override
  void dispose(){
    super.dispose();
    cameraController.dispose();
  }

  late CameraController cameraController;
  late List<CameraDescription> cameras;

  var isCameraInit = false.obs;
  var cameraCount = 0;

  var x = 0.0;
  var y = 0.0;
  var h = 0.0;
  var w = 0.0;
  var label = "";
  var nconf;

  initCamera() async{
    if(await Permission.camera.request().isGranted){
      cameras = await availableCameras();
      cameraController = await CameraController(
          cameras[0],
          ResolutionPreset.max,
      );
      await cameraController.initialize().then((value){
          cameraController.startImageStream((image) {
            cameraCount++ ;
            if(cameraCount%10==0){cameraCount = 0;
              objectDetector(image);
            }
            update();
          });
        });
      isCameraInit(true);
      update();
    }else{
      print("Permission Denied");
    }
  }

  initTFLite() async{
    await Tflite.loadModel(
      model: "assets/model_ssd.tflite",
      labels: "assets/label_ssd.txt",
      isAsset: true,
      numThreads: 1,
      useGpuDelegate: false,
    );
  }


  objectDetector(CameraImage image) async{
    var detector = await Tflite.detectObjectOnFrame(
      bytesList: image.planes.map((plane) {return plane.bytes;}).toList(),// required
      asynch: true,
      model: "SSDMobileNet",
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResultsPerClass: 1,
      rotation: 90,
      threshold: 0.4,
    );

    if(detector != null){
      var detectedObj = detector.first;
      log("Result is $detectedObj");
      var int_conf = detectedObj["confidenceInClass"]*100;
      if(int_conf > 30){
        nconf = int_conf.toStringAsFixed(0);
        label = detectedObj["detectedClass"].toString();
        h = detectedObj["rect"]["h"];
        w = detectedObj["rect"]["w"];
        x = detectedObj["rect"]["x"];
        y = detectedObj["rect"]["y"];
      }
      update();
    }
  }
}



