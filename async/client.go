package main

import (
	"bufio"
	"fmt"
	"net"
	"os"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run client.go <username>")
		os.Exit(1)
	}

	username := os.Args[1]
	conn, err := net.Dial("tcp", "localhost:9000")
	if err != nil {
		fmt.Printf("Error connecting: %s\n", err)
		os.Exit(1)
	}
	defer conn.Close()

	_, err = conn.Write([]byte(username + " has joined the chat\n"))
	if err != nil {
		fmt.Printf("Error writing: %s\n", err)
		os.Exit(1)
	}

	go func() {
		reader := bufio.NewReader(os.Stdin)
		for {
			msg, _ := reader.ReadString('\n')
			_, err := conn.Write([]byte(username + ": " + msg))
			if err != nil {
				fmt.Printf("Error writing: %s\n", err)
				break
			}
		}
	}()

	scanner := bufio.NewScanner(conn)
	for scanner.Scan() {
		fmt.Println(scanner.Text())
	}
}
