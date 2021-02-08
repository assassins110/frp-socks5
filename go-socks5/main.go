package main

import (
	"fmt"
	"os"

	"./socks5"
)

func main() {
	USER, s := os.LookupEnv("SOCKS_USER")
	if !s {
		USER = "tiger"
	}
	PASS, s := os.LookupEnv("SOCKS_PASS")
	if !s {
		PASS = "9527"
	}
	cred := socks5.StaticCredentials{USER: PASS}
	conf := &socks5.Config{Credentials: cred}
	server, err := socks5.New(conf)
	if err != nil {
		panic(err)
	}
	fmt.Println("Listen: 127.0.0.1:9527")
	// Create SOCKS5 proxy on localhost port 8000
	if err := server.ListenAndServe("tcp", "127.0.0.1:9527"); err != nil {
		panic(err)
	}
}
