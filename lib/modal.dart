import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realidadnacional/auth_services.dart';

enum FormType { login, register, recover }

void showAuthModal(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AuthModal(),
  );
}

class AuthModal extends StatefulWidget {
  @override
  _AuthModalState createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal> {
  FormType _formType = FormType.login;
  late AuthService _authService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authService = Provider.of<AuthService>(context, listen: false);
  }

  String _getFormTitle() {
    switch (_formType) {
      case FormType.login:
        return 'Iniciar Sesión';
      case FormType.register:
        return 'Registrarse';
      case FormType.recover:
        return 'Recuperar Contraseña';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[850],
      child: Container(
        width: 425,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getFormTitle(),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white),
            ),
            SizedBox(height: 16),
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    onTap: (index) {
                      setState(() {
                        _formType = FormType.values[index];
                      });
                    },
                    tabs: [
                      Tab(text: 'Iniciar Sesión'),
                      Tab(text: 'Registrarse'),
                      //Tab(text: 'Recuperar'),
                    ],
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                  ),
                  SizedBox(height: 16),
                  [
                    LoginForm(),
                    RegisterForm(),
                    RecoverForm(),
                  ][_formType.index],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  LoginForm();

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late AuthService _authService;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authService = Provider.of<AuthService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Correo electrónico',
            hintText: 'correo@ejemplo.com',
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            labelStyle: TextStyle(color: Colors.white70),
            hintStyle: TextStyle(color: Colors.white30),
          ),
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            labelStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 16),
        if (_errorMessage.isNotEmpty)
          Text(
            _errorMessage,
            style: TextStyle(color: Colors.red),
          ),
        SizedBox(height: 16),
        FilledButton(
          onPressed: _login,
          child: Text('Iniciar Sesión'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
        ),
      ],
    );
  }

  void _login() async {
    final result = await _authService.loginUser({
      'email': _emailController.text,
      'password': _passwordController.text,
    });

    if (result['success']) {
      Navigator.of(context).pop(); // Close the modal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inicio de sesión exitoso')),
      );
    } else {
      setState(() {
        _errorMessage = result['error'];
      });
    }
  }
}

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  late AuthService _authService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authService = Provider.of<AuthService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: 'Nombre de usuario',
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            labelStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Correo electrónico',
            hintText: 'correo@ejemplo.com',
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            labelStyle: TextStyle(color: Colors.white70),
            hintStyle: TextStyle(color: Colors.white30),
          ),
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            labelStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 16),
        if (_errorMessage.isNotEmpty)
          Text(
            _errorMessage,
            style: TextStyle(color: Colors.red),
          ),
        SizedBox(height: 16),
        FilledButton(
          onPressed: _register,
          child: Text('Registrarse'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
        ),
      ],
    );
  }

  void _register() async {
    final result = await _authService.registerUser({
      'fullName': _usernameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
    });

    if (result['success']) {
      Navigator.of(context).pop(); // Close the modal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registro exitoso')),
      );
    } else {
      setState(() {
        _errorMessage = result['error'];
      });
    }
  }
}

class RecoverForm extends StatefulWidget {
  @override
  _RecoverFormState createState() => _RecoverFormState();
}

class _RecoverFormState extends State<RecoverForm> {
  final TextEditingController _emailController = TextEditingController();
  String _errorMessage = '';
  late AuthService _authService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authService = Provider.of<AuthService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Correo electrónico',
            hintText: 'correo@ejemplo.com',
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            labelStyle: TextStyle(color: Colors.white70),
            hintStyle: TextStyle(color: Colors.white30),
          ),
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 16),
        if (_errorMessage.isNotEmpty)
          Text(
            _errorMessage,
            style: TextStyle(color: Colors.red),
          ),
        SizedBox(height: 16),
        FilledButton(
          onPressed: _recoverPassword,
          child: Text('Recuperar Contraseña'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
        ),
      ],
    );
  }

  void _recoverPassword() async {
    final result = await _authService.forgotPassword(_emailController.text);

    if (result['success']) {
      Navigator.of(context).pop(); // Close the modal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Se ha enviado un correo para recuperar tu contraseña')),
      );
    } else {
      setState(() {
        _errorMessage = result['error'];
      });
    }
  }
}
