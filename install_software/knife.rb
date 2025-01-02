current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "wasimcg" ## This name must much the user name on chef io
client_key               "C:/Users/vmadmin/Desktop/chef/install_software/.chef/wasimcg.pem"  ## you need to grab the pem file from chef io zip file
chef_server_url          "https://api.chef.io/organizations/cheforgcg"
cookbook_path            "C:/Users/vmadmin/Desktop/chef"    ## point this tor your local cookbook folder full path