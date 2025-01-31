

import 'dart:math';
import 'package:android/features/Jobs/job_create_bloc/job_create_bloc.dart';
import 'package:android/features/Jobs/ui/create_job.dart';
import 'package:android/features/Jobs/ui/full_job_detail.dart';
import 'package:android/features/Jobs/ui/shimmer/posted_job_shimmer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../core/constants/colors.dart';
import '../../../core/utils/snackBarUtils.dart';
import '../../../data/models/Job/job_model.dart';
import '../job_bloc/job_bloc.dart';
import '../job_stats_bloc/jobs_bloc.dart';
import 'shimmer/Job_stats_shimmer.dart';

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
          bottom: TabBar(
            labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: screenSize.width*0.04,
              fontWeight: FontWeight.w600
          ),
            unselectedLabelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: screenSize.width*0.035,
                fontWeight: FontWeight.w600
            ),
            labelColor: Theme.of(context).brightness == Brightness.dark ?AppColors.darkPrimary:AppColors.lightBackground,
            unselectedLabelColor:Colors.grey,
            indicator: BoxDecoration(),
            tabs: [
              Tab(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.analytics_outlined),
                      SizedBox(width: 8),
                      Text('Statistics'),
                    ],
                  ),
                ),
              ),
              Tab(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.work_outline),
                      SizedBox(width: 8),
                      Text('Posted Jobs'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          title: Text(
            'Job Dashboard',
          ),
        ),
        body: TabBarView(
          children: [
            BlocProvider(
              create: (context) => JobStatsBloc(),
              child: JobStatsTab(screenSize: screenSize),
            ),
            BlocProvider(
              create: (context) => JobBloc(),
              child: PostedJobsScreen(),
            ),
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
          return  JobStatsShimmer(screenSize: widget.screenSize,);
        }

        if (state is JobStatsLoaded) {
         // final stats = state.stats['stats'];
          final jobMetrics = state.stats['jobMetrics'];
          final performanceMetrics = state.stats['performanceMetrics'];
          final distributionInsights = state.stats['distributionInsights'];
          final inclusivityMetrics = state.stats['inclusivityMetrics'];
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
    return Card(
      margin: EdgeInsets.all(0),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Job Insights',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                //  color: Colors.grey[800],
              ),
            ),
            Icon(Icons.bar_chart),
          ],
        ),
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
          //  color: Colors.grey[800],
          ),
        ),
        SizedBox(height: screenSize.height * 0.02),
        Row(
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
        titleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: screenSize.width*0.025,
          fontWeight: FontWeight.w600,
        ),
        color: sectionColors[index % sectionColors.length],
        radius: 60,
        borderSide: const BorderSide(color: Colors.white, width: 1),
        showTitle: true,
      );
    }).toList();

    return Card(
      margin: EdgeInsets.all(0),
      elevation: 0,

      child: Padding(
        padding: const  EdgeInsets.symmetric(vertical: 8,horizontal: 5),
        child: Column(
          children: [
            Text(
              title,
              style:Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700
              )
            ),
            Container(height: screenSize.height*0.01),
            SizedBox(
              height: screenSize.height*0.2,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 25,
                  centerSpaceColor: Theme.of(context).primaryColor,
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Color(0xFF64748B),
                  fontSize: screenSize.width*0.03,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: screenSize.height*0.01,),
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
                        style:Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: screenSize.width*0.028,
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
      ),
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

    return Card(

      margin: EdgeInsets.all(0),
      // color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.only(top: 8,left: 15,right: 5,bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Conversion Metrics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(width: screenSize.width*0.02,),
                Container(
                  width: screenSize.width*0.38,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildMetricBadge(
                          'Views',
                          metrics['totalJobViews'].toString(),
                          Colors.blue[400]!,
                        ),
                         SizedBox(width: screenSize.width*0.02),
                        _buildMetricBadge(
                          'Applicants',
                          metrics['totalApplicants'].toString(),
                          Colors.teal[400]!,
                        ),
                      ],
                    ),
                  ),
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
                    horizontalInterval: roundedMaxY <= 5 ? 1 : (roundedMaxY / 5).ceilToDouble(),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[200],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: _createBarTitles(context,roundedMaxY),
                ),
              ),
            ),
          ],
        ),
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

  FlTitlesData _createBarTitles(BuildContext context, double maxY) {
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
          interval: maxY <= 5 ? 1 : (maxY / 5).ceilToDouble(),
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
            style:Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
                fontWeight: FontWeight.w600
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style:Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
              fontWeight: FontWeight.w600
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }




  Widget _buildInclusivityMetrics(
      BuildContext context,
      Size screenSize,
      Map<String, dynamic> metrics,
      ) {
    final double accessiblePercentage = double.parse(metrics['accessibleJobsPercentage']);

    return Card(
      elevation: 0,
      margin: EdgeInsets.all(0),

      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inclusivity Metrics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  //  color: Colors.grey[800],
                ),
            ),
             SizedBox(height: screenSize.height*0.02),
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
                        screenSize
                      ),
                       SizedBox(height: screenSize.height*0.02),
                      _buildMetricTile(
                        'Blind Recruitment',
                        metrics['blindRecruitmentJobs'].toString(),
                        '${((metrics['blindRecruitmentJobs'] / metrics['totalJobs']) * 100).toStringAsFixed(1)}%',
                        Icons.remove_red_eye_outlined,
                        Colors.blue[400]!,
                        screenSize
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
      ),
    );
  }

  Widget _buildMetricTile(
      String title,
      String value,
      String percentage,
      IconData icon,
      Color color,
      Size screenSize
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
         SizedBox(width: screenSize.width*0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
               style: Theme.of(context).textTheme.bodySmall?.copyWith(
                 color: Colors.grey[500],
                 fontSize:screenSize.width*0.03,
                 fontWeight: FontWeight.w600
               ),
              ),
               SizedBox(height: screenSize.height*0.008),
              Row(
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize:screenSize.width*0.04,
                        fontWeight: FontWeight.w700
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color,
                          fontSize:screenSize.width*0.03,
                          fontWeight: FontWeight.w700
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
            //  color: Colors.grey[800],
          ),
        ),
        SizedBox(height: screenSize.height * 0.02),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: performance['topPerformingJobs'].length,
          itemBuilder: (context, index) {
            final job = performance['topPerformingJobs'][index];
            return Card(
              margin: EdgeInsets.only(bottom: screenSize.height * 0.01),
             elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: screenSize.width*0.04
                            //  color: Colors.grey[800],
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: job['status'].toLowerCase() == 'active'
                                ? Colors.green[700]
                                : Colors.orange[700],
                            fontSize: screenSize.width*0.03,
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
                            // color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${job['views']} views',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                              fontSize: screenSize.width*0.03,
                            ),
                          ),
                          SizedBox(width: screenSize.width*0.05),
                          Icon(
                            Icons.people_outline,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${job['applicantCount']} applicants',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                              fontSize: screenSize.width*0.03,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
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






// posted_jobs_screen.dart
class PostedJobsScreen extends StatefulWidget {
  const PostedJobsScreen({super.key});

  @override
  State<PostedJobsScreen> createState() => _PostedJobsScreenState();
}

class _PostedJobsScreenState extends State<PostedJobsScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    BlocProvider.of<JobBloc>(context).add(FetchJobs());
    scrollController.addListener(_onScroll);
       super.initState();
  }
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = context.read<JobBloc>().state;
    if (_isBottom && state is JobLoaded && !state.hasReachedMax) {
      BlocProvider.of<JobBloc>(context).add(LoadMoreJobs());
    }

  }
  bool get _isBottom {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    // Load more when user has scrolled 80% of the list
    return currentScroll >= (maxScroll * 0.8);
  }
 void _addNewJob(JobModel job){
   final state = context.read<JobBloc>().state;
  if(state is JobLoaded ){

    setState(() {
      state.jobs.insert(0, job);
    });
  }
 }


  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
     // backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical:screenSize.width * 0.04,horizontal: screenSize.width*0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, screenSize),
              SizedBox(height: screenSize.height * 0.02),
              Expanded(
                child: _buildJobsList(screenSize),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Size screenSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Posted Jobs',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: screenSize.width * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: Icon(Icons.add_circle),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BlocProvider(
              create: (context) => JobCreateBloc(),
              child: CreateJobScreen(onJobCreated:_addNewJob,),
            ),));
          },
          iconSize: screenSize.width * 0.08,
        ),
      ],
    );
  }

  Widget _buildJobsList(Size screenSize) {
    return BlocConsumer<JobBloc, JobState>(
        listener: (context,state) {
          if(state is JobError){
            return SnackBarUtils.showRedSnackBar(state.error.toString(), context);
          }
        },
      builder: (context, state) {
        if (state is JobLoading) {
          return PostedJobsShimmer();
        }

        if (state is JobLoaded) {
          return ListView.builder(
            controller: scrollController,
            itemCount:  state.jobs.length + (state.hasReachedMax ? 0 : 1),
            itemBuilder: (context, index) {
              if (index >= state.jobs.length) {
                if (!state.hasReachedMax) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: LoadingAnimationWidget.progressiveDots(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary,
                          size: 20
                      ),
                    ),
                  );
                } else {
                  return SizedBox.shrink(); // Return empty widget if reached max
                }
              }

              final job = state.jobs[index];
              return _buildJobCard(job, screenSize, context);
            },
          );
        }

        return Center(child: Text('No jobs found'));
      }
    );
  }

  Widget _buildJobCard(JobModel job, Size screenSize, BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          // Header with Job Title and Status
          Card(
            margin: EdgeInsets.all(0),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only( topLeft: Radius.circular(16),
              topRight: Radius.circular(16),)),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical :screenSize.width * 0.025,horizontal: screenSize.width*0.015),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          job.description.companyOverview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                            fontSize: screenSize.width*0.04
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(job.status,screenSize),
                ],
              ),
            ),
          ),

          // Main Content
          Padding(
            padding: EdgeInsets.symmetric(vertical :screenSize.width * 0.04,horizontal: screenSize.width*0.015),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Key Information Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoPill(
                        context,
                        Icons.location_on,
                        '${job.jobLocationDetails.city}, ${job.jobLocationDetails.state}',
                      ),
                      SizedBox(width: 5,),
                      _buildInfoPill(
                        context,
                        Icons.work,
                        job.jobType,
                      ),
                      SizedBox(width: 5,),
                      _buildInfoPill(
                        context,
                        Icons.trending_up,
                        job.experienceLevel,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenSize.height * 0.02),

                // Salary and Deadline
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${job.description.salary.currency} ${job.description.salary.min}-${job.description.salary.max}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                       // color: AppColors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Deadline: ${_formatDate(job.deadline)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                        fontSize: screenSize.width*0.04
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),

                SizedBox(height: screenSize.height * 0.02),

                // Key Responsibilities
                Text(
                  'Key Responsibilities:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.01),
                Column(
                  children: job.description.responsibilities
                      .take(2) // Show only first 2 responsibilities
                      .map((resp) => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Icon(Icons.check_circle,
                               size: 16,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              resp,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: screenSize.width*0.035
                              ),
                            ),
                          ),
                        ],
                      ))
                      .toList(),
                ),

                SizedBox(height: screenSize.height * 0.02),

                // Required Skills
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: job.description.qualifications.skills
                      .take(3) // Show only first 3 skills
                      .map((skill) => Card(
                    margin: EdgeInsets.all(0),
                   color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSecondary.withOpacity(0.1):AppColors.lightDeepPurple.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                    child: Padding(
                      padding:   EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text(
                        skill,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: screenSize.width*0.035,
                        )
                      ),
                    ),
                  ))
                      .toList(),
                ),

                SizedBox(height: screenSize.height * 0.02),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (context) => JobDetailsScreen(job: job),));
                        },
                        icon: Icon(Icons.description_outlined),
                        label: Text('View Full Details',style: Theme.of(context).textTheme.bodySmall?.copyWith(

                         // color: Theme.of(context).brightness == Brightness.dark
                        ),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).brightness == Brightness.dark ?AppColors.darkPrimary.withOpacity(0.1):AppColors.lightDisabled,
                        // foregroundColor: AppColors.lightPrimary,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to applicants list
                        },
                        icon: Icon(Icons.people,color: AppColors.lightDivider,),
                        label: Text('${job.applicants.length} Applicants'),
                        style: ElevatedButton.styleFrom(
                          //backgroundColor: AppColors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill(BuildContext context, IconData icon, String text) {
    return Card(
      shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ?AppColors.lightBackground:AppColors.lightPrimary,),borderRadius: BorderRadius.circular(16)),
     color: Theme.of(context).brightness == Brightness.dark ?AppColors.darkPrimary.withOpacity(0.1):AppColors.lightDeepPurple.withOpacity(0.1),
      margin: EdgeInsets.all(0),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16,
            //color:
              ),
            SizedBox(width: 6),
            Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark ?AppColors.lightBackground:AppColors.lightPrimary,
                fontWeight: FontWeight.w500,

              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildStatusChip(String status,Size screenSize) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'open':
        chipColor = Colors.green;
        break;
      case 'closed':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.all(0),
      color: chipColor.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          status,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: chipColor,
            fontSize: screenSize.width*0.04
          )
        ),
      ),
    );
  }

  // Widget _buildLoadMoreButton(JobLoaded state, BuildContext context) {
  //   if (state.hasReachedMax) {
  //     return SizedBox.shrink();
  //   }
  //
  //   return Center(
  //     child: TextButton(
  //       onPressed: () {
  //         context.read<JobBloc>().add(LoadMoreJobs());
  //       },
  //       child: Text('Load More'),
  //     ),
  //   );
  // }
}







