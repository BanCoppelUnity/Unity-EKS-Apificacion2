import pytest
import tftest
import boto3
import subprocess
import os

# Define una ruta al directorio que contiene los archivos de configuración de Terraform
FIXTURES_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)))

# Define la región de AWS como una variable global
AWS_REGION = "us-east-1"

# Configura la secuencia para desplegar los recursos
@pytest.fixture(scope="module", autouse=True)
def terraform_output():
    tf = tftest.TerraformTest(FIXTURES_DIR)
    tf.setup(workspace_name="test")
    tf.apply(tf_var_file="test-vars.tfvars")
    yield tf.output()
    tf.destroy(tf_var_file="test-vars.tfvars",auto_approve=True)

# Verifica que el clúster de EKS se haya creado correctamente
def test_eks_cluster_creation(terraform_output):
    #Verifica que el ARN del clúster no esté vacío y que el nombre se haya creado en el formato correcto
    assert terraform_output['cluster_arn'] is not None
    assert terraform_output['cluster_name'] == "bcpl-eks-test-apificacion"

    # Obtiene el nombre del clúster
    eks_cluster_name = terraform_output['cluster_name']

    # Crea una instancia de cliente de EKS
    eks_client = boto3.client("eks", region_name=AWS_REGION)

    # Obtiene información sobre el clúster de EKS
    cluster_info = eks_client.describe_cluster(name=eks_cluster_name)

    # Verifica que el estado del clúster sea "ACTIVE"
    assert cluster_info["cluster"]["status"] == "ACTIVE"

# Verifica que el grupo de nodos de kubernetes se hayan creado correctamente
def test_node_group_creation(terraform_output):
    # Verifica que los nombres de los grupos de nodosn no estén vacíos
    assert terraform_output['node_names'] is not None

    # Obtiene el nombre del clúster
    cluster_name = terraform_output['cluster_name']

    # Actualiza el kubeconfig
    update_kubeconfig_cmd = f"aws eks update-kubeconfig --name {cluster_name} --region {AWS_REGION}"
    subprocess.run(update_kubeconfig_cmd, shell=True, check=True)

    # Ejecuta el comando kubectl para obtener el estado de los nodos
    cmd = f"kubectl get nodes | grep Ready"
    result = subprocess.run(cmd, shell=True, text=True, capture_output=True)

    # Verifica que al menos un nodo esté en estado "Ready"
    assert "Ready" in result.stdout, f"Ningún nodo en estado Ready. Salida de kubectl:\n{result.stdout}"

# Verifica que el controlador de balanceador de carga se haya creado correctamente
def test_load_balancer_controller_creation(terraform_output):
    #Verifica que el ARN del rol del load balancer controller no esté vacío
    assert terraform_output['aws_load_balancer_controller_role_arn'] is not None

    # Declara el nombre del Deployment
    deployment_name = "aws-load-balancer-controller"

    # Ejecuta el comando kubectl para obtener el estado del Deployment
    cmd = f"kubectl get deployment -n kube-system {deployment_name}"
    result = subprocess.run(cmd, shell=True, text=True, capture_output=True)

    # Verifica que el estado del Deployment sea "2/2" en la columna READY
    assert "2/2" in result.stdout, f"El Deployment {deployment_name} no está activo. Salida de kubectl:\n{result.stdout}"
