import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactsTab extends StatefulWidget {
  const ContactsTab({Key? key}) : super(key: key);

  @override
  State<ContactsTab> createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab> {
  List<Contact>? _contacts;
  bool _isLoading = true;
  late Contact edit = Contact();
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool shouldFetchContacts =
        prefs.getBool('shouldFetchContacts') ?? true;

    if (shouldFetchContacts) {
      PermissionStatus permissionStatus = await Permission.contacts.request();

      if (permissionStatus.isGranted) {
        Iterable<Contact> contacts = await ContactsService.getContacts();
        _contacts = contacts.toList();
        await prefs.setBool('shouldFetchContacts', false);
        await _cacheContacts(_contacts!);
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Permission Denied'),
              content: const Text(
                  'Please grant access to contacts in order to use this feature.'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      _contacts = await _getCachedContacts();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> editContact(Contact contact) async {
    try {
      Contact update = await ContactsService.openExistingContact(contact);
      setState(() {
        int index =
            _contacts!.indexWhere((c) => c.identifier == update.identifier);
        if (index != -1) {
          _contacts![index] = update;
        }
      });
    } on FormOperationException catch (e) {
      switch (e.errorCode) {
        case FormOperationErrorCode.FORM_OPERATION_CANCELED:
        case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
        case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
          print(e.toString());
          break;
      }
    }
  }

  Future<List<Contact>> _getCachedContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? contactIds = prefs.getStringList('contactIds');

    if (contactIds != null) {
      Iterable<Contact> contacts = await ContactsService.getContacts();
      return contacts
          .where((contact) => contactIds.contains(contact.identifier))
          .toList();
    }

    return [];
  }

  Future<void> _cacheContacts(List<Contact> contacts) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> contactIds =
        contacts.map((contact) => contact.identifier!).toList();
    await prefs.setStringList('contactIds', contactIds);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_contacts != null && _contacts!.isNotEmpty) {
      return ListView.builder(
        itemCount: _contacts!.length,
        itemBuilder: (BuildContext context, int index) {
          Contact contact = _contacts![index];
          return InkWell(
            onTap: () {
              String phoneNumber = contact.phones!.first.value!;
              speakContactName(contact.displayName);

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    contentPadding: EdgeInsets.zero,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 56),
                              child: Text(
                                'Contact Details',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              //edit buttton for edit contatc
                              icon: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();

                                    editContact(contact);
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 55),
                                    child: Icon(Icons.edit),
                                  )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text('Name: ${contact.displayName ?? ''}'),
                        ),
                        if (contact.middleName != null &&
                            contact.middleName!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text('Middle Name: ${contact.middleName}'),
                          ),
                        if (contact.phones != null &&
                            contact.phones!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child:
                                Text('Phone: ${contact.phones!.first.value!}'),
                          ),
                        if (contact.emails != null &&
                            contact.emails!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child:
                                Text('Email: ${contact.emails!.first.value}'),
                          ),
                        if (contact.birthday != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text('Birthday: ${contact.birthday}'),
                          ),
                        // Add more contact details here if needed
                      ],
                    ),
                    actions: [
                      InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(Icons.close)),
                      InkWell(
                          onTap: () =>
                              openMessageApp(contact.phones!.first.value!),
                          child: const Icon(Icons.message)),
                      InkWell(
                          onTap: () {
                            String phoneNumber = contact.phones!.first.value!;
                            _makePhoneCall(phoneNumber);
                          },
                          child: const Icon(Icons.call))
                    ],
                  );
                },
              );
            },
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 2, horizontal: 18),
              leading: (contact.avatar != null && contact.avatar!.isNotEmpty)
                  ? CircleAvatar(child: Text(contact.displayName![0]))
                  : CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: Text(contact.initials()),
                    ),
              title: Text(contact.displayName ?? ''),
              subtitle: (contact.phones != null && contact.phones!.isNotEmpty)
                  ? Text(contact.phones!.first.value!)
                  : null, // Handle empty phones list
              trailing: InkWell(
                onTap: () {
                  String phoneNumber = contact.phones!.first.value!;
                  _makePhoneCall(phoneNumber);
                },
                child: const Icon(Icons.phone),
              ),
            ),
          );
        },
      );
    } else {
      return const Center(child: Text('No contacts found.'));
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not dial number.'),
          duration: Duration(seconds: 3),
        ),
      );
      throw 'Could not dial number: $e';
    }
  }

  Future<void> speakContactName(String? contactName) async {
    if (contactName != null) {
      await flutterTts.setLanguage('en-US');
      await flutterTts.speak('Contact name: $contactName');
    }
  }

  void openMessageApp(String phoneNumber) async {
    final Uri _smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
    );
    if (await canLaunch(_smsUri.toString())) {
      await launch(_smsUri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open messaging app.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
