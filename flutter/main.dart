// demo of transfer table
// flutter app
// shows udp client and bluetooth client
// udp communicate with the picow transfer table
// bluetooth communicate with dcc station

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // needed for exit
import 'package:get/get.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert'; // needed for utf8.encode

final buttonStyle = ButtonStyle(backgroundColor:
  MaterialStateProperty.all<Color?>(Colors.teal[100]));
  
final santafe = ButtonStyle(backgroundColor:
  MaterialStateProperty.all<Color?>(Colors.blue[100]));
  
final burlington = ButtonStyle(backgroundColor:
  MaterialStateProperty.all<Color?>(Colors.red[100]));

void main() {WidgetsFlutterBinding.ensureInitialized(); // without this, error tx has not been initialized
  runApp(MaterialApp(home:Home()));}

class Home extends StatelessWidget{
final ble=FlutterReactiveBle();
RawDatagramSocket? socket;
late QualifiedCharacteristic tx;
dynamic trackPower=false.obs;
var status='connect to ble'.obs;

void send(val) async {
  List<int> data=utf8.encode(val);
  await ble.writeCharacteristicWithoutResponse(tx,value:data);}
  
void send_udp(val){socket?.send(val.codeUnits,InternetAddress('192.168.6.214'),8080);}

void udp_connect() async{socket=await RawDatagramSocket.bind(InternetAddress.anyIPv4,8080);}

void ble_connect() async{
  status.value='connecting...';
  late StreamSubscription<ConnectionStateUpdate> c;
  c=ble.connectToDevice(id:'A4:DA:32:55:06:1E').listen((s){
  if (s.connectionState == DeviceConnectionState.connected){
    status.value='connected';
    tx=QualifiedCharacteristic(serviceId:Uuid.parse('0000ffe0-0000-1000-8000-00805f9b34fb'),
    characteristicId:Uuid.parse('0000ffe1-0000-1000-8000-00805f9b34fb'),
    deviceId:'A4:DA:32:55:06:1E');}});}

@override Widget build(BuildContext c){
return Scaffold(appBar:AppBar(title:Text('train transfer demo')),
body:Column(spacing: 20,children:[

ElevatedButton(onPressed:(){ble_connect();}, child: Obx(() =>Text('${status}')),style:buttonStyle),

ElevatedButton(child:Text('connect to transfer station'), onPressed:(){udp_connect();},style:buttonStyle),
  
Padding(padding:EdgeInsets.fromLTRB(30,0,30,0),child: Obx(() => Row(children:[Text('track power on: '),
(Switch(value:trackPower.value, activeColor:Colors.green,
onChanged:(bool v){send('+mte t\r'); trackPower.value=v;}))]))),

Padding(padding:EdgeInsets.fromLTRB(20,0,20,0),child:Row(spacing:20,children:[
ElevatedButton(child:Text('forward burlington'), onPressed:(){send('+ld 15 f\r');},style:burlington),
ElevatedButton(child:Text('reverse burlington'), onPressed:(){send('+ld 15 t\r');},style:burlington),
])),

Padding(padding:EdgeInsets.fromLTRB(20,0,20,0),child:Row(spacing:20,children:[
ElevatedButton(child:Text('move burlington'), onPressed:(){send('+ls 15 20\r');},style:burlington),
ElevatedButton(child:Text('stop burlington'), onPressed:(){send('+ls 15 0\r');},style:burlington),
])),

SizedBox(height:20),

Padding(padding:EdgeInsets.fromLTRB(20,0,20,0),child:Row(spacing:20,children:[
ElevatedButton(child:Text('forward santa fe'), onPressed:(){send('+ld 20 t\r');},style:santafe),
ElevatedButton(child:Text('reverse santa fe'), onPressed:(){send('+ld 20 f\r');},style:santafe),
])),

Padding(padding:EdgeInsets.fromLTRB(20,0,20,0),child:Row(spacing:20,children:[
ElevatedButton(child:Text('move santa fe'), onPressed:(){send('+ls 20 30\r');},style:santafe),
ElevatedButton(child:Text('stop santa fe'), onPressed:(){send('+ls 20 0\r');},style:santafe),
])),
  
Padding(padding:EdgeInsets.all(30.0),child:Row(spacing:20,children:[
ElevatedButton(child:Text('move table left'), onPressed:(){send_udp('move 900 dir 1\r');},style:buttonStyle),
ElevatedButton(child:Text('move table right'), onPressed:(){send_udp('move 900 dir 0\r');},style:buttonStyle),
])), 
  
  //on exit turn off track power
  ElevatedButton(child:Text('Exit'), onPressed:(){
    send('+mte f\r'); SystemNavigator.pop();})]));}}
