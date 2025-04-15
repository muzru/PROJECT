import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class FreelancerDetailsPage extends StatefulWidget {
  final String freelancerId;

  const FreelancerDetailsPage({super.key, required this.freelancerId});

  @override
  State<FreelancerDetailsPage> createState() => _FreelancerDetailsPageState();
}

class _FreelancerDetailsPageState extends State<FreelancerDetailsPage> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? freelancerData;
  List<Map<String, dynamic>> completedWorks = [];
  List<Map<String, dynamic>> previousRatings = []; // Store previous ratings
  bool isLoading = true;
  double _currentRating = 0.0; // Current average rating
  int _userRating = 0; // User's selected rating
  final TextEditingController _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchFreelancerDetails();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _fetchFreelancerDetails() async {
    setState(() => isLoading = true);
    try {
      // Fetch freelancer details
      final freelancerResponse = await supabase
          .from('tbl_freelancer')
          .select(
              'freelancer_id, freelancer_name, freelancer_contact, freelancer_photo, freelancer_email')
          .eq('freelancer_id', widget.freelancerId)
          .single();
      print(freelancerResponse);

      // Fetch average rating from tbl_rating
      final ratingResponse = await supabase
          .from('tbl_rating')
          .select('*')
          .eq('freelancer_id', widget.freelancerId);
      final ratings =
          ratingResponse.map((r) => r['rating_value'] as num).toList();
      final averageRating = ratings.isNotEmpty
          ? ratings.reduce((a, b) => a + b) / ratings.length
          : 0.0;
      previousRatings = ratingResponse; // Store all ratings for display

      // Fetch completed works (status >= 4)
      final completedResponse = await supabase
          .from('tbl_workrequest')
          .select('*, tbl_work(work_name)')
          .eq('freelancer_id', widget.freelancerId)
          .gte('workrequest_status', 4);

      setState(() {
        freelancerData = freelancerResponse;
        _currentRating = averageRating;
        completedWorks = completedResponse;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching freelancer details: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> _submitRatingAndReview() async {
    if (_userRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('tbl_rating').insert({
        'freelancer_id': widget.freelancerId,
        'client_id': userId,
        'rating_value': _userRating,
        'rating_content': _reviewController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });

      // Recalculate average rating and refresh data
      await _fetchFreelancerDetails();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating and review submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _userRating = 0;
        _reviewController.clear(); // Clear review field
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting rating and review: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text(
          "Freelancer Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : freelancerData == null
              ? const Center(child: Text("Freelancer data not found"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile Header
                            Center(
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundImage: freelancerData![
                                                'freelancer_photo'] !=
                                            null
                                        ? NetworkImage(
                                            freelancerData!['freelancer_photo'])
                                        : const AssetImage(
                                                'assets/default_profile.png')
                                            as ImageProvider,
                                    backgroundColor: Colors.grey[200],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    freelancerData!['freelancer_name'] ??
                                        'Unknown',
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    freelancerData!['freelancer_email'] ??
                                        'No email',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Personal Information Section
                            _buildSectionTitle('Personal Information'),
                            _buildDetailRow('Contact',
                                freelancerData!['freelancer_contact'] ?? 'N/A'),
                            const SizedBox(height: 20),
                            // Rating Section
                            _buildSectionTitle('Rating'),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  _currentRating > 0
                                      ? _currentRating.toStringAsFixed(1)
                                      : 'Not rated yet',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${_currentRating > 0 ? 'Based on ratings' : 'No ratings'})',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(5, (index) {
                                return IconButton(
                                  icon: Icon(
                                    index < _userRating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _userRating = index + 1;
                                    });
                                  },
                                );
                              }),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _reviewController,
                              decoration: InputDecoration(
                                labelText: 'Write a review',
                                border: const OutlineInputBorder(),
                                labelStyle: GoogleFonts.poppins(),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _submitRatingAndReview,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E6F40),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Submit Rating and Review',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Previous Ratings and Reviews Section
                            _buildSectionTitle('Previous Ratings and Reviews'),
                            ...previousRatings.map((rating) {
                              return ListTile(
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index < (rating['rating_value'] as num)
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 20,
                                    );
                                  }),
                                ),
                                title: Text(
                                  'Rating: ${(rating['rating_value'] as num).toStringAsFixed(1)}',
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                                subtitle: Text(
                                  rating['rating_content'] ?? 'No review',
                                  style: GoogleFonts.poppins(
                                      fontSize: 14, color: Colors.grey[600]),
                                ),
                                trailing: Text(
                                  (rating['created_at'] as String)
                                      .split('T')[0], // Display date only
                                  style: GoogleFonts.poppins(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                              );
                            }).toList(),
                            const SizedBox(height: 20),
                            // Completed Works Section
                            _buildSectionTitle('Completed Works'),
                            ...completedWorks.map((work) {
                              return ListTile(
                                leading: const Icon(Icons.work,
                                    color: Color(0xFF2E6F40)),
                                title: Text(
                                    work['tbl_work']['work_name'] ??
                                        'Unnamed Work',
                                    style: GoogleFonts.poppins(fontSize: 16)),
                                subtitle: Text(
                                    work['workrequest_message'] ?? 'No details',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12, color: Colors.grey[600])),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
