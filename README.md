# aws-sftp
SFTP server on AWS 

## Problem
- Create an SFTP server which can serve as an interface for clients to Upload daily / weekly data.
- All this data will be uploaded to an S3 bucket which will act as a data lake.
- We should be able to add or delete any user agency with a script
- Every client will use the SFTP user created for that client.

**WARNING: Please note that this is a very basic first draft of the solution that I was trying to implement. That's why this is an untested code which might require a lot of corrections.**

## Solution Outline

- VPC Setup: Create a VPC in the eu-west-1 region with public and private subnets. This will provide isolation and security for your resources.
- SFTP Server: Deploy an SFTP server using AWS Transfer Family. This service allows agencies to securely upload files to your S3 buckets using the SFTP protocol.
- S3 Buckets: Create an S3 bucket to serve as your data lake. Enable server-side encryption and versioning on the bucket to ensure data security and durability.
- VPC Endpoint for S3: Create a VPC endpoint for S3 in your private subnet. This allows the SFTP server and other resources in the VPC to securely access S3 without going over the public internet.
- IAM Roles and Policies: Create an IAM role for the SFTP server with the necessary permissions to access the S3 bucket. The role should follow the principle of least privilege, granting only the required actions on the specific bucket.
- CloudWatch Events: Set up CloudWatch Events to monitor the S3 bucket and trigger an event when new files are uploaded. Configure the event to send notifications to the SRE team via email or Slack, alerting them about missing data.
- Monitoring and Logging: Enable CloudTrail to capture API activity for auditing purposes. Configure CloudWatch Logs to collect logs from the SFTP server, S3 bucket, and other relevant services for troubleshooting and monitoring.
- Secure Access: Configure security groups and network ACLs to control inbound and outbound traffic to the SFTP server and other resources. Use strong password policies and enforce key-based authentication for SFTP access.
- Automation and Scalability: Use AWS Lambda functions or AWS Step Functions to automate the onboarding and off boarding of agencies. Develop scripts or processes to handle the creation and deletion of SFTP user accounts and associated IAM roles.
- Cost Optimisation: Explore options to minimize costs, such as using Reserved Instances for long-term SFTP server usage, leveraging AWS Free Tier-eligible resources, and setting up lifecycle policies to move infrequently accessed data to cheaper storage classes.