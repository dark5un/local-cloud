package main

import (
	"github.com/pulumi/pulumi-aws/sdk/v7/go/aws/ecr"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

// createECR provisions an ECR repository.
func createECR(ctx *pulumi.Context) error {
	repo, err := ecr.NewRepository(ctx, "local-cloud-ecr", &ecr.RepositoryArgs{
		Name: pulumi.String("hello-local-cloud"),
		ImageScanningConfiguration: &ecr.RepositoryImageScanningConfigurationArgs{
			ScanOnPush: pulumi.Bool(true),
		},
		ImageTagMutability: pulumi.String("MUTABLE"),
		Tags: pulumi.StringMap{
			"managed_by":  pulumi.String("pulumi"),
			"environment": pulumi.String("local"),
		},
	})
	if err != nil {
		return err
	}

	ctx.Export("repositoryName", repo.Name)
	ctx.Export("repositoryUrl", repo.RepositoryUrl)
	ctx.Export("repositoryArn", repo.Arn)
	ctx.Export("registryId", repo.RegistryId)
	return nil
}