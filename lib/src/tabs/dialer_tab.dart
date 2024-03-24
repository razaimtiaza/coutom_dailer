import 'package:audioplayers/audioplayers.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../widgets/dialer_button.dart';
import '../widgets/rounded_button.dart';
import 'package:android_intent/android_intent.dart';

class DialerTab extends StatefulWidget {
  const DialerTab({super.key});

  @override
  State<DialerTab> createState() => _DialerTabState();
}

class _DialerTabState extends State<DialerTab> {
  String _phoneNumber = '';
  final List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  final String _dialerDigits = '';
  final String _searchQuery = '';
  final AudioCache _audioCache = AudioCache(prefix: 'sounds/');
  FlutterTts flutterTts = FlutterTts();
  late int selectedSimIndex;

//SIR CODE
  void handleBackspace() {
    if (_phoneNumber.isNotEmpty) {
      setState(() {
        _phoneNumber = _phoneNumber.substring(0, _phoneNumber.length - 1);
      });
    }
  }

  void showSaveContactDialog(BuildContext context, String phoneNumber) {
    String name = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                onChanged: (value) {
                  name = value;
                },
              ),
              const SizedBox(height: 16.0),
              Text(
                'Phone Number: $phoneNumber',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                if (phoneNumber.isNotEmpty) {
                  saveContact(name, phoneNumber); // Save the contact
                } else {
                  Fluttertoast.showToast(
                    msg: 'Enter a number',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                }
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void saveContact(String name, String phoneNumber) async {
    try {
      // Create a new contact
      Contact newContact = Contact();
      newContact.givenName = name; //NAME = desire name
      //newContact.emails = [Item(label: "email", value: EMAIL)]; //EMAIL = desire email
      newContact.phones = [
        Item(label: "phone", value: phoneNumber)
      ]; //PHONE = desire phone
      // newContact.company = COMPANY; //COMPANY = desire company name
      // newContact.jobTitle = JOB_TITLE; //JOB_TITLE = desire job title
      await ContactsService.addContact(newContact);

      // Display a success message
      Fluttertoast.showToast(
        msg: 'Contact saved successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      // Display an error message if saving contact fails
      Fluttertoast.showToast(
        msg: 'Failed to save contact ${e.toString()}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      print("error $e");
    }
  }

  // final player = AudioPlayer();
  // List<Contact> savedContacts = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              // ss
              child: Text(
                _phoneNumber.isEmpty ? 'Enter Phone Number' : _phoneNumber,
                style: const TextStyle(fontSize: 25),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              onTap: handleBackspace,
              child: const Icon(Icons.backspace),
            ),
          ),
          InkWell(
            onTap: () {
              showSaveContactDialog(
                  context, _phoneNumber); // Show the save contact dialog
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.add),
            ),
          )
        ]),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DialerButton(
              digit: '1',
              letters: '',
              onPressed: () {
                setState(() {
                  _phoneNumber += "1";
                  flutterTts.speak(_phoneNumber);
                  // _filterContacts();
                });
              },
            ),
            DialerButton(
              digit: '2',
              letters: 'ABC',
              onPressed: () {
                setState(() {
                  _phoneNumber += "2";
                  flutterTts.speak(_phoneNumber);
                  // _filterContacts();
                });
              },
            ),
            DialerButton(
              digit: '3',
              letters: 'DEF',
              onPressed: () {
                setState(() {
                  _phoneNumber += "3";
                  flutterTts.speak(_phoneNumber);
                  // _filterContacts();
                });
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DialerButton(
              digit: '4',
              letters: 'GHI',
              onPressed: () {
                setState(() {
                  _phoneNumber += "4";
                  flutterTts.speak(_phoneNumber);
                  // _filterContacts();
                });
              },
            ),
            DialerButton(
                digit: '5',
                letters: 'JKL',
                onPressed: () {
                  setState(() {
                    _phoneNumber += "5";
                    flutterTts.speak(_phoneNumber);
                    // _filterContacts();
                  });
                }),
            DialerButton(
              digit: '6',
              letters: 'MNO',
              onPressed: () {
                setState(() {
                  _phoneNumber += "6";
                  flutterTts.speak(_phoneNumber);
                  // _filterContacts();
                });
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DialerButton(
              digit: '7',
              letters: 'PQRS',
              onPressed: () {
                setState(() {
                  _phoneNumber += "7";
                  flutterTts.speak(_phoneNumber);
                  // _filterContacts();
                });
              },
            ),
            DialerButton(
              digit: '8',
              letters: 'TUV',
              onPressed: () {
                setState(() {
                  _phoneNumber += "8";
                  flutterTts.speak(_phoneNumber);
                  // _filterContacts();
                });
              },
            ),
            DialerButton(
              digit: '9',
              letters: 'WXYZ',
              onPressed: () {
                setState(() {
                  _phoneNumber += "9";
                  flutterTts.speak(_phoneNumber);
                  // _filterContacts();
                });
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DialerButton(
              digit: "*",
              letters: "",
              onPressed: () {
                setState(() {
                  _phoneNumber += "*";
                  flutterTts.speak(_phoneNumber);
                  // _filterContacts();
                });
              },
            ),
            DialerButton(
              digit: '0',
              letters: '+',
              onPressed: () {
                setState(() {
                  _phoneNumber += "0";
                  flutterTts.speak(_phoneNumber);
                  // _filterContacts();
                });
              },
            ),
            DialerButton(
              digit: "#",
              letters: "",
              onPressed: () {
                setState(() {
                  _phoneNumber += "#";
                  flutterTts.speak(_phoneNumber);
                  // _filterContacts();
                });
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8.0),
                child: RoundedIconButton(
                  icon: const Icon(Icons.call),
                  color: Colors.green,
                  onPressed: _launchPhoneDialer,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  void _launchPhoneDialer() async {
    try {
      await FlutterPhoneDirectCaller.callNumber(_phoneNumber);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not dial number.'),
        duration: Duration(seconds: 3),
      ));
      throw 'Could not dial number: $e';
    }
  }

  void _filterContacts(String searchText) {
    String searchText0 = '';
    setState(() {
      searchText0 = searchText;

      if (searchText0.isEmpty) {
        _filteredContacts = _contacts;
      } else {
        _filteredContacts = _contacts
            .where((contact) => contact.phones!
                .any((phone) => phone.value!.contains(searchText0)))
            .toList();
      }
    });
  }

  
}
