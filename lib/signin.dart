import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:FoundIT/verifyemail.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _genderController = TextEditingController(text: "Male");
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _isLoading = false;
  bool _agreedToTerms = false;
  String _selectedCountryCode = '+20'; 

  bool _hasMinLength = false;
  bool _hasNumber = false;
  bool _hasUpperAndLower = false;

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;

  final Color _primaryColor = const Color(0xFFB5E575);
  final Color _textColor = const Color(0xFF1E1E1E);
  final Color _subtitleColor = const Color(0xFF8E8E8E);
  final Color _inputFillColor = const Color(0xFFF5F5F5);

  final List<String> _countryCodes = ['+20', '+1', '+44', '+971', '+966'];

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordChecklist);
  }

  void _updatePasswordChecklist() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasNumber = RegExp(r'[0-9]').hasMatch(password);
      _hasUpperAndLower = RegExp(r'[A-Z]').hasMatch(password) && RegExp(r'[a-z]').hasMatch(password);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront_outlined, color: Colors.green[800], size: 32),
                  const SizedBox(width: 8),
                  Text(
                    'FoundIt',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              Text(
                'Welcome to FoundIt',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign up or login below to manage your\nproject, task, and productivity',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: _subtitleColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(child: _buildTab(title: 'Login', isActive: false)),
                  Expanded(child: _buildTab(title: 'Sign Up', isActive: true)),
                ],
              ),
              const SizedBox(height: 30),

              _buildTextField(
                controller: _nameController,
                icon: Icons.person_outline,
                hint: 'Your full name',
                errorText: _nameError,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _emailController,
                icon: Icons.email_outlined,
                hint: 'Enter your email',
                errorText: _emailError,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              _buildPhoneField(),
              const SizedBox(height: 16),

              _buildGenderToggle(),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _passwordController,
                icon: Icons.lock_outline,
                hint: 'Enter your password',
                errorText: _passwordError,
                obscureText: _isPasswordObscured,
                suffixIcon: _buildVisibilityToggle(
                  isObscured: _isPasswordObscured,
                  onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _confirmPasswordController,
                icon: Icons.lock_outline,
                hint: 'Confirm your password',
                obscureText: _isConfirmPasswordObscured,
                suffixIcon: _buildVisibilityToggle(
                  isObscured: _isConfirmPasswordObscured,
                  onPressed: () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured),
                ),
              ),
              const SizedBox(height: 16),

              _buildPasswordChecklist(),
              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreedToTerms,
                      activeColor: Colors.green[800],
                      onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'By agreeing to the terms and conditions, you are entering into a binding contract with FoundIt.',
                      style: TextStyle(fontSize: 12, color: _subtitleColor, height: 1.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              _buildSubmitButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTab({required String title, required bool isActive}) {
    return GestureDetector(
      onTap: () {
        if (title == 'Login') {
          Navigator.pop(context); 
        }
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? Colors.green[800] : _subtitleColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 2, color: isActive ? Colors.green[800] : Colors.transparent),
          Container(height: 1, color: Colors.grey[300]),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    String? errorText,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: _textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _subtitleColor, fontSize: 14),
        errorText: errorText,
        prefixIcon: Icon(icon, color: _subtitleColor),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: _inputFillColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: _inputFillColor,
        borderRadius: BorderRadius.circular(12),
        border: _phoneError != null ? Border.all(color: Colors.redAccent) : null,
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.phone_outlined, color: _subtitleColor),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCountryCode,
              icon: Icon(Icons.arrow_drop_down, color: _subtitleColor),
              style: TextStyle(color: _textColor, fontSize: 14, fontWeight: FontWeight.bold),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCountryCode = newValue!;
                });
              },
              items: _countryCodes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
            ),
          ),
          Container(width: 1, height: 24, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 8)),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: _textColor),
              decoration: InputDecoration(
                hintText: 'Phone number',
                hintStyle: TextStyle(color: _subtitleColor, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderToggle() {
    bool isMaleSelected = _genderController.text == "Male";
    return Container(
      height: 52,
      decoration: BoxDecoration(color: _inputFillColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _genderController.text = "Male"),
              child: Container(
                decoration: BoxDecoration(
                  color: isMaleSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isMaleSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
                ),
                margin: const EdgeInsets.all(4),
                child: Center(
                  child: Text('Male', style: TextStyle(color: isMaleSelected ? Colors.green[800] : _subtitleColor, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _genderController.text = "Female"),
              child: Container(
                decoration: BoxDecoration(
                  color: !isMaleSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !isMaleSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
                ),
                margin: const EdgeInsets.all(4),
                child: Center(
                  child: Text('Female', style: TextStyle(color: !isMaleSelected ? Colors.green[800] : _subtitleColor, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityToggle({required bool isObscured, required VoidCallback onPressed}) {
    return IconButton(
      icon: Icon(isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: _subtitleColor, size: 20),
      onPressed: onPressed,
    );
  }

  Widget _buildPasswordChecklist() {
    return Column(
      children: [
        _buildChecklistItem('At least 8 characters', _hasMinLength),
        const SizedBox(height: 6),
        _buildChecklistItem('At least 1 number', _hasNumber),
        const SizedBox(height: 6),
        _buildChecklistItem('Both upper and lower case letters', _hasUpperAndLower),
      ],
    );
  }

  Widget _buildChecklistItem(String text, bool isMet) {
    return Row(
      children: [
        Icon(Icons.check_circle, color: isMet ? Colors.green[600] : Colors.grey[300], size: 16),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: isMet ? Colors.green[800] : _subtitleColor, fontSize: 12)),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Text('Sign Up', style: TextStyle(color: Colors.green[900], fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }


  Future<void> _handleSignUp() async {
    setState(() {
      _nameError = null;
      _emailError = null;
      _phoneError = null;
      _passwordError = null;
    });

    bool isValid = true;

    if (_nameController.text.trim().isEmpty) {
      _nameError = 'Required';
      isValid = false;
    }
    if (_emailController.text.trim().isEmpty) {
      _emailError = 'Required';
      isValid = false;
    }
    if (_phoneController.text.trim().isEmpty) {
      _phoneError = 'Required';
      isValid = false;
    }

    if (!_hasMinLength || !_hasNumber || !_hasUpperAndLower) {
      _passwordError = 'Please meet all password requirements';
      isValid = false;
    } else if (_passwordController.text != _confirmPasswordController.text) {
      _passwordError = 'Passwords do not match';
      isValid = false;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must agree to the terms.')));
      isValid = false;
    }

    if (!isValid) return;

    setState(() => _isLoading = true);

    try {
      List<String> nameParts = _nameController.text.trim().split(' ');
      String firstName = nameParts[0];
      String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      String fullPhone = _selectedCountryCode + _phoneController.text.trim();

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await userCredential.user!.sendEmailVerification();

      final userData = {
        "firstName": firstName,
        "lastName": lastName,
        "email": _emailController.text.trim(),
        "phone": fullPhone,
        "gender": _genderController.text,
        "createdAt": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('Users').doc(userCredential.user!.uid).set(userData);

      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const VerifyEmailScreen()));
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          _emailError = 'An account already exists for that email.';
        } else {
          _emailError = e.message;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}