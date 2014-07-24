package greeter

import (
	"fmt"
)

func GetGreeting(name string) string { // This time we need capital so the function is exported for other packages to use
	return fmt.Sprintf("Hello %s", name)
}
