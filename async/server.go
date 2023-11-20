package main

import (
	"fmt"
	"net"
	"os"
)

var (
	clients = make(map[net.Addr]net.Conn)
)

func handleConnection(conn net.Conn) {
	fmt.Printf("Connected: %s\n", conn.RemoteAddr())

	clients[conn.RemoteAddr()] = conn

	for {
		buf := make([]byte, 1024)
		n, err := conn.Read(buf)
		if err != nil {
			fmt.Printf("Error reading: %s\n", err)
			break
		}

		if n > 0 {
			msg := string(buf[:n])
			fmt.Printf("Received from %s: %s", conn.RemoteAddr(), msg)

			for _, client := range clients {
				if client != conn {
					_, err := client.Write([]byte(msg))
					if err != nil {
						fmt.Printf("Error writing: %s\n", err)
						delete(clients, client.RemoteAddr())
					}
				}
			}
		}
	}
	conn.Close()
	delete(clients, conn.RemoteAddr())
	fmt.Printf("Disconnected: %s\n", conn.RemoteAddr())
}

func main() {
	listener, err := net.Listen("tcp", "localhost:9000")
	if err != nil {
		fmt.Printf("Error listening: %s\n", err)
		os.Exit(1)
	}
	defer listener.Close()
	fmt.Println("Server is listening on localhost:9000")

	for {
		conn, err := listener.Accept()
		if err != nil {
			fmt.Printf("Error accepting connection: %s\n", err)
			continue
		}
		go handleConnection(conn)
	}
}
