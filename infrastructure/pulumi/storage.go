package main

import (
	"github.com/pulumi/pulumi-aws/sdk/v7/go/aws/s3"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

// createStorage provisions a versioned S3 bucket with tags.
func createStorage(ctx *pulumi.Context) error {
	bucket, err := s3.NewBucket(ctx, "local-cloud-storage", &s3.BucketArgs{
		Bucket: pulumi.String("local-cloud-artifacts"),
		Tags: pulumi.StringMap{
			"managed_by":  pulumi.String("pulumi"),
			"environment": pulumi.String("local"),
		},
	})
	if err != nil {
		return err
	}

	_, err = s3.NewBucketVersioning(ctx, "local-cloud-storage-versioning", &s3.BucketVersioningArgs{
		Bucket: bucket.Bucket,
		VersioningConfiguration: &s3.BucketVersioningVersioningConfigurationArgs{
			Status: pulumi.String("Enabled"),
		},
	})
	if err != nil {
		return err
	}

	ctx.Export("bucketName", bucket.Bucket)
	ctx.Export("bucketArn", bucket.Arn)
	ctx.Export("versioningEnabled", pulumi.String("Enabled"))
	return nil
}