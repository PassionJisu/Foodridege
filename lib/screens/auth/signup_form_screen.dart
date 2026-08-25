import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../services/demo_auth_store.dart';

class SignupFormScreen extends StatefulWidget {
  const SignupFormScreen({super.key, required this.role});

  final UserRole role;

  @override
  State<SignupFormScreen> createState() => _SignupFormScreenState();
}

class _SignupFormScreenState extends State<SignupFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _rrnLastDigitController = TextEditingController();
  final _addressController = TextEditingController();
  final _businessNumberController = TextEditingController();
  final _adminSecretController = TextEditingController();

  DateTime? _birthDate;
  DateTime? _stayStart;
  DateTime? _stayEnd;
  bool _obscurePassword = true;
  String? _school = DemoAuthStore.universities.first;
  StudentOrigin _origin = StudentOrigin.korean;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _rrnLastDigitController.dispose();
    _addressController.dispose();
    _businessNumberController.dispose();
    _adminSecretController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1940),
      lastDate: now,
      locale: const Locale('ko'),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _pickStayDate({required bool start}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: start
          ? (_stayStart ?? now)
          : (_stayEnd ?? now.add(const Duration(days: 180))),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 6),
      locale: const Locale('ko'),
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _stayStart = picked;
        if (_stayEnd != null && _stayEnd!.isBefore(picked)) {
          _stayEnd = null;
        }
      } else {
        _stayEnd = picked;
      }
    });
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('생년월일을 선택해 주세요')),
      );
      return;
    }
    if (widget.role == UserRole.student && _origin == StudentOrigin.exchange) {
      if (_stayStart == null || _stayEnd == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('체류 기간(시작일·종료일)을 선택해 주세요')),
        );
        return;
      }
      if (_stayEnd!.isBefore(_stayStart!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('체류 종료일은 시작일 이후여야 합니다')),
        );
        return;
      }
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final end = DateTime(_stayEnd!.year, _stayEnd!.month, _stayEnd!.day);
      if (todayDate.isAfter(end)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미 종료된 체류 기간으로는 가입할 수 없습니다')),
        );
        return;
      }
    }

    final auth = context.read<AuthProvider>();
    auth.clearError();

    final isStudent = widget.role == UserRole.student;
    final isExchange = isStudent && _origin == StudentOrigin.exchange;

    final success = await auth.signUp(
      email: _emailController.text,
      password: _passwordController.text,
      role: widget.role,
      name: _nameController.text,
      birthDate: _birthDate!,
      rrnLastDigit: isExchange ? '' : _rrnLastDigitController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      schoolInfo: isStudent ? _school : null,
      businessRegistrationNumber: widget.role == UserRole.owner
          ? _businessNumberController.text
          : null,
      adminSecret: widget.role == UserRole.admin ? _adminSecretController.text : null,
      studentOrigin: isStudent ? _origin : null,
      stayStart: isExchange ? _stayStart : null,
      stayEnd: isExchange ? _stayEnd : null,
    );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dateFormat = DateFormat('yyyy년 MM월 dd일');

    return Scaffold(
      appBar: AppBar(title: Text('${widget.role.label} 회원가입')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionTitle(title: '계정 정보'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: '이메일 *',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (v) =>
                  v == null || !v.contains('@') ? '올바른 이메일을 입력해 주세요' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: '비밀번호 *',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) =>
                  v == null || v.length < 6 ? '비밀번호는 6자 이상이어야 합니다' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordConfirmController,
              obscureText: _obscurePassword,
              decoration: const InputDecoration(
                labelText: '비밀번호 확인 *',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: (v) => v != _passwordController.text
                  ? '비밀번호가 일치하지 않습니다'
                  : null,
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: '필수 정보'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '이름 *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? '이름을 입력해 주세요' : null,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _birthDate == null
                    ? '생년월일 *'
                    : dateFormat.format(_birthDate!),
              ),
              subtitle: _birthDate == null
                  ? const Text('탭하여 생년월일 선택')
                  : null,
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onTap: _pickBirthDate,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: '연락처 *',
                prefixIcon: Icon(Icons.phone_outlined),
                hintText: '010-1234-5678',
              ),
              validator: (v) =>
                  v == null || v.trim().length < 10 ? '연락처를 입력해 주세요' : null,
            ),
            if (widget.role == UserRole.student) ...[
              const SizedBox(height: 24),
              const _SectionTitle(title: '대학생 구분'),
              const SizedBox(height: 12),
              RadioGroup<StudentOrigin>(
                groupValue: _origin,
                onChanged: (value) {
                  if (value != null) setState(() => _origin = value);
                },
                child: Column(
                  children: [
                    RadioListTile<StudentOrigin>(
                      value: StudentOrigin.korean,
                      title: Text(StudentOrigin.korean.label),
                      contentPadding: EdgeInsets.zero,
                    ),
                    RadioListTile<StudentOrigin>(
                      value: StudentOrigin.exchange,
                      title: Text(StudentOrigin.exchange.label),
                      subtitle: const Text('학교 정보와 체류 기간으로 가입합니다.'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey(_school),
                initialValue: _school,
                decoration: InputDecoration(
                  labelText: _origin == StudentOrigin.exchange
                      ? '학교 정보 *'
                      : '대학 *',
                  prefixIcon: const Icon(Icons.school_outlined),
                  helperText: _origin == StudentOrigin.exchange
                      ? '교환학생은 소속 학교 정보로 가입합니다.'
                      : null,
                ),
                items: DemoAuthStore.universities
                    .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                    .toList(),
                onChanged: (value) => setState(() => _school = value),
                validator: (v) => v == null || v.isEmpty ? '학교를 선택해 주세요' : null,
              ),
              if (_origin == StudentOrigin.exchange) ...[
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  title: Text(
                    _stayStart == null
                        ? '체류 시작일 *'
                        : '체류 시작일  ${dateFormat.format(_stayStart!)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  onTap: () => _pickStayDate(start: true),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  title: Text(
                    _stayEnd == null
                        ? '체류 종료일 *'
                        : '체류 종료일  ${dateFormat.format(_stayEnd!)}',
                  ),
                  subtitle: const Text('종료일 다음날부터 자동 회원 탈퇴됩니다.'),
                  trailing: const Icon(Icons.event_busy_outlined),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  onTap: () => _pickStayDate(start: false),
                ),
              ],
            ],
            if (widget.role != UserRole.student ||
                _origin == StudentOrigin.korean) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _rrnLastDigitController,
                keyboardType: TextInputType.number,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: '주민등록번호 뒷번호 1자리 *',
                  prefixIcon: Icon(Icons.badge_outlined),
                  counterText: '',
                ),
                validator: (v) {
                  if (v == null || v.length != 1) {
                    return '뒷번호 1자리를 입력해 주세요';
                  }
                  return null;
                },
              ),
            ],
            if (widget.role == UserRole.owner) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _businessNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '사업자 등록 번호 *',
                  prefixIcon: Icon(Icons.business_outlined),
                  hintText: '000-00-00000',
                ),
                validator: (v) => v == null || v.trim().length < 10
                    ? '사업자 등록 번호를 입력해 주세요'
                    : null,
              ),
            ],
            if (widget.role == UserRole.admin) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _adminSecretController,
                decoration: const InputDecoration(
                  labelText: '관리자 시크릿 키 *',
                  prefixIcon: Icon(Icons.key_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? '시크릿 키를 입력해 주세요' : null,
              ),
            ],
            const SizedBox(height: 24),
            _SectionTitle(title: '선택 정보'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: '주소',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: auth.isLoading ? null : _handleSignup,
              child: auth.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('가입 완료'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
