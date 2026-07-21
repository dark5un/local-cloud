package main

import (
	"github.com/pulumi/pulumi-aws/sdk/v7/go/aws/dynamodb"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

// createDynamoDB provisions a DynamoDB table for state management.
func createDynamoDB(ctx *pulumi.Context) error {
	table, err := dynamodb.NewTable(ctx, "local-cloud-state", &dynamodb.TableArgs{
		Name:         pulumi.String("local-cloud-state"),
		BillingMode:  pulumi.String("PAY_PER_REQUEST"),
		HashKey:      pulumi.String("id"),
		Attributes: dynamodb.TableAttributeArray{
			&dynamodb.TableAttributeArgs{
				Name: pulumi.String("id"),
				Type: pulumi.String("S"),
			},
		},
		Tags: pulumi.StringMap{
			"managed_by":  pulumi.String("pulumi"),
			"environment": pulumi.String("local"),
		},
	})
	if err != nil {
		return err
	}

	ctx.Export("tableName", table.Name)
	ctx.Export("tableId", table.ID())
	return nil
}