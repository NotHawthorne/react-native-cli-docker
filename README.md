# react-native-cli-docker
1. Download the Dockerfile and open up the directory you downloaded it to in terminal.
2. docker-machine create react-native
3. eval $(docker-machine env react-native)
4. docker build -t react-native-latest .
5. docker images -q | head -n 1
6. docker run -it --net host --user="root" <output of last command> bash
7. apt-get update -y
8. apt-get install <vim/emacs, your choice>
9. expo init .
10. awsmobile init .
11. awsmobile run
