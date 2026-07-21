package main

import (
	"encoding/json"

	"github.com/pulumi/pulumi-aws/sdk/v7/go/aws/iam"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

// createIAM provisions an ECS task role with a policy.
func createIAM(ctx *pulumi.Context) error {
	assumeRoleJSON, err := json.Marshal(map[string]interface{}{
		"Version": "2012-10-17",
		"Statement": []map[string]interface{}{
			{
				"Effect":    "Allow",
				"Principal": map[string]interface{}{"Service": "ecs-tasks.amazonaws.com"},
				"Action":    "sts:AssumeRole",
			},
		},
	})
	if err != nil {
		return err
	}

	role, err := iam.NewRole(ctx, "local-cloud-role", &iam.RoleArgs{
		Name:             pulumi.String("local-cloud-role"),
		AssumeRolePolicy: pulumi.String(string(assumeRoleJSON)),
		Tags: pulumi.StringMap{
			"managed_by":  pulumi.String("pulumi"),
			"environment": pulumi.String("local"),
		},
	})
	if err != nil {
		return err
	}

	policyJSON, err := json.Marshal(map[string]interface{}{
		"Version": "2012-10-17",
		"Statement": []map[string]interface{}{
			{
				"Effect":   "Allow",
				"Action":   []string{"s3:GetObject", "s3:PutObject", "s3:ListBucket"},
				"Resource": "*",
			},
			{
				"Effect":   "Allow",
				"Action":   []string{"logs:*"},
				"Resource": "*",
			},
		},
	})
	if err != nil {
		return err
	}

	policy, err := iam.NewPolicy(ctx, "local-cloud-policy", &iam.PolicyArgs{
		Name:        pulumi.String("local-cloud-role-policy"),
		Description: pulumi.String("Local cloud policy"),
		Policy:      pulumi.String(string(policyJSON)),
		Tags: pulumi.StringMap{
			"managed_by":  pulumi.String("pulumi"),
			"environment": pulumi.String("local"),
		},
	})
	if err != nil {
		return err
	}

	_, err = iam.NewRolePolicyAttachment(ctx, "local-cloud-role-policy-attachment", &iam.RolePolicyAttachmentArgs{
		Role:      role.Name,
		PolicyArn: policy.Arn,
	})
	if err != nil {
		return err
	}

	ctx.Export("roleName", role.Name)
	ctx.Export("roleArn", role.Arn)
	ctx.Export("policyArn", policy.Arn)
	return nil
}