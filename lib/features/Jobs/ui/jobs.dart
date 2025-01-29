

import 'dart:math';

import 'package:android/features/Jobs/bloc/jobs_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/colors.dart';

class JobStatsScreen extends StatelessWidget {
  const JobStatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const TabBar(
            labelColor: AppColors.deepPurple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.deepPurple,
            tabs: [
              Tab(text:'Statistics'),
              Tab(text: 'Posted Jobs'),
            ],
          ),
          title: Text('Job Dashboard'),
        ),
        body: TabBarView(
          children: [
            BlocProvider(
              create: (context) => JobStatsBloc(),
              child: JobStatsTab(screenSize: screenSize),
            ),
            const Center(child: Text('Posted Jobs - Coming Soon')),
          ],
        ),
      ),
    );
  }
}

class JobStatsTab extends StatefulWidget {
  final Size screenSize;

  const JobStatsTab({
    Key? key,
    required this.screenSize,
  }) : super(key: key);

  @override
  State<JobStatsTab> createState() => _JobStatsTabState();
}

class _JobStatsTabState extends State<JobStatsTab> {

  @override
  void initState() {

    BlocProvider.of<JobStatsBloc>(context).add(FetchJobStats());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobStatsBloc, JobStatsState>(
      builder: (context, state) {
        if (state is JobStatsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is JobStatsLoaded) {
         // final stats = state.stats['stats'];
          Map<String,dynamic> stats = {
            "jobMetrics": {
              "_id": null,
              "totalJobs": 35,
              "openJobs": 25,
              "closedJobs": 10,
              "totalApplicants": 12,
              "totalViews": 780
            },
            "distributionInsights": {
              "jobTypes": [
                {
                  "_id": "Full-time",
                  "count": 15,
                  "applicants": 7,
                  "views": 400
                },
                {
                  "_id": "Part-time",
                  "count": 10,
                  "applicants": 3,
                  "views": 200
                },
                {
                  "_id": "Internship",
                  "count": 5,
                  "applicants": 2,
                  "views": 100
                },
                {
                  "_id": "Freelance",
                  "count": 5,
                  "applicants": 0,
                  "views": 80
                }
              ],
              "experienceLevels": [
                {
                  "_id": "Entry-level",
                  "count": 10,
                  "applicants": 5,
                  "views": 250
                },
                {
                  "_id": "Intermediate",
                  "count": 15,
                  "applicants": 4,
                  "views": 300
                },
                {
                  "_id": "Senior",
                  "count": 5,
                  "applicants": 2,
                  "views": 150
                },
                {
                  "_id": "Expert",
                  "count": 5,
                  "applicants": 1,
                  "views": 80
                }
              ]
            },
            "performanceMetrics": {
              "recentPerformance": {},
              "conversionMetrics": {
                "_id": null,
                "totalJobViews": 780,
                "totalApplicants": 12,
                "averageViewsPerJob": 22.3,
                "averageApplicantsPerJob": 0.34
              },
              "topPerformingJobs": [
                {
                  "_id": "675a9cfbbd365c4f15d1fc99",
                  "title": "Web Designer",
                  "status": "Open",
                  "views": 120,
                  "applicantCount": 4
                },
                {
                  "_id": "67644ff44bc6d912612052bb",
                  "title": "Software Developer",
                  "status": "Open",
                  "views": 100,
                  "applicantCount": 3
                },
                {
                  "_id": "675f1f0b189c2ea9edcff887",
                  "title": "Cybersecurity Analyst",
                  "status": "Open",
                  "views": 85,
                  "applicantCount": 2
                },
                {
                  "_id": "6767072a288e589b7a8fc70d",
                  "title": "Data Scientist",
                  "status": "Open",
                  "views": 75,
                  "applicantCount": 1
                },
                {
                  "_id": "6765b9c4288e589b7a8fb08d",
                  "title": "Full-Stack Developer",
                  "status": "Closed",
                  "views": 70,
                  "applicantCount": 2
                }
              ]
            },
            "inclusivityMetrics": {
              "_id": null,
              "accessibleJobs": 10,
              "blindRecruitmentJobs": 3,
              "totalJobs": 35,
              "accessibleJobsPercentage": "28.57"
            }
          };
          final jobMetrics = stats['jobMetrics'];
          final performanceMetrics = stats['performanceMetrics'];
          final distributionInsights = stats['distributionInsights'];
          final inclusivityMetrics = stats['inclusivityMetrics'];
          final conversionMetrics = performanceMetrics['conversionMetrics'];



          return SingleChildScrollView(
            padding: EdgeInsets.all(widget.screenSize.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, widget.screenSize),
                SizedBox(height: widget.screenSize.height * 0.02),
                _buildOverviewCards(context, widget.screenSize, jobMetrics),
                SizedBox(height: widget.screenSize.height * 0.03),
                _buildDistributionSection(context, widget.screenSize, distributionInsights),
                SizedBox(height: widget.screenSize.height * 0.03),
                _buildConversionMetrics(context, widget.screenSize, conversionMetrics),
                SizedBox(height: widget.screenSize.height * 0.03),
                _buildInclusivityMetrics(context, widget.screenSize, inclusivityMetrics),
                SizedBox(height: widget.screenSize.height * 0.03),
                _buildPerformanceSection(context, widget.screenSize, performanceMetrics),
              ],
            ),
          );
        }

        return const Center(child: Text('Something went wrong'));
      },
    );
  }

  Widget _buildHeader(BuildContext context, Size screenSize) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Job Insights',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.deepPurple,
            ),
          ),
          Icon(Icons.bar_chart, color: AppColors.deepPurple),
        ],
      ),
    );
  }

  Widget _buildDistributionSection(
      BuildContext context,
      Size screenSize,
      Map<String, dynamic> insights,
      ) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Distribution Insights',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: screenSize.height * 0.02),
        SizedBox(
          height: screenSize.height * 0.44,
          child: Row(
            children: [
              Expanded(
                child: _buildPieChart(
                  'Job Types',
                  insights['jobTypes'] as List,
                  Colors.blue[400]!,
                  screenSize
                ),
              ),
              SizedBox(width: screenSize.width * 0.04),
              Expanded(
                child: _buildPieChart(
                  'Experience Levels',
                  insights['experienceLevels'] as List,
                  Colors.teal[400]!,
                  screenSize
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(String title, List<dynamic> data, Color color,Size screenSize) {
    // Create a more visually appealing color palette
    final List<Color> sectionColors = [
      Colors.blue.withOpacity(0.6),
      Colors.green.withOpacity(0.6),
      Colors.orange.withOpacity(0.6),
      Colors.purple.withOpacity(0.6),
      Color(0xFF6366F1), // Indigo
    ];

    final int totalCount = data.fold(0, (sum, item) => sum + (item['count'] as int));

    final List<PieChartSectionData> sections = data.asMap().entries.map((entry) {
      final int index = entry.key;
      final Map<String, dynamic> item = entry.value;
      final double percentage = (item['count'] as int) / totalCount * 100;

      return PieChartSectionData(
        value: percentage,
        title: percentage >= 10 ? '${percentage.toStringAsFixed(1)}%' : '',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(
              color: Colors.black26,
              blurRadius: 2,
            ),
          ],
        ),
        color: sectionColors[index % sectionColors.length],
        radius: 50,
        borderSide: const BorderSide(color: Colors.white, width: 2),
        showTitle: true,
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(color:Colors.grey,height: screenSize.height*0.01),
          Container(
              height: screenSize.height*0.2,
            color: Colors.greenAccent,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                centerSpaceColor: Colors.white,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    // Add touch interaction if needed
                  },
                ),
              ),
            ),
          ),
           SizedBox(height: screenSize.height*0.01),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Total: $totalCount',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Column(
            children: data.asMap().entries.map((entry){
              final int index = entry.key;
                    final item = entry.value;
                    final count = item['count'] as int;
                    final percentage = (count / totalCount * 100).toStringAsFixed(1);
              return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: sectionColors[index % sectionColors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      item['_id'],
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),

              );
            }).toList()
          )
        ],
      ),
    );
  }


  Widget _buildOverviewCards(
      BuildContext context,
      Size screenSize,
      Map<String, dynamic> metrics,
      ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: screenSize.width * 0.03,
      crossAxisSpacing: screenSize.width * 0.03,
      childAspectRatio: 1.5,
      children: [
        _statsCard(
          'Total Jobs',
          metrics['totalJobs'].toString(),
          Icons.work,
          Colors.blue,
          screenSize
        ),
        _statsCard(
          'Open Jobs',
          metrics['openJobs'].toString(),
          Icons.door_back_door_outlined,
          Colors.green,
          screenSize
        ),
        _statsCard(
          'Total Applicants',
          metrics['totalApplicants'].toString(),
          Icons.people,
          Colors.orange,
          screenSize
        ),
        _statsCard(
          'Total Views',
          metrics['totalViews'].toString(),
          Icons.visibility,
          Colors.purple,
          screenSize
        ),
      ],
    );
  }



  Widget _buildConversionMetrics(
      BuildContext context,
      Size screenSize,
      Map<String, dynamic> metrics,
      ) {
    final double averageViews = metrics['averageViewsPerJob'].toDouble();
    final double averageApplicants = metrics['averageApplicantsPerJob'].toDouble();

    // Calculate a reasonable maxY that's slightly above the highest value
    final double maxValue = max(averageViews, averageApplicants);
    final double roundedMaxY = (maxValue * 1.2).ceilToDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Conversion Metrics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Row(
                children: [
                  _buildMetricBadge(
                    'Total Views',
                    metrics['totalJobViews'].toString(),
                    Colors.blue[400]!,
                  ),
                  const SizedBox(width: 8),
                  _buildMetricBadge(
                    'Total Applicants',
                    metrics['totalApplicants'].toString(),
                    Colors.teal[400]!,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: screenSize.height * 0.02),
          SizedBox(
            height: screenSize.height * 0.25,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: roundedMaxY,
                barGroups: [
                  _createBarGroup(0, averageViews, Colors.blue[400]!),
                  _createBarGroup(1, averageApplicants, Colors.teal[400]!),
                ],
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  horizontalInterval: roundedMaxY / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200],
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                titlesData: _createBarTitles(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _createBarGroup(int x, double value, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          borderRadius: BorderRadius.circular(8),
          width: 30,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: value * 1.2,
            color: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  FlTitlesData _createBarTitles(BuildContext context) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final style = TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            );
            switch (value.toInt()) {
              case 0:
                return Text('Avg Views', style: style);
              case 1:
                return Text('Avg Applicants', style: style);
              default:
                return Text('', style: style);
            }
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: null, // Will be calculated based on maxY
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            );
          },
        ),
      ),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }


  Widget _buildInclusivityMetrics(
      BuildContext context,
      Size screenSize,
      Map<String, dynamic> metrics,
      ) {
    final double accessiblePercentage = double.parse(metrics['accessibleJobsPercentage']);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inclusivity Metrics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMetricTile(
                      'Accessible Jobs',
                      '${metrics['accessibleJobs']}',
                      '${metrics['accessibleJobsPercentage']}%',
                      Icons.accessibility_new,
                      Colors.teal[400]!,
                    ),
                    const SizedBox(height: 16),
                    _buildMetricTile(
                      'Blind Recruitment',
                      metrics['blindRecruitmentJobs'].toString(),
                      '${((metrics['blindRecruitmentJobs'] / metrics['totalJobs']) * 100).toStringAsFixed(1)}%',
                      Icons.remove_red_eye_outlined,
                      Colors.blue[400]!,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CustomPaint(
                  size: Size(screenSize.width * 0.2, screenSize.width * 0.2),
                  painter: CircularProgressPainter(
                    percentage: accessiblePercentage / 100,
                    color: Colors.teal[400]!,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
      String title,
      String value,
      String percentage,
      IconData icon,
      Color color,
      ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      percentage,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _statsCard(String title, String count, IconData icon, Color color, Size screenSize) {
    return Container(
      width: screenSize.width * 0.28,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: screenSize.height * 0.01),
          Text(
            count,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: screenSize.width * 0.04,
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w200,
              color: color,
              fontSize: screenSize.width * 0.035,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(
      BuildContext context,
      Size screenSize,
      Map<String, dynamic> performance,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Performing Jobs',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: screenSize.height * 0.02),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: performance['topPerformingJobs'].length,
          itemBuilder: (context, index) {
            final job = performance['topPerformingJobs'][index];
            return Container(
              margin: EdgeInsets.only(bottom: screenSize.height * 0.01),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        job['title'],
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: job['status'].toLowerCase() == 'active'
                            ? Colors.green[50]
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        job['status'],
                        style: TextStyle(
                          color: job['status'].toLowerCase() == 'active'
                              ? Colors.green[700]
                              : Colors.orange[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.remove_red_eye_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${job['views']} views',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 16),
                        Icon(
                          Icons.people_outline,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${job['applicantCount']} applicants',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double percentage;
  final Color color;

  CircularProgressPainter({
    required this.percentage,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * percentage,
      false,
      progressPaint,
    );

    // Draw percentage text
    final textSpan = TextSpan(
      text: '${(percentage * 100).toStringAsFixed(1)}%',
      style: TextStyle(
        color: color,
        fontSize: size.width * 0.2,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

