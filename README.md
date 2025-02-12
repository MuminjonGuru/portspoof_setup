# SSH Security Hardening & Portspoof Setup Script

## Overview
This script enhances SSH security by changing the default SSH port and disabling password authentication. It also installs and configures **Portspoof**, a tool designed to mislead and slow down attackers scanning for open ports. Additionally, the script sets up **iptables** rules to log, redirect, and manage incoming traffic.

## Features
- **Secures SSH:**
  - Changes SSH to listen on **port 2222** instead of the default **22**.
  - Disables **password authentication**, enforcing key-based authentication.
- **Installs and Configures Portspoof:**
  - Clones, compiles, and installs **Portspoof**.
  - Creates a dedicated user for **Portspoof**.
- **Configures Firewall Rules (iptables):**
  - Logs connection attempts to ports other than SSH.
  - Redirects all non-SSH TCP traffic to **port 4444** for Portspoof.
  - Logs port scanning attempts to **detect potential attackers**.

## Prerequisites
- A Linux-based system (Debian/Ubuntu recommended)
- Root or sudo privileges
- Git and build tools installed (if not, the script installs them automatically)

## Usage
1. **Download or create the script file:**
   ```bash
   nano ssh_security.sh
   ```
   Paste the script into the file and save it.

2. **Make the script executable:**
   ```bash
   chmod +x ssh_security.sh
   ```

3. **Run the script with sudo:**
   ```bash
   sudo ./ssh_security.sh
   ```

4. **Verify SSH changes:**
   - Check that SSH is now listening on port 2222:
     ```bash
     sudo netstat -tulnp | grep ssh
     ```
   - Ensure password authentication is disabled:
     ```bash
     sudo grep PasswordAuthentication /etc/ssh/sshd_config
     ```

5. **Check iptables rules:**
   ```bash
   sudo iptables -t nat -L
   sudo iptables -L
   ```

## Uninstallation
To revert changes manually:
1. **Restore SSH settings:**
   - Edit the SSH configuration file:
     ```bash
     sudo nano /etc/ssh/sshd_config
     ```
   - Set `Port 22` and `PasswordAuthentication yes`.
   - Restart SSH:
     ```bash
     sudo systemctl restart ssh
     ```

2. **Remove iptables rules:**
   ```bash
   sudo iptables -t nat -F
   sudo iptables -F
   ```

3. **Remove Portspoof:**
   ```bash
   sudo rm -rf /home/portspoof
   sudo deluser portspoof
   ```

## Notes
- Ensure you configure your **firewall rules** to allow connections on port **2222** after running this script.
- If using **Fail2Ban**, update its configuration to monitor **port 2222** instead of **22**.
- If SSH is inaccessible, revert settings manually by booting into **recovery mode** and editing `/etc/ssh/sshd_config`.

Enjoy enhanced security and protection against port scanning attacks! 🚀
