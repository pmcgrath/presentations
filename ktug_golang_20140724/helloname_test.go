package main

import (
	"fmt"
	"testing"
)

func TestgetGreeting(t *testing.T) {
	name := "Ted"

	greeting := getGreeting(name)
	fmt.Println(greeting)
	if greeting != "" {
		t.Errorf("log output should match %q is %q", pattern, line)
	}
}
