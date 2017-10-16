all: sendfile recvfile

sendfile: bin/sender.o bin/sender_socket.o bin/file.o bin/receiver_socket.o bin/packet.o bin/receiver_window.o bin/ack.o bin/sender_window.o
	@echo "Linking sendfile ..."
	@g++ bin/sender.o bin/sender_socket.o bin/file.o bin/receiver_socket.o bin/packet.o bin/receiver_window.o bin/ack.o bin/sender_window.o -o sendfile -g

recvfile: bin/receiver.o bin/sender_socket.o bin/file.o bin/receiver_socket.o bin/packet.o bin/receiver_window.o bin/ack.o bin/sender_window.o
	@echo "Linking recvfile ..."
	@g++ bin/receiver.o bin/sender_socket.o bin/file.o bin/receiver_socket.o bin/packet.o bin/receiver_window.o bin/ack.o bin/sender_window.o -o recvfile -g

bin/sender.o: src/sender.cpp
	@echo "Compiling sender.cpp ..."
	@g++ -c src/sender.cpp -o bin/sender.o 

bin/sender_socket.o: src/sender_socket.cpp src/sender_socket.h
	@echo "Compiling sender_socket.cpp ..."
	@g++ -c src/sender_socket.cpp -o bin/sender_socket.o 

bin/file.o: src/file.cpp src/file.h
	@echo "Compiling file.cpp ..."
	@g++ -c src/file.cpp -o bin/file.o 

bin/receiver_socket.o: src/receiver_socket.cpp src/receiver_socket.h
	@echo "Compiling receiver_socket.cpp ..."
	@g++ -c src/receiver_socket.cpp -o bin/receiver_socket.o 

bin/packet.o: src/packet.cpp src/packet.h
	@echo "Compiling packet.cpp ..."
	@g++ -c src/packet.cpp -o bin/packet.o 

bin/receiver_window.o: src/receiver_window.cpp src/receiver_window.h
	@echo "Compiling receiver_window.cpp ..."
	@g++ -c src/receiver_window.cpp -o bin/receiver_window.o 

bin/ack.o: src/ack.cpp src/ack.h
	@echo "Compiling ack.cpp ..."
	@g++ -c src/ack.cpp -o bin/ack.o 

bin/receiver.o: src/receiver.cpp src/receiver_window.h
	@echo "Compiling receiver.cpp ..."
	@g++ -c src/receiver.cpp -o bin/receiver.o 

bin/sender_window.o: src/sender_window.cpp
	@echo "Compiling sender_window.cpp ..."
	@g++ -c src/sender_window.cpp -o bin/sender_window.o 

.PHONY: clean all

clean:
	@echo "Removing object files ..."
	@rm -rf bin/*.o

	@echo "Removing executables ..."
	@rm -rf sendfile recvfile