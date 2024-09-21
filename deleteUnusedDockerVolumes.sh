#!/bin/bash

for volume in $(docker volume ls --format "{{.Name}}"); do
    containers=$(docker ps -a --filter volume=$volume --format '{{.Names}}' | tr '\n' ',')
    echo "Volume $volume is used by $containers"

    # Check if the volume is used by any running or stopped containers
    if [[ "$containers" != "" ]]; then
        echo "Volume $volume is still in use. Skipping removal."
    else
        # Check if the volume is used by any exited containers
        exited_containers=$(docker ps -a --filter volume=$volume --filter status=exited --format '{{.Names}}' | tr '\n' ',')
        if [[ "$exited_containers" != "" ]]; then
            echo "Volume $volume is used by exited containers: $exited_containers"
            # Prompt the user for confirmation before removing the volume
            read -p "Do you want to remove volume $volume? (y/n): " response
            if [[ "$response" == "y" || "$response" == "yes" ]]; then
                sudo docker volume rm $volume
                echo "Volume $volume removed successfully."
            else
                echo "Volume $volume removal canceled."
            fi
        else
            # If the volume is not used by any containers, prompt for confirmation
            echo "Volume $volume is not used by any containers. Do you want to remove it? (y/n): "
            read -p "> " response
            if [[ "$response" == "y" || "$response" == "yes" ]]; then
                sudo docker volume rm $volume
                echo "Volume $volume removed successfully."
            else
                echo "Volume $volume removal canceled."
            fi
        fi
    fi
done