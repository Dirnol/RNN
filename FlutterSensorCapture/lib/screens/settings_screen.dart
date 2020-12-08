import 'package:RNNSensorCapture/model/settings.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settingsScreen';
  @override
  State<StatefulWidget> createState() {
    return _SettingsState();
  }
}

class _SettingsState extends State<SettingsScreen> {
  var formKey = GlobalKey<FormState>();
  Settings settings;
  String _outputType = 'file';
  bool keyboardVisible = false;
  Controller con;

  @override
  void initState() {
    super.initState();
    con = Controller(this);
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        keyboardVisible = visible;
      },
    );
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    settings ??= args['settings'];
    return Scaffold(
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 50,
              ),
              IconButton(
                  icon: Icon(Icons.keyboard_hide),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                  }),
              Center(
                child: Container(
                  width: 200,
                  child: RadioListTile<String>(
                      title: Text('Write to File'),
                      value: 'file',
                      groupValue: _outputType,
                      onChanged: (String value) {
                        render(() {
                          _outputType = value;
                        });
                      }),
                ),
              ),
              Center(
                child: Container(
                  width: 200,
                  child: RadioListTile<String>(
                      title: Text('Write to Port'),
                      value: 'port',
                      groupValue: _outputType,
                      onChanged: (String value) {
                        render(() {
                          _outputType = value;
                        });
                      }),
                ),
              ),
              _outputType == 'file'
                  ? SizedBox()
                  : Container(
                      width: 200,
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Host IP',
                        ),
                        initialValue: '192.168.1.70',
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        autocorrect: false,
                        validator: con.validatorIP,
                        onSaved: con.onSavedIP,
                      ),
                    ),
              _outputType == 'file'
                  ? SizedBox()
                  : Container(
                      width: 200,
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Port',
                        ),
                        initialValue: '25555',
                        keyboardType: TextInputType.number,
                        autocorrect: false,
                        validator: con.validatorPort,
                        onSaved: con.onSavedPort,
                      ),
                    ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: RaisedButton(
                  onPressed: con.save,
                  child: Text('Save'),
                ),
              ),
              IconButton(
                  icon: Icon(Icons.keyboard_hide),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class Controller {
  _SettingsState _state;
  Controller(this._state);

  String ip;
  int port;

  String validatorIP(String value) {
    if (value.split('.').length != 4) {
      return 'invalid ip';
    }
    return null;
  }

  void onSavedIP(String value) {
    _state.settings.ip = value;
  }

  String validatorPort(String value) {
    try {
      int.parse(value);
    } catch (e) {
      return 'invalid port';
    }
    return null;
  }

  void onSavedPort(String value) {
    _state.settings.port = int.parse(value);
  }

  void save() {
    if (_state._outputType == 'file') {
      _state.settings.outputType = OUTPUT_TYPE.file;
      Navigator.pop(_state.context);
    } else {
      if (!_state.formKey.currentState.validate()) {
        return;
      }
      _state.settings.outputType = OUTPUT_TYPE.port;
      _state.formKey.currentState.save();
      Navigator.pop(_state.context);
    }
  }
}
