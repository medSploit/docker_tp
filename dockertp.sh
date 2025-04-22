#!/bin/bash
echo "automated script: docker Tp by med_oussalh"
sleep 2

# Update system
echo "Updating system packages..."
sudo apt update -y

# Pulling images
echo "Pulling docker images..."
sudo docker pull mysql:latest
sudo docker pull php:apache
sudo docker pull delfer/alpine-ftp-server

# Build custom PHP+Apache image with MySQLi
echo "Building custom PHP+Apache image with MySQLi support..."
mkdir -p docker-build
cat << 'EOF' > docker-build/Dockerfile
FROM php:apache
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
EOF

sudo docker build -t apache_mysqli docker-build/

# Create network
echo "Creating docker network..."
sudo docker network create my_network

# Create and start containers
echo "Creating and starting containers..."
sudo docker run -d --name mysql_container --network my_network \
    -e MYSQL_ROOT_PASSWORD=password -p 3306:3306 mysql:latest || { echo "MySQL container failed"; exit 1; }

sudo docker run -d --name apache_container --network my_network \
    -p 8080:80 -v /var/www/html apache_mysqli || { echo "Apache container failed"; exit 1; }

sudo docker run -d --name ftp_container --network my_network \
    -v /home/ftp -p 21:21 -p 21100-21110:21100-21110 \
    -e USERS="admin|admin" delfer/alpine-ftp-server || { echo "FTP container failed"; exit 1; }

# Setup MySQL database
echo "Setting up MySQL database..."
cat << 'EOF' > setup.sql
CREATE DATABASE IF NOT EXISTS football_db;
USE football_db;
CREATE TABLE IF NOT EXISTS players (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    position VARCHAR(50),
    age INT,
    nationality VARCHAR(50),
    club VARCHAR(100)
);
INSERT INTO players (name, position, age, nationality, club) VALUES
('Lionel Messi', 'Forward', 36, 'Argentina', 'Inter Miami'),
('Kylian Mbappé', 'Forward', 25, 'France', 'Paris Saint-Germain'),
('Kevin De Bruyne', 'Midfielder', 32, 'Belgium', 'Manchester City'),
('Virgil van Dijk', 'Defender', 32, 'Netherlands', 'Liverpool'),
('Thibaut Courtois', 'Goalkeeper', 31, 'Belgium', 'Real Madrid');
CREATE USER 'webuser'@'%' IDENTIFIED BY 'webpassword';
GRANT ALL PRIVILEGES ON football_db.* TO 'webuser'@'%';
FLUSH PRIVILEGES;
EOF

sudo docker cp setup.sql mysql_container:/setup.sql
sudo docker exec -it mysql_container mysql -u root -ppassword < setup.sql
rm setup.sql

# Create PHP application
echo "Creating PHP application..."
mkdir -p web
cat << 'EOF' > web/index.php
<?php
$servername = "mysql_container";
$username = "webuser";
$password = "webpassword";
$dbname = "football_db";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$sql = "SELECT * FROM players";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    echo "<table border='1'>";
    echo "<tr><th>Name</th><th>Position</th><th>Age</th><th>Nationality</th><th>Club</th></tr>";
    while($row = $result->fetch_assoc()) {
        echo "<tr><td>" . htmlspecialchars($row["name"]) . "</td><td>" . 
             htmlspecialchars($row["position"]) . "</td><td>" . 
             htmlspecialchars($row["age"]) . "</td><td>" . 
             htmlspecialchars($row["nationality"]) . "</td><td>" . 
             htmlspecialchars($row["club"]) . "</td></tr>";
    }
    echo "</table>";
} else {
    echo "0 results";
}
$conn->close();
?>
EOF

sudo docker cp web/index.php apache_container:/var/www/html/
rm -rf web

# Install FileZilla
echo "Installing FileZilla FTP client..."
sudo apt install -y filezilla

echo "Setup completed successfully!"
echo "You can now access:"
echo " - Web application: http://localhost:8080/index.php"
echo " - MySQL server: localhost:3306 (user: webuser, password: webpassword)"
echo " - FTP server: localhost:21 (user: admin, password: admin)"
