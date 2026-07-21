package main

import (
	appsv1 "github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/apps/v1"
	corev1 "github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/core/v1"
	metav1 "github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/meta/v1"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

// createK8s provisions a Kubernetes namespace, deployment, and service.
func createK8s(ctx *pulumi.Context) error {
	ns, err := corev1.NewNamespace(ctx, "local-cloud-ns", &corev1.NamespaceArgs{
		Metadata: &metav1.ObjectMetaArgs{
			Name: pulumi.String("local-cloud"),
		},
	})
	if err != nil {
		return err
	}

	deploy, err := appsv1.NewDeployment(ctx, "local-cloud-deploy", &appsv1.DeploymentArgs{
		Metadata: &metav1.ObjectMetaArgs{
			Name:      pulumi.String("hello-local-cloud"),
			Namespace: ns.Metadata.Name().Elem(),
		},
		Spec: &appsv1.DeploymentSpecArgs{
			Replicas: pulumi.Int(2),
			Selector: &metav1.LabelSelectorArgs{
				MatchLabels: pulumi.StringMap{
					"app": pulumi.String("hello-local-cloud"),
				},
			},
			Template: &corev1.PodTemplateSpecArgs{
				Metadata: &metav1.ObjectMetaArgs{
					Labels: pulumi.StringMap{
						"app": pulumi.String("hello-local-cloud"),
					},
				},
				Spec: &corev1.PodSpecArgs{
					Containers: corev1.ContainerArray{
						&corev1.ContainerArgs{
							Name:  pulumi.String("hello-local-cloud"),
							Image: pulumi.String("nginx:alpine"),
							Ports: corev1.ContainerPortArray{
								&corev1.ContainerPortArgs{
									ContainerPort: pulumi.Int(80),
								},
							},
						},
					},
				},
			},
		},
	})
	if err != nil {
		return err
	}

	svc, err := corev1.NewService(ctx, "local-cloud-svc", &corev1.ServiceArgs{
		Metadata: &metav1.ObjectMetaArgs{
			Name:      pulumi.String("hello-local-cloud"),
			Namespace: ns.Metadata.Name().Elem(),
		},
		Spec: &corev1.ServiceSpecArgs{
			Selector: pulumi.StringMap{
				"app": pulumi.String("hello-local-cloud"),
			},
			Ports: corev1.ServicePortArray{
				&corev1.ServicePortArgs{
					Port:       pulumi.Int(80),
					TargetPort: pulumi.Int(80),
				},
			},
			Type: pulumi.String("ClusterIP"),
		},
	})
	if err != nil {
		return err
	}

	ctx.Export("k8sNamespace", ns.Metadata.Name().Elem())
	ctx.Export("k8sDeployment", deploy.Metadata.Name().Elem())
	ctx.Export("k8sService", svc.Metadata.Name().Elem())
	return nil
}