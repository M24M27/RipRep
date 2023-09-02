# RipRep
A Bash script to automate GitHub repository creation and initialization using the GitHub CLI. This script allows the user to specify repository details such as the name, description, visibility, .gitignore template, and license. It also provides an option to clone the newly created repository and initialize it with a README file, .gitignore, and license, then push these changes to GitHub. Additionally, the script ensures the GitHub CLI is installed on the user's system and prompts for authentication if not already authenticated. This makes the entire process of creating and setting up a new repository on GitHub seamless and efficient.

Requirements:

GitHub CLI
GitHub account
Usage:
Run 'bash RipRep.sh' and follow the prompts.

Note:
The script supports multiple operating systems and package managers, making it versatile for various environments. It will attempt to install the GitHub CLI if it is not found on the system. It is recommended to check the script and modify the installation commands if necessary, as it may not cover all possible package managers or may require additional repositories to be added.
