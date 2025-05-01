import 'package:flutter/material.dart';
import '../models/hawker.dart';

class HawkerCard extends StatelessWidget {
  final Hawker hawker;
  final VoidCallback? onTap;
  
  const HawkerCard({
    Key? key, 
    required this.hawker,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: hawker.isOpen ? Colors.green.shade100 : Colors.red.shade100,
                    radius: 30,
                    backgroundImage: hawker.profileImage != null ? NetworkImage(hawker.profileImage!) : null,
                    child: hawker.profileImage == null 
                        ? Icon(Icons.store, color: hawker.isOpen ? Colors.green.shade800 : Colors.red.shade800) 
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hawker.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber.shade700, size: 16),
                            Text(
                              ' ${hawker.rating} (${hawker.totalRatings})',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: hawker.isOpen ? Colors.green.shade100 : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: hawker.isOpen ? Colors.green.shade300 : Colors.red.shade300,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      hawker.isOpen ? 'Open' : 'Closed',
                      style: TextStyle(
                        color: hawker.isOpen ? Colors.green.shade800 : Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.directions, color: Colors.blue.shade200, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${hawker.distanceFromUser.toStringAsFixed(1)} km away',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.home_work_outlined, color: Colors.grey.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hawker.address,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone, color: Colors.grey.shade700, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    hawker.phone,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.shopping_basket, color: Colors.green.shade700, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Available Items (${hawker.inventory.length})',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: hawker.inventory.length > 3 ? 3 : hawker.inventory.length,
                  itemBuilder: (context, index) {
                    final item = hawker.inventory[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        '${item.name} - ₹${item.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (hawker.inventory.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+ ${hawker.inventory.length - 3} more items',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hawker.isOpen ? Colors.green.shade600 : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      hawker.isOpen ? Icons.shopping_cart : Icons.info_outline,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      hawker.isOpen ? 'Order Now' : 'View Details',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              if (hawker.inventory.isNotEmpty)
                Row(
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'Menu: ${hawker.inventory.take(3).map((item) => '${item.name} - ₹${item.price.toStringAsFixed(0)}').join(', ')}${hawker.inventory.length > 3 ? '...' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
} 