package common

import (
        "context"
        //"strings"
        "testing"
        "github.com/aws/aws-sdk-go-v2/aws"
        "github.com/aws/aws-sdk-go-v2/config"
        "github.com/aws/aws-sdk-go-v2/service/appmesh"
        "github.com/aws/aws-sdk-go-v2/service/elasticloadbalancingv2"
        "github.com/gruntwork-io/terratest/modules/terraform"
        "github.com/launchbynttdata/lcaf-component-terratest/types"
        "github.com/stretchr/testify/require"
)


const expectedAlbState           = "active"


func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	albArn        := terraform.Output(t, ctx.TerratestTerraformOptions(), "alb_arn")
	albDns        := terraform.Output(t, ctx.TerratestTerraformOptions(), "alb_dns")
	appMeshId     := terraform.Output(t, ctx.TerratestTerraformOptions(), "app_mesh_id")

        appmeshClient := GetAWSAppmeshClient(t)
        t.Run("TestAppmeshExists", func(t *testing.T) {
		output, err := appmeshClient.DescribeMesh(context.TODO(), &appmesh.DescribeMeshInput{MeshName: &appMeshId})
                if err != nil {
                        t.Errorf("Error describing mesh: %v", err)
		}
                RequireEqualString(t, appMeshId, *output.Mesh.MeshName, "mesh name/mesh id")
        })


        elbv2Client := GetAWSElbv2Client(t)
	t.Run("TestALB", func(t *testing.T) {
		output, err := elbv2Client.DescribeLoadBalancers(context.TODO(), &elasticloadbalancingv2.DescribeLoadBalancersInput{LoadBalancerArns: []string{albArn}})
                if err != nil {
                        t.Errorf("Error describing alb: %v", err)
		}
		loadBalancers := output.LoadBalancers
		require.Equal(t, 1, len(loadBalancers), "Expected exactly 1 ALB with the ARN %s", albArn)
                RequireEqualString(t, albArn, *loadBalancers[0].LoadBalancerArn, "ALB ARN")
                RequireEqualString(t, albDns, *loadBalancers[0].LoadBalancerName, "ALB name")
		RequireEqualString(t, expectedAlbState, string(loadBalancers[0].State.Code), "ALB state")
        })
}


func RequireEqualString(t *testing.T, expected string, actual string, resource_type string) {
        require.Equal(t, expected, actual, "Expected %s to be %s, but got %s", resource_type, expected, actual)
}

func GetAWSAppmeshClient(t *testing.T) *appmesh.Client {
        awsAppmeshClient := appmesh.NewFromConfig(GetAWSConfig(t))
        return awsAppmeshClient
}

func GetAWSElbv2Client(t *testing.T) *elasticloadbalancingv2.Client {
        awsElbv2Client := elasticloadbalancingv2.NewFromConfig(GetAWSConfig(t))
        return awsElbv2Client
}

func GetAWSConfig(t *testing.T) (cfg aws.Config) {
        cfg, err := config.LoadDefaultConfig(context.TODO())
        require.NoErrorf(t, err, "unable to load SDK config, %v", err)
        return cfg
}
