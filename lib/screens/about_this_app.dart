import 'package:flutter/material.dart';
import 'package:flutter_code_challenge/utilities/constants.dart';

class AboutThisApp extends StatelessWidget {
  const AboutThisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'About Skyz',
          style: kAppbarText,
        ),
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
          child: Column(
            children: [
              Text(
                'Created in response to the Hey Flutter competition challenge, Skyz was developed over the space of 4 days as a viable entry.',
                style: kDrawerText,
              ),
              SizedBox(height: 12.0),
              Text(
                'The app seeks to build on the core entry requirements of demonstrating the ability to work with an external API.',
                style: kDrawerText,
              ),
              Text(
                'Rather than simply rstrict myself to just a weather API, I have elected to also integrate the capability to dynamically'
                'add relevant images to the core display with the integration of the Unsplash image library. \n'
                'The search criteria is controlled by the weather condition code, returned from the core api together with the '
                'target location which is geo-located at launch and also capable of selection by the user later within the app.',
                style: kDrawerText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
