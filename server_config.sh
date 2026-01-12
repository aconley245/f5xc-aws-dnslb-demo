#!/bin/bash
sudo apt update -y
sudo apt install nginx -y
# Modify the default Nginx configuration file
cat <<EOF | sudo tee /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        # Return a simple message with the client IP address in a header
        default_type text/plain;
        add_header X-Client-IP \$remote_addr;
        return 200 "Your client IP address is \$remote_addr\n
        \n
        Info:
		Server Address:\t\t\t \$server_addr:\$server_port
		Host Header:\t\t\t \$host
		Request URI:\t\t\t \$request_uri
		Served by NGINX \$nginx_version\n";
    }
}
EOF
# Restart Nginx to apply changes
sudo systemctl restart nginx