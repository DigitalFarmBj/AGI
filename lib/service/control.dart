
import 'package:agriconnect/models/userModek.dart';
import 'package:get/get.dart';

class ContactController extends GetxController {
  RxList<UserModel> contacts = RxList<UserModel>();
  var selectedContacts = <UserModel>[].obs;
 
}