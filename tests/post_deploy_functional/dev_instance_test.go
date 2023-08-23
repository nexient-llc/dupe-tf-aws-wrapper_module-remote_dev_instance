package test

import (
	"context"
	"fmt"
	"io/fs"
	"os"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
	"github.com/aws/aws-sdk-go-v2/service/efs"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

const (
	base            = "../../examples/"
	testVarFileName = "test.tfvars"
)

func TestDevInstanceModule(t *testing.T) {
	t.Parallel()
	examplesFolders, err := os.ReadDir(base)
	if err != nil {
		assert.Error(t, err)
	}
	forEveryExampleRunTests(t, examplesFolders)

}
func forEveryExampleRunTests(t *testing.T, examplesFolders []fs.DirEntry) {
	for _, file := range examplesFolders {
		dir := base + file.Name()
		if file.IsDir() {
			runSetupTestTeardown(t, dir)
		}
	}
}

func runSetupTestTeardown(t *testing.T, dir string) {
	stage := test_structure.RunTestStage
	defer stage(t, "teardown_dev_instance", func() { tearDownDevInstanceModuleTest(t, dir) })
	stage(t, "setup_dev_instance", func() { setupDevInstanceModuleTest(t, dir) })
	stage(t, "test_dev_instance", func() { testDevInstance(t, dir) })
	stage(t, "test_efs_volume", func() { testEFSVolume(t, dir) })
}

func setupDevInstanceModuleTest(t *testing.T, dir string) {
	terraformOptions := &terraform.Options{
		TerraformDir: dir,
		VarFiles:     []string{testVarFileName},
		NoColor:      true,
		Logger:       logger.Discard,
	}
	test_structure.SaveTerraformOptions(t, dir, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}

func testDevInstance(t *testing.T, dir string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, dir)
	terraformOptions.Logger = logger.Discard
	testOutputInstanceIPs(t, terraformOptions, dir)
	testValidInstance(t, terraformOptions, dir, getAWSAPIEC2Client(t))
}

func testEFSVolume(t *testing.T, dir string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, dir)
	terraformOptions.Logger = logger.Discard
	testValidEFSVolume(t, terraformOptions, dir, getAWSAPIEFSClient(t))
}

func getAWSAPIEC2Client(t *testing.T) *ec2.Client {
	cfg, err := config.LoadDefaultConfig(
		context.TODO(),
		config.WithSharedConfigProfile(os.Getenv("AWS_PROFILE")),
	)
	assert.NoError(t, err, "can't acquire aws EC2 client")
	return ec2.NewFromConfig(cfg)
}

func getAWSAPIEFSClient(t *testing.T) *efs.Client {
	cfg, err := config.LoadDefaultConfig(
		context.TODO(),
		config.WithSharedConfigProfile(os.Getenv("AWS_PROFILE")),
	)
	assert.NoError(t, err, "can't acquire aws EFS client")
	return efs.NewFromConfig(cfg)
}

func testOutputInstanceIPs(t *testing.T, opts *terraform.Options, dir string) {
	instanceIPs, err := terraform.OutputListE(t, opts, "instance_ip")
	assert.NoError(t, err, "error retrieving output for instance_ip")
	assert.Equal(t, len(instanceIPs), len(terraform.GetVariableAsListFromVarFile(t, dir+"/"+testVarFileName, "user_list")), "Mismatch in instances returned vs user_list")
}

func testValidInstance(t *testing.T, opts *terraform.Options, dir string, client *ec2.Client) {
	instanceIDs, err := terraform.OutputListE(t, opts, "instance_ids")
	instanceIDps := make([]*string, len(instanceIDs))
	for i, s := range instanceIDs {
		instanceIDps[i] = &s
	}
	assert.NoError(t, err)

	userList := terraform.GetVariableAsListFromVarFile(t, dir+"/"+testVarFileName, "user_list")
	result, err := client.DescribeInstances(context.TODO(), &ec2.DescribeInstancesInput{
		InstanceIds: instanceIDs,
	})
	assert.NoError(t, err)
	assert.NotNil(t, result, "result is empty")
	assert.NotNil(t, result.Reservations, "result.Reservations is nil")

	assert.Equal(t, len(userList), len(result.Reservations), "incorrect number of instances found")
	for _, r := range result.Reservations {
		assert.Equal(t, 1, len(r.Instances), "incorrect number of instances found on reservation")
		for _, i := range r.Instances {
			testNoPublicIPAddress(t, i.PublicIpAddress)
			assert.Equal(t, terraform.GetVariableAsStringFromVarFile(t, dir+"/"+testVarFileName, "ami_instance_type"), string(i.InstanceType), "incorrect instance type")
			testInstanceState(t, string(i.State.Name))
		}
	}
}

func testNoPublicIPAddress(t *testing.T, publicIP *string) {
	assert.Nil(t, publicIP, "instance has a public IP address")
}

func testInstanceState(t *testing.T, state string) {
	switch state {
	case "running":
		return
	case "pending":
		return
	default:
		assert.Fail(t, fmt.Sprintf("unexpected instance state: %v", state))
	}
}

func getEFSVolumeName(t *testing.T, opts *terraform.Options, dir string) string {
	fname := dir + "/" + testVarFileName
	region := strings.ReplaceAll(terraform.GetVariableAsStringFromVarFile(t, fname, "region"), "-", "")
	naming_prefix := terraform.GetVariableAsStringFromVarFile(t, fname, "naming_prefix")
	environment := terraform.GetVariableAsStringFromVarFile(t, fname, "environment")
	environment_number := terraform.GetVariableAsStringFromVarFile(t, fname, "environment_number")
	resource_number := terraform.GetVariableAsStringFromVarFile(t, fname, "resource_number")
	return fmt.Sprintf("%s-%s-%s-%s-devefsfs-%s", naming_prefix, region, environment, environment_number, resource_number)
}

func testValidEFSVolume(t *testing.T, opts *terraform.Options, dir string, client *efs.Client) {
	tokenName := getEFSVolumeName(t, opts, dir) //"test-useast2-dev-000-devefsfs-000"
	result, err := client.DescribeFileSystems(context.TODO(), &efs.DescribeFileSystemsInput{
		CreationToken: &tokenName,
	})
	assert.NoError(t, err)
	assert.NotNil(t, result, "describe EFS filesystem result is empty")
	assert.Equal(t, 1, len(result.FileSystems), "expected a single EFS filesystem")
	subnets := terraform.GetVariableAsListFromVarFile(t, dir+"/"+testVarFileName, "subnet_names")
	assert.Equal(t, len(subnets), int(result.FileSystems[0].NumberOfMountTargets), "incorrect number of EFS mount targets found")

	res2, err := client.DescribeAccessPoints(context.TODO(), &efs.DescribeAccessPointsInput{
		FileSystemId: result.FileSystems[0].FileSystemId,
	})
	userList := terraform.GetVariableAsListFromVarFile(t, dir+"/"+testVarFileName, "user_list")
	assert.NoError(t, err, "error retrieving EFS access points")
	assert.Equal(t, len(userList), len(res2.AccessPoints), "incorrect number of EFS access points found")

}

func tearDownDevInstanceModuleTest(t *testing.T, dir string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, dir)
	terraformOptions.Logger = logger.Discard
	terraform.Destroy(t, terraformOptions)
}
