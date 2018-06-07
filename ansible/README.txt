Installation:

1) Generate your self signed certificate:
   openssl req -newkey rsa:4096 -nodes -sha512 -x509 -days 3650 -nodes -out roles/webservers/tasks/files/wildcard.crt -keyout roles/webservers/tasks/files/wildcard.key
2) edit inventory.yaml 
  all:
    vars:
      enable_ssl: true                         # Disable SSL or enable it in this deployment (see limitations and todo)
      db_name: test_db                         # Ansible will use this database name to create the database
      db_table: test_table                     # Ansible will use this table in index.cgi
      db_username: test_user                   # Ansible will use this username to create it in mysql and use it in index.cgi
      db_password: test_password               # Ansible will use this password to create it in mysql and use it in index.cgi
      db_hostname: ssh2.davidchill.ca          # Ansible will use this hostname in index.cgi
      ssl_bind_ip: 158.69.192.170              # Ansible will use this in the virtualhost definition test.conf and is required by SSL (should be your webserver IP)
      domain_name: test.davidchill.ca          # Ansible will use this in the virtualhost definition test.conf
    children:
      webservers:
        hosts:
          ssh1.davidchill.ca:                  # Change this for the hostname or IP of your webserver
      dbservers:
        hosts:
          ssh2.davidchill.ca:                  # This can be the same hostname as the webserver but you can't have more than one database at this time
3) Deploy your environment:
  ansible-playbook -i inventory.yml -s playbook.yml   

Todo:
  - Add some master/slave or master/master mysql replication in order to support multiple database servers

Limitations: 
  - Multiple web servers is only supported by non-SSL deployment and I didn't work this feature 
  - Only one database server is supported at this time

What it does:
  - Set httpd 
  - Set mod_ssl
  - Set a SSL vhost and a non-SSL vhost that redirect to the SSL vhost
  - Make sure selinux is not in our way
  - Enable firewall
  - Install some packages
