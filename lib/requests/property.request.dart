import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/property.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/http.service.dart';

class PropertyRequest extends HttpService {
  //
  Future<List<Property>> getProperties({
    Map<String, dynamic>? queryParams,
    int? page = 1,
  }) async {
    final apiResult = await get(
      Api.properties,
      queryParameters: {
        ...(queryParams != null ? queryParams : {}),
        "page": "$page",
      },
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      if (page == null || page == 0) {
        return (apiResponse.body as List)
            .map((jsonObject) => Property.fromJson(jsonObject))
            .toList();
      } else {
        return apiResponse.data
            .map((jsonObject) => Property.fromJson(jsonObject))
            .toList();
      }
    }

    throw apiResponse.message;
  }

  //
  Future<Property> propertyDetails(int id) async {
    //
    final apiResult = await get("${Api.properties}/$id");
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return Property.fromJson(apiResponse.body);
    }

    throw apiResponse.message;
  }

  Future<ApiResponse> deleteProperty(Property service) async {
    final apiResult = await delete(Api.properties + "/${service.id}");
    //
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> updateProperty(
    Property service, {
    Map<String, dynamic>? data,
    List<File>? photos,
  }) async {
    final postBody = {
      "_method": "PUT",
      ...(data == null ? service.toJson() : data),
      "vendor_id": (await AuthServices.getCurrentVendor(force: true)).id,
    };

    FormData formData = FormData.fromMap(postBody);
    for (File file in photos ?? []) {
      formData.files.addAll([
        MapEntry("photos[]", await MultipartFile.fromFile(file.path)),
      ]);
    }

    final apiResult = await postWithFiles(
      Api.properties + "/${service.id}",
      null,
      formData: formData,
    );

    //
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> newProperty({
    required Map<String, dynamic> data,
    List<File>? photos,
  }) async {
    final postBody = {
      ...data,
      "vendor_id": (await AuthServices.getCurrentVendor(force: true)).id,
    };

    FormData formData = FormData.fromMap(postBody);
    for (File file in photos ?? []) {
      formData.files.addAll([
        MapEntry("photos[]", await MultipartFile.fromFile(file.path)),
      ]);
    }

    final apiResult = await postWithFiles(
      Api.properties,
      null,
      formData: formData,
    );
    //
    return ApiResponse.fromResponse(apiResult);
  }
}
