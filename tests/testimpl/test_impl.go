package common

import (
	"context"
	//"encoding/json"
	"fmt"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
        "github.com/aws/aws-sdk-go-v2/service/appmesh"
	//"github.com/gruntwork-io/terratest/modules/logger"
        "github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
        "github.com/stretchr/testify/require"
)

func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	appmeshClient := GetAWSAppmeshClient(t)
        /*appmeshClientJSON, err := json.Marshal(appmeshClient)
        if err != nil {
            panic(err)
        }*/

	// The hardcoded value here matches that in test.tfvars
	appMeshId := "tests_appmesh1-999"
	virtualNodeId := terraform.Output(t, ctx.TerratestTerraformOptions(), "virtual_node_id")
	virtualNodeArn := terraform.Output(t, ctx.TerratestTerraformOptions(), "virtual_node_arn")

	fmt.Println(virtualNodeId)
	fmt.Println(virtualNodeArn)
	//fmt.Println(string(&appmeshClientJSON))

	t.Run("TestDoesVirtualNodeExist", func(t *testing.T) {
		output, err := appmeshClient.ListVirtualNodes(context.TODO(), &appmesh.ListVirtualNodesInput{MeshName: &appMeshId})
		if err != nil {
			t.Errorf("Error getting virtual node list: %v", err)
		}

		require.Equal(t, 1, len(output.VirtualNodes), "Expected 1 virtual node to be returned")
		require.Equal(t, virtualNodeArn, *output.VirtualNodes[0].Arn, "Expected virtual node ARN to match")
		require.Equal(t, virtualNodeId, *output.VirtualNodes[0].VirtualNodeName, "Expected virtual node id to match")
	})
}

func GetAWSAppmeshClient(t *testing.T) *appmesh.Client {
	awsAppmeshClient := appmesh.NewFromConfig(GetAWSConfig(t))
	return awsAppmeshClient
}

func GetAWSConfig(t *testing.T) (cfg aws.Config) {
	cfg, err := config.LoadDefaultConfig(context.TODO())
	require.NoErrorf(t, err, "unable to load SDK config, %v", err)
	return cfg
}
