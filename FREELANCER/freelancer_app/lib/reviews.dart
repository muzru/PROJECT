import 'package:flutter/material.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> reviews = [
      {
        'name': 'John Doe',
        'rating': 4.5,
        'comment': 'Great work, very professional!'
      },
      {
        'name': 'Alice Smith',
        'rating': 5.0,
        'comment': 'Outstanding job, will hire again!'
      },
      {
        'name': 'Michael Brown',
        'rating': 3.8,
        'comment': 'Good work, but can improve on deadlines.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews & Ratings'),
        backgroundColor: Color(0xFF8C735B),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.brown.shade300,
                child: Text(review['name'][0]),
              ),
              title: Text(review['name'],
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(
                        5,
                        (i) => Icon(
                              i < review['rating'].floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                            )),
                  ),
                  Text(review['comment']),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
