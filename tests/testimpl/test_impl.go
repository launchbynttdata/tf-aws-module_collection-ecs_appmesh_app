package common

import (
        "context"
        //"strings"
        "testing"
        "github.com/aws/aws-sdk-go-v2/aws"
        "github.com/aws/aws-sdk-go-v2/config"
        "github.com/aws/aws-sdk-go-v2/service/appmesh"
        "github.com/gruntwork-io/terratest/modules/terraform"
        "github.com/launchbynttdata/lcaf-component-terratest/types"
        "github.com/stretchr/testify/require"
)


const expectedAlbState           = "active"


func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	appMeshId     := terraform.Output(t, ctx.TerratestTerraformOptions(), "app_mesh_id")
	appMeshName   := terraform.Output(t, ctx.TerratestTerraformOptions(), "app_mesh_name")

        appmeshClient := GetAWSAppmeshClient(t)
        t.Run("TestAppmeshExists", func(t *testing.T) {
		output, err := appmeshClient.DescribeMesh(context.TODO(), &appmesh.DescribeMeshInput{MeshName: &appMeshName})
                if err != nil {
                        t.Errorf("Error describing mesh: %v", err)
		}
                RequireEqualString(t, appMeshName, *output.Mesh.MeshName, "app mesh name")
                RequireEqualString(t, appMeshId, *output.Mesh.Metadata.Arn, "app mesh id/arn")
        })
}


func RequireEqualString(t *testing.T, expected string, actual string, resource_type string) {
        require.Equal(t, expected, actual, "Expected %s to be %s, but got %s", resource_type, expected, actual)
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
