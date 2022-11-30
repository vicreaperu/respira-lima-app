import 'dart:io';
import 'package:app4/blocs/blocs.dart';
import 'package:app4/db/principal_db.dart';
import 'package:app4/helpers/helpers.dart';
import 'package:app4/screens_alerts/screens_alerts.dart';
import 'package:app4/share_preferences/internal_validations.dart';
import 'package:app4/themes/themes.dart';
import 'package:app4/ui/input_decorations.dart';
import 'package:app4/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:app4/providers/providers.dart';
import 'package:app4/share_preferences/preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import '../services/services.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  static String pageRoute = 'Settings';
  @override
  Widget build(BuildContext context) {
    final userAppDataBloc = BlocProvider.of<UserAppDataBloc>(context, listen: false);
    return ChangeNotifierProvider(
        create: (settingsContext) => AuthFormProvider(),
        child: Consumer<AuthFormProvider>(
            builder: (context, settingForm, _) => Scaffold(
                  resizeToAvoidBottomInset: false,
                  backgroundColor: AppTheme.white,
                  appBar: AppBar(
                    centerTitle: true,
                    automaticallyImplyLeading:
                        settingForm.isLoading ? false : true,
                    title: const Text(
                      'Datos personales',
                      style: TextStyle(color: AppTheme.black),
                    ),
                  ),
                  body: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlocBuilder<UserAppDataBloc, UserAppDataState>(
                          builder: (context, state) {
                            return Container(
                              alignment: Alignment.center,
                              color: AppTheme.gray30,
                              height: 200,
                              width: double.infinity,
                              child:
                                        state.picName.isNotEmpty ?
                                        Stack(
                                          children: [
                                            Image.file(
                                              
                                              state.picName.first,
                                              fit: BoxFit.cover,
                                              height: 200,
                                              width: double.infinity,
                                            ),
                                            Positioned(
                                              bottom: 10,
                                              right: 10,
                                              child: IconButton(
                                                icon: const CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  child: Icon(
                                                    Icons.edit,
                                                    size: 22,
                                                    color: AppTheme.blue,
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  await dialogForPic(context, userAppDataBloc);
                                                  // getFromGallery();
                                                  // getFromCamera();
                                                },
                                              ),
                                            ),
                                          ],
                                        ) 
                                        : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                        height: 135,
                                        width: 135,
                                        color: AppTheme.gray30,
                                        child: 
                                        Stack(
                                          children: [
                                            const Icon(
                                              Icons.person,
                                              color: AppTheme.gray50,
                                              size: 150,
                                            ),
                                            // Align(
                                            //     alignment: Alignment.bottomRight,
    
                                            //   ),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: Stack(
                                                alignment:
                                                    AlignmentDirectional.center,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.only(
                                                        right: 10),
                                                    height: 40,
                                                    width: 40,
                                                    decoration: const BoxDecoration(
                                                        color: AppTheme.white,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    50))),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.camera_alt,
                                                      size: 30,
                                                      color: AppTheme.blue,
                                                    ),
                                                    onPressed: () async {
                                                      await dialogForPic(context, userAppDataBloc);
                                                      // getFromGallery();
                                                      // getFromCamera();
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
    
                                            // Positioned(
                                            //   right: 5.0,
                                            //   bottom: 0.0,
                                            //   child:
                                            //     Icon(
                                            //       Icons.remove_circle,
                                            //       color: Colors.red,
                                            //     ),
    
                                            // ),
                                          ],
                                        ),
                                      ),
                                    
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(
                          height: 25,
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Text(
                            'Datos personales',
                            style: TextStyle(
                                color: AppTheme.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                        ),

                        // const SizedBox(height: 15,),

                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: _SettingsForm(),
                        ),
                      ],
                    ),
                  ),
                )));
  }

  dialogForPic(BuildContext context, UserAppDataBloc userAppDataBloc) async {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder:
      (context) => Center(
            child:
                Container(
              // decoration:
              //     const BoxDecoration(
              //   color: Colors
              //       .white,
              //   borderRadius:
              //       BorderRadius.all(
              //           Radius.circular(10)),
              // ),
              color: Colors.transparent,
              width: 210,
              height: 170,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [


                  BtnAllConfirmations(
                    text: 'Elegir imagen', 
                    onPressed: () async {
                      userAppDataBloc.add(OnSelectingPicEvent());
                      await getFromGallery()
                          .then((fileName) async {
                        print('pic--->>> GALLERY ${fileName?.path ?? 'X'}');
                        userAppDataBloc.add(OffSelectingPicEvent());
                        if(fileName != null){
                          userAppDataBloc.add(AddNewPicEvent(fileName: fileName ));
                          // await PrincipalDB.saveProfilePicture(fileName).then((value) {
                            Navigator.pop(context);
                          // });
                        }
                      });
                    }, 
                    btnColor: AppTheme.black, 
                    btnWidth: 200
                    ),

                  const SizedBox(
                    height: 20,
                  ),
                  BtnAllConfirmations(
                    text: "Tomar una foto", 
                    onPressed: () async {
                      userAppDataBloc.add(OnSelectingPicEvent());
                      await getFromCamera().then((fileName) async {
                        print('pic--->>> CAMERA ${fileName?.path ?? 'X'}');
                        userAppDataBloc.add(OffSelectingPicEvent());
                        if(fileName != null){
                          userAppDataBloc.add(AddNewPicEvent(fileName: fileName ));
                          // await PrincipalDB.saveProfilePicture(fileName).then((value) {
                            Navigator.pop(context);
                          // });
                        }
                      });
                    }, 
                    btnColor: AppTheme.black, 
                    btnWidth: 200),
                 
       
                ],
              ),
            ),
          ));
  }
}

class LabeledRadio extends StatelessWidget {
  const LabeledRadio({
    Key? key,
    required this.label,
    required this.padding,
    required this.groupValue,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  final String label;
  final EdgeInsets padding;
  final int groupValue;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (value != groupValue) {
          onChanged(value);
        }
      },
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            Radio<int>(
              activeColor: AppTheme.darkBlue,
              groupValue: groupValue,
              value: value,
              onChanged: (int? newValue) {
                onChanged(newValue!);
              },
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsForm extends StatefulWidget {
  const _SettingsForm({
    Key? key,
  }) : super(key: key);

  @override
  State<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<_SettingsForm> {
  @override
  Widget build(BuildContext context) {
    final settingForm = Provider.of<AuthFormProvider>(context);
    final Size screenSize = MediaQuery.of(context).size;
    final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
    final navigationBloc =
        BlocProvider.of<NavigationBloc>(context, listen: false);
    return authBloc.state.isAGuest
        ? const Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 20),
            child: SizedBox(
              child: Text(
                'Regístrate para porder ingresar completamente a esta ventana',
                style: TextStyle(
                    color: AppTheme.gray80,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
            ),
          )
        : Form(
            key: settingForm.formKeyRegister,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const _SettingDivider(),
                    TextFormField(
                      keyboardType: TextInputType.name,
                      // inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.singleLineFormatter],
                      initialValue: Preferences.userName,
                      decoration: InputDecotations.authInputDecoration(
                          hintText: 'Jose Perez',
                          labelText: 'Nombre',
                          sufixIcon: Icons.create_rounded),
                      // decoration: const InputDecoration(
                      //   labelText: 'Nombre',
                      //   helperText: 'Nombre del Usuario',
                      //   hintText: 'Pepe',
                      // ),
                      onChanged: (value) {
                        setState(() {
                          print('------name-----');
                          print(value);
                          settingForm.userName = value;
                          print(settingForm.userName);
                        });
                        // setState(() {});
                        // name = value;
                      },
                      validator: (value) {
                        return InternalValidations.nameValidator(value)
                            ? null
                            : 'Sin nombre';
                      },
                    ),

                    const _SettingDivider(),
                    TextFormField(
                      readOnly: true,
                      keyboardType: TextInputType.emailAddress,
                      initialValue: Preferences.userEmail,
                      decoration: InputDecotations.authInputDecoration(
                        hintText: 'aa@aa.com',
                        labelText: 'Correo electrónico',
                        // sufixIcon: Icons.create_rounded
                      ),
                      // decoration: const InputDecoration(
                      //   labelText: 'Email',
                      //   helperText: 'Correo electrónico',
                      //   hintText: 'aa@aa.com',
                      // ),
                      onChanged: (value) {
                        setState(() {
                          print('------email-----');
                          print(value);
                          settingForm.userEmail = value;
                          print(settingForm.userEmail);
                        });
                      },
                    ),
                    const _SettingDivider(),
                    // TextFormField(

                    //   keyboardType: TextInputType.phone,
                    //   inputFormatters: <TextInputFormatter>[
                    //     FilteringTextInputFormatter.digitsOnly
                    //   ],
                    //   initialValue: Preferences.userPhoneNumber,

                    //   decoration: InputDecotations.authInputDecoration(
                    //     hintText: '999999999',
                    //     labelText: 'Teléfono',
                    //     sufixIcon: Icons.create_rounded
                    //     ),
                    //   // decoration: const InputDecoration(
                    //   //   labelText: 'Teléfono',
                    //   //   helperText: 'Número de teléfono',
                    //   //   hintText: '000',
                    //   // ),
                    //   onChanged: (value) {
                    //     setState(() {

                    //     settingForm.userPhoneNumber = value;
                    //     });
                    //   },
                    //   validator: (value) {
                    //     return InternalValidations.phoneValidator(value) ? null : 'número incorrecto';
                    //   },
                    // ),

                    // const _SettingDivider(),

                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      initialValue: Preferences.userPassword,
                      obscuringCharacter: '•',
                      obscureText: true,
                      decoration: InputDecotations.authInputDecoration(
                          hintText: '••••••••',
                          labelText: 'Cambiar contraseña',
                          sufixIcon: Icons.create_rounded),
                      // decoration: const InputDecoration(
                      //   labelText: 'Contraseña',
                      //   helperText: 'Contraseña',
                      //   hintText: '••••••••',
                      // ),
                      onChanged: (value) {
                        setState(() {
                          print('-----passs--');
                          print(value);
                          settingForm.userPassword = value;
                        });
                      },
                      validator: (value) {
                        return InternalValidations.passwordValidator(value)
                            ? null
                            : 'Miinimo 6 caracteres';
                      },
                    ),
                    const _SettingDivider(),
                    TextFormField(
                      keyboardType: TextInputType.datetime,
                      initialValue: Preferences.userBirthday,
                      inputFormatters: [
                        MaskTextInputFormatter(
                          mask: "##-##-####",
                          filter: {
                            "#": RegExp(r'\d+|-|/'),
                          },
                        )
                      ],
                      decoration: InputDecotations.authInputDecoration(
                          hintText: '12-11-2000',
                          labelText: 'Fecha de nacimiento',
                          sufixIcon: Icons.calendar_month),
                      // const InputDecoration(
                      //   labelText: 'Fecha de nacimiento',
                      //   helperText: 'Fecha de nacimiento',
                      //   hintText: '12-11-2000',
                      // ),
                      onChanged: (value) {
                        settingForm.userBirthday = value;
                        print('/////////--------12');
                        print(value);
                      },
                    ),

                    const _SettingDivider(),
                    Container(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Género',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Wrap(
                            direction: Axis.horizontal,
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                color: Colors.white,
                                width: 120,
                                child: LabeledRadio(
                                  label: 'Femenino',
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5.0),
                                  value: 2,
                                  groupValue: Preferences.userGender,
                                  onChanged: (int newValue) {
                                    setState(() {
                                      Preferences.userGender = newValue;
                                    });
                                  },
                                ),
                              ),
                              Container(
                                width: 120,
                                color: Colors.white,
                                child: LabeledRadio(
                                  label: 'Masculino',
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5.0),
                                  value: 1,
                                  groupValue: Preferences.userGender,
                                  onChanged: (int newValue) {
                                    setState(() {
                                      Preferences.userGender = newValue;
                                    });
                                  },
                                ),
                              ),
                              Container(
                                color: Colors.white,
                                width: 100,
                                child: LabeledRadio(
                                  label: 'Otros',
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5.0),
                                  value: 3,
                                  groupValue: Preferences.userGender,
                                  onChanged: (int newValue) {
                                    setState(() {
                                      Preferences.userGender = newValue;
                                    });
                                  },
                                ),
                              ),
                              // Expanded(
                              //   child: RadioListTile<int>(
                              //     contentPadding: const EdgeInsets.all(0),
                              //     title: const Text(
                              //       'Femenino',
                              //       style: TextStyle(fontSize: 11, backgroundColor: AppTheme.red),),
                              //     value: 2,
                              //     groupValue: Preferences.userGender,
                              //     onChanged: (value) {

                              //       setState(() {
                              //         Preferences.userGender = value ?? 2;
                              //       });
                              // }),
                              // ),
                              // Expanded(
                              //   child: RadioListTile<int>(
                              //     contentPadding: const EdgeInsets.all(0),
                              //     title: const Text('masculino'),
                              //     value: 1,
                              //     groupValue: Preferences.userGender,
                              //     onChanged: (value) {
                              //       setState(() {
                              //           Preferences.userGender = value ?? 1;
                              //       });
                              // }),
                              // ),

                              // Expanded(
                              //   child: RadioListTile<int>(
                              //     contentPadding: const EdgeInsets.all(0),
                              //     title: const Text('otros'),
                              //     value: 3,
                              //     groupValue: Preferences.userGender,
                              //     onChanged: (value) {
                              //       setState(() {
                              //         Preferences.userGender = value ?? 3;
                              //       });
                              // }),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const _SettingDivider(),
                    Container(
                      color: AppTheme.gray30,
                      width: double.infinity,
                      height: 1.5,
                    ),
                    const _SettingDivider(),

                    navigationBloc.state.isNavigating || settingForm.isLoading
                        ? const SizedBox()
                        : Container(
                            width: double.infinity,
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: settingForm.isLoading 
                                  ? null
                                  : () async {
                                      settingForm.isLoading = true;
                                      final authService = Provider.of<AuthService>(
                                          context,
                                          listen: false);
                                      final String token =
                                          await PrincipalDB.getFirebaseToken();
                                      final bool isDeleted = await authService
                                          .deleteUserAccount(token);
                                      // final bool isDeleted = await authService.deleteUserAccount(Preferences.firebaseToken);
                                      if (isDeleted) {
                                        await Preferences.cleanTotalPreferences();
                                        authBloc.add(NotHasAccountEvent());
                                        await PrincipalDB.clearUserInfo()
                                            .then((value) {
                                              // settingForm.isLoading = false;
                                          if (value) {
                                            // Navigator.pushReplacementNamed(context, SplashScreen.pageRoute);
                                            if (Platform.isAndroid) {
                                              Restart.restartApp();
                                            } else {
                                              Phoenix.rebirth(context);
                                            }
                                          }
                                        });
                                      }
                                      settingForm.isLoading = false;
                                    },
                              style: ButtonStyle(
                                  overlayColor:
                                      MaterialStateProperty.all(AppTheme.red)),
                              child: const Text(
                                'Eliminar cuenta',
                                style: TextStyle(fontSize: 13, color:   AppTheme.red),
                              ),
                            ),
                          ),
                    const _SettingDivider(),

                    MaterialButton(
                      minWidth: double.infinity,
                      onPressed: settingForm.isLoading
                          ? null
                          : () async {
                              print('Aqui--------');
                              print(!settingForm.isValidRegister());

                              print('Aqui--------222');
                              settingForm.isLoading = true;
                              final authService =
                                  Provider.of<AuthService>(context, listen: false);
                              // TODO: The preferences must change after the updating was confirmed
                              print('----PRINTING ALL VALUES --------');

                              print(settingForm.userEmail.length);
                              print('Email is: ${settingForm.userEmail}');
                              print('Name is: ${settingForm.userName}');
                              print(
                                  'PhoneNumber is: ${settingForm.userPhoneNumber}');
                              print('Password is: ${settingForm.userPassword}');
                              // TODO: CAN ADD AND RESTRICTION BEFORE SENDING TO CHANGE
                              // TODO: DELETE ALL PRINTS
                              final String token =
                                  await PrincipalDB.getFirebaseToken();
                              final bool isChangedUserData =
                                  await authService.changeUserData(
                                email: Preferences.userEmail,
                                name: settingForm.userName.length == 0
                                    ? Preferences.userName
                                    : settingForm.userName,
                                phone: settingForm.userPhoneNumber.length == 0
                                    ? Preferences.userPhoneNumber
                                    : settingForm.userPhoneNumber,
                                birthday: settingForm.userBirthday.length == 0
                                    ? Preferences.userBirthday
                                    : settingForm.userBirthday,
                                gender: Preferences.getGenderString(),
                                idToken: token,
                                // idToken:   Preferences.firebaseToken ,
                              );

                              print('======ASKING IF CHANGE======');
                              print(isChangedUserData);
                              if (isChangedUserData) {
                                print('WILLL changeeeee0////////======');
                                // Preferences.userEmail        = settingForm.userEmail;
                                Preferences.userName =
                                    settingForm.userName.length == 0
                                        ? Preferences.userName
                                        : settingForm.userName;
                                Preferences.userPhoneNumber =
                                    settingForm.userPhoneNumber.length == 0
                                        ? Preferences.userPhoneNumber
                                        : settingForm.userPhoneNumber;
                                Preferences.userBirthday =
                                    settingForm.userBirthday.length == 0
                                        ? Preferences.userBirthday
                                        : settingForm.userBirthday;
                                // Preferences.userGender       = settingForm.userGender ;
                                print('WILLL changeeeee============');
                              }
                              if (settingForm.userPassword.length >= 6 &&
                                  Preferences.userPassword !=
                                      settingForm.userPassword) {
                                final bool changedPassword =
                                    await authService.changePassword(
                                        token, settingForm.userPassword);
                                // final bool changedPassword = await authService.changePassword(Preferences.firebaseToken, settingForm.userPassword);
                                if (changedPassword)
                                  Preferences.userPassword =
                                      settingForm.userPassword;
                              }
                              // await Future.delayed(Duration(seconds: 2));
                              print('outt/////////');
                              settingForm.isLoading = false;
                            },
                      disabledColor: AppTheme.gray50,
                      elevation: 0,
                      color: Color.fromRGBO(26, 74, 132, 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 15),
                        child: const Text(
                          'Guardar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const _SettingDivider(
                      height: 50,
                    )
                  ],
                ),
                settingForm.isLoading ? LoadingAlert(
                            screenSize: screenSize,
                            color: AppTheme.blue,
                          ): const SizedBox(),
              ],
            ),
          );
  }
}

class _SettingDivider extends StatelessWidget {
  final double? height;
  final Color colorDiv;
  const _SettingDivider({
    Key? key,
    this.height,
    this.colorDiv = AppTheme.gray10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: colorDiv,
      height: height,
    );
  }
}
