#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "========================================"
echo "       INCEPTION TEST SUITE             "
echo "========================================"

# 1. Check Containers
echo -n "Checking containers status... "
if [ $(docker ps -q | wc -l) -eq 9 ]; then
	echo -e "${GREEN}PASS (9/9 Running)${NC}"
else
	echo -e "${RED}FAIL (Not all 9 containers are running)${NC}"
fi

# 2. Check NGINX & WordPress
echo -n "Checking NGINX & WordPress (HTTPS)... "
HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}\n" -k https://eala-lah.42.fr)
if [ "$HTTP_CODE" -eq 200 ] || [ "$HTTP_CODE" -eq 301 ]; then
	echo -e "${GREEN}PASS (HTTP $HTTP_CODE)${NC}"
else
	echo -e "${RED}FAIL (HTTP $HTTP_CODE)${NC}"
fi

# 3. Check MariaDB
echo -n "Checking MariaDB access... "
if docker exec mariadb mariadb -u wp_user -p"$(cat secrets/db_user_password.txt)" -e "SHOW DATABASES;" > /dev/null 2>&1; then
	echo -e "${GREEN}PASS${NC}"
else
	echo -e "${RED}FAIL${NC}"
fi

# 4. Check Redis
echo -n "Checking Redis Cache... "
if docker exec wordpress php /usr/local/bin/wp redis status --allow-root | grep -q "Status: Connected"; then
	echo -e "${GREEN}PASS${NC}"
else
	echo -e "${RED}FAIL${NC}"
fi

# 5. Check FTP
echo -n "Checking FTP access... "
if curl -s ftp://localhost:21 --user "ftp_user:$(cat secrets/ftp_password.txt)" | grep -q "wp-config.php"; then
	echo -e "${GREEN}PASS${NC}"
else
	echo -e "${RED}FAIL${NC}"
fi

# 6. Check Adminer
echo -n "Checking Adminer (Port 8080)... "
HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}\n" -I http://localhost:8080)
if [ "$HTTP_CODE" -eq 200 ]; then
	echo -e "${GREEN}PASS${NC}"
else
	echo -e "${RED}FAIL${NC}"
fi

# 7. Check Static Site
echo -n "Checking Static Site (Port 8081)... "
HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}\n" -I http://localhost:8081)
if [ "$HTTP_CODE" -eq 200 ]; then
	echo -e "${GREEN}PASS${NC}"
else
	echo -e "${RED}FAIL${NC}"
fi

# 8. Check GoAccess
echo -n "Checking GoAccess (Port 7890 WebSocket)... "
HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}\n" -I http://localhost:7890)
if [ "$HTTP_CODE" -eq 400 ]; then
	echo -e "${GREEN}PASS (HTTP 400 Expected for WS)${NC}"
else
	echo -e "${RED}FAIL (HTTP $HTTP_CODE)${NC}"
fi

# 9. Check Cowsay
echo -n "Checking Cowsay (Port 4243)... "
if nc -vz localhost 4243 > /dev/null 2>&1; then
	echo -e "${GREEN}PASS${NC}"
else
	echo -e "${RED}FAIL${NC}"
fi

# 10. Check PID 1 Isolation
echo -n "Checking NGINX PID 1 isolation... "
if docker exec nginx ps -o pid,comm | grep -q "^    1 nginx"; then
	echo -e "${GREEN}PASS${NC}"
else
	echo -e "${RED}FAIL${NC}"
fi

# 11. Check Alpine Version
echo -n "Checking Alpine Version (3.22.x)... "
if docker exec wordpress cat /etc/os-release | grep -q "3.22"; then
	echo -e "${GREEN}PASS${NC}"
else
	echo -e "${RED}FAIL${NC}"
fi

echo "========================================"
echo "       TESTING COMPLETE                 "
echo "========================================"
