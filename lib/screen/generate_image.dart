import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:aiimagegenerator2/controller/GenerateImageController.dart';

class GenerateImage extends StatelessWidget {
  GenerateImage({super.key});

  final GenerateImageController controller = Get.put(GenerateImageController());
  



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actionsIconTheme: IconThemeData(
          color: Colors.white
        ),
        leading: GestureDetector(
            onTap: (){
              if(controller.isLoading.value == false){
                Get.back();
              }else{
                //show dialog
              }
            },
            child: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        backgroundColor: Colors.grey[900],
        title: const Text("Generate Image"),
        centerTitle: true,
      ),
      body: Obx(
          ()=> controller.isLoading.value == false ? SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Enter your Prompt",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      final randomPrompts = [
                        "A futuristic cityscape",
                        "Cute animals in a meadow",
                        "Surreal dreamlike forest",
                        "Cyberpunk character portrait",
                      ];
                      controller.promptController.text = (randomPrompts..shuffle()).first;
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.amber,
                    ),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text("Surprise Me"),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Stack(
                children: [
                  TextField(
                    controller: controller.promptController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    maxLines: 5,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(
                        top: 20,
                        left: 50,
                        right: 12,
                        bottom: 16,
                      ),
                      hintText: "Beautiful Scenery surreal",
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 20,
                    left: 12,
                    child: Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Super",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Size",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
               SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.sizes.length,
                  itemBuilder: (context, index) {
                    return Obx(
                        ()=>  Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: controller.selectedSizeIndex.value == index
                                  ? Colors.amber
                                  : Colors.grey,
                            ),
                            backgroundColor: controller.selectedSizeIndex.value == index
                                ? Colors.amber.withOpacity(0.2)
                                : Colors.transparent,
                          ),
                          onPressed: () {
                            controller.selectedSizeIndex.value = index;
                            controller.selectedSize.value = controller.sizes[controller.selectedSizeIndex.value];
                          },
                          child: Text(
                            controller.sizes[index],
                            style: TextStyle(
                              color: controller.selectedSizeIndex.value == index
                                  ? Colors.amber
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "Let us know your style",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              50.verticalSpace,
            SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.imageStyleData.keys.toList().length,
                    itemBuilder: (context, index) {
                      final cat = controller.imageStyleData.keys.toList()[index];
                      // final isSelected = cat == controller.selectedCategory.value;
                      return Obx(
                          ()=>  Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: OutlinedButton(
                            onPressed: (){
                              controller.selectedStyleIndex.value =-1;
                              // print(controller.selectedStyleIndex.value);
                              controller.selectedCatagoryIndex.value = index;
                              controller.selectedCategory.value = controller.imageStyleData.keys.toList()[controller.selectedCatagoryIndex.value];
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: controller.selectedCatagoryIndex.value == index ? Colors.amber : Colors.grey[850],
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: controller.selectedCatagoryIndex.value == index ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              50.verticalSpace,
               Obx(
                 ()=> SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.imageStyleData[controller.selectedCategory.value]!.length,
                      itemBuilder: (context, index) {
                        final style = controller.imageStyleData[controller.selectedCategory.value]![index];
                       return Obx(
                           ()=> GestureDetector(
                            onTap: (){
                              controller.selectedStyleIndex.value =index;
                              controller.selectedStyle.value  = (controller.selectedStyle(style["style"]));
                              print(controller.selectedStyleIndex.value);


                              controller.selectedStyleId.value =  style["id"];
                              print(controller.selectedStyleId.value);
                              },
                            child: Container(
                              width: 130,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: controller.selectedStyleIndex.value == index ? Colors.amber[700] : Colors.grey[800],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Image.network(
                                      style["avatar"] ?? "",
                                      height: 110,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey,
                                        height: 110,
                                        child: const Icon(Icons.broken_image, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      style["style"],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                       );
                      },
                    ),
                  ),
               ),
              300.verticalSpace,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if(controller.selectedStyleIndex.value != -1){
                      controller.generateImage();
                    }

                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.purpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Generate Image✨",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ) : Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white,),
             70.verticalSpace,
            Text("Please Wait Image is Generating ...",style: TextStyle(color: Colors.white),)
          ],
        )),
      ),
    );
  }
}
