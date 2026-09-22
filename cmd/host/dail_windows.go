package main

import (
	"net"

	"github.com/Microsoft/go-winio"
)

func Dial() (net.Conn, error) {
	return winio.DialPipe(`\\.\pipe\ponydownloader_host`, nil)
}
