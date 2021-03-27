#!/bin/bash
RAILS_ENV=production bundle exec rake assets:clean assets:precompile
sudo rm -r /var/www/html/route_guides/*
sudo cp -r /home/mbriggs/rails_projects/route_guides/* /var/www/html/route_guides/
sudo chmod a+rw /var/www/html/route_guides/log/*
sudo service apache2 restart
sudo /etc/rc.local
