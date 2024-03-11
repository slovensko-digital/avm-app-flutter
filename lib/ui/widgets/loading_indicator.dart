import 'package:flutter/material.dart';

/// Widget for displaying loading indicator
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO Add also optional text on the right
    // https://www.figma.com/file/9i8kwShc6o8Urp2lYoPg6M/Autogram-v-mobile-(WIP)?type=design&node-id=74-328&mode=design&t=LuXUEfCXSSwa3qBf-0
    return const CircularProgressIndicator();
  }
}
