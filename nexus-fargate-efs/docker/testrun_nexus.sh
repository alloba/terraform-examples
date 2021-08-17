docker build -t "nexus-test" .

# -d=detached, -p=port
docker run -dp 8081:8081 nexus-test