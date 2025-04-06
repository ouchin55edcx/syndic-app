import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size; // Variable for the size of the avatar

  UserAvatar({this.imageUrl, this.size = 57.0}); // Default size is 57.0

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, // Set the width of the container
      height: size, // Set the height of the container
      decoration: BoxDecoration(
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover, // To ensure the image covers the whole container
              )
            : null,
        color: const Color.fromARGB(255, 64, 66, 69), // Set a background color if no image is provided
      ),
      child: imageUrl == null
          ? Icon(Icons.person, color: Colors.white, size: size / 2) // Show an icon if no image is provided
          : null,
    );
  }
}
