import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),

          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          )
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenSize.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App logo and name
              Center(
                child: Column(
                  children: [
                    // Image.asset(
                    //   'assets/images/logo.png',
                    //   height: screenSize.height * 0.15,
                    //   width: screenSize.width * 0.3,
                    // ),
                    SizedBox(height: screenSize.height * 0.02),
                    Text(
                      'Ability Connect',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    SizedBox(height: screenSize.height * 0.01),
                    Text(
                      'Empowering abilities, connecting opportunities',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenSize.height * 0.04),

              // Our Mission section
              _buildSectionTitle(context, 'Our Mission', FontAwesomeIcons.lightbulb, screenSize),
              SizedBox(height: screenSize.height * 0.01),
              Text(
                'AbilityConnect is dedicated to breaking barriers and creating equal job opportunities for people with disabilities. We believe that everyone deserves a chance to showcase their talents and contribute meaningfully to society.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              SizedBox(height: screenSize.height * 0.03),

              // What We Offer section
              _buildSectionTitle(context, 'What We Offer', FontAwesomeIcons.handHoldingHeart, screenSize),
              SizedBox(height: screenSize.height * 0.01),
              _buildFeatureCard(
                context,
                FontAwesomeIcons.briefcase,
                'Job Opportunities',
                'Access job listings specifically posted for people with disabilities by inclusive employers.',
                screenSize,
              ),
              SizedBox(height: screenSize.height * 0.02),
              _buildFeatureCard(
                context,
                FontAwesomeIcons.bookOpen,
                'Community Stories',
                'Share and read inspirational success stories, challenges overcome, and journeys of growth.',
                screenSize,
              ),
              SizedBox(height: screenSize.height * 0.02),
              _buildFeatureCard(
                context,
                FontAwesomeIcons.users,
                'Connect & Support',
                'Build connections with others, exchange advice, and create a supportive community.',
                screenSize,
              ),

              SizedBox(height: screenSize.height * 0.03),

              // Our Values section
              _buildSectionTitle(context, 'Our Values', FontAwesomeIcons.heart, screenSize),
              SizedBox(height: screenSize.height * 0.01),
              _buildValueItem(context, 'Inclusion', 'We believe in a world where everyone belongs', screenSize),
              _buildValueItem(context, 'Empowerment', 'Supporting independence and self-determination', screenSize),
              _buildValueItem(context, 'Accessibility', 'Making opportunities available to all', screenSize),
              _buildValueItem(context, 'Community', 'Building connections and support networks', screenSize),

              SizedBox(height: screenSize.height * 0.03),

              // Contact Us section
              _buildSectionTitle(context, 'Contact Us', FontAwesomeIcons.envelope, screenSize),
              SizedBox(height: screenSize.height * 0.01),
              _buildContactItem(context, FontAwesomeIcons.envelope, 'support@abilityconnect.com', screenSize),
              _buildContactItem(context, FontAwesomeIcons.phone, '+1 (800) 123-4567', screenSize),
              _buildContactItem(context, FontAwesomeIcons.globe, 'www.abilityconnect.com', screenSize),

              SizedBox(height: screenSize.height * 0.04),

              // Social Media links
              Center(
                child: Wrap(
                  spacing: screenSize.width * 0.05,
                  children: [
                    _buildSocialIcon(FontAwesomeIcons.facebook, Colors.blue),
                    _buildSocialIcon(FontAwesomeIcons.twitter, Colors.lightBlue),
                    _buildSocialIcon(FontAwesomeIcons.instagram, Colors.purple),
                    _buildSocialIcon(FontAwesomeIcons.linkedin, Colors.blueAccent),
                  ],
                ),
              ),

              SizedBox(height: screenSize.height * 0.04),

              // Version info
              Center(
                child: Text(
                  'Version 1.0.1',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon, Size screenSize) {
    return Row(
      children: [
        FaIcon(
          icon,
          size: screenSize.width * 0.05,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(width: screenSize.width * 0.02),
        Text(
          title,
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ],
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title, String description, Size screenSize) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.04),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FaIcon(
              icon,
              size: screenSize.width * 0.06,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: screenSize.width * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueItem(BuildContext context, String value, String description, Size screenSize) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
      child: Row(
        children: [
          FaIcon(
            FontAwesomeIcons.circleDot,
            size: screenSize.width * 0.03,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: screenSize.width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, IconData icon, String text, Size screenSize) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
      child: Row(
        children: [
          FaIcon(
            icon,
            size: screenSize.width * 0.04,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: screenSize.width * 0.03),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return CircleAvatar(
      backgroundColor: color,
      child: FaIcon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}