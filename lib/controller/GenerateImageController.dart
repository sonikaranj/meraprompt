import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:aiimagegenerator2/screen/result_screen.dart';

class GenerateImageController extends GetxController {
  final List<String> sizes =
      ["1:1", "16:9", "3:2", "4:3", "5:4", "9:16", "2:3", "3:4", "4:5"].obs;

  final TextEditingController promptController = TextEditingController();

  RxBool isLoading = false.obs;
  RxString selectedSize = "1:1".obs;
  RxInt selectedSizeIndex = 0.obs;
  RxInt selectedCatagoryIndex = 0.obs;
  RxInt selectedStyleIndex = 0.obs;

  RxInt selectedStyleId = 1.obs;
  var selectedStyle = "".obs;

  // NEW: Store full style data
  var imageStyleData = <String, List<Map<String, dynamic>>>{}.obs;

  // NEW: Store selected category name
  var selectedCategory = "Photograph".obs;

  void selectSize(String size) {
    selectedSize.value = size;
  }

  void selectStyle(String style) {
    selectedStyle.value = style;
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void generateImage() async {
    isLoading.value = true;

    var headers = {
      'Content-Type': 'application/json',
      'x-rapidapi-host':
          'ai-text-to-image-generator-flux-free-api.p.rapidapi.com',
      'x-rapidapi-key': 'cf4fe6aff6msh7f823bff2d2863ap16290ajsnd6996866d979',
    };
    var request = http.Request(
      'POST',
      Uri.parse(
        'https://ai-text-to-image-generator-flux-free-api.p.rapidapi.com/aaaaaaaaaaaaaaaaaiimagegenerator/quick.php',
      ),
    );
    request.body = json.encode({
      "prompt": promptController.text.toString(),
      "style_id": selectedStyleId.value,
      "size":   "${selectedSize.value.split(":").first}-${selectedSize.value.split(":").last}"
    });
    // request.body = json.encode({
    //   "prompt": promptController.text,
    //   "style_id": selectedStyleId.value,
    //   "size":
    //       "${selectedSize.value.split(":").first}-${selectedSize.value.split(":").last}",
    // });

    print(request.body);
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = (await response.stream.bytesToString());
      var jsonResponse = json.decode(responseString);
      print(jsonResponse);
      if(isLoading.value == true){
        // Get.to(() => ResultScreen(finalResults: jsonResponse['final_result']));
        List<ResultItem> resultList = (jsonResponse['final_result'] as List)
            .map((e) => ResultItem(
          index: e['index'],
          nsfw: e['nsfw'],
          origin: e['origin'],
          thumb: e['thumb'],
        ))
            .toList();
        Get.to(() => ResultScreen(finalResults: resultList));
      }
     isLoading.value = false;
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  void onInit() {
    super.onInit();

    imageStyleData.value =
        {
          "Photograph": [
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F0.webp",
              "hot": false,
              "id": 1,
              "newFeature": false,
              "style": "No Style",
              "style_cls": "Photograph",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F1.webp",
              "hot": false,
              "id": 2,
              "newFeature": false,
              "style": "Bokeh",
              "style_cls": "Photograph",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F2.webp",
              "hot": false,
              "id": 3,
              "newFeature": false,
              "style": "Food",
              "style_cls": "Photograph",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F3.webp",
              "hot": false,
              "id": 4,
              "newFeature": false,
              "style": "iPhone",
              "style_cls": "Photograph",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F4.webp",
              "hot": false,
              "id": 5,
              "newFeature": false,
              "style": "Film Noir",
              "style_cls": "Photograph",
            },
          ],
          "Art": [
            {
              "avatar":
                  "https://pub-static.aiease.ai/aiease-sys/common/e6fdfa65719544d1bac831820c5d3b7b.webp",
              "hot": false,
              "id": 70,
              "newFeature": true,
              "style": "ToothiePop",
              "style_cls": "Art",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2Fart_v1-Ghibli.webp",
              "hot": false,
              "id": 68,
              "newFeature": false,
              "style": "Ghibli",
              "style_cls": "Art",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F5.webp",
              "hot": false,
              "id": 6,
              "newFeature": false,
              "style": "Cubist",
              "style_cls": "Art",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F6.webp",
              "hot": false,
              "id": 7,
              "newFeature": false,
              "style": "Pixel",
              "style_cls": "Art",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F7.webp",
              "hot": false,
              "id": 8,
              "newFeature": false,
              "style": "Dark Fantasy",
              "style_cls": "Art",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F8.webp",
              "hot": false,
              "id": 9,
              "newFeature": false,
              "style": "Van Gogh",
              "style_cls": "Art",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F9.webp",
              "hot": false,
              "id": 10,
              "newFeature": false,
              "style": "Caricature",
              "style_cls": "Art",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F10.webp",
              "hot": false,
              "id": 11,
              "newFeature": false,
              "style": "Statue",
              "style_cls": "Art",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F11.webp",
              "hot": false,
              "id": 12,
              "newFeature": false,
              "style": "Watercolor",
              "style_cls": "Art",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F12.webp",
              "hot": false,
              "id": 13,
              "newFeature": false,
              "style": "Oil Painting",
              "style_cls": "Art",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F250226%2F48.webp",
              "hot": false,
              "id": 50,
              "newFeature": false,
              "style": "Pattern",
              "style_cls": "Art",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F250226%2F49.webp",
              "hot": false,
              "id": 51,
              "newFeature": false,
              "style": "Painting",
              "style_cls": "Art",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F250226%2F50.webp",
              "hot": false,
              "id": 52,
              "newFeature": false,
              "style": "Lego character",
              "style_cls": "Art",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F250226%2F52.webp",
              "hot": false,
              "id": 54,
              "newFeature": false,
              "style": "Doodle",
              "style_cls": "Art",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F250226%2F53.webp",
              "hot": false,
              "id": 55,
              "newFeature": false,
              "style": "Fantasy",
              "style_cls": "Art",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F250226%2F54.webp",
              "hot": false,
              "id": 56,
              "newFeature": false,
              "style": "Concept",
              "style_cls": "Art",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F250226%2F51.webp",
              "hot": false,
              "id": 53,
              "newFeature": false,
              "style": "Lego blocks",
              "style_cls": "Art",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F250226%2F59.webp",
              "hot": false,
              "id": 61,
              "newFeature": false,
              "style": "Barbie world",
              "style_cls": "Art",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F250226%2F60.webp",
              "hot": false,
              "id": 62,
              "newFeature": false,
              "style": "Cyberpunk",
              "style_cls": "Art",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F250226%2F62.webp",
              "hot": false,
              "id": 64,
              "newFeature": false,
              "style": "Pop",
              "style_cls": "Art",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F250226%2F63.webp",
              "hot": false,
              "id": 65,
              "newFeature": false,
              "style": "Steampunk",
              "style_cls": "Art",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F250226%2F64.webp",
              "hot": false,
              "id": 66,
              "newFeature": false,
              "style": "Cubism",
              "style_cls": "Art",
            },
          ],
          "Cartoon": [
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F13.webp",
              "hot": false,
              "id": 14,
              "newFeature": false,
              "style": "Manga",
              "style_cls": "Cartoon",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F14.webp",
              "hot": false,
              "id": 15,
              "newFeature": false,
              "style": "Sketch",
              "style_cls": "Cartoon",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F15.webp",
              "hot": false,
              "id": 16,
              "newFeature": false,
              "style": "Comic",
              "style_cls": "Cartoon",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F16.webp",
              "hot": false,
              "id": 17,
              "newFeature": false,
              "style": "Kawaii",
              "style_cls": "Cartoon",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F17.webp",
              "hot": false,
              "id": 18,
              "newFeature": false,
              "style": "Chibi",
              "style_cls": "Cartoon",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F18.webp",
              "hot": false,
              "id": 19,
              "newFeature": false,
              "style": "Disney",
              "style_cls": "Cartoon",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F19.webp",
              "hot": false,
              "id": 20,
              "newFeature": false,
              "style": "Pixar",
              "style_cls": "Cartoon",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F20.webp",
              "hot": false,
              "id": 21,
              "newFeature": false,
              "style": "Funko Pop",
              "style_cls": "Cartoon",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F250226%2F47.webp",
              "hot": false,
              "id": 49,
              "newFeature": false,
              "style": "Furry Art",
              "style_cls": "Cartoon",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F250226%2F56.webp",
              "hot": false,
              "id": 58,
              "newFeature": false,
              "style": "Shrek",
              "style_cls": "Cartoon",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F250226%2F58.webp",
              "hot": false,
              "id": 60,
              "newFeature": false,
              "style": "Barbie doll",
              "style_cls": "Cartoon",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F250226%2F61.webp",
              "hot": false,
              "id": 63,
              "newFeature": false,
              "style": "Bratz Doll",
              "style_cls": "Cartoon",
            },
          ],
          "Game": [
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F21.webp",
              "hot": false,
              "id": 22,
              "newFeature": false,
              "style": "Bubble Bobble",
              "style_cls": "Game",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F22.webp",
              "hot": false,
              "id": 23,
              "newFeature": false,
              "style": "Retro Arcade",
              "style_cls": "Game",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F23.webp",
              "hot": false,
              "id": 24,
              "newFeature": false,
              "style": "Minecraft",
              "style_cls": "Game",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F24.webp",
              "hot": false,
              "id": 25,
              "newFeature": false,
              "style": "GTA",
              "style_cls": "Game",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F25.webp",
              "hot": false,
              "id": 26,
              "newFeature": false,
              "style": "Pokemon",
              "style_cls": "Game",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F250226%2F46.webp",
              "hot": false,
              "id": 47,
              "newFeature": false,
              "style": "DND",
              "style_cls": "Game",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F250226%2F57.webp",
              "hot": false,
              "id": 59,
              "newFeature": false,
              "style": "Fortnite",
              "style_cls": "Game",
            },
          ],
          "Logo": [
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F26.webp",
              "hot": false,
              "id": 27,
              "newFeature": false,
              "style": "3D",
              "style_cls": "Logo",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F27.webp",
              "hot": false,
              "id": 28,
              "newFeature": false,
              "style": "Minimalist",
              "style_cls": "Logo",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F28.webp",
              "hot": false,
              "id": 29,
              "newFeature": false,
              "style": "Cartoon",
              "style_cls": "Logo",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F29.webp",
              "hot": false,
              "id": 30,
              "newFeature": false,
              "style": "Energetic",
              "style_cls": "Logo",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F30.webp",
              "hot": false,
              "id": 31,
              "newFeature": false,
              "style": "Cute",
              "style_cls": "Logo",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F250226%2F55.webp",
              "hot": false,
              "id": 57,
              "newFeature": false,
              "style": "Graffiti",
              "style_cls": "Logo",
            },
          ],
          "Tattoo": [
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F31.webp",
              "hot": false,
              "id": 32,
              "newFeature": false,
              "style": "Default",
              "style_cls": "Tattoo",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F32.webp",
              "hot": false,
              "id": 33,
              "newFeature": false,
              "style": "Line Art",
              "style_cls": "Tattoo",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F250226%2F65.webp",
              "hot": false,
              "id": 67,
              "newFeature": false,
              "style": "Mandala",
              "style_cls": "Tattoo",
            },
          ],
          "Icon": [
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F33.webp",
              "hot": false,
              "id": 34,
              "newFeature": false,
              "style": "2D",
              "style_cls": "Icon",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F34.webp",
              "hot": false,
              "id": 35,
              "newFeature": false,
              "style": "3D",
              "style_cls": "Icon",
            },
          ],
          "Text": [
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F35.webp",
              "hot": false,
              "id": 36,
              "newFeature": false,
              "style": "Plush",
              "style_cls": "Text",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F36.webp",
              "hot": false,
              "id": 37,
              "newFeature": false,
              "style": "Graffiti",
              "style_cls": "Text",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F37.webp",
              "hot": false,
              "id": 38,
              "newFeature": false,
              "style": "Hand-drawn",
              "style_cls": "Text",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F38.webp",
              "hot": false,
              "id": 39,
              "newFeature": false,
              "style": "Balloon",
              "style_cls": "Text",
            },
          ],
          "Sticker": [
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F39.webp",
              "hot": false,
              "id": 40,
              "newFeature": false,
              "style": "Illustration",
              "style_cls": "Sticker",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F40.webp",
              "hot": false,
              "id": 41,
              "newFeature": false,
              "style": "Sketch",
              "style_cls": "Sticker",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F41.webp",
              "hot": false,
              "id": 42,
              "newFeature": false,
              "style": "Colorful",
              "style_cls": "Sticker",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F42.webp",
              "hot": false,
              "id": 43,
              "newFeature": false,
              "style": "Cartoon",
              "style_cls": "Sticker",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F43.webp",
              "hot": false,
              "id": 44,
              "newFeature": false,
              "style": "kawaii",
              "style_cls": "Sticker",
            },
            {
              "avatar":
                  "https://pub-static.aiease.ai/aieaseExample%2FartV1%2Fstyle%2F44.webp",
              "hot": false,
              "id": 45,
              "newFeature": false,
              "style": "Q-version",
              "style_cls": "Sticker",
            },
          ],
        }.obs;
  }
}
