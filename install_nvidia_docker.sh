#!/bin/bash

echo "====================================================="
echo " Installing NVIDIA Container Toolkit for Docker"
echo "====================================================="

# 1. Add the package repositories
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# 2. Update package list and install
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# 3. Configure Docker
sudo nvidia-ctk runtime configure --runtime=docker

# 4. Restart Docker daemon
sudo systemctl restart docker

echo "====================================================="
echo " Installation Complete!"
echo " You should now be able to run: ./run.sh --gpu"
echo "====================================================="
