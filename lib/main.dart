
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VyroApp());
}

const Color auroraBlack = Color(0xFF080B16);
const Color auroraPurple = Color(0xFF8B5CF6);
const Color auroraTeal = Color(0xFF22D3C5);
const Color auroraPink = Color(0xFFEC4899);

class VyroApp extends StatelessWidget {
  const VyroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VYRO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: auroraBlack,
        colorScheme: ColorScheme.fromSeed(
          seedColor: auroraPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _openWelcome();
  }

  Future<void> _openWelcome() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const WelcomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AuroraBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              VyroLogo(size: 100),
              SizedBox(height: 22),
              Text(
                'VYRO',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 9,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'A WORLD WITHOUT LIMITS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  letterSpacing: 3,
                ),
              ),
              SizedBox(height: 38),
              SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: auroraTeal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuroraBackground extends StatelessWidget {
  final Widget child;

  const AuroraBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.7, -0.8),
          radius: 1.5,
          colors: [
            Color(0xFF26305B),
            auroraBlack,
            Color(0xFF100D24),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: _glow(auroraPurple, 240),
          ),
          Positioned(
            bottom: -130,
            left: -100,
            child: _glow(auroraTeal, 260),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }

  Widget _glow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.17),
            blurRadius: 100,
            spreadRadius: 35,
          ),
        ],
      ),
    );
  }
}

class VyroLogo extends StatelessWidget {
  final double size;

  const VyroLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            auroraTeal,
            auroraPurple,
            auroraPink,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: auroraPurple.withOpacity(0.35),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        Icons.bolt_rounded,
        color: Colors.white,
        size: size * 0.68,
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _openAuth(BuildContext context, bool createAccount) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AuthScreen(
          createAccount: createAccount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const VyroLogo(size: 90),
              const SizedBox(height: 25),
              const Text(
                'WELCOME TO VYRO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Discover people, share your world, '
                'and connect beyond boundaries.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [auroraTeal, auroraPurple, auroraPink],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ElevatedButton(
                    onPressed: () => _openAuth(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'CREATE ACCOUNT',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () => _openAuth(context, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('I ALREADY HAVE AN ACCOUNT'),
                ),
              ),
              const SizedBox(height: 35),
              const Text(
                'YOUR WORLD. YOUR VOICE. YOUR VYRO.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 9,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  final bool createAccount;

  const AuthScreen({
    super.key,
    required this.createAccount,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hidePassword = true;

  @override
  void dispose() {
    _contactController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Form validated. Account services will be connected '
          'in the next development stage.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final creating = widget.createAccount;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('VYRO'),
      ),
      body: AuroraBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: VyroLogo(size: 65)),
                  const SizedBox(height: 25),
                  Text(
                    creating ? 'Join VYRO' : 'Welcome back',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    creating
                        ? 'Start creating your world.'
                        : 'Sign in to continue.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 30),
                  _field(
                    controller: _contactController,
                    label: 'Email address or phone number',
                    icon: Icons.alternate_email_rounded,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter your email or phone number';
                      }
                      return null;
                    },
                  ),
                  if (creating) ...[
                    const SizedBox(height: 16),
                    _field(
                      controller: _usernameController,
                      label: 'Choose a username',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().length < 3) {
                          return 'Username must have at least 3 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _hidePassword,
                    validator: (value) {
                      if (value == null || value.length < 8) {
                        return 'Password must have at least 8 characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _hidePassword = !_hidePassword;
                          });
                        },
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: auroraPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        creating ? 'CONTINUE' : 'SIGN IN',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
