import 'dart:io';

import 'package:chesster/models/player.dart';
import 'package:chesster/widgets/container_form_field.dart';
import 'package:chesster/widgets/image_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebaseAuth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignup = false;
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _username = '';
  String? _usernameErrorMessage;
  File? _image;
  bool _isAuthenticating = false;
  bool _attemptedSubmit = false;

  void onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      print('nononononon');
      return;
    }
    _formKey.currentState!.save();

    try {
      setState(() {
        _usernameErrorMessage = null;
        _attemptedSubmit = true;
        _isAuthenticating = true;
      });
      if (_isSignup) {
        final usernameDoc = _firestore.collection('usernames').doc(_username);

        if ((await usernameDoc.get()).exists) {
          setState(() {
            _usernameErrorMessage = 'Username taken!';
          });
          return;
        }
        final userCreds = await _firebaseAuth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCreds.user!.uid}.jpg');
        await storageRef.putFile(_image!);
        final imageUrl = await storageRef.getDownloadURL();
        final newPlayer = Player(
          username: _username,
          email: _email,
          imageUrl: imageUrl,
        );
        final batch = _firestore.batch();
        final userDoc = _firestore.collection('users').doc(userCreds.user!.uid);
        batch.set(usernameDoc, {'uid': userCreds.user!.uid});
        batch.set(userDoc, newPlayer.toJson);
        await batch.commit();
      } else {
        await _firebaseAuth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
      }
    } on FirebaseAuthException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? "Authentication failed")),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isSignup) ...[
                            ContainerFormField<ImageInput, File>(
                              errorColor: Theme.of(context).colorScheme.error,
                              validator: (imageFile) => imageFile == null
                                  ? 'Profile picture required'
                                  : null,
                              onSaved: (File? imageFile) {
                                _image = imageFile;
                              },
                              child: ImageInput.new,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Username',
                                errorText: _usernameErrorMessage,
                              ),
                              enableSuggestions: false,
                              autovalidateMode: _attemptedSubmit
                                  ? AutovalidateMode.onUserInteraction
                                  : AutovalidateMode.onUnfocus,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length < 3) {
                                  return 'Please enter a longer username';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _username = value!;
                              },
                            )
                          ],
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            enableSuggestions: false,
                            autovalidateMode: _attemptedSubmit
                                ? AutovalidateMode.onUserInteraction
                                : AutovalidateMode.onUnfocus,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _email = value!;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                            obscureText: true,
                            autovalidateMode: _attemptedSubmit
                                ? AutovalidateMode.onUserInteraction
                                : AutovalidateMode.onUnfocus,
                            validator: (value) {
                              if (value == null || value.trim().length < 8) {
                                return 'Password must be at least 8 characters long';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _password = value!;
                            },
                          ),
                          const SizedBox(height: 12),
                          _isAuthenticating
                              ? const CircularProgressIndicator()
                              : Column(
                                  children: [
                                    ElevatedButton(
                                      onPressed: onSubmit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                      ),
                                      child:
                                          Text(_isSignup ? 'Signup' : 'Login'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _isSignup = !_isSignup;
                                        });
                                        _formKey.currentState!.reset();
                                      },
                                      child: Text(_isSignup
                                          ? 'I already have an account'
                                          : 'Create an account'),
                                    )
                                  ],
                                )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
