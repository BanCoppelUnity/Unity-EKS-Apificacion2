# Configuración Terraform para el despliegue del módulo de EKS

Esta configuración de Terraform se encarga de crear y desplegar clústeres de EKS, Nodos de Kubernetes con autoescalamiento, y el Load Balancer correspondiente en AWS.

## Características

- Configura el proveedor AWS y establece el backend de estado remoto de Terraform en un bucket S3. 

- Gestiona los recursos de EKS, KNodes y Load Balancer en un solo módulo.

- Permite crear clústeres de EKS asignados a la VPC y subnets correspondientes.

- Permite crear diferentes nodos de Kubernetes dentro de los clústeres de EKS, y elegir los criterios para el autoescalamiento mediante las variables  `asg_desired_capacity`, `asg_max_size`, `asg_min_size` y el tipo de instancia `instance_type `.

- Permite crear un Balanceador de carga para tráfico de red, permitiendo crear health checks para los nodos de Kubernetes.

- Permite asignar las etiquetas especificadas en `tags` a todos los recursos generados, incluyendo la etiqueta `Name` implementando una convención de nombrado estándarizado para los recursos creados generada según el tipo de recurso.

## Uso

Para la ejecución de la configuración deben seguirse los siguientes puntos:

- Debe de crearse un archivo `.tfvars` donde se definan los valores de las variables utilizadas por la configuración. 

- Se debe de especificar la configuración del backend dentro del archivo `backend.tf`, esta configuración debe de coincidir con un bucket de S3 existente al que la cuenta de AWS que se defina para la configuración tenga permisos de acceder.

```hcl
# Se especifica el backend para el estado de Terraform, en este caso un bucket S3.
terraform {
  backend "s3" {
    bucket               = "<nombre del bucket>"
    key                  = "<ruta del archivo .tfstate>"
    workspace_key_prefix = "<prefijo del workspace>"
    region               = "<región en la que se encuentra el bucket>"
  }
}
```

- De igual forma, deben de colocarse en la rutas adecuadas de los módulos de los que depende la configuración o en su defecto modificar las rutas de los mismos en el archivo `main.tf`.

- Deben de definirse las credeciales de la cuenta de AWS para poder desplegar los recursos y acceder al backend en donde se almacenará el archivo del estado de terraform `.tfstate`.

Una vez se completa con lo anterior, se ejecuta el comando para inicializar el provedor y la configuración del backend.

```bash
$ terraform init
```

Después se selecciona el workspace de Terraform en el cual se esté trabajando.

```bash
$ terraform workspace select nombre_del_workspace
```

En caso de que no exista el workspace seleccionado, se debe crear con  el siguiente comando.

```bash
$ terraform workspace new nombre_del_workspace
```

Posteriormente, se ejecuta el plan y se verifica el mismo, para asegurar la creación de la configuración deseada para cada uno de los recursos.

```bash
$ terraform plan -var-file="<archivo de los valores de la configuración>"
```

Si la información proporcionada por el plan es correcta, se aplica y acepta para la creación de los recursos.

```bash
$ terraform apply -var-file="<archivo de los valores de la configuración>"
```

## Variables de entrada

La configuración tiene las siguientes variables de entrada:

- `aws_region` - Región en la que se desplegarán los recursos AWS.

- `bucket` - Nombre del Bucket de S3 donde está almacenado el terraform state de Networking.

- `bucket_region` - Región de AWS del Bucket de S3 donde está el terraform state de Networking.

- `key` - Llave del bucket S3 donde está el terraform state de Networking.

- `workspace_key_prefix` - Prefijo del espacio de trabajo para la Llave del bucket S3 donde está el terraform state de Networking.

- `cluster_name` - Nombre único del clúster relacionado a la iniciativa

- `environment` - Ambiente en el que se desplegará la infraestructura, por ejemplo, prod, dev, qa.

- `eks_version` - La versión de EKS a utilizar para el clúster y los worker nodes

- `asg_desired_capacity` - El número de instancias de Amazon EC2 que deberían estar funcionando en el grupo de autoescalamiento.

- `asg_max_size` - El número máximo de instancias de Amazon EC2 en el grupo de autoescalamiento.

- `asg_min_size` - El número mínimo de instancias de Amazon EC2 en el grupo de autoescalamiento.

- `instance_type` - Tipo de instancia EC2 para el grupo de autoescalamiento.

- `usuarios_auth` - Lista de usuarios autorizados en el configmap de EKS para conexión.

- `cuentas_aws_auth` - Lista de cuentas autorizados en el configmap de EKS para conexión.


## Variables de salida

La configuración tiene las siguientes variables de salida:

- `cluster_arn` - El ARN de los clústeres de EKS. 

- `cluster_endpoint` - Los endpoints de los clústeres de EKS. 

- `cluster_name` - El nombre del clúster de EKS. 

- `cluster_ca_certificate` - El certificado CA del clúster de EKS. 

- `node_names` - El nombre de los nodos gestionados de Kubernetes".

- `eks_role_config_map_arn` - El ARN del rol del config map.

- `aws_load_balancer_controller_role_arn` - El El ARN del rol del AWS Load Balancer Controller.

## Recursos creados

Esta configuración despliega los siguientes recursos en AWS:

- Clúster de EKS.

- Grupos de nodos gestionados de Kubernetes.

- Roles de IAM

- Políticas de IAM

- Acoplamientos entre roles y políticas

- Perfil de instancia para los nodos

- Open ID Connect Provider

- Launch template

- Helm release

- Kubernetes config map

- Kubernetes config map v1

## Dependencias

- Requiere del proveedor aws, la versión recomendada es la ~> 5.0.

- Requiere que exista un bucket S3 donde se almacena el estado de Terraform de Networking, el cual contiene los valores de las variables `vpc_id`,`subnets_id` y `security_groups_id`. En el bucket mencionado, también se almacenará el estado de Terraform que genera este módulo de despliegue.

- Requiere que los recursos del módulo 'Unity-Networking-Apificacion-deploy' esté correctamente desplegados y que las subredes tengan salida a internet.

- Esta configuración depende del módulo de 'Unity-eks-module'.

## Pruebas

Este módulo incorpora pruebas unitarias desarrolladas con `tftest` y `pytest`, las cuales son liberias de `python`. Las pruebas se encuentran en el directorio `test`. Para su ejecución, deben seguirse los siguientes pasos:

1. Se debe de navegar hasta el directorio `test` dentro del repositorio.
    ```bash
    cd test
2. Asegurarse de tener`python` instalado en la máquina donde se llevarán a cabo las pruebas, además de instalar ambas liberias.
    ```python
      # tftest
      pip install tftest

      # pytest
      pip install pytest

      #boto3
      pip install boto3
    ```
4. Se debe de ejecutar el siguiente comando para ejecutar las pruebas:
    ```bash
    pytest
    ```
    #### Nota
    Deben configurarse las credenciales de AWS correspondientes como variables de entorno, ya que la prueba implica la creación de infraestructura real en una cuenta de AWS, lo cual podría incurrir en cargos.

Para más información sobre la configuración y modificación de las pruebas, consultar [terraform-python-testing-helper](https://github.com/GoogleCloudPlatform/terraform-python-testing-helper).

## Configuración del Pre-Commit Hook

Este proyecto utiliza un pre-commit hook para asegurar que los archivos de Terraform estén correctamente formateados y validados antes de cada commit. Para configurar este hook en su sistema, siga los siguientes pasos:

1. Asegúrese de tener Terraform instalado en su máquina, ya que el script utiliza `terraform fmt` y `terraform validate`.

2. Navegue hasta el directorio `.git/hooks` dentro del repositorio.

3. Copie el archivo `pre-commit` del directorio `hooks` a `.git/hooks`:
   ```bash
   copy hooks\pre-commit .git\hooks\pre-commit

Cuando realice un commit, el pre-commit hook verificará automáticamente los archivos de Terraform en espera de commit, los formateará con `terraform fmt`, y los validará con `terraform validate`. Si alguna de estas verificaciones falla, el commit se detendrá, permitiéndole corregir los errores antes de continuar.

