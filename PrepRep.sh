#!/bin/bash

install_gh() {
    case "$OSTYPE" in
        linux*)
            if command -v apt-get &> /dev/null; then
                sudo apt-get update
                sudo apt-get install gh -y
            elif command -v dnf &> /dev/null; then
                sudo dnf install gh -y
            elif command -v pacman &> /dev/null; then
                sudo pacman -S gh
            elif command -v yum &> /dev/null; then
                sudo yum install gh -y
            elif command -v zypper &> /dev/null; then
                sudo zypper install gh
            elif command -v eopkg &> /dev/null; then
                sudo eopkg install gh
            elif command -v emerge &> /dev/null; then
                sudo emerge --ask app-misc/gh
            else
                echo "Unknown Linux distribution. Please install GitHub CLI manually."
                exit 1
            fi
            ;;
        darwin*)
            if ! command -v brew &> /dev/null; then
                echo "Homebrew not installed. Please install Homebrew and then run this script again."
                exit 1
            fi
            brew install gh
            ;;
        msys*)
            if ! command -v choco &> /dev/null; then
                echo "Chocolatey not installed. Please install Chocolatey and then run this script again."
                exit 1
            fi
            choco install gh
            ;;
        *)
            echo "Unknown operating system. Please install GitHub CLI manually."
            exit 1
            ;;
    esac
}

install_jq() {
    case "$OSTYPE" in
        linux*)
            if command -v apt-get &> /dev/null; then
                sudo apt-get install jq -y
            elif command -v dnf &> /dev/null; then
                sudo dnf install jq -y
            elif command -v pacman &> /dev/null; then
                sudo pacman -S jq
            elif command -v yum &> /dev/null; then
                sudo yum install jq -y
            elif command -v zypper &> /dev/null; then
                sudo zypper install jq
            elif command -v eopkg &> /dev/null; then
                sudo eopkg install jq
            elif command -v emerge &> /dev/null; then
                sudo emerge --ask app-misc/jq
            else
                echo "Unknown Linux distribution. Please install jq manually."
                exit 1
            fi
            ;;
        darwin*)
            if ! command -v brew &> /dev/null; then
                echo "Homebrew not installed. Please install Homebrew and then run this script again."
                exit 1
            fi
            brew install jq
            ;;
        msys*)
            if ! command -v choco &> /dev/null; then
                echo "Chocolatey not installed. Please install Chocolatey and then run this script again."
                exit 1
            fi
            choco install jq
            ;;
        *)
            echo "Unknown operating system. Please install jq manually."
            exit 1
            ;;
    esac
}

prompt_input() {
    local prompt_message=$1
    local input
    while true; do
        read -p "$prompt_message" input
        if [ -z "$input" ]; then
            echo "Input cannot be empty. Please try again."
        else
            break
        fi
    done
    echo "$input"
}

# Check if gh and jq are installed
if ! command -v gh &> /dev/null
then
    install_gh
fi

if ! command -v jq &> /dev/null
then
    install_jq
fi

USERNAME=$(prompt_input "Enter your GitHub username: ")
TOKEN=$(prompt_input "Enter your GitHub personal access token: ")

# Ask the user where to backup the repositories
while true; do
    read -p "Where do you want to backup your repositories? (c: current directory, s: specify a directory, n: create a new directory) " DEST_OPTION
    case $DEST_OPTION in
        [cC]* ) DEST_DIR=$(pwd); break;;
        [sS]* ) DEST_DIR=$(prompt_input "Enter the directory where you want to backup your repositories: "); break;;
        [nN]* ) DEST_DIR=$(prompt_input "Enter the name of the new directory you want to create: "); mkdir -p "$DEST_DIR"; break;;
        * ) echo "Please answer c, s, or n.";;
    esac
done

# Get list of all repository names
response=$(curl -s -H "Authorization: token $TOKEN" "https://api.github.com/users/$USERNAME/repos")
repos=$(echo $response | jq -r '.[].name')

if [[ $response == *"API rate limit exceeded"* ]]; then
    echo "API rate limit exceeded. Please try again later."
    exit 1
elif [[ $response == *"Bad credentials"* ]]; then
    echo "Invalid token. Please check your token and try again."
    exit 1
elif [[ $repos == "null" ]]; then
    echo "No repositories found for the given username and token."
    exit 1
fi

# Clone all repositories
for repo in $repos
do
  git clone "https://github.com/$USERNAME/$repo.git" "$DEST_DIR/$repo"
done

echo "Backup completed successfully!"
