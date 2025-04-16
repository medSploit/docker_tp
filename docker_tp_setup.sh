#!/bin/bash
echo "automated script: docker Tp by med_oussalh"
sleep 2
sudo apt update
##pulling images:
echo "pulling images !!!!"
sudo docker pull mysql:latest
sudo docker pull php:apache
sudo docker pull delfer/alpine-ftp-server
##PHP + Apache + MySQLi:
echo "adding exetension mysqli to apache:php"
sleep 2
touch Dockerfile
echo "FROM php:apache

RUN docker-php-ext-install mysqli

RUN docker-php-ext-enable mysqli" > Dockerfile
sudo docker build -t apache_mysqli .
##docker network
echo "creating network for containers"
sleep 2
sudo docker network create my_network
##create containers
echo"creating containers!!!"
sleep 2
sudo docker run -d --name mysql_container --network my_network -e MYSQL_ROOT_PASSWORD=password -p 3306:3306 mysql:latest
sudo docker run -d --name apache_container --network my_network -p 8080:80 -v /var/www/html apache_mysqli
sudo docker run -d --name ftp_container --network my_network -v /home/ftp -p 21:21 -p  21100-21110:21100-21110 -e FTP_USER=user -e FTP_PASS=password delfer/alpine-ftp-server
##start conatiners
sudo docker start mysql_container
sudo docker start apache_container
sudo docker start ftp_container
##mysql database
echo "setup up the mysql db!!!"
sleep 2
echo "CREATE DATABASE IF NOT EXISTS football_db;
USE football_db;
CREATE TABLE IF NOT EXISTS players (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    position VARCHAR(50),
    age INT,
    natatinality VARCHAR(50),
    club VARCHAR(100)
);
INSERT INTO players (name, position, age, nationality, club) VALUES
('Lionel Messi', 'Forward', 36, 'Argentina', 'Inter Miami'),
('Kylian MbappÃ©', 'Forward', 25, 'France', 'Paris Saint-Germain'),
('Kevin De Bruyne', 'Midfielder', 32, 'Belgium', 'Manchester City'),
('Virgil van Dijk', 'Defender', 32, 'Netherlands', 'Liverpool'),
('Thibaut Courtois', 'Goalkeeper', 31, 'Belgium', 'Real Madrid');
CREATE USER 'webuser'@'%' IDENTIFIED BY 'webpassword';
GRANT ALL PRIVILEGES ON football_db.* TO 'webuser'@'%';
FLUSH PRIVILEGES;
exit" > setup.sql
sudo docker cp setup.sql mysql_container:/setup.sql
sudo docker  exec -it mysql_container mysql -u root -ppassword < setup.sql
##apache_container
echo "creating index.php"
sleep 2
touch index.php
echo " <?php
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
        echo "<tr><td>" . $row["name"]. "</td><td>" . $row["position"]. "</td><td>" . $row["age"]. "</td><td>" . $row["nationality"]. "</td><td>" . $row["club"]. "</td></tr>";
    }
    echo "</table>";
} else {
    echo "0 results";
}
$conn->close();
?> " >> index.php
path=$(pwd)
sudo docker cp $path/index.php apache_container:/var/www/html/
echo "Visit http://localhost:8080/index.php"
sleep 5
##ftp_container
echo "install ftp client filezilla"
sleep 2
sudo apt install filezilla
