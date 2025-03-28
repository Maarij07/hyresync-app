import 'package:flutter/material.dart';

class JobDescriptionPage extends StatefulWidget {
  final Map<String, dynamic> jobData;

  const JobDescriptionPage({Key? key, required this.jobData}) : super(key: key);

  @override
  _JobDescriptionPageState createState() => _JobDescriptionPageState();
}

class _JobDescriptionPageState extends State<JobDescriptionPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color lightBlue = const Color(0xFF0057FF);
  final Color darkBlue = const Color(0xFF001A4E);
  final Color subtleGrey = const Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border_outlined, color: Colors.black87, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black87, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company logo and job type
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: subtleGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          widget.jobData['company'][0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: darkBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: subtleGrey,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.jobData['type'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: darkBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Job Title
                Text(
                  widget.jobData['title'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Company and Location
                Text(
                  widget.jobData['company'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      widget.jobData['location'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      widget.jobData['posted'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  widget.jobData['salary'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: lightBlue,
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: lightBlue,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: lightBlue,
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Description'),
              Tab(text: 'Company'),
              Tab(text: 'Reviews'),
            ],
          ),
          
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Description Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Job description
                      const Text(
                        'Job Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'A Software Engineer designs, develops, tests software, and maintains existing applications. They collaborate with development teams, ensure product quality, and hold a degree in Computer Science or related fields. Experience in web or mobile development, Agile/Scrum knowledge, and relevant certifications are beneficial.',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Qualifications
                      const Text(
                        'Qualifications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      QualificationItem(text: 'Strong portfolio to be presented'),
                      const SizedBox(height: 12),
                      QualificationItem(text: 'Minimum 2-3 years Experience needed'),
                      const SizedBox(height: 12),
                      QualificationItem(text: 'Able to study a problem with systematic techniques and frameworks'),
                      
                      const SizedBox(height: 30),
                      
                      // Skills
                      const Text(
                        'Required Skills',
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          SkillChip(label: 'Flutter'),
                          SkillChip(label: 'Dart'),
                          SkillChip(label: 'Firebase'),
                          SkillChip(label: 'REST API'),
                          SkillChip(label: 'Git'),
                          SkillChip(label: 'UI/UX'),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Company Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About Company',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Founded in 2010, we are a leading technology company specializing in innovative solutions for businesses and consumers. Our mission is to create products that simplify everyday life and enhance productivity.',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      const Text(
                        'Company Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CompanyDetailItem(
                        icon: Icons.people_outline,
                        label: 'Company Size',
                        value: '1000+ employees',
                      ),
                      const SizedBox(height: 16),
                      CompanyDetailItem(
                        icon: Icons.public,
                        label: 'Website',
                        value: 'www.${widget.jobData['company'].toString().toLowerCase()}.com',
                      ),
                      const SizedBox(height: 16),
                      CompanyDetailItem(
                        icon: Icons.category_outlined,
                        label: 'Industry',
                        value: 'Technology',
                      ),
                      const SizedBox(height: 16),
                      CompanyDetailItem(
                        icon: Icons.location_on_outlined,
                        label: 'Headquarters',
                        value: widget.jobData['location'],
                      ),
                      const SizedBox(height: 16),
                      CompanyDetailItem(
                        icon: Icons.calendar_today_outlined,
                        label: 'Founded',
                        value: '2010',
                      ),
                    ],
                  ),
                ),
                
                // Reviews Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Employee Reviews',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9F7EF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: Color(0xFF27AE60), size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '4.5',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ReviewItem(
                        userName: 'John Doe',
                        role: 'Senior Developer',
                        rating: 5,
                        date: '2 months ago',
                        comment: 'Great company to work for! The work-life balance is excellent and the team is very supportive.',
                      ),
                      const Divider(height: 32, thickness: 1),
                      ReviewItem(
                        userName: 'Jane Smith',
                        role: 'UX Designer',
                        rating: 4,
                        date: '3 months ago',
                        comment: 'Good benefits and interesting projects. The only downside is sometimes the workload can be high.',
                      ),
                      const Divider(height: 32, thickness: 1),
                      ReviewItem(
                        userName: 'Alex Johnson',
                        role: 'Product Manager',
                        rating: 5,
                        date: '4 months ago',
                        comment: 'Excellent career growth opportunities. Management is transparent and the company culture is amazing.',
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'See all reviews',
                                style: TextStyle(
                                  color: lightBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward, size: 16, color: lightBlue),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: lightBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Apply for this position',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper widgets
class QualificationItem extends StatelessWidget {
  final String text;

  const QualificationItem({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline, size: 20, color: Color(0xFF27AE60)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

class SkillChip extends StatelessWidget {
  final String label;

  const SkillChip({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class CompanyDetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const CompanyDetailItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ReviewItem extends StatelessWidget {
  final String userName;
  final String role;
  final int rating;
  final String date;
  final String comment;

  const ReviewItem({
    Key? key,
    required this.userName,
    required this.role,
    required this.rating,
    required this.date,
    required this.comment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFF5F7FA),
              child: Text(
                userName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              date,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: const Color(0xFFFFC107),
              size: 16,
            );
          }),
        ),
        const SizedBox(height: 12),
        Text(
          comment,
          style: const TextStyle(
            fontSize: 15,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}