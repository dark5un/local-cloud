package main

import (
	"github.com/pulumi/pulumi-aws/sdk/v7/go/aws/ec2"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

// createNetwork provisions a VPC with a public subnet.
func createNetwork(ctx *pulumi.Context) error {
	vpc, err := ec2.NewVpc(ctx, "local-cloud-vpc", &ec2.VpcArgs{
		CidrBlock:          pulumi.String("10.0.0.0/16"),
		EnableDnsSupport:   pulumi.Bool(true),
		EnableDnsHostnames: pulumi.Bool(true),
		Tags: pulumi.StringMap{
			"Name":        pulumi.String("local-cloud-vpc"),
			"managed_by":  pulumi.String("pulumi"),
			"environment": pulumi.String("local"),
		},
	})
	if err != nil {
		return err
	}

	subnet, err := ec2.NewSubnet(ctx, "local-cloud-public-subnet", &ec2.SubnetArgs{
		VpcId:            vpc.ID(),
		CidrBlock:        pulumi.String("10.0.1.0/24"),
		AvailabilityZone: pulumi.String("us-east-1a"),
		Tags: pulumi.StringMap{
			"Name":        pulumi.String("local-cloud-public"),
			"managed_by":  pulumi.String("pulumi"),
			"environment": pulumi.String("local"),
		},
	})
	if err != nil {
		return err
	}

	ctx.Export("vpcId", vpc.ID())
	ctx.Export("vpcCidr", vpc.CidrBlock)
	ctx.Export("subnetId", subnet.ID())
	ctx.Export("subnetCidr", subnet.CidrBlock)
	return nil
}