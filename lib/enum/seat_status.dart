enum TrainSeatStatus { booked, available, unavailable }

class TrainSeat {
  String getTrainSeatEnumToStr(TrainSeatStatus trainSeatStatus) {
    switch (trainSeatStatus) {
      case TrainSeatStatus.booked:
        return "Booked";
      case TrainSeatStatus.unavailable:
        return "Unavailable";
      default:
        return "Available";
    }
  }

  TrainSeatStatus getEnumFromStr(String value) {
    switch (value) {
      case "Booked":
        return TrainSeatStatus.booked;
      case "Unavailable":
        return TrainSeatStatus.unavailable;
      default:
        return TrainSeatStatus.available;
    }
  }
}
