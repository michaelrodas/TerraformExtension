name = "rnf-tf"

vmpassword ="rnftfctrlr1Psw"

vm_size = "Standard_F4s_v2"

image_publisher = "MicrosoftWindowsServer"

image_offer = "WindowsServer"

image_sku = "2012-R2-Datacenter"

image_version = "latest"

ip_manager = "181.143.142.66"

bpm_vhd = "https://qadevopsstorage.blob.core.windows.net/vhdtemplate/bizagi_products.vhd"
sql_vhd = "https://qadevopsstorage.blob.core.windows.net/vhdtemplate/sql.vhd"
cli_vhd = "https://qadevopsstorage.blob.core.windows.net/vhdtemplate/cli.vhd"
mf_vhd = "https://qadevopsstorage.blob.core.windows.net/vhdtemplate/mf.vhd"

storage_name ="qadevopsstorage"

nsr_in_winrm_name = "allow_in_winrm"
nsr_in_rdp_name = "allow_in_rdp"

credential = {
  subscription_id = "8b9b5c7d-24dc-4898-9b0d-00f755bd2317"
  client_id       = "bed3aa9c-65c2-4283-bec3-5cf82a937408"
  client_secret   = "RnfTerraformPsw"
  tenant_id       = "7ea17f8a-dbcb-48fd-90ad-d1a0493f49d8"
}

#dnsdb = "dnsdb"
dnsdb = "Persist Security Info=True;User ID=sa;Password=B1z4g1;Data Source=RNF-FILE-SQL-1;Initial Catalog=RNF;"
domainName = "my-env"