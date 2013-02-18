# port numbers that you wish to open up on your environment 
ports = [8080]

# open ports via fog
ruby_block "open up ports via EC2 security groups" do
  block do
    # require fog gem (version 0.7.2)
    require 'fog'
      
    # build endpoint (fixes issue with fog 0.7.2 not knowing about newer regions)
    region = node['engineyard']['environment']['region']
    endpoint = "https://ec2.#{region}.amazonaws.com:443/"

    # connect to EC2 via fog
    ec2 = Fog::Compute.new({
      :provider => 'AWS',
      :aws_access_key_id => node['aws_secret_id'],
      :aws_secret_access_key => node['aws_secret_key'],
      :endpoint => endpoint
    })
    
    # find security group for environment
    env_name = node['engineyard']['environment']['name']
    security_group = ec2.security_groups.all.find{|g| g.name[/\Aey-#{env_name}-\d+/]}
    
    # get ports that are already open
    permissions = security_group.ip_permissions.select{|p| p['groups'].empty?}
    open_ports = permissions.map{|p| (p['fromPort'].to_i..p['toPort'].to_i).to_a}.flatten
    
    # authorize port if not already authorized
    ports.each do |port|
      if open_ports.include?(port)
        Chef::Log.info "Port #{port} is already open (open ports: #{open_ports.join(', ')})"
      else
        Chef::Log.info "Opening port #{port} to the outside world"
        security_group.authorize_port_range(port..port)
      end
    end
  end
end