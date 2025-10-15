#!/bin/bash
set -e
/usr/local/bin/banner.sh

# Default values
readonly DEFAULT_PUID=1000
readonly DEFAULT_PGID=1000
readonly DEFAULT_PORT=8050
readonly DEFAULT_PROTOCOL="SHTTP"
readonly FIRST_RUN_FILE="/tmp/first_run_complete"

# Perplexity default configuration values
readonly DEFAULT_MODEL="sonar-pro"
readonly DEFAULT_MAX_TOKENS=4096
readonly DEFAULT_TEMPERATURE=0.7
readonly DEFAULT_SEARCH_RECENCY_FILTER="month"

# Function to trim whitespace using parameter expansion
trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    printf '%s' "$var"
}

# Validate positive integers
is_positive_int() {
    [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -gt 0 ]
}

# Validate floating point numbers (for temperature)
is_valid_float() {
    [[ "$1" =~ ^[0-9]+(\.[0-9]+)?$ ]] && [ "$(echo "$1 >= 0" | bc -l 2>/dev/null || echo 0)" -eq 1 ]
}

# Validate directory path
validate_directory() {
    local dir="$1"
    [[ -n "$dir" ]] && [[ "$dir" =~ ^/ ]] && [[ ! "$dir" =~ \.\. ]] && [[ "${#dir}" -le 255 ]]
}

# First run handling
handle_first_run() {
    local uid_gid_changed=0

    # Handle PUID/PGID logic
    if [[ -z "$PUID" && -z "$PGID" ]]; then
        PUID="$DEFAULT_PUID"
        PGID="$DEFAULT_PGID"
        echo "PUID and PGID not set. Using defaults: PUID=$PUID, PGID=$PGID"
    elif [[ -n "$PUID" && -z "$PGID" ]]; then
        if is_positive_int "$PUID"; then
            PGID="$PUID"
        else
            echo "Invalid PUID: '$PUID'. Using default: $DEFAULT_PUID"
            PUID="$DEFAULT_PUID"
            PGID="$DEFAULT_PGID"
        fi
    elif [[ -z "$PUID" && -n "$PGID" ]]; then
        if is_positive_int "$PGID"; then
            PUID="$PGID"
        else
            echo "Invalid PGID: '$PGID'. Using default: $DEFAULT_PGID"
            PUID="$DEFAULT_PUID"
            PGID="$DEFAULT_PGID"
        fi
    else
        if ! is_positive_int "$PUID"; then
            echo "Invalid PUID: '$PUID'. Using default: $DEFAULT_PUID"
            PUID="$DEFAULT_PUID"
        fi
        
        if ! is_positive_int "$PGID"; then
            echo "Invalid PGID: '$PGID'. Using default: $DEFAULT_PGID"
            PGID="$DEFAULT_PGID"
        fi
    fi

    # Check existing UID/GID conflicts
    local current_user current_group
    current_user=$(id -un "$PUID" 2>/dev/null || true)
    current_group=$(getent group "$PGID" | cut -d: -f1 2>/dev/null || true)

    [[ -n "$current_user" && "$current_user" != "node" ]] &&
        echo "Warning: UID $PUID already in use by $current_user - may cause permission issues"

    [[ -n "$current_group" && "$current_group" != "node" ]] &&
        echo "Warning: GID $PGID already in use by $current_group - may cause permission issues"

    # Modify UID/GID if needed
    if [ "$(id -u node)" -ne "$PUID" ]; then
        if usermod -o -u "$PUID" node 2>/dev/null; then
            uid_gid_changed=1
        else
            echo "Error: Failed to change UID to $PUID. Using existing UID $(id -u node)"
            PUID=$(id -u node)
        fi
    fi

    if [ "$(id -g node)" -ne "$PGID" ]; then
        if groupmod -o -g "$PGID" node 2>/dev/null; then
            uid_gid_changed=1
        else
            echo "Error: Failed to change GID to $PGID. Using existing GID $(id -g node)"
            PGID=$(id -g node)
        fi
    fi

    [ "$uid_gid_changed" -eq 1 ] && echo "Updated UID/GID to PUID=$PUID, PGID=$PGID"
    touch "$FIRST_RUN_FILE"
}

# Validate and set PORT
validate_port() {
    # Ensure PORT has a value
    PORT=${PORT:-$DEFAULT_PORT}
    
    # Check if PORT is a positive integer
    if ! is_positive_int "$PORT"; then
        echo "Invalid PORT: '$PORT'. Using default: $DEFAULT_PORT"
        PORT="$DEFAULT_PORT"
    elif [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
        echo "Invalid PORT: '$PORT'. Using default: $DEFAULT_PORT"
        PORT="$DEFAULT_PORT"
    fi
    
    # Check if port is privileged
    if [ "$PORT" -lt 1024 ] && [ "$(id -u)" -ne 0 ]; then
        echo "Warning: Port $PORT is privileged and might require root"
    fi
}

# Build MCP server command with environment variables
build_mcp_server_cmd() {
    # Start with the base command
    MCP_SERVER_CMD="npx -y @perplexity-ai/mcp-server"
    
    # Build environment variable arguments array
    PERPLEXITY_ENV_ARGS=()
    
    # Add PERPLEXITY_API_KEY (required)
    if [[ -n "${PERPLEXITY_API_KEY:-}" ]]; then
        PERPLEXITY_ENV_ARGS+=(env "PERPLEXITY_API_KEY=$PERPLEXITY_API_KEY")
    fi
    
    # Add default model configuration (optional)
    if [[ -n "${PERPLEXITY_DEFAULT_MODEL:-}" ]]; then
        PERPLEXITY_ENV_ARGS+=(env "PERPLEXITY_DEFAULT_MODEL=$PERPLEXITY_DEFAULT_MODEL")
    fi
    
    # Add max tokens configuration (optional)
    if [[ -n "${PERPLEXITY_MAX_TOKENS:-}" ]]; then
        PERPLEXITY_ENV_ARGS+=(env "PERPLEXITY_MAX_TOKENS=$PERPLEXITY_MAX_TOKENS")
    fi
    
    # Add temperature configuration (optional)
    if [[ -n "${PERPLEXITY_TEMPERATURE:-}" ]]; then
        PERPLEXITY_ENV_ARGS+=(env "PERPLEXITY_TEMPERATURE=$PERPLEXITY_TEMPERATURE")
    fi
    
    # Add search domain filter (optional)
    if [[ -n "${PERPLEXITY_SEARCH_DOMAIN_FILTER:-}" ]]; then
        PERPLEXITY_ENV_ARGS+=(env "PERPLEXITY_SEARCH_DOMAIN_FILTER=$PERPLEXITY_SEARCH_DOMAIN_FILTER")
    fi
    
    # Add search recency filter (optional)
    if [[ -n "${PERPLEXITY_SEARCH_RECENCY_FILTER:-}" ]]; then
        PERPLEXITY_ENV_ARGS+=(env "PERPLEXITY_SEARCH_RECENCY_FILTER=$PERPLEXITY_SEARCH_RECENCY_FILTER")
    fi
    
    # Add return images flag (optional)
    if [[ -n "${PERPLEXITY_RETURN_IMAGES:-}" ]]; then
        PERPLEXITY_ENV_ARGS+=(env "PERPLEXITY_RETURN_IMAGES=$PERPLEXITY_RETURN_IMAGES")
    fi
    
    # Add return related questions flag (optional)
    if [[ -n "${PERPLEXITY_RETURN_RELATED_QUESTIONS:-}" ]]; then
        PERPLEXITY_ENV_ARGS+=(env "PERPLEXITY_RETURN_RELATED_QUESTIONS=$PERPLEXITY_RETURN_RELATED_QUESTIONS")
    fi
    
    # Combine env args with the base command
    if [[ ${#PERPLEXITY_ENV_ARGS[@]} -gt 0 ]]; then
        MCP_SERVER_CMD="${PERPLEXITY_ENV_ARGS[@]} $MCP_SERVER_CMD"
    fi
}

# Validate CORS patterns
validate_cors() {
    CORS_ARGS=()
    ALLOW_ALL_CORS=false
    local cors_value

    if [[ -n "${CORS:-}" ]]; then
        IFS=',' read -ra CORS_VALUES <<< "$CORS"
        for cors_value in "${CORS_VALUES[@]}"; do
            cors_value=$(trim "$cors_value")
            [[ -z "$cors_value" ]] && continue

            if [[ "$cors_value" =~ ^(all|\*)$ ]]; then
                ALLOW_ALL_CORS=true
                CORS_ARGS=(--cors)
                echo "Caution! CORS allowing all origins - security risk in production!"
                break
            elif [[ "$cors_value" =~ ^/.*/$ ]] ||
                 [[ "$cors_value" =~ ^https?:// ]] ||
                 [[ "$cors_value" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(:[0-9]+)?$ ]] ||
                 [[ "$cors_value" =~ ^https?://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(:[0-9]+)?$ ]] ||
                 [[ "$cors_value" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(:[0-9]+)?$ ]]
            then
                CORS_ARGS+=(--cors "$cors_value")
            else
                echo "Warning: Invalid CORS pattern '$cors_value' - skipping"
            fi
        done
    fi
}

# Generate client configuration example
generate_client_config_example() {
    echo ""
    echo "=== PERPLEXITY ASK MCP TOOL LIST ==="
    echo "To enable auto-approval in your MCP client, add this to your configuration:"
    echo ""
    echo "\"TOOL LIST\": ["
    echo "  \"perplexity_search\","
    echo "  \"perplexity_ask\","
    echo "  \"perplexity_research\","
    echo "  \"perplexity_reason\""
    echo "]"
    echo ""
    echo "=== END TOOL LIST ==="
    echo ""
}

# Validate and set Perplexity environment variables
validate_perplexity_env() {
    # STRICT VALIDATION: PERPLEXITY_API_KEY is REQUIRED
    if [[ -z "${PERPLEXITY_API_KEY:-}" ]]; then
        echo "❌ ERROR: PERPLEXITY_API_KEY environment variable is REQUIRED."
        echo ""
        echo "The Perplexity Ask MCP server cannot start without an API key."
        echo ""
        echo "You can obtain an API key by:"
        echo "  1. Visiting: https://www.perplexity.ai/account/api/group"
        echo "  2. Creating an account if you don't have one"
        echo "  3. Choosing a plan and generating a new API key"
        echo ""
        echo "Then set the environment variable:"
        echo "  docker run -e PERPLEXITY_API_KEY=your-api-key ..."
        echo ""
        return 1
    fi

    # Validate API key format (basic check - should be non-empty and reasonable length)
    if [[ ${#PERPLEXITY_API_KEY} -lt 10 ]]; then
        echo "⚠️  Warning: PERPLEXITY_API_KEY seems too short (${#PERPLEXITY_API_KEY} characters)"
    fi

    # Validate model name if set (optional)
    if [[ -n "${PERPLEXITY_DEFAULT_MODEL:-}" ]]; then
        local valid_models="sonar-pro sonar-reasoning-pro sonar-deep-research llama-3.1-sonar-small-128k-online llama-3.1-sonar-large-128k-online llama-3.1-sonar-huge-128k-online"
        if ! echo "$valid_models" | grep -wq "$PERPLEXITY_DEFAULT_MODEL"; then
            echo "⚠️  Warning: Unknown PERPLEXITY_DEFAULT_MODEL: '$PERPLEXITY_DEFAULT_MODEL'."
            echo "   Valid models: sonar-pro, sonar-reasoning-pro, sonar-deep-research"
            echo "   Using default: $DEFAULT_MODEL"
            export PERPLEXITY_DEFAULT_MODEL="$DEFAULT_MODEL"
        fi
    fi

    # Validate max tokens if set (optional)
    if [[ -n "${PERPLEXITY_MAX_TOKENS:-}" ]]; then
        if ! is_positive_int "$PERPLEXITY_MAX_TOKENS"; then
            echo "⚠️  Warning: Invalid PERPLEXITY_MAX_TOKENS: '$PERPLEXITY_MAX_TOKENS'. Using default: $DEFAULT_MAX_TOKENS"
            export PERPLEXITY_MAX_TOKENS="$DEFAULT_MAX_TOKENS"
        elif [ "$PERPLEXITY_MAX_TOKENS" -lt 1 ] || [ "$PERPLEXITY_MAX_TOKENS" -gt 131072 ]; then
            echo "⚠️  Warning: PERPLEXITY_MAX_TOKENS out of range (1-131072). Using default: $DEFAULT_MAX_TOKENS"
            export PERPLEXITY_MAX_TOKENS="$DEFAULT_MAX_TOKENS"
        fi
    fi

    # Validate temperature if set (optional)
    if [[ -n "${PERPLEXITY_TEMPERATURE:-}" ]]; then
        if ! is_valid_float "$PERPLEXITY_TEMPERATURE"; then
            echo "⚠️  Warning: Invalid PERPLEXITY_TEMPERATURE: '$PERPLEXITY_TEMPERATURE'. Using default: $DEFAULT_TEMPERATURE"
            export PERPLEXITY_TEMPERATURE="$DEFAULT_TEMPERATURE"
        else
            local temp_check=$(echo "$PERPLEXITY_TEMPERATURE >= 0 && $PERPLEXITY_TEMPERATURE <= 2" | bc -l 2>/dev/null || echo 0)
            if [ "$temp_check" -eq 0 ]; then
                echo "⚠️  Warning: PERPLEXITY_TEMPERATURE out of range (0-2). Using default: $DEFAULT_TEMPERATURE"
                export PERPLEXITY_TEMPERATURE="$DEFAULT_TEMPERATURE"
            fi
        fi
    fi

    # Validate search recency filter if set (optional)
    if [[ -n "${PERPLEXITY_SEARCH_RECENCY_FILTER:-}" ]]; then
        local valid_recency="hour day week month year"
        if ! echo "$valid_recency" | grep -wq "$PERPLEXITY_SEARCH_RECENCY_FILTER"; then
            echo "⚠️  Warning: Invalid PERPLEXITY_SEARCH_RECENCY_FILTER: '$PERPLEXITY_SEARCH_RECENCY_FILTER'."
            echo "   Valid values: hour, day, week, month, year"
            echo "   Using default: $DEFAULT_SEARCH_RECENCY_FILTER"
            export PERPLEXITY_SEARCH_RECENCY_FILTER="$DEFAULT_SEARCH_RECENCY_FILTER"
        fi
    fi

    # Validate boolean flags if set (optional)
    if [[ -n "${PERPLEXITY_RETURN_IMAGES:-}" ]]; then
        local return_images_lower=$(echo "$PERPLEXITY_RETURN_IMAGES" | tr '[:upper:]' '[:lower:]')
        if [[ "$return_images_lower" != "true" && "$return_images_lower" != "false" ]]; then
            echo "⚠️  Warning: Invalid PERPLEXITY_RETURN_IMAGES: '$PERPLEXITY_RETURN_IMAGES'. Using false."
            export PERPLEXITY_RETURN_IMAGES="false"
        fi
    fi

    if [[ -n "${PERPLEXITY_RETURN_RELATED_QUESTIONS:-}" ]]; then
        local return_questions_lower=$(echo "$PERPLEXITY_RETURN_RELATED_QUESTIONS" | tr '[:upper:]' '[:lower:]')
        if [[ "$return_questions_lower" != "true" && "$return_questions_lower" != "false" ]]; then
            echo "⚠️  Warning: Invalid PERPLEXITY_RETURN_RELATED_QUESTIONS: '$PERPLEXITY_RETURN_RELATED_QUESTIONS'. Using false."
            export PERPLEXITY_RETURN_RELATED_QUESTIONS="false"
        fi
    fi

    return 0
}

# Display Perplexity configuration summary
display_config_summary() {
    echo ""
    echo "=== PERPLEXITY ASK MCP SERVER CONFIGURATION ==="
    
    # Always show API configuration
    echo "🔑 API Key: ${PERPLEXITY_API_KEY:0:8}...${PERPLEXITY_API_KEY: -4} (length: ${#PERPLEXITY_API_KEY})"
    
    # Show model configuration if customized
    local model_display="${PERPLEXITY_DEFAULT_MODEL:-$DEFAULT_MODEL}"
    if [[ "$model_display" != "$DEFAULT_MODEL" ]]; then
        echo "🤖 Default Model: $model_display"
    fi
    
    # Show max tokens if customized
    local max_tokens_display="${PERPLEXITY_MAX_TOKENS:-$DEFAULT_MAX_TOKENS}"
    if [[ "$max_tokens_display" != "$DEFAULT_MAX_TOKENS" ]]; then
        echo "📊 Max Tokens: $max_tokens_display"
    fi
    
    # Show temperature if customized
    local temperature_display="${PERPLEXITY_TEMPERATURE:-$DEFAULT_TEMPERATURE}"
    if [[ "$temperature_display" != "$DEFAULT_TEMPERATURE" ]]; then
        echo "🌡️  Temperature: $temperature_display"
    fi
    
    # Show search configuration if customized
    if [[ -n "${PERPLEXITY_SEARCH_DOMAIN_FILTER:-}" ]]; then
        echo "🔍 Search Domain Filter: $PERPLEXITY_SEARCH_DOMAIN_FILTER"
    fi
    
    local recency_display="${PERPLEXITY_SEARCH_RECENCY_FILTER:-$DEFAULT_SEARCH_RECENCY_FILTER}"
    if [[ "$recency_display" != "$DEFAULT_SEARCH_RECENCY_FILTER" ]]; then
        echo "📅 Search Recency: $recency_display"
    fi
    
    # Show optional flags if enabled
    if [[ "${PERPLEXITY_RETURN_IMAGES:-false}" == "true" ]]; then
        echo "🖼️  Return Images: enabled"
    fi
    
    if [[ "${PERPLEXITY_RETURN_RELATED_QUESTIONS:-false}" == "true" ]]; then
        echo "❓ Return Related Questions: enabled"
    fi
    
    # Always show server configuration
    echo "📡 Server:"
    echo "   - Port: $PORT"
    echo "   - Protocol: $PROTOCOL_DISPLAY"
    
    echo "=========================================="
    echo ""
}

# Main execution
main() {
    # Trim all input parameters
    [[ -n "${PUID:-}" ]] && PUID=$(trim "$PUID")
    [[ -n "${PGID:-}" ]] && PGID=$(trim "$PGID")
    [[ -n "${PORT:-}" ]] && PORT=$(trim "$PORT")
    [[ -n "${PROTOCOL:-}" ]] && PROTOCOL=$(trim "$PROTOCOL")
    [[ -n "${CORS:-}" ]] && CORS=$(trim "$CORS")
    
    # Trim Perplexity specific environment variables
    [[ -n "${PERPLEXITY_API_KEY:-}" ]] && PERPLEXITY_API_KEY=$(trim "$PERPLEXITY_API_KEY")
    [[ -n "${PERPLEXITY_DEFAULT_MODEL:-}" ]] && PERPLEXITY_DEFAULT_MODEL=$(trim "$PERPLEXITY_DEFAULT_MODEL")
    [[ -n "${PERPLEXITY_MAX_TOKENS:-}" ]] && PERPLEXITY_MAX_TOKENS=$(trim "$PERPLEXITY_MAX_TOKENS")
    [[ -n "${PERPLEXITY_TEMPERATURE:-}" ]] && PERPLEXITY_TEMPERATURE=$(trim "$PERPLEXITY_TEMPERATURE")
    [[ -n "${PERPLEXITY_SEARCH_DOMAIN_FILTER:-}" ]] && PERPLEXITY_SEARCH_DOMAIN_FILTER=$(trim "$PERPLEXITY_SEARCH_DOMAIN_FILTER")
    [[ -n "${PERPLEXITY_SEARCH_RECENCY_FILTER:-}" ]] && PERPLEXITY_SEARCH_RECENCY_FILTER=$(trim "$PERPLEXITY_SEARCH_RECENCY_FILTER")
    [[ -n "${PERPLEXITY_RETURN_IMAGES:-}" ]] && PERPLEXITY_RETURN_IMAGES=$(trim "$PERPLEXITY_RETURN_IMAGES")
    [[ -n "${PERPLEXITY_RETURN_RELATED_QUESTIONS:-}" ]] && PERPLEXITY_RETURN_RELATED_QUESTIONS=$(trim "$PERPLEXITY_RETURN_RELATED_QUESTIONS")

    # First run handling
    if [[ ! -f "$FIRST_RUN_FILE" ]]; then
        handle_first_run
    fi

    # Validate configurations
    validate_port
    validate_cors
    
    # Validate Perplexity environment - this will exit if configuration is invalid
    if ! validate_perplexity_env; then
        echo "❌ Perplexity Ask MCP Server cannot start due to configuration errors."
        exit 1
    fi

    # Build MCP server command with environment variables
    build_mcp_server_cmd

    # Generate client configuration example
    generate_client_config_example

    # Protocol selection
    local PROTOCOL_UPPER=${PROTOCOL:-$DEFAULT_PROTOCOL}
    PROTOCOL_UPPER=${PROTOCOL_UPPER^^}

    case "$PROTOCOL_UPPER" in
        "SHTTP"|"STREAMABLEHTTP")
            CMD_ARGS=(npx --yes supergateway --port "$PORT" --streamableHttpPath /mcp --outputTransport streamableHttp "${CORS_ARGS[@]}" --healthEndpoint /healthz --stdio "$MCP_SERVER_CMD")
            PROTOCOL_DISPLAY="SHTTP/streamableHttp"
            ;;
        "SSE")
            CMD_ARGS=(npx --yes supergateway --port "$PORT" --ssePath /sse --outputTransport sse "${CORS_ARGS[@]}" --healthEndpoint /healthz --stdio "$MCP_SERVER_CMD")
            PROTOCOL_DISPLAY="SSE/Server-Sent Events"
            ;;
        "WS"|"WEBSOCKET")
            CMD_ARGS=(npx --yes supergateway --port "$PORT" --messagePath /message --outputTransport ws "${CORS_ARGS[@]}" --healthEndpoint /healthz --stdio "$MCP_SERVER_CMD")
            PROTOCOL_DISPLAY="WS/WebSocket"
            ;;
        *)
            echo "Invalid PROTOCOL: '$PROTOCOL'. Using default: $DEFAULT_PROTOCOL"
            CMD_ARGS=(npx --yes supergateway --port "$PORT" --streamableHttpPath /mcp --outputTransport streamableHttp "${CORS_ARGS[@]}" --healthEndpoint /healthz --stdio "$MCP_SERVER_CMD")
            PROTOCOL_DISPLAY="SHTTP/streamableHttp"
            ;;
    esac

    # Display configuration summary
    display_config_summary

    # Debug mode handling
    case "${DEBUG_MODE:-}" in
        [1YyTt]*|[Oo][Nn]|[Yy][Ee][Ss]|[Ee][Nn][Aa][Bb][Ll][Ee]*)
            echo "DEBUG MODE: Installing nano and pausing container"
            apk add --no-cache nano 2>/dev/null || echo "Warning: Failed to install nano"
            echo "Container paused for debugging. Exec into container to investigate."
            exec tail -f /dev/null
            ;;
        *)
            # Normal execution
            echo "🚀 Launching Perplexity Ask MCP Server with protocol: $PROTOCOL_DISPLAY on port: $PORT"
            
            # Check for npx availability
            if ! command -v npx &>/dev/null; then
                echo "❌ Error: npx not available. Cannot start server."
                exit 1
            fi

            # Final check - ensure API key is set
            if [[ -z "${PERPLEXITY_API_KEY:-}" ]]; then
                echo "❌ CRITICAL: PERPLEXITY_API_KEY is not set."
                echo "   The server cannot start without a Perplexity API key."
                exit 1
            fi

            # Display the actual command being executed for debugging
            if [[ "${DEBUG_MODE:-}" == "verbose" ]]; then
                echo "🔧 DEBUG - Final command: ${CMD_ARGS[*]}"
            fi

            if [ "$(id -u)" -eq 0 ]; then
                echo "👤 Running as user: node (PUID: $PUID, PGID: $PGID)"
                exec su-exec node "${CMD_ARGS[@]}"
            else
                if [ "$PORT" -lt 1024 ]; then
                    echo "❌ Error: Cannot bind to privileged port $PORT without root"
                    exit 1
                fi
                echo "👤 Running as current user"
                exec "${CMD_ARGS[@]}"
            fi
            ;;
    esac
}

# Run the script with error handling
if main "$@"; then
    exit 0
else
    echo "❌ Perplexity Ask MCP Server failed to start"
    exit 1
fi