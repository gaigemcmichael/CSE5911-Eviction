---
layout: post
title:  "Developer Manual"
date:   2025-03-04 17:59:43 -0500
categories: documentation
---
## Introduction

This Developer Manual provides future developers with essential documentation to understand, modify, and maintain the Eviction Mediation Platform. This document outlines the system architecture, installation procedures, key source files, best practices for testing and debugging, and anticipated improvements for future iterations. By using this guide, developers can efficiently contribute to the project’s success.

## Environment Set Up

### Required Software & Tools

To develop and run the Eviction Mediation Platform Ruby on Rails application, the following software and tools are required:

#### Operating Systems

*   **Windows 10/11** (with Windows Subsystem for Linux – WSL/Ubuntu)
    
*   **macOS** (M1 or later recommended)
    

#### Development Tools

*   Visual Studio Code (Extensions: WSL, SQL Server)
    
*   Ruby 3.4.1
    
*   Rails 7.x
    
*   Bundler
    
*   Git
    
*   Node.js (for npm and frontend assets)
    

#### Database

*   Microsoft SQL Server
    
    *   **Windows:** SQL Server Developer Edition
        
    *   **macOS:** Dockerized SQL Server (Azure SQL Edge)
        

#### Additional Tools

*   Docker (for macOS)
    
*   MS SQL CLI
    
*   Azure Data Studio (optional, for database management)
    

## Installation Instructions

### Windows 10

#### 1\. Install WSL & Ubuntu

Follow the [GoRails Windows 10 setup](https://gorails.com/setup/windows) (including the Rails installation). For Windows 11, see [Windows 11 Setup Guide](https://gorails.com/setup/windows/11)**Do not follow the database installation steps.**

#### 2\. Set Up Visual Studio Code

a. Install the WSL extension and SQL Server extensions.  
b. Open a new VS Code window with the command:
```!whitespace-pre
code .
```

#### 3\. Set Up Git & Permissions

a. In the WSL or Ubuntu terminal, run:

```!whitespace-pre
sudo mount -t drvfs D: /mnt/d -o metadata
sudo umount /mnt/d
wsl --shutdown
```

> **Note:** Replace `D:` with your drive letter.

b. Navigate to the desired folder and run:
`git clone <ssh link to repository>`

**Potential Problem:** If you encounter an error when trying to clone the repository (for example):

`error: chmod on /mnt/d/eviction1/CSE5915_Eviction1/.git/config.lock failed: Operation not permitted fatal: could not set 'core.filemode' to 'false'`

**Solution:** Run:

```!whitespace-pre
sudo mount -t drvfs D: /mnt/d -o metadata
sudo umount /mnt/d
```

> The above was an issue with a team member's D: drive not having the proper permissions to interact with the Linux subsystem, so replace the "D:" and two "d" with the drive you installed it on. Changes won't take effect until you do the wsl shutdown below.

After this, open Windows PowerShell and execute:

```!whitespace-pre
wsl --shutdown
```

Finally, retry the Git clone command.

#### 4\. Install Required Gems

a. In the WSL or Ubuntu terminal, run:

```!whitespace-pre
sudo apt-get --assume-yes update
curl -sSL https://rvm.io/pkuczynski.asc | gpg -
import -
\curl -sSL https://get.rvm.io/ | bash -s stable

# *ENSURE YOU RUN THE COMMAND SPECIFIED IN THE RECENT OUTPUT TO CONSOLE, THEN PROCEED BELOW*

rvm install "ruby-3.4.1"
sudo apt-get --assume-yes
install freetds-dev freetds-bin
bundle install
```

#### 5\. Install SQL Server

a. Download and install Microsoft SQL Server Developer Edition.

#### 6\. Configure SQL Server

a. Enable TCP/IP in SQL Server Configuration Manager.  
b. Set the port to 1433 and update `database.yml` to match the specified configuration settings.

#### 7\. Firewall Settings

a. Open PowerShell as an administrator and run:

```!whitespace-pre
New-NetFirewallRule -DisplayName "Allow SQL Server
from WSL" -Direction Inbound -Protocol TCP -
LocalPort 1433 -Action Allow
```

#### 8\. Initialize Database

a. In the terminal, run:

```!whitespace-pre
rails db:create
rails db:drop
```

b. Add proper dependencies for SQL Server by running:

```!whitespace-pre
curl
https://packages.microsoft.com/keys/microsoft.asc | 
sudo apt-key add -
sudo add-apt-repository "$(curl -fsSL
https://packages.microsoft.com/config/ubuntu/20.04/prod.list)"
sudo apt update
sudo apt install mssql-tools unixodbc-dev -y
# Accept the terms, then:
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >>
~/.bashrc
source ~/.bashrc
```

c. Ensure the SQL Browser service is installed and running:

*   In PowerShell, run:
    
    ```!whitespace-pre
    Get-Service -Name SQLBrowser
    ```
    
*   If the service is stopped, run:
    
    ```!whitespace-pre
    Start-Service -Name SQLBrowser
    ```
    
*   If you cannot start it via the command line, open **Run** (Windows key + R), type `services.msc`, and hit enter. Locate **SQL Server Browser**, right-click, select **Properties**, change the **Startup Type** to **Manual**, and then start the service.

d. Check for a connection to the database (replace IP, username, and password as needed):

```!whitespace-pre
sqlcmd -S 172.21.176.1 -U sa -P changeme
```

If successfully connected, you should see a prompt similar to: `1>`

Then, to check for existing databases, type:

```!whitespace-pre
1> SELECT name FROM sys.databases;
2> GO
```

If the desired database is not present, create it:

*   Create the database (replace `EVICTION_TEST` with your database name):
    
    ```!whitespace-pre
    1> CREATE DATABASE EVICTION_TEST;
    2> GO
    ```
    
*   Then select it:
    
    ```!whitespace-pre
    1> USE EVICTION_TEST;
    2> GO
    ```

e. To initialize from the `DBInitTest.sql` file (replace username, password, IP, and database name as needed), run:

```!whitespace-pre
sqlcmd -S 172.21.176.1 -U sa -P changeme -d
EVICTION_TEST -i "DBInitTest.sql"
```

f. Run the migrations:

```!whitespace-pre
rails db:migrate
```

### macOS (M1)

#### 1\. Install Prerequisites

a. Install **Homebrew**:

```!whitespace-pre
/bin/bash -c "$(curl -fsSL
https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install docker
```

b. Install **Docker** for Mac with Apple Silicon – see the [Docker Setup for Mac](https://docs.docker.com/desktop/setup/install/mac-install/).

c. Follow the [GoRails macOS 14 Setup](https://gorails.com/setup/macos/14-sonoma) to install **Ruby on Rails**:

*   Follow the linked tutorial and complete the instructions up to and including the Rails installation (do not install the database).
    

#### 2\. Run MS SQL Server in Docker

a. Refer to [Setting Up A Local SQL Server on a Mac](https://medium.com/@aleksej.gudkov/how-to-set-up-a-local-sql-server-on-an-m1-mac-88d0ff0fed4c) for guidance.

b. Start the SQL Server container by running:

```!whitespace-pre
docker run mcr.microsoft.com/azure-sql-edge
docker run -p 1433:1433 mcr.microsoft.com/azure-sql-edge
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=StrongPassword1" -p 1433:1433 -d mcr.microsoft.com/azure-sql-edge docker ps
docker ps
```

#### 3\. Run in the VS Code Terminal

a. Clone your Git repository.  
b. Update `database.yml` with your specific configuration.  
c. Run the following commands:

```!whitespace-pre
bundle install
ruby ./bin/rails server
```

This will start the application; the database is initialized in the container (not locally).

#### 4\. Initialize Database

a. Create a folder on your local machine (e.g., `SQLData`) in the same directory where you cloned the Git repository.  
b. Open the **Docker** terminal and run:

```!whitespace-pre
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=StrongPassword1" -p 1433:1433 -v ./SQLData:/var/opt/mssql --name sqlserver -d --rm mcr.microsoft.com/azure-sql-edge
```

> **Notes:**
> 
> *   The `-v ./SQLData:/var/opt/mssql` flag saves the database to your local machine.
>     
> *   The container is named `sqlserver` with the `--name` flag.
>     
> *   The `--rm` flag ensures that the container is removed when stopped.
>     

c. In VS Code, run:

```!whitespace-pre
ruby ./bin/rails server
```

d. Whenever you need to run Docker, use the command from step 4b.

e. Download [MS Azure Data Studio](https://builtin.com/software-engineering-perspectives/sql-server-management-studio-mac).

f. **Install MS SQL CLI:**

i. Download [npm](https://nodejs.org/en/download/).  
ii. To install and test, run:

```!whitespace-pre
npm install -g sql-cli

# OR

sudo npm install -g sql-cli
mssql -u sa -p
```

g. Install the GUI application – [Azure Data Studio](https://learn.microsoft.com/en-us/azure-data-studio/download-azure-data-studio?view=sql-server-ver15&viewFallbackFrom=sql-server-ver15%5D&tabs=win-install%2Cwin-user-install%2Credhat-install%2Cwindows-uninstall%2Credhat-uninstall). After installation, add the necessary credentials and click connect.

h. Initialize the database using your DB initialization file.

## Version Numbers & Configuration Settings

### Software Versions

*   **Ruby:** 3.4.1
    
*   **Rails:** 7.x
    
*   **SQL Server:** Developer Edition (Windows) / Azure SQL Edge (macOS)
    
*   **Node.js:** Latest LTS
    
*   **Docker:** Latest stable
    

### Configuration Settings

a. **config/database.yml** (modify according to your specific setup):

```!whitespace-pre
development:
    adapter: sqlserver
    host: '127.0.0.1'
    port: 1433 database: EVICTION_TEST
    username: 'sa'
    password: 'StrongPassword1'
    trust_server_certificate: true
    timeout: 5000
```

b. **freetds.conf** (modify for your specific SQL Server name and host IP):

```!whitespace-pre
[EVICTION_TEST]
    host = 127.0.0.1
    port = 1433
    tds version = 7.4
```

### SQL Server Configurations

*   **TCP/IP:** Enabled
    
*   **Port:** 1433
    
*   **Firewall Rule:** Allow Inbound TCP 1433
    

### Email Configurations

In **config/environments/development.rb** (for development) and **config/environments/production.rb** (for production):

```!whitespace-pre
  config.action_mailer.delivery_method = :smtp

  # Configuring smpt settings, will need changed to proper MSA.
  config.action_mailer.smtp_settings = {
    address: "smtp.gmail.com",
    port: 587,
    domain: "gmail.com",
    authentication: "plain",
    enable_starttls_auto: true,
    user_name: ENV["GMAIL_USERNAME"], # Use environment variables for security
    password: ENV["GMAIL_PASSWORD"]   # Use environment variables for security
  }

  # Show error if mailer can't send
  config.action_mailer.raise_delivery_errors = true

  # Make template changes take effect immediately.
  config.action_mailer.perform_caching = false

  # Mailer performs deliveries
  config.action_mailer.perform_deliveries = true
```

> **Note:** You can change the `ENV[]` values in your `.env` file (for example, Gmail username and password).

## Source File Locations & Overview

### 1\. Directory Structure

Our project uses the standard Ruby on Rails directory structure. Key points include:

*   **app/**: Contains the main application logic (MVC components)
    
*   **config/**: Manages application settings (database connection and routes file)
    
*   **db/**: Contains database migrations and the schema file (note: these are less critical since our database is external)
    

### 2\. Key Source Files & Functions

*   As an MVC application, the models, controller, and view files (and the functions contained within) are obviously quite important.
    1. Controller File Details:
       - Controllers/admin/accounts_controller
         - This controller handles the functionality found in the Admin view on the Manage Accounts tab. It allows the admin to create & modify mediator accounts
       - Controllers/admin/flagged_mediations_controller
         - This controller handles the functionality found in the Admin view on the  mediatons tab. This allows the admin to resolve mediations that were flagged from the screening questions. Gives the admin the option to reassign the third party mediator or simply unflag the mediation. 
       - Controllers/Account_controller
         - This controller handles the functionality found on tenants, landlords, and mediator account pages. It handles the password reset for all, the address change for tenants and the mediator availability change for mediators. 
       - Controllers/Application_controller
         - This controller gives a couple of helpers in order to facilitate some of the error handling for signup and login flow. 
       - Controllers/Dashboard_controller
         - This controller handles the functionality of rendering the different dashboards based on user role. Also gives the log out functionality. 
       - Controllers/Documents_controller
         - This controller handles the functionality allowing tenants and landlords to generate, view, download and sign documents. Also helps show the documents page.
       - Controllers/Intake_questions_controller
         - This controller handles the functionality of allowing a tenant to complete the intake form upon requesting negotiation with a landlord. This intake form receives most of the needed information used in document generation (for payment plans)
       - Controllers/Mediations_controller
         - This controllers handles the functionality of most mediation/negotiation creation and termination.  Firstly, it allows a tenant to request negotiation (from a backend perspective the table is PrimaryMessageGroups) with a landlord, and also will invite the landlord to the app if they don’t already have an account.  This also allows the landlord to accept the negotiation. This also allows landlords and tenants to end the negotiation, and allows the mediator to end the mediation (if a mediator was requested and assigned). It also has the good faith form feedback logic. Upon a negotiation/mediation being terminated, the tenant and landlord are prompted to fill out a form asking if the other party acted in good faith, and the functionality can be found here. 
       - Controllers/Mediator_cases_controller
         - This controller handles the functionality mediators being able to see their assigned cases properly. It makes it possible for the mediator to see the two chat boxes: tenant <-> mediator and landlord <-> mediator. 
       - Controllers/Mediator_messages_controller
         - This controller handles the functionality sending the just_mediator_chats. So when a mediator sends a chat message to either the tenant or landlord, it goes through this controller. 
       - Controllers/Resources_controller
         - This controller handles the functionality of showing the FAQ sections on the resources tab for Tenant view.
       - Controllers/ messages_controller
         - This controller does a lot. It handles the functionality for the following: 
           - This shows the respective index pages for tenants and landlords. The index pages have their current negotiation(s)/mediation(s) as well as a table of their prior mediations and negotiations. 
           - This controller also handles the functionality needed to show each instance of negotiation/mediation. 
           - It also provides the necessary logic for a tenant or landlord to request a third party mediator to turn their negotiation into a mediation.  
           - This controller also provides the means to create texts to send in the chat box, and contains the action_cable broadcast to make the chat box real-time
           - This controller also provides the necessary logic to show the negotiation/mediation summaries upon the termination of them. 
      - Controllers/Screenings_controller
        - This controller handles the functionality needed for the user to be able to fill out the screening questionnaire that both the tenant and landlord must fill out in order to start communicating with their third party mediator when one is requested. This will also flag the mediation for review by admin if certain answers are given on the screening questionaire. 
      - Controllers/Sessions_controller
        - This controller handles the session creation and destruction for when a user logs in or logs out. 
      - Controllers/Third_party_mediations_controller
        - This controller handles the logic for allowing a third party mediator to be able to view a table of all of their current assigned cases, and a table of all their previous cases. 
      - Controllers/Users_controller
        - This controller enables users to sign up as a tenant or a landlord.

*   Chat box JavaScript files
     1.	App/javascript/messages_channel.js
        - This is how tenant <-> landlord chats show up instantly.
     2.	App/javascript/mediator_messages_channel.js
        - This is how tenant <-> mediator and landlord <-> mediator chats show up instantly
     3.	App/assets/javascripts/negotiations_chat.js
        - This helps messages_channel.js to facilitate the tenant <-> landlord chats. 
     4.	App/assets/javascritps/mediator_chats.js
        - This helps mediator_messages_channel.js to faciltate the tenant <-> mediator and landlord <-> mediator chats. 

*   **.env:** Contains mailing server username & password and should also put the database logins here.

*   **routes.rb:** Lays out the routes connecting our views.
    
*   **schema.rb and database.yml:** While `schema.rb` is typically very important, it is less so in this project because we use an external database. The `database.yml` file connects the project to the external MS SQL Server database (as detailed in the environment setup).
    

### 3\. Configuration Files & Roles

*   **database.yml:** Connects the local database with the Rails application.
    
*   **schema.rb:** Remains in sync with the local database to effectively leverage Rails’ MVC structure.
    
*   **application.rb** contains much of the application's necessary configuration.

## Running the Application

### Starting the Server

To start the server, run either:

```!whitespace-pre
rails s
```
or
```!whitespace-pre
rails server
```

A message should confirm that the server is online. In VS Code, you may also be prompted to view the application in your browser. If not, access the application at [http://localhost:3000](http://localhost:3000).

### Navigating the Application

The pages can be navigated via the top navigation bar:

| Home | Messages | Documents | Account |
| --- | --- | --- | --- |

Different account types have access to different pages. For example, a landlord account may manage multiple mediations simultaneously, while a tenant is limited to one active mediation. **More details will be added as functionality (e.g., admin roles) is implemented.**

## Test Suite & Manual Tests

### Automated Tests

Rails uses **Continuous Integration Tests** to automatically scan for known Ruby and JavaScript vulnerabilities and to check for consistent styling via lint tools. CI tests can be configured by modifying the `CI.yml` file located in the `.github` folder.

### Running the Test Suite

Rails’ built-in testing framework executes tests located under the `test/` folder. Run:

```!whitespace-pre
rails test
```

to execute all tests. To run tests for a specific component (for example, controllers), use:

```!whitespace-pre
rails test:controllers
```

(replace `controllers` with the desired test subcategory).

### Manual Tests

Running the automated test suite will execute all current test cases. For guidance on developing additional test cases, refer to the [Testing Rails Applications — Ruby on Rails Guides](https://guides.rubyonrails.org/testing.html).

## Unique Aspects & Known Issues

### Unique Features

The primary unique feature of this application is the use of Microsoft SQL Server with Ruby on Rails—an unorthodox pairing that can lead to technical challenges during setup.

### Common Issues

Currently, there are no broadly documented common issues. Any SQL Server setup issues have been addressed in the latest setup instructions. Unresolved issues will be documented as they are encountered.

### Troubleshooting Development Issues

One member’s Windows 11 device is still unable to connect to a local instance of SQL Server at the time of writing. If a solution is discovered, it will be added to this section.

## Next Steps for Development

### Feature Roadmap

**1\. Production Deployment**

*   Plan for deployment to production over the summer.
    
*   Conduct security compliance validation to meet state requirements.
    
*   Enable admins to collect data on user engagement.
    
*   Establish a process for collecting user feedback.
    

**2\. Language and Translation**

*   Implement translation features beyond the current flagging system for admin review.
    

**3\. Authentication & Accessibility**

*   Evaluate using a phone number as a username to improve accessibility.
    
*   Maintain email-based authentication as the primary method for now.
    
*   Develop a method for verifying a landlord’s property ownership.
    

**4\. Accessibility Enhancements**

*   Explore text-to-speech functionality.
    
*   Improve screen reader compatibility.
    

**5\. Legal Considerations**

*   Integrate educational and other resources within the app (potentially in collaboration with Eviction 2) for users who do not reach an agreement.
    
*   Expand the types of agreements and enhance the customizability of individual agreement provisions.
    
*   Integrate tools (e.g., LLMediator) to flag adversarial language in real time and suggest improvements.
    
*   Provide a space for users to vent before mediation, adding flexibility to text communications.
    

### Anticipated Next Steps

1.  Finalize security and legal compliance measures.
    
2.  Assess the feasibility of phone number-based usernames while retaining email authentication.
    
3.  Expand accessibility features for broader user inclusivity.
    
4.  Improve translation support for multilingual users.
    
5.  Gather and analyze user feedback to guide future updates.
    

### Suggestions for Future Improvements

1.  Enhance production monitoring and analytics.
    
2.  Optimize the user onboarding and authentication experience.
    
3.  Expand accessibility and localization efforts.
    
4.  Implement additional security features as compliance needs evolve.

## Appendices

### Coding Standards & Guidelines

-	Coding standards were loosely based on the: [MU Coding Standards](https://miamioh.edu/cec/departments/computer-science-software-engineering/student-resources/coding-guidelines.html)

### Useful Resources & References

- [Testing Rails Applications - Ruby on Rails Guides](https://guides.rubyonrails.org/testing.html)
- [Azure Data Studio](https://learn.microsoft.com/en-us/azure-data-studio/download-azure-data-studio?view=sql-server-ver15&viewFallbackFrom=sql-server-ver15%5D&tabs=win-install%2Cwin-user-install%2Credhat-install%2Cwindows-uninstall%2Credhat-uninstall)
- [npm](https://nodejs.org/en/download/)
- [Setting Up a SQL Server on an M1 Mac](mailto:a.%09https://medium.com/@aleksej.gudkov/how-to-set-up-a-local-sql-server-on-an-m1-mac-88d0ff0fed4c)
- [GoRails macOS 14 Setup](https://gorails.com/setup/macos/14-sonoma)
- [Windows 11 Setup Guide](https://gorails.com/setup/windows/11)
