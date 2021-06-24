import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map _checkboxes = {
    "owner": {"read": false, "write": false, "execute": false},
    "group": {"read": false, "write": false, "execute": false},
    "public": {"read": false, "write": false, "execute": false}
  };

  final _permissionCodeController = TextEditingController();
  final _permissionStringController = TextEditingController();

  bool wasLengthThree = false;
  bool wasLengthNine = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _permissionCodeController.dispose();
    _permissionStringController.dispose();
    super.dispose();
  }

  String _calculatePermissionCodeFromCheckboxes() {
    const Map<String, int> permissionValues = {"read": 4, "write": 2, "execute": 1};

    int ownerPermissionNumber = 0;
    int groupPermissionNumber = 0;
    int publicPermissionNumber = 0;

    for (String per in _checkboxes["owner"].keys) {
      _checkboxes["owner"][per]
          ? ownerPermissionNumber += permissionValues[per]
          : ownerPermissionNumber += 0;
    }

    for (String per in _checkboxes["group"].keys) {
      _checkboxes["group"][per]
          ? groupPermissionNumber += permissionValues[per]
          : groupPermissionNumber += 0;
    }

    for (String per in _checkboxes["public"].keys) {
      _checkboxes["public"][per]
          ? publicPermissionNumber += permissionValues[per]
          : publicPermissionNumber += 0;
    }

    return "$ownerPermissionNumber$groupPermissionNumber$publicPermissionNumber";
  }

  String _fitDecimal2Binary(int decimal) {
    String binaryNumber = decimal.toRadixString(2).toString();
    if (binaryNumber.length < 3) {
      for (int j = 0; j <= (3 - binaryNumber.length); j++) {
        binaryNumber = "0" + binaryNumber;
      }
    }

    return binaryNumber;
  }

  String _calculatePermissionString(int permissionNumber) {
    String binaryNumber = _fitDecimal2Binary(permissionNumber);

    List<String> permissions = ["r", "w", "x"];
    String permission = "";

    for (int i = 0; i < binaryNumber.length; i++) {
      if (binaryNumber[i] == "1") {
        permission += permissions[i];
      } else {
        permission += "-";
      }
    }

    return permission;
  }

  String _permissionCode2String(String permissionCode) {
    String fullPermissionString = "";

    permissionCode.split('').forEach((String permissionNumber) {
      String permissionString = _calculatePermissionString(int.parse(permissionNumber));
      fullPermissionString += permissionString;
    });

    return fullPermissionString;
  }

  _calculatePermission({String permissionCode}) {
    if (permissionCode == null) {
      permissionCode = _calculatePermissionCodeFromCheckboxes();
    }

    String fullPermissionString = _permissionCode2String(permissionCode);

    wasLengthThree = true;
    _permissionCodeController.value = TextEditingValue(
      text: permissionCode,
      selection: TextSelection.fromPosition(
        TextPosition(offset: permissionCode.length),
      ),
    );

    wasLengthNine = true;
    _permissionStringController.value = TextEditingValue(
      text: fullPermissionString,
      selection: TextSelection.fromPosition(
        TextPosition(offset: fullPermissionString.length),
      ),
    );
  }

  _fixCheckBoxes(String permissionCode, List<Map<String, bool>> valuesOfCheckBoxes) {
    for (int i = 0; i < 3; i++) {
      const List<String> valueNames = ["read", "write", "execute"];

      var number = permissionCode[i];
      String binaryNumber = _fitDecimal2Binary(int.parse(number));

      var checkboxValues = valuesOfCheckBoxes[i];

      for (int j = 0; j < 3; j++) {
        String valueName = valueNames[j];

        if (binaryNumber[j] == "1") {
          checkboxValues[valueName] = true;
        } else {
          checkboxValues[valueName] = false;
        }
      }
    }
  }

  String _permissionString2Code(String permissionString) {
    const Map<String, int> permissionValues = {"r": 4, "w": 2, "x": 1};

    int ownerPermissionNumber = 0;
    int groupPermissionNumber = 0;
    int publicPermissionNumber = 0;

    int i;

    for (i = 0; i < 3; i++) {
      if (permissionString[i] != "-") {
        ownerPermissionNumber += permissionValues[permissionString[i]];
      }
    }

    for (i = 3; i < 6; i++) {
      if (permissionString[i] != "-") {
        groupPermissionNumber += permissionValues[permissionString[i]];
      }
    }

    for (i = 6; i < 9; i++) {
      if (permissionString[i] != "-") {
        publicPermissionNumber += permissionValues[permissionString[i]];
      }
    }

    return "$ownerPermissionNumber$groupPermissionNumber$publicPermissionNumber";
  }

  void _handleCheckboxChanged(newCheckboxValues) {
    setState(() {
      _checkboxes = newCheckboxValues;
      _calculatePermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    final _containerColor = Color.fromARGB(255, 232, 232, 232);

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Chmod Calculator",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          SizedBox(height: 10),
          MyContainer("owner", _checkboxes, _handleCheckboxChanged),
          MyContainer("group", _checkboxes, _handleCheckboxChanged),
          MyContainer("public", _checkboxes, _handleCheckboxChanged),
          Container(
            width: 150,
            height: 115,
            margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _containerColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: [
                Flexible(
                  flex: 1,
                  child: Text(
                    "Linux Permissions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.lightBlue,
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 45,
                        child: TextField(
                          controller: _permissionCodeController,
                          enableInteractiveSelection: false,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '666',
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white70,
                            counterText: "",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(90.0)),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.copy),
                              onPressed: () {
                                if (_permissionCodeController.text != "") {
                                  FlutterClipboard.copy(_permissionCodeController.text)
                                      .then((value) {
                                    Fluttertoast.showToast(msg: "Code Copied");
                                  });
                                }
                              },
                            ),
                          ),
                          maxLength: 3,
                          cursorColor: Colors.lightBlue,
                          textAlignVertical: TextAlignVertical.bottom,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-7]')),
                          ],
                          onChanged: (value) {
                            if (value.length == 3) {
                              setState(() {
                                wasLengthThree = true;

                                _calculatePermission(permissionCode: value);
                                _fixCheckBoxes(value, [
                                  _checkboxes["owner"],
                                  _checkboxes["group"],
                                  _checkboxes["public"]
                                ]);
                              });
                            }

                            if (wasLengthThree && value.length == 2) {
                              wasLengthThree = false;

                              setState(() {
                                _permissionStringController.clear();
                                _fixCheckBoxes("000", [
                                  _checkboxes["owner"],
                                  _checkboxes["group"],
                                  _checkboxes["public"]
                                ]);
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        height: 45,
                        child: TextField(
                          controller: _permissionStringController,
                          enableInteractiveSelection: false,
                          decoration: InputDecoration(
                            hintText: 'rw-rw-rw-',
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white70,
                            counterText: "",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(90.0)),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.paste),
                              onPressed: () {
                                FlutterClipboard.paste().then((permissionString) {
                                  RegExp codeRegExp = RegExp(r'^[0-7]{3}$');
                                  RegExp stringRegExp = RegExp(r'^([r-][w-][x-]){3}$');

                                  if (codeRegExp.hasMatch(permissionString)) {
                                    permissionString = _permissionCode2String(permissionString);
                                  }

                                  if (stringRegExp.hasMatch(permissionString) ||
                                      stringRegExp.hasMatch(permissionString.substring(1))) {
                                    if (permissionString.length == 10)
                                      permissionString = permissionString.substring(1, 10);

                                    setState(() {
                                      _permissionStringController.value = TextEditingValue(
                                        text: permissionString,
                                        selection: TextSelection.fromPosition(
                                          TextPosition(
                                            offset: permissionString.length,
                                          ),
                                        ),
                                      );

                                      wasLengthNine = true;

                                      String permissionCode =
                                          _permissionString2Code(permissionString);
                                      _calculatePermission(permissionCode: permissionCode);
                                      _fixCheckBoxes(permissionCode, [
                                        _checkboxes["owner"],
                                        _checkboxes["group"],
                                        _checkboxes["public"]
                                      ]);
                                    });
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: "Please Paste Valid Permission",
                                    );
                                  }
                                });
                              },
                            ),
                          ),
                          maxLength: 9,
                          cursorColor: Colors.lightBlue,
                          textAlignVertical: TextAlignVertical.bottom,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^(([r-][w-][x-])|([r-][w-])|([r-])){0,3}'),
                            ),
                            FilteringTextInputFormatter.deny(
                              RegExp(r'[r]{2}'),
                              replacementString: "r",
                            )
                          ],
                          onChanged: (value) {
                            if (value.length == 9) {
                              setState(() {
                                wasLengthNine = true;

                                String permissionCode = _permissionString2Code(value);
                                _calculatePermission(permissionCode: permissionCode);
                                _fixCheckBoxes(permissionCode, [
                                  _checkboxes["owner"],
                                  _checkboxes["group"],
                                  _checkboxes["public"]
                                ]);
                              });
                            }

                            if (wasLengthNine && value.length == 8) {
                              wasLengthNine = false;

                              setState(() {
                                _permissionCodeController.clear();
                                _fixCheckBoxes("000", [
                                  _checkboxes["owner"],
                                  _checkboxes["group"],
                                  _checkboxes["public"]
                                ]);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyContainer extends StatelessWidget {
  MyContainer(this.name, this.checkboxes, this.onChanged);

  final name;
  final checkboxes;
  final onChanged;

  @override
  Widget build(BuildContext context) {
    final _containerColor = Color.fromARGB(255, 232, 232, 232);
    double _checkBoxSize = 28.0;

    return Container(
      height: 105,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _containerColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Text(
              name[0].toUpperCase() + name.substring(1),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.lightBlue,
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Read",
                        style: TextStyle(fontSize: 17),
                      ),
                      SizedBox(
                        height: _checkBoxSize,
                        width: _checkBoxSize,
                        child: Checkbox(
                          value: checkboxes[name]["read"],
                          onChanged: (value) {
                            checkboxes[name]["read"] = value;
                            onChanged(checkboxes);
                          },
                          activeColor: Colors.lightBlue,
                        ),
                      ),
                    ],
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(
                      "Write",
                      style: TextStyle(fontSize: 17),
                    ),
                    SizedBox(
                      height: _checkBoxSize,
                      width: _checkBoxSize,
                      child: Checkbox(
                        value: checkboxes[name]["write"],
                        onChanged: (value) {
                          checkboxes[name]["write"] = value;
                          onChanged(checkboxes);
                        },
                        activeColor: Colors.lightBlue,
                      ),
                    ),
                  ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Execute",
                        style: TextStyle(fontSize: 17),
                      ),
                      SizedBox(
                        height: _checkBoxSize,
                        width: _checkBoxSize,
                        child: Checkbox(
                          value: checkboxes[name]["execute"],
                          onChanged: (value) {
                            checkboxes[name]["execute"] = value;
                            onChanged(checkboxes);
                          },
                          activeColor: Colors.lightBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
