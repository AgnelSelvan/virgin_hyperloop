enum TrainStatusEnum { initial, inJouney, stopped, finshed }

class TrainStatus {
  TrainStatusEnum getEnumFromTrainStatusStr(String value) {
    switch (value) {
      case "Initial":
        return TrainStatusEnum.initial;
      case "In Jouney":
        return TrainStatusEnum.inJouney;
      case "Stopped":
        return TrainStatusEnum.stopped;
      default:
        return TrainStatusEnum.finshed;
    }
  }

  String getStrFromEnum(TrainStatusEnum value) {
    switch (value) {
      case TrainStatusEnum.initial:
        return "Initial";
      case TrainStatusEnum.inJouney:
        return "In Jouney";
      case TrainStatusEnum.stopped:
        return "Stopped";
      default:
        return "Finished";
    }
  }
}
