# Docker TP by Mohamed_Oussalh

This repository contains an automated script for setting up a Docker environment that includes:
- MySQL
- PHP with Apache (with the MySQLi extension)
- FTP Server
The script pulls the required Docker images, sets up the containers, creates a MySQL database with a `football_db`, and sets up an Apache server with PHP to interact with the database.

## Requirements

- Docker must be installed on your machine.
- You should have a basic understanding of Docker and containerized applications.
- A working Linux-based environment for executing the script (e.g., Ubuntu).

## Features

- Pulls and sets up MySQL, PHP, and FTP Docker containers.
- Creates a custom network for the containers.
- Sets up a MySQL database (`football_db`) and a table for storing football players' information.
- Configures an Apache server with PHP and connects it to the MySQL database.
- FTP server configuration to interact with files.

## Installation and Usage

1. Clone the repository to your local machine:

   ```bash
   git clone https://github.com/medSploit/docker_tp.git
   ```

2. Navigate to the directory where the repository is cloned:

   ```bash
   cd docker_tp
   ```

3. Run the script:

   ```bash
   chmod +x dockertp.sh
   ./dockertp.sh
   ```

4. Visit the PHP + Apache web page by navigating to (http://localhost:8080/index.php) in your browser.

5. Install FileZilla (for FTP client access):

   ```bash
   sudo apt install filezilla
   ```
   Open your FTP client (ileZilla).

Enter the following details in the client:

    Host: localhost

    Username: user

    Password: password

    Port: 21

## Credits

- This project was created by Mohamed Oussalh as part of a Docker and containerization study.

