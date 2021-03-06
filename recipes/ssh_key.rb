include_recipe "ak-odoo-chef-base::default"

#Unless ssh is already set up (possibly because of the virtualization host machine), generates ssh keys for the user dev and prod and super user and also add ssh authorized key

[:dev].each do |user| #FIXME [:super_user, :prod, :dev] ?

  unix_user = node[:openerp][user][:unix_user]

  execute "ssh-keygen -f /home/#{unix_user}/.ssh/id_rsa -N ''" do
    creates "/home/#{unix_user}/.ssh/id_rsa"
    user unix_user
    not_if {::File.exist?("/home/#{unix_user}/.ssh/id_rsa")}
  end

  template "/home/#{unix_user}/.ssh/authorized_keys" do
    #action "create_if_missing" #FIX me
    action "create" #check if this code is executed only if the node info have been modified
    owner unix_user
    group node[:openerp][:group_unix]
    mode 00600
    source "authorized_keys.erb"
    not_if {unix_user == 'vagrant'}
    variables :ssh_key_list => "#{node[:openerp][user][:authorized_ssh_key]}\n#{node[:openerp][user][:extra_authorized_ssh_key]}"
  end

end
