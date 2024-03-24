import 'package:flutter/material.dart';

class CustomIncomingCallScreen extends StatelessWidget {
  final String contactName;
  final String phoneNumber;
  final VoidCallback onAcceptCall;
  final VoidCallback onRejectCall;

  CustomIncomingCallScreen({
    required this.contactName,
    required this.phoneNumber,
    required this.onAcceptCall,
    required this.onRejectCall,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            // Swipe right, reject call
            onRejectCall();
          } else if (details.primaryVelocity! < 0) {
            // Swipe left, accept call
            onAcceptCall();
          }
        },
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                contactName,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                phoneNumber,
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.call_end),
                    onPressed: onRejectCall,
                  ),
                  SizedBox(width: 32.0),
                  IconButton(
                    icon: Icon(Icons.call),
                    onPressed: onAcceptCall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
