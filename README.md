# react-native-cli-docker
1. Download the Dockerfile and open up the directory you downloaded it to in terminal.
2. docker-machine create hackathon
3. eval $(docker-machine env hackathon)
4. docker build -t btb .
5. docker images -q | head -n 1
6. docker run -it --net host --user="root" <output of last command> bash
7. apt-get update -y
8. apt-get install <vim/emacs, your choice>
9. expo init .
10. awsmobile init .
11. awsmobile run
