package main

import (
	"fmt"

	"./greeter" // Here i am using a local folder package ref, this is unusual, usually want a path relative to $GOROOT/src
)

func main() {
	prefixedGreeting := getPrefixedGreeting("---> ", "Ted")
	fmt.Println(prefixedGreeting)
}

func getPrefixedGreeting(prefix, name string) string { // Since bot prefix and name are the same type here i can just give the type once
	return prefix + greeter.GetGreeting(name)
}
