enum StationEnum { bkc, pune }

class Station {
  String getStationEnumToStr(StationEnum stationEnum) {
    switch (stationEnum) {
      case StationEnum.bkc:
        return "Mumbai BKC Portal";
      default:
        return "Pune Portal";
    }
  }
}
