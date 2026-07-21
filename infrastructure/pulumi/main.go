package main

import (
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

// createLocalCloud provisions all local-cloud infrastructure modules.
func createLocalCloud(ctx *pulumi.Context) error {
	if err := createStorage(ctx); err != nil {
		return err
	}
	if err := createNetwork(ctx); err != nil {
		return err
	}
	if err := createIAM(ctx); err != nil {
		return err
	}
	if err := createDynamoDB(ctx); err != nil {
		return err
	}
	if err := createECS(ctx); err != nil {
		return err
	}
	if err := createECR(ctx); err != nil {
		return err
	}
	if err := createK8s(ctx); err != nil {
		return err
	}
	return nil
}

func main() {
	pulumi.Run(createLocalCloud)
}