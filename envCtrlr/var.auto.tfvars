name = "om-tt"

nsr_in_winrm_name= "allow_in_winrm"

nsr_in_rdp_name ="allow_in_rdp"

vmpassword ="pastslslwWPSW"

vm_size = "Standard_F4s_v2"

image_publisher = "MicrosoftWindowsServer"

image_offer = "WindowsServer"

image_sku = "2012-R2-Datacenter"

image_version = "latest"

ip_manager = "181.143.142.66"

/*
bpm_vhd = "https://vhdrnf.blob.core.windows.net/vhdtemplate/bizagi_products.vhd"
sql_vhd = "https://vhdrnf.blob.core.windows.net/vhdtemplate/sql.vhd"
cli_vhd = "https://vhdrnf.blob.core.windows.net/vhdtemplate/cli.vhd"
sch_vhd = "https://vhdrnf.blob.core.windows.net/vhdtemplate/bizagi_products.vhd"
*/
bpm_vhd = "https://qadevopsstorage.blob.core.windows.net/vhdtemplate/bizagi_products.vhd"
sql_vhd = "https://qadevopsstorage.blob.core.windows.net/vhdtemplate/sql2014.vhd"
cli_vhd = "https://qadevopsstorage.blob.core.windows.net/vhdtemplate/cli.vhd"
sch_vhd = "https://qadevopsstorage.blob.core.windows.net/vhdtemplate/bizagi_products.vhd"

storage_name ="qadevopsstorage"

#storage_name ="vhdrnf"

credential = {
  subscription_id = "8b9b5c7d-24dc-4898-9b0d-00f755bd2317"
  client_id       = "bed3aa9c-65c2-4283-bec3-5cf82a937408"
  client_secret   = "RnfTerraformPsw"
  tenant_id       = "7ea17f8a-dbcb-48fd-90ad-d1a0493f49d8"
}

/*
credential = {
  subscription_id = "12a9a933-9df5-4872-8e4a-de9511c7f107"
  client_id       = "792e7ac3-e4ac-440a-b46b-a15010eafbad"
  client_secret   = "B1z4g1"
  tenant_id       = "7ea17f8a-dbcb-48fd-90ad-d1a0493f49d8"
}
*/

dnsdb = "Persist Security Info=True;User ID=sa;Password=B1z4g1;Data Source=RNF-FILE-SQL-1;Initial Catalog=RNF;"

domainName = "my-env"