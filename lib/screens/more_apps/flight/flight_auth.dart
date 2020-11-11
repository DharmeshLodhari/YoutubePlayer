import 'package:Slydo/services/auth.dart';

import 'models/Ticket.dart';
import 'models/Transport.dart';

class FlightAuthService extends AuthService {
  Future<List<Transport>> getAvailableTransports() async {
    List<Transport> transport = List.generate(
        10,
        (index) => Transport.fromJson({
              "name": "Slydo Train",
              "logo": "",
              "date": "Thu, Oct 15",
              "time": "9:00 AM",
              "from": "Lagos",
              "to": "Abuja",
              "price": "34.00",
              "travel_time": "15 minutes",
              "currency": "NGN"
            }));
    await Future.delayed(Duration(seconds: 1));
    return transport;
  }

  Future<List<Ticket>> getTicket() async {
    List<Ticket> ticket = List.generate(
        10,
        (index) => Ticket.fromJson({
              "from": "Lagos",
              "to": "Abuja",
              "from_time": "9:00 AM",
              "to_time": "11:00 AM",
              "journey_time": "2h30m",
              "gate": "G3",
              "seat": "B1",
              "qr_code":
                  "https://www.pixavi.com/wp-content/uploads/2015/10/apb-qr-code.png"
            }));
    await Future.delayed(Duration(seconds: 1));
    return ticket;
  }
}
