#!/usr/bin/env zsh
set -e

# Logging mechanism for debugging
LOG_FILE="/tmp/node-env-install.log"
log_debug() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [DEBUG] $*" >> "$LOG_FILE"
}

# Initialize logging
log_debug "=== NODE-ENV INSTALL STARTED ==="
log_debug "Script path: $0"
log_debug "PWD: $(pwd)"
log_debug "Environment: USER=$USER HOME=$HOME"

# Node.js Environment Fragment - Detects official DevContainer Node feature installation
echo "Creating Node.js environment fragment..."

# Get username from environment or default to babaji
USERNAME=${USERNAME:-"babaji"}
USER_HOME="/home/${USERNAME}"

# 🧩 Create Self-Healing Environment Fragment
create_environment_fragment() {
    local feature_name="node-env"
    local fragment_file_skel="/etc/skel/.ohmyzsh_source_load_scripts/.${feature_name}.zshrc"
    local fragment_file_user="$USER_HOME/.ohmyzsh_source_load_scripts/.${feature_name}.zshrc"
    
    # Create fragment content with self-healing detection
    local fragment_content='# 🟢 Node.js Environment Fragment
# Self-healing detection and environment setup for official DevContainer Node feature

# Check if Node.js is available
node_available=false

# Check for Node.js in common DevContainer locations
for node_path in "/usr/local/share/nvm/current/bin" "/usr/local/bin" "/usr/bin" "$HOME/.nvm/current/bin"; do
    if [ -d "$node_path" ] && [ -x "$node_path/node" ]; then
        if [[ ":$PATH:" != *":$node_path:"* ]]; then
            export PATH="$node_path:$PATH"
        fi
        node_available=true
        break
    fi
done

# Check if Node.js is now available
if command -v node >/dev/null 2>&1; then
    node_available=true
    
    # Set NODE_PATH for global modules
    if command -v npm >/dev/null 2>&1; then
        NPM_GLOBAL_PATH="$(npm config get prefix 2>/dev/null)/lib/node_modules"
        if [ -d "$NPM_GLOBAL_PATH" ]; then
            export NODE_PATH="$NPM_GLOBAL_PATH"
        fi
        
        # Add npm global bin to PATH
        NPM_BIN_PATH="$(npm config get prefix 2>/dev/null)/bin"
        if [ -d "$NPM_BIN_PATH" ] && [[ ":$PATH:" != *":$NPM_BIN_PATH:"* ]]; then
            export PATH="$NPM_BIN_PATH:$PATH"
        fi
    fi
    
    # Check for NVM integration
    if [ -d "/usr/local/share/nvm" ]; then
        export NVM_DIR="/usr/local/share/nvm"
        if [ -s "$NVM_DIR/nvm.sh" ]; then
            source "$NVM_DIR/nvm.sh"
        fi
    elif [ -d "$HOME/.nvm" ]; then
        export NVM_DIR="$HOME/.nvm"
        if [ -s "$NVM_DIR/nvm.sh" ]; then
            source "$NVM_DIR/nvm.sh"
        fi
    fi
fi

# If Node.js is not available, cleanup this fragment
if [ "$node_available" = false ]; then
    echo "Node.js removed, cleaning up environment"
    rm -f "$HOME/.ohmyzsh_source_load_scripts/.node-env.zshrc"
fi'

    # Create fragment for /etc/skel
    if [ -d "/etc/skel/.ohmyzsh_source_load_scripts" ]; then
        echo "$fragment_content" > "$fragment_file_skel"
    fi

    # Create fragment for existing user
    if [ -d "$USER_HOME/.ohmyzsh_source_load_scripts" ]; then
        echo "$fragment_content" > "$fragment_file_user"
        if [ "$USER" != "$USERNAME" ]; then
            chown ${USERNAME}:${USERNAME} "$fragment_file_user" 2>/dev/null || chown ${USERNAME}:users "$fragment_file_user" 2>/dev/null || true
        fi
    elif [ -d "$USER_HOME" ]; then
        # Create the directory if it doesn't exist
        mkdir -p "$USER_HOME/.ohmyzsh_source_load_scripts"
        echo "$fragment_content" > "$fragment_file_user"
        if [ "$USER" != "$USERNAME" ]; then
            chown -R ${USERNAME}:${USERNAME} "$USER_HOME/.ohmyzsh_source_load_scripts" 2>/dev/null || chown -R ${USERNAME}:users "$USER_HOME/.ohmyzsh_source_load_scripts" 2>/dev/null || true
        fi
    fi
    
    echo "Self-healing environment fragment created: .node-env.zshrc"
}

# Call the fragment creation function
create_environment_fragment

echo "Node.js environment fragment installation completed."

log_debug "=== NODE-ENV INSTALL COMPLETED ==="
# Auto-trigger build Tue Sep 23 20:03:18 BST 2025
# Auto-trigger build Sun Sep 28 03:45:27 BST 2025
