import 'package:amazon_cognito_identity_dart_2/cognito.dart';

class AwsCredentialsService {
  Future<Credentials> getTemporaryCredentials() async {
    final userPool = CognitoUserPool(
      'your-user-pool-id',
      'your-client-id',
    );
    
    // Use Cognito to get temporary credentials
    // This is much safer than hardcoding credentials
    return await userPool.getCredentials();
  }
} 