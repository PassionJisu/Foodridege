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
  final _studentIdController = TextEditingController();
  final _arcController = TextEditingController();
  final _orgNameController = TextEditingController();
  final _businessTypeController = TextEditingController();

  DateTime? _birthDate;
  DateTime? _stayStart;
  DateTime? _stayEnd;
  bool _obscurePassword = true;
  String? _school = DemoAuthStore.universities.first;
  StudentOrigin _origin = StudentOrigin.korean;

  bool get _needsRrn {
    if (widget.role == UserRole.org) return false;
    if (widget.role == UserRole.student || widget.role == UserRole.youth) {
      return _origin == StudentOrigin.korean;
    }
    return true;
  }

  bool get _isOrg => widget.role == UserRole.org;

  bool get _bilingual => widget.role.showsEnglishSignup;

  String _l(String ko, [String? en]) {
    if (!_bilingual || en == null || en.isEmpty) return ko;
    return '$ko  /  $en';
  }

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
    _studentIdController.dispose();
    _arcController.dispose();
    _orgNameController.dispose();
    _businessTypeController.dispose();
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
    if (!_isOrg && _birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_l('생년월일을 선택해 주세요', 'Please select your date of birth'))),
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
    final isYouth = widget.role == UserRole.youth;
    final isOrg = widget.role == UserRole.org;
    final isForeign = (isStudent || isYouth) && _origin == StudentOrigin.exchange;
    final isExchange = isStudent && _origin == StudentOrigin.exchange;

    final success = await auth.signUp(
      email: _emailController.text,
      password: _passwordController.text,
      role: widget.role,
      name: _nameController.text,
      birthDate: _birthDate ?? DateTime(1980, 1, 1),
      rrnLastDigit: (isForeign || isOrg) ? '' : _rrnLastDigitController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      schoolInfo: isStudent
          ? _school
          : (isOrg ? _orgNameController.text : null),
      businessRegistrationNumber:
          (widget.role == UserRole.owner || isOrg)
              ? _businessNumberController.text
              : null,
      adminSecret: widget.role == UserRole.admin ? _adminSecretController.text : null,
      studentOrigin: (isStudent || isYouth) ? _origin : null,
      stayStart: isExchange ? _stayStart : null,
      stayEnd: isExchange ? _stayEnd : null,
      studentId: isExchange ? _studentIdController.text : null,
      arcNumber: isYouth && isForeign ? _arcController.text : null,
      orgName: isOrg ? _orgNameController.text : null,
      businessType: isOrg ? _businessTypeController.text : null,
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
      appBar: AppBar(
        title: Text(_l('${widget.role.label} 회원가입', 'Sign up')),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionTitle(title: _l('계정 정보', 'Account')),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: _l('이메일 *', 'Email *'),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              validator: (v) =>
                  v == null || !v.contains('@')
                      ? _l('올바른 이메일을 입력해 주세요', 'Enter a valid email')
                      : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: _l('비밀번호 *', 'Password *'),
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
                  v == null || v.length < 6
                      ? _l('비밀번호는 6자 이상이어야 합니다', 'Password must be at least 6 characters')
                      : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordConfirmController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: _l('비밀번호 확인 *', 'Confirm password *'),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              validator: (v) => v != _passwordController.text
                  ? _l('비밀번호가 일치하지 않습니다', 'Passwords do not match')
                  : null,
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: _l('필수 정보', 'Required')),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: _isOrg ? '대표자명 *' : _l('이름 *', 'Name *'),
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty
                      ? (_isOrg
                          ? '대표자명을 입력해 주세요'
                          : _l('이름을 입력해 주세요', 'Please enter your name'))
                      : null,
            ),
            if (!_isOrg) ...[
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _birthDate == null
                      ? _l('생년월일 *', 'Date of birth *')
                      : dateFormat.format(_birthDate!),
                ),
                subtitle: _birthDate == null
                    ? Text(_l('탭하여 생년월일 선택', 'Tap to select'))
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
                decoration: InputDecoration(
                  labelText: _l('연락처 *', 'Phone *'),
                  prefixIcon: const Icon(Icons.phone_outlined),
                  hintText: '010-1234-5678',
                ),
                validator: (v) =>
                    v == null || v.trim().length < 10
                        ? _l('연락처를 입력해 주세요', 'Please enter your phone number')
                        : null,
              ),
            ],
            if (widget.role == UserRole.student ||
                widget.role == UserRole.youth) ...[
              const SizedBox(height: 24),
              _SectionTitle(
                title: widget.role == UserRole.youth
                    ? _l('청년 구분', 'Youth category')
                    : _l('대학생 구분', 'Student category'),
              ),
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
                      title: Text(
                        _l(
                          StudentOrigin.korean.labelFor(widget.role),
                          widget.role == UserRole.youth
                              ? 'Korean youth'
                              : 'Korean university student',
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    RadioListTile<StudentOrigin>(
                      value: StudentOrigin.exchange,
                      title: Text(
                        _l(
                          StudentOrigin.exchange.labelFor(widget.role),
                          widget.role == UserRole.youth
                              ? 'International youth'
                              : 'International / exchange student',
                        ),
                      ),
                      subtitle: Text(
                        widget.role == UserRole.youth
                            ? _l(
                                'ARC(외국인등록증) 정보가 필요합니다.',
                                'ARC (Alien Registration Card) is required.',
                              )
                            : _l(
                                '학번으로 가입합니다. ARC는 필요하지 않습니다.',
                                'Sign up with your student ID. ARC is not required.',
                              ),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ],
            if (widget.role == UserRole.student) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey(_school),
                initialValue: _school,
                decoration: InputDecoration(
                  labelText: _origin == StudentOrigin.exchange
                      ? _l('학교 정보 *', 'University *')
                      : _l('대학 *', 'University *'),
                  prefixIcon: const Icon(Icons.school_outlined),
                  helperText: _origin == StudentOrigin.exchange
                      ? _l(
                          '교환학생은 소속 학교 정보로 가입합니다.',
                          'Exchange students sign up with their host university.',
                        )
                      : null,
                ),
                items: DemoAuthStore.universities
                    .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                    .toList(),
                onChanged: (value) => setState(() => _school = value),
                validator: (v) => v == null || v.isEmpty
                    ? _l('학교를 선택해 주세요', 'Please select a university')
                    : null,
              ),
              if (_origin == StudentOrigin.exchange) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _studentIdController,
                  decoration: InputDecoration(
                    labelText: _l('학번 *', 'Student ID *'),
                    prefixIcon: const Icon(Icons.badge_outlined),
                    hintText: '202412345',
                    helperText: _l(
                      '외국인 대학생은 학번만 있으면 됩니다. (ARC 불필요)',
                      'Student ID is enough. ARC is not required.',
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty
                          ? _l('학번을 입력해 주세요', 'Please enter your student ID')
                          : null,
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  title: Text(
                    _stayStart == null
                        ? _l('체류 시작일 *', 'Stay start date *')
                        : '${_l('체류 시작일', 'Stay start')}  ${dateFormat.format(_stayStart!)}',
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
                        ? _l('체류 종료일 *', 'Stay end date *')
                        : '${_l('체류 종료일', 'Stay end')}  ${dateFormat.format(_stayEnd!)}',
                  ),
                  subtitle: Text(
                    _l(
                      '종료일 다음날부터 자동 회원 탈퇴됩니다.',
                      'Your account is closed the day after this date.',
                    ),
                  ),
                  trailing: const Icon(Icons.event_busy_outlined),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  onTap: () => _pickStayDate(start: false),
                ),
              ],
            ],
            if (widget.role == UserRole.youth &&
                _origin == StudentOrigin.exchange) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _arcController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: _l('ARC (외국인등록증) 번호 *', 'Alien Registration Card *'),
                  prefixIcon: const Icon(Icons.credit_card_outlined),
                  hintText: '000000-0000000',
                  helperText: _l(
                    '외국인 청년은 ARC 정보 기입이 필수입니다.',
                    'Required for international youth.',
                  ),
                ),
                validator: (v) {
                  final value = v?.replaceAll(RegExp(r'[\s-]'), '') ?? '';
                  if (value.length < 8) {
                    return _l('ARC 번호를 입력해 주세요', 'Please enter your ARC number');
                  }
                  return null;
                },
              ),
            ],
            if (_needsRrn) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _rrnLastDigitController,
                keyboardType: TextInputType.number,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: _l('주민등록번호 뒷번호 1자리 *', 'RRN last digit *'),
                  prefixIcon: const Icon(Icons.badge_outlined),
                  counterText: '',
                ),
                validator: (v) {
                  if (v == null || v.length != 1) {
                    return _l('뒷번호 1자리를 입력해 주세요', 'Enter the last digit of your RRN');
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
                decoration: InputDecoration(
                  labelText: _l('사업자 등록 번호 *', 'Business registration number *'),
                  prefixIcon: const Icon(Icons.business_outlined),
                  hintText: '000-00-00000',
                ),
                validator: (v) => v == null || v.trim().length < 10
                    ? _l('사업자 등록 번호를 입력해 주세요', 'Please enter your business number')
                    : null,
              ),
            ],
            if (_isOrg) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _orgNameController,
                decoration: const InputDecoration(
                  labelText: '기관명 (상호명) *',
                  prefixIcon: Icon(Icons.account_balance_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? '기관명을 입력해 주세요' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _businessNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '사업자등록번호 (또는 고유번호) *',
                  prefixIcon: Icon(Icons.business_outlined),
                  hintText: '000-00-00000',
                ),
                validator: (v) => v == null || v.trim().length < 10
                    ? '사업자등록번호 또는 고유번호를 입력해 주세요'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: '기관 소재지 (주소) *',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? '기관 소재지를 입력해 주세요' : null,
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
            _SectionTitle(title: _l('선택 정보', 'Optional')),
            const SizedBox(height: 12),
            if (_isOrg)
              TextFormField(
                controller: _businessTypeController,
                decoration: const InputDecoration(
                  labelText: '업태 및 종목',
                  prefixIcon: Icon(Icons.work_outline),
                  hintText: '예: 공공행정 / 식생활 지원',
                ),
              )
            else
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: _l('주소', 'Address'),
                  prefixIcon: const Icon(Icons.location_on_outlined),
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
                  : Text(_l('가입 완료', 'Complete sign-up')),
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
