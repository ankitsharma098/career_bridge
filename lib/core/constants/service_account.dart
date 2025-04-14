import 'package:flutter/cupertino.dart';
import 'package:googleapis_auth/auth_io.dart';

Future<String> getAccessToken() async {
  final serviceAccountCredentials = ServiceAccountCredentials.fromJson({
    "type": "service_account",
    "project_id": "scenic-reason-445114-j8",
    "private_key_id": "72ab355c5d27a6c24078fbb6fc97bf7b6387f78a",
    "private_key":
        "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCQcggV4a+WMCyJ\nxEqRzpsPfLZiklwidgggfCd206xXyTFQDo2BxRO3MkKscmfI7QZebROX2WjHVtcY\ntLR0KmS/l+S99S3Lb1jG2eC2gqjSUv548U8XBC7XeDtWO+N97MKtgH1eUrYf2q68\nXcDhC1C4poDk8zdZ+vF+iDL6TZREbsKYSkbjzUtFpgv84qnS15/jFEp2Ltl15CtD\nDv1KrjfpoN5S1r3k2a4FVT9Z5ZgmBZKf3A3YpYg7Ii010ITSSJ0fpQnArs1W8Tlg\nfw82aOtiG8iMcYZO0++9HLtP6jZq8VEdH7ZBNpG9DFLgdRG1kciEydjNyyTzjJOd\nuVETeNa9AgMBAAECggEAJAl3D/J+6pL5QaPJ0OfBUtNT83K9btGQxH4FIIW93Sby\nWR1QW5xuB0oQTVK7purPqHZBKaTRmc4GGwFWdhbvjMdaB7RoKPWOKgpIoHAnq1WO\nbGET0NO31gUGlMSbRJrxlPTWElbDXl4iMxeW2+6FRJQx2yz81cOgRWe4hC8fuxSh\nHxyyoHG5HBaAdC6mG50h7spsluzvpwxLjYLvz+1jDnFBv0IToGthFw6tOSk1W704\nF2bHOUyfS/bhIOh876OmUMEepNwEh9X/ZO0wG2tE9xoiv6CABJ9lKf2tyX/9y7M2\nSf9Hn2WtdYqUbiwLkaxwt/ZJGtSBcaCbaaIX79zMdwKBgQDBGWIHOEd36gyRSjzF\nup5GvDItb6aiGHYisXT5qLguG9A6Fydfmq1WyU/XPEm8yLg/N4CfUVc0ux0dzJJ2\nQYuqK5hZtuywlFkbzwANhgyx4Va24rGoZs6IujoQPer0U4KY1homLKXzk11Bo7h1\n6q8yDk7hgVs5W+qI7INOS04yCwKBgQC/f2U6Ig54quKIxUc7Yt103bJghHYHiHTD\nsFIitsYiy5Q32ORcfT8M/WmRa+EZiA1knuJ+uXkzjvQsMylIUHT1c73JJPu3WhlO\nRUrKOOYwLmeNT2uXNobXnkijVTtWW0YzHHsFFRmyfXLByCOsxuZ27FynKgd30oCn\nDhibHBOfVwKBgAtO7zy5AQZ2wHGpxVFXEnnV/6JFjZ6kjBaQCeetB8w7eMBOJtIk\nfs48T96s+yyBHLknCPNLki3WX2glWNZwFDvM/ckTO11D8sv8HWatWQT5y1g+gmT4\nUFQVg9z7o0zXryhAMZvWtYlEMgvsCJtvOP9Xcyslpi//wAZww2fMZTHtAoGAK+uV\nFPMwrH5M/J96ieVP83jRa4+V3n5ugV9URz/yS5KziOeG4KudJWaNqtu6QffRUo2a\nVwRFBw03dVe6lSpW2ODV22dPECtq+GeuEplgOha6i0921rSb0qIr+MIYnOLMQ/a5\nRF4lial6A3XasMrhms71JSXflpzCAw6ZmCGlYnsCgYB1B8vVf2o/01UBXI6g6yJk\nslYU9Dd3wa6rS0L9cHlb8GqUuyJt4McxNU61w9P2j1SDtDmLBQ6+9DfRvd+s2+J7\nBHJpFMmSyrvGs/cyM1kpRsd5u0FNuFYGlHElcrDT2U0130yzGA5NHH+ITQIbQ+eo\n1HLGfoR2r09Ak8AIyYycLQ==\n-----END PRIVATE KEY-----\n",
    "client_email":
        "ankit-sharma-920@scenic-reason-445114-j8.iam.gserviceaccount.com",
    "client_id": "111859920864777312599",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url":
        "https://www.googleapis.com/robot/v1/metadata/x509/ankit-sharma-920%40scenic-reason-445114-j8.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  });

  final client = await clientViaServiceAccount(
    serviceAccountCredentials,
    ['https://www.googleapis.com/auth/cloud-platform'],
  );

  final accessToken = client.credentials.accessToken.data;
  debugPrint('Generated access token: $accessToken');
  return accessToken;
}
