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

type TestTfvars struct {
	AppMeshId string  `json:"app_mesh_id"`
}


func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	appmeshClient := GetAWSAppmeshClient(t)
        //appmeshClientJSON, err := json.Marshal(appmeshClient)
        //if err != nil {
        //    panic(err)
        //}

	// The hardcoded value here matches that in test.tfvars
	appMeshId := "terratest-vgwtest-app-mesh-39104"
	virtualNodeId := terraform.Output(t, ctx.TerratestTerraformOptions(), "virtual_node_id")
	virtualNodeArn := terraform.Output(t, ctx.TerratestTerraformOptions(), "virtual_node_arn")

	fmt.Println(appMeshId)
	fmt.Println(virtualNodeId)
	fmt.Println(virtualNodeArn)
	//fmt.Println(string(&appmeshClientJSON))


	t.Run("TestDoesMeshExist", func(t *testing.T) {
		output, err := appmeshClient.DescribeMesh(context.TODO(), &appmesh.DescribeMeshInput{MeshName: &appMeshId})
		if err != nil {
			t.Errorf("Error describing mesh: %v", err)
		}

		RequireEqualHelper(t, appMeshId, *output.Mesh.MeshName, "mesh name")
		require.Equal(t, appMeshId, *output.Mesh.MeshName, "Expected mesh name to be %s, but got %s", appMeshId, *output.Mesh.MeshName)
	})

	t.Run("TestDoesVirtualNodeExist", func(t *testing.T) {
		output, err := appmeshClient.ListVirtualNodes(context.TODO(), &appmesh.ListVirtualNodesInput{MeshName: &appMeshId})
		if err != nil {
			t.Errorf("Error getting virtual node list: %v", err)
		}

		require.Equal(t, 1, len(output.VirtualNodes), "Expected 1 virtual node to be returned")
		RequireEqualHelper(t, virtualNodeArn, *output.VirtualNodes[0].Arn, "virtual node ARN")
		RequireEqualHelper(t, virtualNodeId, *output.VirtualNodes[0].VirtualNodeName, "virtual node ID")
		require.Equal(t, virtualNodeArn, *output.VirtualNodes[0].Arn, "Expected virtual node ARN to be %s, but got %s","","" )
		require.Equal(t, virtualNodeId, *output.VirtualNodes[0].VirtualNodeName, "Expected virtual node id to be %s, but got %s","","")
	})
}


func RequireEqualHelper(t *testing.T, expected string, actual string, resource_type string) bool {
	require.Equal(t, expected, actual, "Expected %s to be %s, but got %s", resource_type, expected, actual)
	return true
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
