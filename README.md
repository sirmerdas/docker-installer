# Docker Installer Script

## Overview
This script automates the process of installing Docker on an Ubuntu-based system, updating system packages, and configuring DNS settings if necessary. It also provides an option to switch to a registry mirror for users in restricted countries.

## Features
- Checks system requirements before installation
- Updates system packages
- Installs Docker and necessary dependencies
- Configures a custom DNS if required
- Supports ArvanCloud registry mirror for restricted countries
- Restores original DNS settings after installation (if changed)

## Usage
### Running the Script
To execute the script, open a terminal and run:
```bash
bash script.sh
```
You may need to grant execution permission first:
```bash
chmod +x script.sh
```

### Features Explained
#### System Requirements Check
The script verifies that the system supports the installation process before proceeding.

#### DNS Configuration
If the script is being run in a restricted country, it allows the user to set custom DNS servers for accessibility.

#### Docker Installation
The script installs Docker and its dependencies from the official Docker repository.

#### Registry Mirror Option
Users can choose to configure ArvanCloud as a Docker registry mirror for better access in restricted countries.

## Notes
- The script requires **sudo** privileges to execute certain commands.
- It automatically restores the original DNS configuration after execution if it was modified.
- Ensure your system is connected to the internet before running the script.

## Disclaimer
> [!CAUTION]
> This script modifies system configurations, including DNS settings. Use with caution and at your own risk. Take backup of /etc/resolv.conf file before executing ```installer.sh```