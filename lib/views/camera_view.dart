import 'package:camera/camera.dart';
import 'package:camgle/controller/scan_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ScanController>(
        init: ScanController(),
        builder: (controller) {
          return controller.isCameraInit.value
              ? Stack(
                children: [
                  CameraPreview(controller.cameraController),
                  Positioned(
                    left: controller.x*600,
                    top: controller.y*400,
                    child: Container(
                      width: controller.w*context.width,
                      height: controller.h*context.height,
                      padding: const EdgeInsets.only(top: 5.0, left: 5.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 3.5),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            color: Colors.white,
                            child: Text("${controller.conf*100}% - ${controller.label}"),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )
              : const Center(child: Text("Loading Preview..."));
        }
      ),
    );
  }
}
