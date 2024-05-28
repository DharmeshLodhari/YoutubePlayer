import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class UserProfileShimmer extends StatelessWidget {
  const UserProfileShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.white,
          period: const Duration(seconds: 1),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                ShimmerProfile(),
                const SizedBox(height: 30),
                ShimmerTab(),
                const SizedBox(height: 20),
                ShimmerProductList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShimmerProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: 15,
          color: Colors.white,
        ),
        const SizedBox(height: 8),
        Container(
          width: 120,
          height: 15,
          color: Colors.white,
        ),
        const SizedBox(
          height: 15,
        ),
        Container(
          width: 350,
          height: 15,
          color: Colors.white,
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          width: 100,
          height: 15,
          color: Colors.white,
        ),
      ],
    );
  }
}

class ShimmerTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        return Flexible(
          child: Container(
            height: 30,
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 5),
          ),
        );
      }),
    );
  }
}

class ShimmerProductList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 150,
          color: Colors.white,
        ),
        const SizedBox(height: 20),
        Container(
          width: 100,
          height: 20,
          color: Colors.white,
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 100,
          color: Colors.white,
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 100,
          color: Colors.white,
        ),
      ],
    );
  }
}
