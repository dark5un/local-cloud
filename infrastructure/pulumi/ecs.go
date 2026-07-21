package main

import (
	"encoding/json"

	"github.com/pulumi/pulumi-aws/sdk/v7/go/aws/ecs"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

// createECS provisions an ECS cluster, task definition, and service.
func createECS(ctx *pulumi.Context) error {
	cluster, err := ecs.NewCluster(ctx, "local-cloud-ecs", &ecs.ClusterArgs{
		Name: pulumi.String("local-cloud"),
		Tags: pulumi.StringMap{
			"managed_by":  pulumi.String("pulumi"),
			"environment": pulumi.String("local"),
		},
	})
	if err != nil {
		return err
	}

	containerDef, err := json.Marshal([]map[string]interface{}{
		{
			"name":      "web",
			"image":     "localhost:5000/hello:latest",
			"essential": true,
			"portMappings": []map[string]interface{}{
				{
					"containerPort": 80,
					"protocol":      "tcp",
				},
			},
		},
	})
	if err != nil {
		return err
	}

	taskDef, err := ecs.NewTaskDefinition(ctx, "local-cloud-task", &ecs.TaskDefinitionArgs{
		Family:                  pulumi.String("web"),
		NetworkMode:             pulumi.String("awsvpc"),
		RequiresCompatibilities: pulumi.StringArray{pulumi.String("FARGATE")},
		Cpu:                     pulumi.String("256"),
		Memory:                  pulumi.String("512"),
		ExecutionRoleArn:        pulumi.String("arn:aws:iam::000000000000:role/local-cloud-role"),
		TaskRoleArn:             pulumi.String("arn:aws:iam::000000000000:role/local-cloud-role"),
		ContainerDefinitions:    pulumi.String(string(containerDef)),
	})
	if err != nil {
		return err
	}

	service, err := ecs.NewService(ctx, "local-cloud-service", &ecs.ServiceArgs{
		Name:             pulumi.String("web"),
		Cluster:          cluster.ID(),
		TaskDefinition:   taskDef.Arn,
		DesiredCount:     pulumi.Int(1),
		LaunchType:       pulumi.String("FARGATE"),
		NetworkConfiguration: &ecs.ServiceNetworkConfigurationArgs{
			Subnets: pulumi.StringArray{pulumi.String("subnet-placeholder")},
		},
	})
	if err != nil {
		return err
	}

	ctx.Export("clusterName", cluster.Name)
	ctx.Export("serviceName", service.Name)
	ctx.Export("desiredCount", service.DesiredCount)
	ctx.Export("taskDefinitionArn", taskDef.Arn)
	return nil
}