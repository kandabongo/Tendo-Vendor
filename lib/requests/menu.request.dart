import 'package:dio/dio.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/menu.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/http.service.dart';

class MenuRequest extends HttpService {
  //
  Future<List<Menu>> getMenus() async {
    final apiResult = await get(
      Api.menus,
      queryParameters: {"vendor_id": AuthServices.currentVendor?.id},
    );
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse.data.map((jsonObject) {
        return Menu.fromJson(jsonObject);
      }).toList();
    } else {
      throw apiResponse.message;
    }
  }

  //creates a single menu (name) or multiple menus at once (names)
  Future<ApiResponse> newMenu({required List<String> names}) async {
    Map<String, dynamic> postBody = {
      "names": names,
      "vendor_id": AuthServices.currentVendor?.id,
    };
    final apiResult = await post(Api.menus, postBody);
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> updateMenu(Menu menu, Map<String, dynamic> value) async {
    final postBody = {
      "_method": "PUT",
      ...value,
      "vendor_id": AuthServices.currentVendor?.id,
    };
    FormData formData = FormData.fromMap(postBody);

    final apiResult = await postWithFiles(
      "${Api.menus}/${menu.id}",
      null,
      formData: formData,
    );
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> deleteMenu(Menu menu) async {
    final apiResult = await delete("${Api.menus}/${menu.id}");
    return ApiResponse.fromResponse(apiResult);
  }
}
