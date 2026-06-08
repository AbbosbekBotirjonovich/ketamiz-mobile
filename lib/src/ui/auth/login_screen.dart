import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:ketamiz/src/ui/auth/verification_screen.dart';
import 'package:ketamiz/src/ui/widgets/texts/text_16h_500w.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/api/login_model.dart';
import '../../model/api/register_model.dart';
import '../../resources/repository.dart';
import '../../utils/secure_storage.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../dialogs/center_dialog.dart';
import '../dialogs/response_popup.dart';
import '../menu/main_screen.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/textfield/main_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  bool isLogin = true;

  // Keeps the focused field visible above the keyboard AND the
  // bottom-anchored login/register button (48 high + 24 bottom padding).
  static const EdgeInsets _fieldScrollPadding =
      EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 110);

  Repository _repository = Repository();

  String _getErrorMessage(dynamic result) {
    if (result == null) return translate("auth.failed_msg");

    String message = "";
    if (result is Map) {
      message = (result['message'] ?? result['error'] ?? "").toString();
    } else {
      message = result.toString();
    }

    final lowerMsg = message.toLowerCase();

    if (lowerMsg.contains("selected phone is invalid")) {
      return translate("auth.invalid_phone");
    }
    if (lowerMsg.contains("tasdiqlang") || lowerMsg.contains("verify")) {
      return translate("auth.verify_account");
    }
    if (lowerMsg.contains("phone") && (lowerMsg.contains("taken") || lowerMsg.contains("already registered") || lowerMsg.contains("already been taken"))) {
      return translate("auth.phone_taken");
    }
    if (lowerMsg.contains("password") && (lowerMsg.contains("incorrect") || lowerMsg.contains("invalid") || lowerMsg.contains("not match") || lowerMsg.contains("wrong"))) {
      return translate("auth.incorrect_password");
    }

    // If it's a long stack trace or HTML, don't show it raw
    if (message.contains("Illuminate\\") || message.contains("<!DOCTYPE html>")) {
      return translate("auth.failed_msg");
    }

    return message.isNotEmpty ? message : translate("auth.failed_msg");
  }

  /// Login
  TextEditingController phoneController = TextEditingController();
  TextEditingController passController = TextEditingController();

  /// Register
  TextEditingController phoneRegController = TextEditingController();
  TextEditingController passRegController = TextEditingController();
  TextEditingController passAgainController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController fatherNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFFF8EE),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  color: const Color(0xFFFFF8EE),
                  padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
                  height: MediaQuery.sizeOf(context).height / 2.2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/logos/logo-square.png',
                          height: 80,
                          width: 80,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        "${translate("auth.hello")},\n${translate("auth.welcome_back")}",
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w500,
                          fontFamily: AppTheme.fontFamily,
                          height: 1.4,
                          letterSpacing: 1,
                          color: AppTheme.black,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 8),
                      Text16h500w(
                        title: translate("auth.please_enter"),
                        color: AppTheme.gray,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 470),
                    margin: EdgeInsets.only(top: isLogin ? 340 : 0),
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(isLogin ? 32 : 0),
                        topLeft: Radius.circular(isLogin ? 32 : 0),
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: isLogin
                          ? MediaQuery.of(context).size.height - 340
                          : MediaQuery.of(context).size.height - 22,
                    ),
                    child: Container(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.only(
                        top: isLogin ? 0 : 20,
                        bottom: 100,
                      ),
                      // The outer SingleChildScrollView is the only scrollable —
                      // so focused fields are auto-scrolled in the right view.
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        if (!isLogin) ...[
                          Center(
                            child: Image.asset(
                              'assets/logos/logo-square.png',
                              height: 72,
                              width: 72,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        Container(
                          height: 56,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.light,
                            borderRadius: BorderRadius.circular(56),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (!isLogin) {
                                      setState(() {
                                        isLogin = true;
                                      });
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 280),
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isLogin
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(40),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: const Offset(0, 5),
                                          blurRadius: 8,
                                          color: isLogin
                                              ? AppTheme.dark.withOpacity(0.2)
                                              : Colors.transparent,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        translate("auth.login"),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: AppTheme.fontFamily,
                                          height: 1.5,
                                          letterSpacing: 0.5,
                                          color: isLogin
                                              ? AppTheme.black
                                              : AppTheme.dark,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (isLogin) {
                                      setState(() {
                                        isLogin = false;
                                      });
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 280),
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isLogin
                                          ? Colors.transparent
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(40),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: const Offset(0, 8),
                                          blurRadius: 8,
                                          color: isLogin
                                              ? Colors.transparent
                                              : AppTheme.dark.withOpacity(0.2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        translate("auth.sign_up"),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: AppTheme.fontFamily,
                                          height: 1.5,
                                          letterSpacing: 0.5,
                                          color: isLogin
                                              ? AppTheme.dark
                                              : AppTheme.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        isLogin
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  MainTextField(
                                    hintText: translate("auth.phone_number"),
                                    icon: Icons.phone_outlined,
                                    controller: phoneController,
                                    phone: true,
                                    scrollPadding: _fieldScrollPadding,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 16),
                                  MainTextField(
                                    hintText: translate("auth.password"),
                                    icon: Icons.lock_outline_rounded,
                                    controller: passController,
                                    pass: true,
                                    scrollPadding: _fieldScrollPadding,
                                    textInputAction: TextInputAction.done,
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  MainTextField(
                                    hintText: translate("auth.first_name"),
                                    icon: Icons.person_outline_rounded,
                                    controller: firstNameController,
                                    scrollPadding: _fieldScrollPadding,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    height: 66,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          offset:
                                          const Offset(0, 4),
                                          blurRadius: 100,
                                          spreadRadius: 0,
                                          color: AppTheme.black
                                              .withOpacity(0.05),
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      controller: lastNameController,
                                      scrollPadding: _fieldScrollPadding,
                                      textInputAction: TextInputAction.next,
                                      textAlignVertical: TextAlignVertical.center,
                                      cursorColor: AppTheme.purple,
                                      enableInteractiveSelection: true,
                                      obscureText: false,
                                      style: const TextStyle(
                                        fontFamily: AppTheme.fontFamily,
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        height: 1.5,
                                        color: AppTheme.black,
                                      ),
                                      keyboardType: TextInputType.text,
                                      autofocus: false,
                                      decoration: InputDecoration(
                                        border:
                                        const OutlineInputBorder(),
                                        enabledBorder:
                                        OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius
                                              .circular(16),
                                          borderSide:
                                          const BorderSide(
                                              color: AppTheme
                                                  .border),
                                        ),
                                        focusedBorder:
                                        OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius
                                              .circular(16),
                                          borderSide:
                                          const BorderSide(
                                            color:
                                            AppTheme.purple,
                                          ),
                                        ),
                                        contentPadding:
                                        const EdgeInsets
                                            .symmetric(
                                          vertical: 20,
                                          horizontal: 16,
                                        ),
                                        labelText: translate("auth.last_name"),
                                        labelStyle: TextStyle(
                                          fontFamily: AppTheme.fontFamily,
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          color: AppTheme.dark.withOpacity(0.6),
                                        ),
                                        prefixIcon: const Icon(Icons.person_outline_rounded),
                                        prefixIconColor: MaterialStateColor.resolveWith(
                                              (Set<MaterialState> states) {
                                            if (states.contains(MaterialState.focused)) {
                                              return AppTheme.black;
                                            }
                                            return AppTheme.dark;
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  MainTextField(
                                    hintText: translate("auth.father_name"),
                                    icon: Icons.person_outline_rounded,
                                    controller: fatherNameController,
                                    scrollPadding: _fieldScrollPadding,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 16),
                                  MainTextField(
                                    hintText: translate("auth.phone_number"),
                                    icon: Icons.phone_outlined,
                                    controller: phoneRegController,
                                    phone: true,
                                    scrollPadding: _fieldScrollPadding,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 16),
                                  MainTextField(
                                    hintText: translate("auth.email"),
                                    icon: Icons.email_outlined,
                                    controller: emailController,
                                    scrollPadding: _fieldScrollPadding,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 16),
                                  MainTextField(
                                    hintText: translate("auth.password"),
                                    icon: Icons.lock_outline_rounded,
                                    controller: passRegController,
                                    pass: true,
                                    scrollPadding: _fieldScrollPadding,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 16),
                                  MainTextField(
                                    hintText:
                                        translate("auth.confirm_password"),
                                    icon: Icons.lock_outline_rounded,
                                    controller: passAgainController,
                                    pass: true,
                                    scrollPadding: _fieldScrollPadding,
                                    textInputAction: TextInputAction.done,
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 24,
                  ),
                  child: SecondaryButton(
                    title: isLogin
                        ? translate("auth.login")
                        : translate("auth.register"),
                    onTap: () async {
                      if (isLogin == true) {
                        if (phoneController.text.trim().isEmpty ||
                            passController.text.isEmpty) {
                          CenterDialog.showActionFailed(
                            context,
                            translate("auth.error"),
                            translate("auth.fill_login_fields"),
                          );
                          return;
                        }
                        setState(() {
                          isLoading = true;
                        });
                        var response = await _repository.fetchLogin(
                          phoneController.text,
                          passController.text,
                        );

                        if (response.isSuccess) {
                          var result = LoginModel.fromJson(response.result);
                          setState(() {
                            isLoading = false;
                          });
                          if (result.status == "success") {
                            await SecureStorage.setToken(
                                result.authorisation.token);
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setBool("isFirst", false);
                            prefs.setString(
                              "token_date",
                              "${result.user.createdAt.day}-${result.user.createdAt.month}-${result.user.createdAt.year}",
                            );
                            showResponsePopup(
                              context,
                              status: result.status,
                              message: result.message,
                            );
                            await _repository.cacheLoginUser(result.user);
                            Navigator.of(context).popUntil(
                              (route) => route.isFirst,
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const MainScreen();
                                },
                              ),
                            );
                          } else {
                            showResponsePopup(
                              context,
                              status: result.status,
                              message: result.message,
                            );
                          }
                        } else {
                          setState(() {
                            isLoading = false;
                          });
                          if (response.status == 403) {
                            final serverMsg = response.result['message'] ?? "";
                            if (serverMsg.toString().toLowerCase().contains("tasdiqlang") ||
                                serverMsg.toString().toLowerCase().contains("verify")) {
                              String phone = phoneController.text;
                              phone = phone.replaceAll(' ', '');
                              phone = phone.replaceAll('-', '');
                              if (!phone.contains("+")) {
                                phone = "+$phone";
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VerificationScreen(
                                    phone: phone,
                                  ),
                                ),
                              );
                              showResponsePopup(
                                context,
                                status: 'error',
                                message: serverMsg.toString(),
                              );
                              return;
                            }
                          }

                          if (response.status == -1) {
                            showResponsePopup(
                              context,
                              status: 'error',
                              message: translate("auth.connection_failed_msg"),
                            );
                          } else {
                            showResponsePopup(
                              context,
                              status: 'error',
                              message: _getErrorMessage(response.result),
                            );
                          }
                        }
                      } else {
                        String phone = phoneRegController.text;

                        if (firstNameController.text.isNotEmpty &&
                            lastNameController.text.isNotEmpty &&
                            emailController.text.isNotEmpty &&
                            phoneRegController.text.isNotEmpty &&
                            passRegController.text.isNotEmpty &&
                            Validators.phoneNumberValidator(phone) == true &&
                            Validators.passwordValidator(
                                    passRegController.text) ==
                                true &&
                            passAgainController.text ==
                                passRegController.text) {
                          setState(() {
                            isLoading = true;
                          });
                          var response = await _repository.fetchRegister(
                            firstNameController.text,
                            lastNameController.text,
                            fatherNameController.text,
                            emailController.text,
                            phone,
                            passRegController.text,
                            passAgainController.text,
                          );
                          if (response.isSuccess) {
                            var result = RegisterModel.fromJson(
                              response.result,
                            );
                            setState(() {
                              isLoading = false;
                            });
                            if (result.status == "success") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return VerificationScreen(
                                      phone: phone,
                                    );
                                  },
                                ),
                              );
                              showResponsePopup(
                                context,
                                status: result.status,
                                message: result.message,
                              );
                            } else {
                              showResponsePopup(
                                context,
                                status: result.status,
                                message: result.message,
                              );
                            }
                          } else {
                            setState(() {
                              isLoading = false;
                            });
                            if (response.status == -1) {
                              showResponsePopup(
                                context,
                                status: 'error',
                                message: translate("auth.connection_failed_msg"),
                              );
                            } else {
                              showResponsePopup(
                                context,
                                status: 'error',
                                message: _getErrorMessage(response.result),
                              );
                            }
                          }
                        } else if (firstNameController.text.isEmpty ||
                            lastNameController.text.isEmpty ||
                            emailController.text.isEmpty ||
                            phoneRegController.text.isEmpty ||
                            passRegController.text.isEmpty ||
                            passAgainController.text.isEmpty) {
                          CenterDialog.showActionFailed(
                            context,
                            translate('auth.error'),
                            translate('auth.fill_signup_fields'),
                          );
                        } else if (Validators.phoneNumberValidator(
                                phoneRegController.text) ==
                            false) {
                          CenterDialog.showActionFailed(
                            context,
                            translate('auth.error'),
                            translate('auth.invalid_phone_format'),
                          );
                        } else if (!Validators.emailValidator(
                                emailController.text)) {
                          CenterDialog.showActionFailed(
                            context,
                            translate('auth.error'),
                            translate('auth.invalid_email'),
                          );
                        } else if (Validators.passwordValidator(
                                passRegController.text) ==
                            false) {
                          CenterDialog.showActionFailed(
                            context,
                            translate('auth.password_error'),
                            translate('auth.password_requirements'),
                          );
                        } else if (passAgainController.text !=
                            passRegController.text) {
                          CenterDialog.showActionFailed(
                            context,
                            translate('auth.password_error'),
                            translate('auth.password_mismatch'),
                          );
                        } else {
                          resetValues();
                          CenterDialog.showActionFailed(
                            context,
                            translate('auth.error'),
                            translate('auth.something_went_wrong'),
                          );
                        }
                      }
                    },
                  ),
                )
              ],
            ),
            isLoading == true
                ? Container(
                    color: AppTheme.black.withOpacity(0.45),
                    child: Center(
                      child: Container(
                        height: 96,
                        width: 96,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, 5),
                              blurRadius: 25,
                              spreadRadius: 0,
                              color: AppTheme.dark.withOpacity(0.2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppTheme.purple),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  void resetValues() {
    phoneController.clear();
    passController.clear();
    firstNameController.clear();
    lastNameController.clear();
    fatherNameController.clear();
    phoneRegController.clear();
    passRegController.clear();
    passAgainController.clear();
  }
}
