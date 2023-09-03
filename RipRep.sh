#!/bin/bash

# Function to install GitHub CLI on various Linux distributions
install_gh_linux() {
    if command -v apt-get &> /dev/null; then
        sudo apt-get install software-properties-common
        sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
        sudo apt-add-repository https://cli.github.com/packages
        sudo apt-get update
        sudo apt-get install gh
    elif command -v dnf &> /dev/null; then
        sudo dnf install gh
    elif command -v pacman &> /dev/null; then
        sudo pacman -S gh
    elif command -v yum &> /dev/null; then
        sudo yum install gh
    elif command -v zypper &> /dev/null; then
        sudo zypper install gh
    elif command -v eopkg &> /dev/null; then
        sudo eopkg install gh
    elif command -v emerge &> /dev/null; then
        sudo emerge --ask app-misc/gh
    else
        echo "Unsupported package manager. Please install GitHub CLI manually."
        exit 1
    fi
}

# Check if gh is installed
if ! command -v gh &> /dev/null
then
    echo "GitHub CLI (gh) could not be found. Installing it now..."

    # Detect the operating system
    OS="$(uname)"

    case $OS in
        'Linux')
            install_gh_linux
            ;;
        'Darwin')
            brew install gh
            ;;
        'WindowsNT')
            choco install gh
            ;;
        *)
            echo "Unsupported OS. Please install GitHub CLI manually."
            exit 1
            ;;
    esac

    echo "GitHub CLI (gh) installed successfully."
fi

# Authenticate with GitHub
echo "Please manually authenticate with GitHub when prompted."
gh auth login

# Prompt for GitHub username
read -p "Enter your GitHub username: " github_username

# Prompt for repository details
read -p "Enter the name of the new repository: " repo_name
read -p "Enter the description of the repository (or 'none' if not needed): " repo_description
read -p "Enter the visibility of the repository (public/private): " repo_visibility
read -p "Enter the .gitignore template to use (e.g., Node, Python, etc., or 'none' if not needed): " gitignore_template
read -p "Enter the license to use (e.g., MIT, GPL, etc., or 'none' if not needed): " license
read -p "Do you want to initialize a README file? (y for yes / n for no): " init_readme

# Create the repository
if [ "$repo_description" != "none" ]; then
    gh repo create $repo_name --description "$repo_description" --$repo_visibility
else
    gh repo create $repo_name --$repo_visibility
fi

# Ask if user wants to clone the repository
read -p "Do you want to clone the repository? (y for yes / n for no): " clone_repo

if [ "$clone_repo" == "y" ]; then
    read -p "Do you want to clone the repository in the current directory, specify a directory, or create a new directory? (c for current / s for specify / n for new): " clone_directory

    # Set the directory to clone the repository to
    if [ "$clone_directory" == "c" ]; then
        directory="."
    elif [ "$clone_directory" == "s" ]; then
        read -p "Enter the directory to clone the repository to: " directory
    elif [ "$clone_directory" == "n" ]; then
        read -p "Enter the name of the new directory to create and clone the repository to: " new_directory
        mkdir $new_directory
        directory="./$new_directory"
    else
        echo "Invalid option. Exiting."
        exit 1
    fi

    # Navigate to the directory
    cd $directory

    # Clone the repository to the directory
    git clone "https://github.com/$github_username/$repo_name.git"

    # Navigate to the new repository folder
    cd $repo_name

    # If user wants to initialize a README file
    if [ "$init_readme" == "y" ]; then
        read -p "Enter the contents of the README file: " readme_contents
        echo "$readme_contents" >> README.md
        git add README.md
    fi

    # If a .gitignore template was provided, create the .gitignore file
    if [ "$gitignore_template" != "none" ]; then
        curl -o .gitignore "https://www.toptal.com/developers/gitignore/api/$gitignore_template"
        git add .gitignore
    fi

    # If a license was provided, create the LICENSE file
    if [ "$license" != "none" ]; then
        gh license $license > LICENSE
        git add LICENSE
    fi

    git commit -m "Initial commit"

    # Push to GitHub
    git push

    echo "Repository $repo_name cloned to $directory/$repo_name and pushed to GitHub."
else
    echo "Repository $repo_name created on GitHub."
fi

# Add the directory to the system-wide PATH
echo "Adding directory to system-wide PATH..."
echo "PATH=\"$PATH:/path/to/your/directory\"" | sudo tee -a /etc/environment
