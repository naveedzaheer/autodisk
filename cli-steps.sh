# Please provide your subscription id here
export APP_SUBSCRIPTION_ID=XXXXXXXXXXXXXX
# Please provide your unique prefix to make sure that your resources are unique
export APP_PREFIX=nzwineast21
# Please provide your region
export LOCATION=EastUS2

# Set script variables
export APP_DEMO_RG=$APP_PREFIX"-sched-rg"
export DEMO_FUNC_PLAN=$APP_PREFIX"-sched-func-plan"
export DEMO_FUNC_NAME=$APP_PREFIX"-sched-func"
export DEMO_LOGIC_APP=$APP_PREFIX"-sched-logic-app"
export DEMO_VM_NAME=$APP_PREFIX"-sched-vm"
export DEMO_DISK_NAME=$APP_PREFIX"-sched-disk"
export DEMO_APP_STORAGE_ACCT=$APP_PREFIX"appsstore"

# Create Resource Group
az group create -l $LOCATION -n $APP_DEMO_RG

az vm create -n $DEMO_VM_NAME -g $APP_DEMO_RG --location $LOCATION --image UbuntuLTS --ultra-ssd-enabled --size Standard_D2s_v3 --zone 1

az vm disk attach --new --resource-group $APP_DEMO_RG --size-gb 128 --sku UltraSSD_LRS --vm-name $DEMO_VM_NAME --name $DEMO_DISK_NAME

az storage account create --name $DEMO_APP_STORAGE_ACCT --location $LOCATION -g $APP_DEMO_RG --sku Standard_LRS

az functionapp create --name $DEMO_FUNC_NAME --consumption-plan-location $LOCATION --storage-account $DEMO_APP_STORAGE_ACCT \
  --resource-group $APP_DEMO_RG --runtime powershell --functions-version 3

az functionapp identity assign -g $APP_DEMO_RG -n $DEMO_FUNC_NAME

# Capture identity from output
APP_MSI=$(az webapp show --name $DEMO_FUNC_NAME -g $APP_DEMO_RG --query identity.principalId -o tsv)

az role assignment create --assignee $APP_MSI --role "Contributor" -g $APP_DEMO_RG

az functionapp app up --app-name $DEMO_FUNC_NAME

az logic workflow create --resource-group $APP_DEMO_RG --location $LOCATION --name $DEMO_LOGIC_APP --definition "Scheduler.json"

 