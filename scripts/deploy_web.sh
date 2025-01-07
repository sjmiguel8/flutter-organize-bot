#!/bin/bash

# Build web version
echo "Building web version..."
flutter build web

# Deploy to S3
echo "Deploying to S3..."
aws s3 rm s3://fluttertryweb/ --recursive
aws s3 sync build/web/ s3://fluttertryweb/

echo "Deployment complete!"
echo "Your app should be available at: http://fluttertryweb.s3-website-[your-region].amazonaws.com" 