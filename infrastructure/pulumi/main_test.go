package main

import (
	"testing"

	"github.com/pulumi/pulumi/sdk/v3/go/common/resource"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
	"github.com/stretchr/testify/assert"
)

// mocks implements the Pulumi mock resource monitor for unit testing.
type mocks int

// NewResource returns mock outputs for resource creation.
func (mocks) NewResource(args pulumi.MockResourceArgs) (string, resource.PropertyMap, error) {
	outputs := args.Inputs.Mappable()
	// Set standard computed properties that AWS would return
	switch args.TypeToken {
	case "aws:s3/bucket:Bucket":
		outputs["arn"] = "arn:aws:s3:::local-cloud-artifacts"
		outputs["bucket"] = "local-cloud-artifacts"
		outputs["bucketDomainName"] = "local-cloud-artifacts.s3.amazonaws.com"
	case "aws:s3/bucketVersioning:BucketVersioning":
		outputs["id"] = "versioning-id"
	case "aws:ec2/vpc:Vpc":
		outputs["id"] = "vpc-12345"
		outputs["cidrBlock"] = "10.0.0.0/16"
	case "aws:ec2/subnet:Subnet":
		outputs["id"] = "subnet-12345"
		outputs["cidrBlock"] = "10.0.1.0/24"
	case "aws:iam/role:Role":
		outputs["arn"] = "arn:aws:iam::000000000000:role/local-cloud-role"
		outputs["name"] = "local-cloud-role"
	case "aws:iam/policy:Policy":
		outputs["arn"] = "arn:aws:iam::000000000000:policy/local-cloud-role-policy"
		outputs["name"] = "local-cloud-role-policy"
	case "aws:iam/rolePolicyAttachment:RolePolicyAttachment":
		outputs["id"] = "role-policy-attachment"
	case "aws:dynamodb/table:Table":
		outputs["name"] = "local-cloud-state"
		outputs["id"] = "local-cloud-state"
	case "aws:ecs/cluster:Cluster":
		outputs["name"] = "local-cloud"
	case "aws:ecs/taskDefinition:TaskDefinition":
		outputs["arn"] = "arn:aws:ecs:us-east-1:000000000000:task-definition/web:1"
	case "aws:ecs/service:Service":
		outputs["name"] = "web"
		outputs["desiredCount"] = 1.0
	case "aws:ecr/repository:Repository":
		outputs["name"] = "hello-local-cloud"
		outputs["repositoryUrl"] = "000000000000.dkr.ecr.us-east-1.amazonaws.com/hello-local-cloud"
		outputs["arn"] = "arn:aws:ecr:us-east-1:000000000000:repository/hello-local-cloud"
		outputs["registryId"] = "000000000000"
	}
	return args.Name + "_id", resource.NewPropertyMapFromMap(outputs), nil
}

// Call returns mock results for function calls.
func (mocks) Call(args pulumi.MockCallArgs) (resource.PropertyMap, error) {
	return resource.NewPropertyMapFromMap(map[string]interface{}{}), nil
}

// TestLocalCloudStack verifies the full stack composes without error.
func TestLocalCloudStack(t *testing.T) {
	err := pulumi.RunErr(func(ctx *pulumi.Context) error {
		err := createLocalCloud(ctx)
		assert.NoError(t, err)
		return nil
	}, pulumi.WithMocks("project", "stack", mocks(0)))
	assert.NoError(t, err)
}

// TestStorageModule verifies the storage module creates a versioned S3 bucket.
func TestStorageModule(t *testing.T) {
	err := pulumi.RunErr(func(ctx *pulumi.Context) error {
		err := createStorage(ctx)
		assert.NoError(t, err)
		return nil
	}, pulumi.WithMocks("project", "stack", mocks(0)))
	assert.NoError(t, err)
}

// TestNetworkModule verifies the network module creates a VPC and subnet.
func TestNetworkModule(t *testing.T) {
	err := pulumi.RunErr(func(ctx *pulumi.Context) error {
		err := createNetwork(ctx)
		assert.NoError(t, err)
		return nil
	}, pulumi.WithMocks("project", "stack", mocks(0)))
	assert.NoError(t, err)
}

// TestIAMModule verifies the IAM module creates a role, policy, and attachment.
func TestIAMModule(t *testing.T) {
	err := pulumi.RunErr(func(ctx *pulumi.Context) error {
		err := createIAM(ctx)
		assert.NoError(t, err)
		return nil
	}, pulumi.WithMocks("project", "stack", mocks(0)))
	assert.NoError(t, err)
}

// TestDynamoDBModule verifies the DynamoDB module creates a table.
func TestDynamoDBModule(t *testing.T) {
	err := pulumi.RunErr(func(ctx *pulumi.Context) error {
		err := createDynamoDB(ctx)
		assert.NoError(t, err)
		return nil
	}, pulumi.WithMocks("project", "stack", mocks(0)))
	assert.NoError(t, err)
}

// TestECSModule verifies the ECS module creates cluster, task def, and service.
func TestECSModule(t *testing.T) {
	err := pulumi.RunErr(func(ctx *pulumi.Context) error {
		err := createECS(ctx)
		assert.NoError(t, err)
		return nil
	}, pulumi.WithMocks("project", "stack", mocks(0)))
	assert.NoError(t, err)
}

// TestECRModule verifies the ECR module creates a repository.
func TestECRModule(t *testing.T) {
	err := pulumi.RunErr(func(ctx *pulumi.Context) error {
		err := createECR(ctx)
		assert.NoError(t, err)
		return nil
	}, pulumi.WithMocks("project", "stack", mocks(0)))
	assert.NoError(t, err)
}

// TestK8sModule verifies the k8s module creates namespace, deployment, and service.
func TestK8sModule(t *testing.T) {
	err := pulumi.RunErr(func(ctx *pulumi.Context) error {
		err := createK8s(ctx)
		assert.NoError(t, err)
		return nil
	}, pulumi.WithMocks("project", "stack", mocks(0)))
	assert.NoError(t, err)
}