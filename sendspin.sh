#!/bin/bash
sudo apt-get update
sudo apt-get install -y golang libopus-dev libopusfile-dev libasound2-dev
go install github.com/Sendspin/sendspin-go@latest

# Configuration
SERVICE_NAME="sendspin"
BINARY_PATH="$HOME/go/bin/sendspin-go"
USER_NAME=$(whoami)
GROUP_NAME=$(id -gn)

echo "--- Setting up $SERVICE_NAME as a systemd service ---"

# 1. Check if binary exists
if [ ! -f "$BINARY_PATH" ]; then
    echo "Error: Binary not found at $BINARY_PATH"
    echo "Please run 'go install github.com/Sendspin/sendspin-go@latest' first."
    exit 1
fi

# 2. Create the service file using a 'Here Document'
# We use sudo tee to write to a protected directory
sudo tee /etc/systemd/system/$SERVICE_NAME.service > /dev/null <<EOF
[Unit]
Description=Sendspin Go Service
After=network.target sound.target

[Service]
User=$USER_NAME
Group=$GROUP_NAME
ExecStart=$BINARY_PATH
Restart=always
RestartSec=5
SupplementaryGroups=audio
WorkingDirectory=$HOME

[Install]
WantedBy=multi-user.target
EOF

echo "--- Service file created at /etc/systemd/system/$SERVICE_NAME.service ---"

# 3. Reload, Enable, and Start
echo "--- Initialising systemd service ---"
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME.service
sudo systemctl restart $SERVICE_NAME.service

# 4. Show status
echo "--- Setup Complete! Checking status: ---"
sleep 2
sudo systemctl status $SERVICE_NAME --no-pager
