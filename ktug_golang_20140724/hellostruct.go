// Once go is on your path, should be able to run with : go run hellostruct.go
package main

import "fmt"

// Interface type, using lowercase h to again make private to the current package
type howler interface {
	howl() string // Single method that returns a single string
}

// Struct type, using lowercase p to again make private to the current package
type person struct {
	name string
	age  int
}

// Function which is attached to the person struct, note not using a pointer here so we cannot mutate, if we want to mutate use a pointer receiver i.e. *person
func (self person) String() string {
	return fmt.Sprintf("%s is %d years old", self.name, self.age)
}

// Function which is attached to the person struct and matches the howler interface
func (self person) howl() string {
	return fmt.Sprintf("%v !!!!!!!!!!!", self)
}

func main() {
	var name string // Need vars so we can store scanf results
	var age int

	// Read some input
	fmt.Print("Gimme name :")
	fmt.Scanf("%s", &name) // Using a specific verb and passing a pointer to the name var
	fmt.Print("Gimme age :")
	fmt.Scanf("%d", &age) // Different verb for a number

	p := person{name: name, age: age} // Using composite literal to create with named members, could pass just vals based on sequence, if using named members can do so in any order, could use new(person) which would give us a pointer

	fmt.Printf("p %v\n", p) // Toggle String() method name to show how person is satisying the stringer interface and how this affects output

	fmt.Println()
	passByVal(p)
	fmt.Printf("\tp after passByVal : %v\n", p)

	fmt.Println()
	passByPointer(&p) // Need &p to get a pointer to p as the function expects a *person
	fmt.Printf("\tp after passByPointer : %v\n", p)

	fmt.Println()
	makeHowlerHowl(p) // Pass person to function expecting an interface, since person has a howl method that matches the interface we are good
}

func passByVal(p person) {
	p.name = "passByVal"
	fmt.Printf("\tp within passByVal %v\n", p)
}

func passByPointer(p *person) {
	p.name = "passByPointer"
	fmt.Printf("\tp within passByPointer %v\n", p)
}

func makeHowlerHowl(h howler) {
	fmt.Printf("\tHOWLER howls [%s]\n", h.howl())
}
