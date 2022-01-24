enum AdminEnum { addTrain, ticketHistory, makeAdmin }

class Admin {
  String getAdminEnumToStr(AdminEnum adminEnum) {
    switch (adminEnum) {
      case AdminEnum.addTrain:
        return "Add Convey";
      case AdminEnum.makeAdmin:
        return "Make Admin";
      default:
        return "Ticket History";
    }
  }
}
