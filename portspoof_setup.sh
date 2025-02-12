#!/bin/bash

# Set variables
REAL_SSH_PORT=2222
SSH_CONFIG_FILE="/etc/ssh/sshd_config"

# Update SSH to listen on a new port
echo "Updating SSH configuration to listen on port $REAL_SSH_PORT..."
if grep -q "^#Port" "$SSH_CONFIG_FILE"; then
    # If the 'Port' directive is commented out in sshd_config, uncomment it and set the new port
    sed -i "s/^#Port.*/Port $REAL_SSH_PORT/" "$SSH_CONFIG_FILE"
else
    # If 'Port' is not commented out, add or replace the existing line with the new port
    echo "Port $REAL_SSH_PORT" >> "$SSH_CONFIG_FILE"
fi

# Disable password-based authentication to enforce key-based authentication
if grep -q "^#PasswordAuthentication" "$SSH_CONFIG_FILE"; then
    # If 'PasswordAuthentication' is commented out, uncomment it and disable it
    sed -i "s/^#PasswordAuthentication.*/PasswordAuthentication no/" "$SSH_CONFIG_FILE"
elif grep -q "^PasswordAuthentication" "$SSH_CONFIG_FILE"; then
    # If 'PasswordAuthentication' is already present, replace its value with 'no'
    sed -i "s/^PasswordAuthentication.*/PasswordAuthentication no/" "$SSH_CONFIG_FILE"
else
    # If 'PasswordAuthentication' is missing, add it to the config file
    echo "PasswordAuthentication no" >> "$SSH_CONFIG_FILE"
fi

# Apply changes by restarting SSH services
systemctl daemon-reload  # Reload systemd manager configuration
systemctl restart ssh.socket  # Restart the SSH socket service
systemctl restart ssh  # Restart the main SSH service

# Install Portspoof (a tool to deceive and mislead port scanners)
sudo apt install -y build-essential  # Ensure required dependencies are installed
sudo adduser portspoof  # Create a new user named 'portspoof'
cd /home/portspoof  # Navigate to the new user's home directory
git clone https://github.com/drk1wi/portspoof.git  # Clone the Portspoof repository
cd portspoof  # Change to the cloned repository directory
./configure; make; make install  # Build and install Portspoof


# Set up iptables rules to log and redirect suspicious traffic

# Log all incoming connection attempts except the real SSH port (2222)
sudo iptables -t nat -A PREROUTING -p tcp -m multiport ! --dports 2222 -j LOG --log-prefix "Pre-redirect scan attempt: "

# Redirect all TCP traffic (except SSH on port 2222) to port 4444, where Portspoof will handle fake responses
sudo iptables -t nat -A PREROUTING -p tcp -m multiport ! --dports 2222 -j REDIRECT --to-port 4444

# Log any remaining incoming TCP connections (port scan attempts) with a limit of 10 per minute
sudo iptables -A INPUT -p tcp --dport 1:65535 -m limit --limit 10/min -j LOG --log-prefix "Port scan attempt: "

# Switch to the Portspoof user to run the service securely
chown -R portspoof: /home/portspoof/portspoof/  # Change ownership of the Portspoof directory
su - portspoof  # Switch to the Portspoof user session
