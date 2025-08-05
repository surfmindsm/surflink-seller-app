import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../utils/theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  
  UserType _userType = UserType.influencer;
  bool _isPasswordVisible = false;
  bool _isPasswordConfirmVisible = false;
  bool _agreeTerms = false;
  bool _agreePrivacy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_agreeTerms || !_agreePrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이용약관과 개인정보처리방침에 동의해주세요.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signup(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
      type: _userType,
      phone: _phoneController.text.trim().isNotEmpty 
          ? _phoneController.text.trim() 
          : null,
      company: _userType == UserType.seller && _companyController.text.trim().isNotEmpty
          ? _companyController.text.trim()
          : null,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('회원가입이 완료되었습니다. 프로필을 설정해주세요.'),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
      context.go('/profile');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? '회원가입에 실패했습니다.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 사용자 유형 선택
                        Text(
                          '사용자 유형',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<UserType>(
                                title: const Text('인플루언서'),
                                subtitle: const Text('콘텐츠 제작자'),
                                value: UserType.influencer,
                                groupValue: _userType,
                                onChanged: (value) {
                                  setState(() {
                                    _userType = value!;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<UserType>(
                                title: const Text('판매사'),
                                subtitle: const Text('광고주'),
                                value: UserType.seller,
                                groupValue: _userType,
                                onChanged: (value) {
                                  setState(() {
                                    _userType = value!;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // 이메일
                        Text(
                          '이메일',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'example@email.com',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '이메일을 입력해주세요';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return '올바른 이메일 형식을 입력해주세요';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 비밀번호
                        Text(
                          '비밀번호',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: '8자 이상, 특수문자 포함',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible 
                                    ? Icons.visibility_off 
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '비밀번호를 입력해주세요';
                            }
                            if (value.length < 8) {
                              return '비밀번호는 8자 이상이어야 합니다';
                            }
                            if (!RegExp(r'[!@#$%^&*(),.?\":{}|<>]').hasMatch(value)) {
                              return '특수문자를 포함해야 합니다';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 비밀번호 확인
                        Text(
                          '비밀번호 확인',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordConfirmController,
                          obscureText: !_isPasswordConfirmVisible,
                          decoration: InputDecoration(
                            hintText: '비밀번호를 다시 입력하세요',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordConfirmVisible 
                                    ? Icons.visibility_off 
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordConfirmVisible = !_isPasswordConfirmVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '비밀번호 확인을 입력해주세요';
                            }
                            if (value != _passwordController.text) {
                              return '비밀번호가 일치하지 않습니다';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 이름/상호명
                        Text(
                          _userType == UserType.seller ? '상호명' : '이름',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: _userType == UserType.seller ? '회사명을 입력하세요' : '이름을 입력하세요',
                            prefixIcon: Icon(_userType == UserType.seller 
                                ? Icons.business : Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '${_userType == UserType.seller ? '상호명' : '이름'}을 입력해주세요';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 휴대폰 번호
                        Text(
                          '휴대폰 번호 (선택)',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: '010-1234-5678',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                        ),
                        
                        if (_userType == UserType.seller) ...[
                          const SizedBox(height: 16),
                          
                          // 담당자명
                          Text(
                            '담당자명 (선택)',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _companyController,
                            decoration: const InputDecoration(
                              hintText: '담당자 이름을 입력하세요',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 24),
                        
                        // 약관 동의
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                CheckboxListTile(
                                  value: _agreeTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreeTerms = value ?? false;
                                    });
                                  },
                                  title: const Text('이용약관 동의'),
                                  subtitle: const Text('(필수)'),
                                  secondary: TextButton(
                                    onPressed: () {
                                      // TODO: 이용약관 보기
                                    },
                                    child: const Text('보기'),
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                CheckboxListTile(
                                  value: _agreePrivacy,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreePrivacy = value ?? false;
                                    });
                                  },
                                  title: const Text('개인정보처리방침 동의'),
                                  subtitle: const Text('(필수)'),
                                  secondary: TextButton(
                                    onPressed: () {
                                      // TODO: 개인정보처리방침 보기
                                    },
                                    child: const Text('보기'),
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                
                // 회원가입 버튼
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _handleSignup,
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('회원가입'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
