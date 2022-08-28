# SNS and SQS notes

AWS Simple Notification Service (SNS) allows us to send messages to various
endpoints in publish/subscribe fashion. One such endpoint is AWS Simple Queue
Service (SQS), which stores messages for other microservices and serverless
functions to process. SQS can provide exactly once processing guarantees when
using the FIFO implementation.

In our application, we use SNS to send updates on the most recent posts to
subscribers every 5 minutes. This choice is arbitrary--real users would likely
want less frequent updates--but it demonstrates the capability. SNS can send
to email, SMS, SQS, and other endpoints. We used email initially, but switched
to SQS because pending email subscription requests (SNS sends a subscription
request to the specified email address so that a user can confirm their desire
to subscribe to the feed) cannot be deleted by Terraform or even in the AWS
console. The subscription resources remain in AWS until they expire, 3 days by
default. We disliked having outstanding resources after destroying all other
infrastructure. SQS provides a more manageable endpoint for messages.
