import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yalla_safqa/verifyemail.dart';



class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // 1. ALL CONTROLLERS
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _facultyController = TextEditingController();
  final TextEditingController _genderController = TextEditingController(
    text: "Male",
  );
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  bool _isLoading = false;
  

  // 2. ERROR VARIABLES FOR ALL FIELDS
  String? _firstNameError;
  String? _lastNameError;
  String? _phoneError;
  String? _facultyError;
  String? _emailError;
  String? _passwordError;

  // Colors
  final Color _bgColor = const Color.fromARGB(255, 38, 2, 58);
  final Color _inputBgColor = const Color(0xFF1B1B28);
  final Color _primaryPurple = const Color(0xFF6E56FF);
  final Color _textSecondary = const Color.fromARGB(255, 255, 255, 255);

  final List<String> _faculties = [
    'Computer Science',
    'Business',
    'Art and Design',
    'Engineering',
  ];

  // 3. MEMORY MANAGEMENT
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _facultyController.dispose();
    _genderController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _primaryPurple),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: "syne",
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderBanner(),
              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('First Name'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          hint: 'John',
                          controller: _firstNameController,
                          errorText: _firstNameError,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Last Name'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          hint: 'Doe',
                          controller: _lastNameController,
                          errorText: _lastNameError,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // University Email
              _buildLabel('University Email'),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: _getSharedInputDecoration(
                  'yourid@students.eui.edu.eg',
                  errorText: _emailError,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Requires verification via .edu domain',
                style: TextStyle(
                  color: _primaryPurple.withOpacity(0.8),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),

              // Phone Number
              _buildLabel('Phone Number'),
              const SizedBox(height: 8),
              _buildTextField(
                hint: '00000000000',
                controller: _phoneController,
                errorText: _phoneError,
              ),
              const SizedBox(height: 20),

              // Faculty Dropdown
              _buildLabel('Faculty'),
              const SizedBox(height: 8),
              _buildDropdown(),
              const SizedBox(height: 20),

              // Gender Toggle
              _buildLabel('Gender'),
              const SizedBox(height: 8),
              _buildGenderToggle(),
              const SizedBox(height: 20),

              // Password
              _buildLabel('Password'),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _isPasswordObscured,
                style: const TextStyle(color: Colors.white),
                decoration: _getSharedInputDecoration('••••••••').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordObscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: _textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordObscured = !_isPasswordObscured;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Confirm Password
              _buildLabel('Confirm Password'),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _isConfirmPasswordObscured,
                style: const TextStyle(color: Colors.white),
                decoration:
                    _getSharedInputDecoration(
                      '••••••••',
                      errorText: _passwordError,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordObscured
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: _textSecondary,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordObscured =
                                !_isConfirmPasswordObscured;
                          });
                        },
                      ),
                    ),
              ),
              const SizedBox(height: 32),

              // Continue Button
              _buildContinueButton(),
              const SizedBox(height: 16),

              // Verified Badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _inputBgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _primaryPurple.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline, color: _primaryPurple, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'VERIFIED STUDENTS ONLY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _primaryPurple,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Footer Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(color: _textSecondary, fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: _primaryPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: _getSharedInputDecoration(hint, errorText: errorText),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      // Connect to the controller text
      value: _facultyController.text.isEmpty ? null : _facultyController.text,
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
      dropdownColor: _inputBgColor,
      style: const TextStyle(color: Colors.white),
      decoration: _getSharedInputDecoration(
        'Select your faculty',
        errorText: _facultyError,
      ),
      items: _faculties.map((String faculty) {
        return DropdownMenuItem<String>(value: faculty, child: Text(faculty));
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _facultyController.text = newValue ?? '';
        });
      },
    );
  }

Widget _buildGenderToggle() {
    // Read state directly from the controller
    bool isMaleSelected = _genderController.text == "Male";

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: _inputBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _genderController.text = "Male";
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isMaleSelected ? _primaryPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    'Male',
                    style: TextStyle(
                      color: isMaleSelected ? Colors.white : _textSecondary,
                      fontWeight: isMaleSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _genderController.text = "Female";
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: !isMaleSelected ? _primaryPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    'Female',
                    style: TextStyle(
                      color: !isMaleSelected ? Colors.white : _textSecondary,
                      fontWeight: !isMaleSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildContinueButton() {
    return Center(
      child: Container(
        width: 200,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            colors: [Color(0xFF6E56FF), Color.fromARGB(255, 161, 2, 179)],
          ),
          boxShadow: [
            BoxShadow(
              color: _primaryPurple.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          // STEP 2: Added 'async' here
          onPressed: _isLoading ? null : () async { 
            setState(() {
              _firstNameError = null;
              _lastNameError = null;
              _phoneError = null;
              _facultyError = null;
              _emailError = null;
              _passwordError = null;
            });

            bool isValid = true;

            // --- Your existing validation checks ---
            if (_firstNameController.text.trim().isEmpty) {
              _firstNameError = 'Required';
              isValid = false;
            }
            if (_lastNameController.text.trim().isEmpty) {
              _lastNameError = 'Required';
              isValid = false;
            }
            if (_phoneController.text.trim().isEmpty ||
                !RegExp(r'^(010|011)\d{8}$').hasMatch(_phoneController.text.trim())) {
              _phoneError = 'Enter valid Egyptian number';
              isValid = false;
            }
            if (_facultyController.text.isEmpty) {
              _facultyError = 'Required';
              isValid = false;
            }

            String email = _emailController.text.trim();
            // if (email.isEmpty || !email.endsWith('@students.eui.edu.eg')) {
            //   _emailError = 'Must use a valid @students.eui.edu.eg email';
            //   isValid = false;
            // }

            // --- Replace the old Validate Passwords section with this ---
              
              String password = _passwordController.text;

              if (password.isEmpty) {
                _passwordError = 'Password cannot be empty';
                isValid = false;
              } else if (password.length < 8) {
                _passwordError = 'Must be at least 8 characters long';
                isValid = false;
              } else if (!RegExp(r'[A-Z]').hasMatch(password)) {
                _passwordError = 'Must contain at least one uppercase letter';
                isValid = false;
              } else if (!RegExp(r'[a-z]').hasMatch(password)) {
                _passwordError = 'Must contain at least one lowercase letter';
                isValid = false;
              } else if (!RegExp(r'[0-9]').hasMatch(password)) {
                _passwordError = 'Must contain at least one number';
                isValid = false;
              } else if (!RegExp(r'[!@#\$&*~%^()-+]').hasMatch(password)) {
                _passwordError = 'Must contain a special character (e.g., @, #, !)';
                isValid = false;
              } else if (password != _confirmPasswordController.text) {
                _passwordError = 'Passwords do not match';
                isValid = false;
              }
              
              // ------------------------------------------------------------

            if (!isValid) {
              setState(() {}); // Trigger rebuild to show red borders
              return; // Stop execution if validation failed
            }

            // --- FIREBASE SIGN UP LOGIC ---
            
            // Start the loading spinner
            setState(() {
              _isLoading = true; 
            });

            try {
              // STEP 3: Create the user in Firebase Auth
              UserCredential userCredential = await FirebaseAuth.instance
                  .createUserWithEmailAndPassword(
                email: email,
                password: _passwordController.text,
              );
              await userCredential.user!.sendEmailVerification();

              // STEP 4: Save extra data to Firestore
              final userData = {
                "firstName": _firstNameController.text.trim(),
                "lastName": _lastNameController.text.trim(),
                "email": email,
                "password":password,
                "phone": _phoneController.text.trim(),
                "faculty": _facultyController.text,
                "gender": _genderController.text,
                "createdAt": FieldValue.serverTimestamp(), //track when they joined
              };

              // Use the unique UID provided by Auth as the document ID in Firestore
              await FirebaseFirestore.instance
                  .collection('Users')
                  .doc(userCredential.user!.uid)
                  .set(userData);

              // SUCCESS! Navigate to the Verification Screen
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const VerifyEmailScreen()),
                );
              }

            } on FirebaseAuthException catch (e) {
              // STEP 5: Handle Firebase-specific errors
              setState(() {
                if (e.code == 'weak-password') {
                  _passwordError = 'The password provided is too weak.';
                } else if (e.code == 'email-already-in-use') {
                  _emailError = 'An account already exists for that email.';
                } else {
                  _emailError = e.message; // Catch-all for other errors
                }
              });
            } catch (e) {
              setState(() {
                _emailError = 'An error occurred. Please try again.';
              });
            } finally {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          // Swap the text/icon for a loading spinner if _isLoading is true
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ],
                ),
        ),
      ),
    );
  }

Widget _buildHeaderBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: const BoxDecoration(color: Colors.black),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/img/stu.png', fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Yallasafqa',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: "syne",
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'FOR STUDENTS, BY STUDENTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _primaryPurple,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- STYLING HELPERS ---

InputDecoration _getSharedInputDecoration(String hint, {String? errorText}) {
    return InputDecoration(
      hintText: hint,
      errorText: errorText,
      hintStyle: TextStyle(
        color: _textSecondary.withOpacity(0.6),
        fontSize: 14,
      ),
      filled: true,
      fillColor: _inputBgColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: _primaryPurple.withOpacity(0.5)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }
}
