import 'package:audioplayers/audioplayers.dart';
import 'package:call_log/call_log.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/dialer_button.dart';
import '../widgets/rounded_button.dart';

class CallLogScreen extends StatefulWidget {
  const CallLogScreen({Key? key}) : super(key: key);

  @override
  _CallLogScreenState createState() => _CallLogScreenState();
}

class _CallLogScreenState extends State<CallLogScreen> {
  final FlutterTts flutterTts = FlutterTts();
  List<CallLogEntry> _callLogEntries = [];
  // List<int> _deletedEntryIndexes = [];
  String _formatDateTime(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String time = DateFormat.jm().format(dateTime);
    return time;
  }

  @override
  void initState() {
    super.initState();
    _getCallLog();
  }

  void _getCallLog() async {
    Iterable<CallLogEntry> entries = await CallLog.get();
    setState(() {
      _callLogEntries = entries.toList();
    });
    // Iterable<CallLogEntry> entries = await CallLog.get();
    // setState(() {
    //   _callLogEntries = entries.toList();
    // });
  }

  Future<void> _requestCallLogPermission() async {
    if (await Permission.contacts.isGranted) {
      // Permission is already granted
      _getCallLog();
    } else {
      // Request permission
      PermissionStatus status = await Permission.contacts.request();
      if (status.isGranted) {
        // Permission granted
        _getCallLog();
      } else if (status.isDenied) {
        // Permission denied
        // Handle the case when the user denies the permission
      } else if (status.isPermanentlyDenied) {
        // Permission permanently denied
        // Handle the case when the user permanently denies the permission
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ListView.builder(
        itemCount: _callLogEntries.length,
        itemBuilder: (BuildContext context, int index) {
          CallLogEntry entry = _callLogEntries[index];
          String formattedNumber = entry.formattedNumber ?? entry.number ?? '';
          String formattedTimestamp = _formatDateTime(entry.timestamp ?? 0);
          // Skip rendering deleted entries
          // if (_deletedEntryIndexes.contains(index)) {
          //   return SizedBox.shrink();
          // }
          return Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.horizontal,
            onDismissed: (direction) async {},
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: InkWell(
              onTap: () {
                String phoneNumber = formattedNumber;
                speakContactName(entry.name, formattedNumber);
                _showCallDetails(entry);
              },
              child: ListTile(
                leading: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.phone),
                ),
                title: Text(entry.name ?? ''),
                subtitle: Text(formattedNumber),
                trailing: Text(formattedTimestamp),
              ),
            ),
          );
        },
      ),
      Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 40, right: 30),
          child: FloatingActionButton(
            onPressed: () {
              _showBottomSheet(context);
            },
            child: const Icon(Icons.add),
          ),
        ),
      )
    ]);
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not dial number.'),
        duration: Duration(seconds: 3),
      ));
      throw 'Could not dial number: $e';
    }
  }

  Future<void> speakContactName(
      String? contactName, String contactNumber) async {
    if (contactName != null) {
      await flutterTts.setLanguage('en-US');
      await flutterTts.speak('Contact name: $contactName');
    } else {
      await flutterTts.setLanguage('en-US');
      await flutterTts.speak('Contact number: $contactNumber');
    }
  }

  void _showCallDetails(CallLogEntry callLog) {
    String startTime = _formatDateTime(callLog.timestamp ?? 0);
    String endTime = _formatDateTime(callLog.duration ?? 0);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Call Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    callLog.callType == CallType.incoming
                        ? Icons.call_received
                        : Icons.call_made,
                    color: callLog.callType == CallType.incoming
                        ? Colors.green
                        : Colors.blue,
                  ),
                  //const SizedBox(width: 8),
                  const Text(
                    'Caller Name:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Expanded(child: Text(callLog.name ?? 'Unknown')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone),
                  //const SizedBox(width: 8),
                  const Text(
                    ' Number:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  // const SizedBox(width: 4),
                  Expanded(
                      child: Text(
                          callLog.formattedNumber ?? callLog.number ?? '')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time),
                  //const SizedBox(width: 8),
                  const Text(
                    'Call Start Time:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Text(startTime),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time),
                  // const SizedBox(width: 8),
                  const Text(
                    'Call End Time:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Text(endTime),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

void _showBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    // isScrollControlled: true,
    builder: (BuildContext context) {
      return SizedBox(
        height: MediaQuery.of(context).size.height *
            0.8, // Adjust the height as per your requirement

        child: DialerTab(
          onNumberDialed: (String phoneNumber) {
            // Handle the dialed number, e.g., make a phone call
            _makePhoneCall(phoneNumber);
          },
        ),
      );
    },
  );
}

Future<void> _makePhoneCall(String phoneNumber) async {
  try {
    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  } catch (e) {
    throw 'Could not dial number: $e';
  }
}

class DialerTab extends StatefulWidget {
  const DialerTab(
      {super.key, required Null Function(String phoneNumber) onNumberDialed});

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
            child: Text(
              _phoneNumber.isEmpty ? 'Enter  Number' : _phoneNumber,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
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
      // Code for announcing the caller's name or number before dialing

      await FlutterPhoneDirectCaller.callNumber(_phoneNumber);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not dial number.'),
        duration: Duration(seconds: 3),
      ));
      throw 'Could not dial number: $e';
    }
  }

  // Future<void> _announceCaller() async {
  //   // Get the caller's name or number from your data source
  //   String callerName =
  //       "John Doe"; // Replace with the actual caller's name or number

  //   await flutterTts.setLanguage('en-US'); // Set the desired language
  //   await flutterTts.speak(
  //       'Incoming call from $callerName'); // Perform the voice announcement
  // }

  // void _launchPhoneDialer() async {
  //   try {
  //     // Get the caller's name from your contact list
  //     String callerName = getCallerName(_phoneNumber);

  //     // Speak the caller's name
  //     await flutterTts.speak('Incoming call from $callerName');

  //     // Delay for a brief period to allow the name to be spoken
  //     await Future.delayed(Duration(seconds: 2));

  //     // Play the ringtone
  //     FlutterRingtonePlayer.play(
  //       android: AndroidSounds.ringtone,
  //       ios: IosSounds.electronic,
  //       looping: true,
  //       volume: 0.5,
  //     );

  //     // Open the dialer with the phone number
  //     await FlutterPhoneDirectCaller.callNumber(_phoneNumber);
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //       content: Text('Could not dial number.'),
  //       duration: Duration(seconds: 3),
  //     ));
  //     throw 'Could not dial number: $e';
  //   }
  // }

  // String getCallerName(String phoneNumber) {
  //   String callerName =
  //       'Unknown'; // Default value if the caller's name is not found

  //   // Fetch all contacts
  //   Iterable<Contact>? contacts =
  //       ContactsService.getContacts() as Iterable<Contact>?;

  //   // Iterate through each contact to find the caller's name
  //   if (contacts != null) {
  //     for (Contact contact in contacts) {
  //       if (contact.phones != null) {
  //         for (Item phone in contact.phones!) {
  //           if (phone.value == phoneNumber) {
  //             // Caller's phone number matches a contact's phone number
  //             callerName = contact.displayName ?? 'Unknown';
  //             break;
  //           }
  //         }
  //       }

  //       if (callerName != 'Unknown') {
  //         // Caller's name is found, no need to search further
  //         break;
  //       }
  //     }
  //   }

  //   return callerName;
  // }

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

void main() {
  runApp(const MaterialApp(
    home: CallLogScreen(),
  ));
}
