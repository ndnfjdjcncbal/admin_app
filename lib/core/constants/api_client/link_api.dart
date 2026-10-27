class ApiConstants {
  static const String Api = "http://20.0.24.135/ecommerceapp";
  ////////////////////////auth//////////////////////////////
  static const String signupl = "$Api/adminapp/auth/signin.php";
  static const String verifiedcodesignup =
      "$Api/adminapp/auth/verfiecationcode.php";
  static const String resendcode =
      "$Api/adminapp/auth/forgetpassword/resendcode.php";
  static const String login = "$Api/adminapp/auth/login.php";
  static const String rimages = "$Api/image";

  ////////////////////////forgetpassword//////////////////////////////
  static const String forgetpasswordlink =
      "$Api/adminapp/auth/forgetpassword/forgetpassword.php";
  static const String checkcodelogin =
      "$Api/adminapp/auth/forgetpassword/checkcodelogin.php";
  static const String resetpass =
      "$Api/adminapp/auth/forgetpassword/resetpassword.php";
  ///////////////////////category//////////////////////////////////
  static const String getcategory = "$Api/adminapp/category/get_categories.php";
  static const String getitemsforcategoty =
      "$Api/adminapp/category/get_category_products.php";
  static const String addcategory = "$Api/adminapp/category/add_category.php";
  static const String deletecategory =
      "$Api/adminapp/category/delete_category.php";
  static const String editcategory = "$Api/adminapp/category/edit_categort.php";
  ////////////////////////////////products//////////////////////////

  static const String addproduct = "$Api/adminapp/products/add_product.php";
  static const String deleteproduct =
      "$Api/adminapp/products/delete_product.php";
  static const String editproduct = "$Api/adminapp/products/edit_product.php";
  /////////////////////////////profile//////////////////////////////////////////
  static const String updateprofile =
      "$Api/adminapp/profile/update_profile.php";
  static const String updateimage = "$Api/adminapp/profile/update_image.php";
  static const String changepassword =
      "$Api/adminapp/profile/change_password.php";
  static const String update_fcm_token = "$Api/adminapp/update_fcm_token.php";
  static const String aproveorder = "$Api/adminapp/orders/approve_order.php";
  static const String rejectorder = "$Api/adminapp/orders/reject_order.php";
  static const String get_new_orders =
      "$Api/adminapp/orders/get_new_orders.php";
}
