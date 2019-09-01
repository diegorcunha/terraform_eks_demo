terraform {
 backend "s3" {
   region         = "us-east-1"
   bucket         = "tf.aws.test"
   key            = "terraform.tfstate"
   encrypt        = "true"
   dynamodb_table = "test_state_conf"

 }
}