enum TrainHistoryFilterEnum { filterByStatus, filterByNormal }

class TrainHistoryFilterClass {
  TrainHistoryFilterEnum getEnumByStr(String val) {
    switch (val) {
      case "Seat Status":
        return TrainHistoryFilterEnum.filterByStatus;
      default:
        return TrainHistoryFilterEnum.filterByNormal;
    }
  }

  String getStrByEnum(TrainHistoryFilterEnum val) {
    switch (val) {
      case TrainHistoryFilterEnum.filterByStatus:
        return "Seat Status";
      default:
        return "Normal";
    }
  }
}
