import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';

class ResultItem {
  final int index;
  final bool nsfw;
  final String origin;
  final String thumb;

  ResultItem({
    required this.index,
    required this.nsfw,
    required this.origin,
    required this.thumb,
  });
}

class ResultScreen extends StatefulWidget {
  final List<ResultItem> finalResults;

  const ResultScreen({Key? key, required this.finalResults}) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          leading: GestureDetector(
              onTap: (){
                Get.back();
              },
              child: Icon(Icons.arrow_back_ios,color: Colors.white,)),
          title: const Text("Your Results"),
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: widget.finalResults.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final item = widget.finalResults[index];
            return GestureDetector(
              onTap: () {
                _openCarouselDialog(index);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.thumb,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openCarouselDialog(int initialIndex) {
    showDialog(
      context: context,
      builder: (_) {
        final List<List<ResultItem>> imagePairs = [];

        // Create pairs of 2 images each
        for (int i = 0; i < widget.finalResults.length; i += 2) {
          imagePairs.add(widget.finalResults.skip(i).take(2).toList());
        }

        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CarouselSlider.builder(
                options: CarouselOptions(
                  initialPage: initialIndex ~/ 2,
                  enableInfiniteScroll: false,
                  viewportFraction: 1.0,
                  height: MediaQuery.of(context).size.height * 0.6,
                ),
                itemCount: imagePairs.length,
                itemBuilder: (context, pageIndex, _) {
                  final pair = imagePairs[pageIndex];
                  return Row(
                    children: pair
                        .map(
                          (item) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.origin,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text("Save"),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Save functionality here")),
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text("Share"),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Share functionality here")),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
