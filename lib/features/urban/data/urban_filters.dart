import 'package:motodi_go_mobile/features/urban/data/urban_models.dart';

List<UrbanDriverCard> applyUrbanFilters(List<UrbanDriverCard> drivers, UrbanFilters filters) {
  return drivers.where((driver) {
    if (filters.minRating != null && driver.rating < filters.minRating!) {
      return false;
    }
    if (filters.immediateOnly && !driver.isAvailable) {
      return false;
    }
    if (filters.maxPriceFcfa != null && driver.priceFcfa > filters.maxPriceFcfa!) {
      return false;
    }
    return true;
  }).toList();
}
