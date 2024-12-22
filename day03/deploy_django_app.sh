#!/bin/bash

<< Task
Deploy a Django app and handle the code for errors
Task

code_clone(){
        echo "Cloning the Django app...."
        git clone https://github.com/LondheShubham153/django-notes-app.git
}

install_requirements(){
        echo "Installing Dependencies...."
        sudo apt-get install docker.io nginx docker-compose -y
}

required_restarts(){
        sudo chown $USER /var/run/docker.sock
        #sudo systemctl enable docker
        #sudo systemctl enable nginx
        #sudo systemctl restart docker
}

# Check if port 80 is already in use, and if so, free it or change port mapping in docker-compose
check_port(){
        if sudo lsof -i :80; then
                echo "Port 80 is already in use. Changing NGINX port mapping to 8080."
                sed -i 's/80:80/8080:80/' docker-compose.yml
        fi
}

# Clean up Docker resources
clean_docker(){
        docker system prune -f
}

deploy(){
        docker build -t notes-app .
        # Stop and remove any running containers before starting fresh
        docker-compose down
        docker-compose up -d
}

echo "**************** DEPLOYMENT STARTED ****************"

if ! code_clone; then
        echo "The Code Directory Already Exists !"
        cd django-notes-app
fi

if ! install_requirements; then
        echo "Installation Failed !"
        exit 1
fi

if ! required_restarts; then
        echo "System Fault Identified"
        exit 1
fi

# Check if port 80 is in use and modify if necessary
check_port

# Clean up Docker containers, networks, and volumes
clean_docker

if ! deploy; then
        echo "Deployment Failed, mailing the admin"
        #sendmail
        exit 1
fi

echo "**************** DEPLOYMENT DONE *******************"

