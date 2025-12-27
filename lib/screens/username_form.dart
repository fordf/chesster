import 'package:chesster/models/player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebaseAuth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class UsernameForm extends StatefulWidget {
  // final String? userImageUrl;

  const UsernameForm({
    super.key,
    // this.userImageUrl,
  });

  @override
  State<StatefulWidget> createState() => _UsernameFormState();
}

class _UsernameFormState extends State<UsernameForm> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String? _usernameErrorMessage;

  bool _isAuthenticating = false;
  bool _attemptedSubmit = false;

  void onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _usernameErrorMessage = null;
      _attemptedSubmit = true;
      _isAuthenticating = true;
    });

    final user = _firebaseAuth.currentUser!;
    final userJson = Player(
      username: _username,
      email: user.email!,
      imageUrl: null,
    ).toJson;
    final userDocRef = _firestore.collection('users').doc(user.uid);
    final usernameDocRef = _firestore.collection('usernames').doc(_username);

    final batch = _firestore.batch();
    batch.set(usernameDocRef, {'uid': user.uid});
    batch.set(userDocRef, userJson);
    try {
      await batch.commit();
      return;
    } on FirebaseException catch (e) {
      print(e);
      _usernameErrorMessage = 'Username taken';
    }
    // try {
    //   final Map<String, dynamic> transactionRes =
    //       await _firestore.runTransaction(
    //     (transaction) async {
    //       final usernameDoc = await transaction.get(usernameDocRef);
    //       if (usernameDoc.exists) {
    //         return {'error': 'Username taken'};
    //       } else {
    //         await transaction.set(usernameDocRef, {'uid': uid});
    //         await transaction.set(userDocRef, newPlayer);
    //         return {'success': 'user created'};
    //       }
    //     },
    //   );
    // } catch (e) {
    //   print(e);
    // }
    // setState(() {
    //   _isAuthenticating = false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your chosen username was already taken :(',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                    errorText: _usernameErrorMessage,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _usernameErrorMessage = null;
                    });
                  },
                  enableSuggestions: false,
                  autocorrect: false,
                  autovalidateMode: _attemptedSubmit
                      ? AutovalidateMode.always
                      : AutovalidateMode.onUnfocus,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 3) {
                      return 'Please enter a longer username';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _username = value!;
                  },
                ),
                const SizedBox(height: 12),
                _isAuthenticating
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: const Text('Submit'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
