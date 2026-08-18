import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/models/property.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/property_details.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/currency_hstack.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class PropertyDetailsPage extends StatelessWidget {
  const PropertyDetailsPage(this.property, {Key? key}) : super(key: key);

  final Property property;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PropertyDetailsViewModel>.reactive(
      viewModelBuilder: () => PropertyDetailsViewModel(context, property),
      builder: (context, vm, child) {
        return BasePage(
          showAppBar: false,
          body: Stack(
            children: [
              // Content
              SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: VStack([
                  // Images
                  _buildImageHeader(context),

                  // Details
                  VStack([
                    // Title & Rating
                    HStack([
                      property.name.text.xl2.bold.make().expand(),
                      if (property.reviewsCount > 0)
                        HStack([
                          Icon(Icons.star, color: Colors.orange, size: 18),
                          "${property.rating}".text.bold.make(),
                          " (${property.reviewsCount})".text.gray500.sm.make(),
                        ]),
                    ]),
                    UiSpacer.verticalSpace(space: 5),

                    // Location
                    HStack([
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      5.widthBox,
                      property.address.text.gray500.make().expand(),
                    ]),
                    UiSpacer.verticalSpace(),

                    // Price
                    _buildPriceSection(context),
                    UiSpacer.verticalSpace(),
                    Divider(color: Colors.grey[200]),
                    UiSpacer.verticalSpace(),

                    // Stats Grid
                    _buildStatsGrid(context),
                    UiSpacer.verticalSpace(),
                    Divider(color: Colors.grey[200]),
                    UiSpacer.verticalSpace(),

                    // Description
                    if (property.description.isNotEmpty) ...[
                      "About this place".tr().text.xl.bold.make(),
                      UiSpacer.verticalSpace(space: 10),
                      property.description.text.lg.heightRelaxed.make(),
                      UiSpacer.verticalSpace(),
                      Divider(color: Colors.grey[200]),
                      UiSpacer.verticalSpace(),
                    ],

                    // Amenities
                    if (property.amenities.isNotEmpty) ...[
                      "What this place offers".tr().text.xl.bold.make(),
                      UiSpacer.verticalSpace(space: 10),
                      _buildAmenities(context),
                      UiSpacer.verticalSpace(),
                      Divider(color: Colors.grey[200]),
                      UiSpacer.verticalSpace(),
                    ],

                    // Policies
                    "Things to know".tr().text.xl.bold.make(),
                    UiSpacer.verticalSpace(space: 10),
                    _buildPolicies(context),
                    (context.percentHeight * 20).heightBox,
                  ]).p20(),
                ]),
              ),

              // Back Button & AppBar Actions
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child:
                      HStack([
                        // Back Button
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(Icons.arrow_back, color: Colors.black),
                        ).onInkTap(vm.goBack),
                        Spacer(),
                        // Optional Actions (Like Share/Favorite if needed later)
                      ]).p16(),
                ),
              ),

              // Bottom Actions
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomBar(context, vm),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageHeader(BuildContext context) {
    return VxSwiper.builder(
      itemCount: property.photos.isNotEmpty ? property.photos.length : 1,
      height: 300,
      viewportFraction: 1.0,
      autoPlay: true,
      itemBuilder: (context, index) {
        String imageUrl = property.mainPhoto;
        if (property.photos.isNotEmpty) {
          imageUrl = property.photos[index];
        }
        return CustomImage(
          imageUrl: imageUrl,
          width: double.infinity,
          height: 300,
          boxFit: BoxFit.cover,
        );
      },
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return HStack([
      CurrencyHStack([
        AppStrings.currencySymbol.text.xl2.bold
            .color(context.primaryColor)
            .make(),
        property.price
            .toString()
            .text
            .xl2
            .bold
            .color(context.primaryColor)
            .make(),
      ]),
      " / night".tr().text.gray500.lg.make(),
    ]);
  }

  Widget _buildStatsGrid(BuildContext context) {
    return HStack(
      [
        _buildStatItem(
          context,
          Icons.people_outline,
          "${property.maxGuests}",
          "Guests",
        ),
        _buildStatItem(
          context,
          Icons.bed_outlined,
          "${property.bedrooms}",
          "Bedrooms",
        ),
        _buildStatItem(
          context,
          Icons.bathtub_outlined,
          "${property.bathrooms}",
          "Baths",
        ),
        _buildStatItem(
          context,
          Icons.square_foot,
          "${property.squareMeters}",
          "m²",
        ),
      ],
      alignment: MainAxisAlignment.spaceBetween,
      axisSize: MainAxisSize.max,
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return VStack([
          Icon(icon, size: 24, color: Colors.grey[700]),
          5.heightBox,
          value.text.bold.lg.make(),
          label.tr().text.xs.gray500.make(),
        ], crossAlignment: CrossAxisAlignment.center)
        .p12()
        .box
        .color(Vx.gray50)
        .rounded
        .make()
        .expand();
  }

  Widget _buildAmenities(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
          property.amenities.map((amenity) {
            return HStack([
                  // If amenity has an icon/image, we could show it here.
                  // For now, dot indicator
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: context.primaryColor,
                  ),
                  8.widthBox,
                  amenity.name.text.make(),
                ])
                .pSymmetric(h: 12, v: 8)
                .box
                .border(color: Colors.grey[300]!)
                .rounded
                .make();
          }).toList(),
    );
  }

  Widget _buildPolicies(BuildContext context) {
    return VStack([
      _buildPolicyRow(
        "Check-in".tr(),
        "${property.checkInTimeStart} - ${property.checkInTimeEnd}",
      ),
      Divider(color: Colors.grey[100]),
      _buildPolicyRow("Check-out".tr(), property.checkOutTime),
      if (property.cancellationPolicy != null) ...[
        Divider(color: Colors.grey[100]),
        _buildPolicyRow("Cancellation".tr(), property.cancellationPolicy!.name),
      ],
    ]).p16().box.border(color: Colors.grey[200]!).rounded.make();
  }

  Widget _buildPolicyRow(String label, String value) {
    return HStack([
      label.text.gray600.make().expand(),
      value.text.medium.make(),
    ]).py8();
  }

  Widget _buildBottomBar(BuildContext context, PropertyDetailsViewModel vm) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: CustomButton(
              title: "Manage Property".tr(),
              color: Colors.white,
              titleStyle: TextStyle(color: Colors.black),
              onPressed: vm.manageProperty,
              elevation: 0,
              shapeRadius: Sizes.radiusDefault,
            )
            .cornerRadius(Sizes.radiusDefault)
            .box
            .border(color: Colors.grey[300]!)
            .withRounded(value: Sizes.radiusDefault)
            .clip(Clip.antiAlias)
            .make()
            .wFull(context),
      ),
    );
  }
}
