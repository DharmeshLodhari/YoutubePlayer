import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

class OrderPreview extends StatelessWidget {
  const OrderPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            color: navyBlue,
            size: 24,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: false,
        title: Text(
          "Receipt",
          style: TextStyle(
            color: blackFont,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: "Inter",
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Text(
                    'Prineygladhair Emporium',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Order No: #1678',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14.0,
                    ),
                  ),
                  Text(
                    'Order Placed: 28 March, 2024, 12:04:23',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            const Center(
              child: Text(
                'AWAITING PAYMENT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18.0,
                ),
              ),
            ),
            const Divider(thickness: 2.0),
            const SizedBox(height: 8.0),
            Text(
              'Item',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8.0),
            _buildItemRow(
                'Bodywave Frontal Wig (Black)', '₦38,000.00 (+₦2,000)'),
            _buildItemRow(
                'Bodywave Frontal Wig (Black)', '₦38,000.00 (+₦2,000)'),
            _buildItemRow('Bob Frontal Wig (12”)', '₦50,000.00'),
            _buildItemRow('Tiwa Bouncy (16”, Black)...', '₦100,000.00'),
            const SizedBox(height: 8.0),
            const Divider(thickness: 2.0),
            _buildTotalRow('Subtotal', '₦190,000.00'),
            _buildTotalRow('Shipping', '₦7,000.00'),
            _buildTotalRow('Service Charge', '₦500.00'),
            _buildTotalRow('Tax', '₦0.00'),
            const Divider(thickness: 2.0),
            const SizedBox(height: 8.0),
            _buildTotalRow('Total', '₦178,000.00', isTotal: true),
            const SizedBox(height: 24.0),
            Text(
              'Delivery Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8.0),
            _buildDeliveryRow('Customer', 'Adebimpe Yusuf'),
            _buildDeliveryRow('Username', '@adebimpe'),
            _buildDeliveryRow('Payment Method', 'Slydo'),
            _buildDeliveryRow('Delivery Option', 'Pick Up'),
            _buildDeliveryRow('Pickup Date/Time', '10 March, 2024, 12:05:45'),
            const SizedBox(height: 24.0),
            Center(
              child: Column(
                children: [
                  const Icon(Icons.qr_code, size: 80.0),
                  Text(
                    'Powered by SLYDO',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.0,
                    ),
                  ),
                  Text(
                    'Download Slydo App on Google Play Store & App Store',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(String itemName, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              itemName,
              style: const TextStyle(fontSize: 14.0),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            amount,
            style: const TextStyle(fontSize: 14.0),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String title, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 18.0 : 14.0,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18.0 : 14.0,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryRow(String title, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(
            '$title : ',
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.grey[700],
            ),
          ),
          Text(
            info,
            style: const TextStyle(fontSize: 14.0),
          ),
        ],
      ),
    );
  }
}
