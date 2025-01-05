
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yajurmandir/MasterDataProvider.dart';


import 'GateRegisterProvider.dart';

var gateRegisterProviderALLP = ChangeNotifierProvider.autoDispose((ref) => GateRegisterProvider());
var masterRegisterProviderALLP = ChangeNotifierProvider.autoDispose((ref) => MasterDataProvider());
