// Conditions
String title = "iOS"
if (title.equals("iOS")) {
    System.out.println("Good choice");
}
else {
    System.out.println("Maybe next time")
}

// Arrays
int[] values = new int[]{1,2,3}
for (int i = 0; i < values.length; i++) {
    System.out.println(i);
}

//Lists
List<String> values = new ArrayList<>();
values.add("one");
values.add("two");
for (String value : values) {
    System.out.println(value);
}

// Generics
List<String> strings = new ArrayList<>();
List<Integer> integers = new ArrayList<>();

// Maps
Map<String, String> airports = new Hashmap<>();
airports.put("SFO"; "San Francisco");
airports.put("BOS", "Boston");
for (Map.Entry<String, String> e: airports.entrySet()) {
    System.out.println(e.getKey() + ": " + e.getValue());
}

// Classes
public class Person { //public is a global variable declaration that allow other function to use it while private is for specific use
    String name; // take one parameter call name and it's a string
    Person(String name) { // method of saying that the value name is whatever the user input
        this.name = name;
    }
}
Person person = new Person("Tommy") // Use of class: object of a class is at the lower case

// Methods
public class Person {
    ...
    public void sayHello() {
        System.out.println("I'm " + name):
    }
}

Person person = new Person("Tommy");
person.sayHello();

// Static Methods
public class Person {
    ...
    public static void wave() {
        System.out.println("Wave");
    }
}
Person.wave();

// Inheritenace
public class Vehicle {
    public int wheels() { // public that return an integer
        return 4;
    }
    public void go() {
        System.out.println("zoom!");
    }
}

public class Motorcycle extends Vehicle { //subclass of Vehicle: means that Motocycle can access to any element of the Vehicle class
    @Override //signal to the compile that I overide a method
    public int wheels () {
        return 2;
    }
}

// Interfaces

public interface Teacher { //list of method that some class need to element
    public void teach();
}

public class CS50Teacher implements Teacher {
    @Override
    public void teach() {
        ...
    }
}

List<String> strings = new ArrayList<>(); // a concrete class

// Packackages

package edu.havard.cs50.example;
import java.util.List

// 1. Gradle: Android build System taking care of compiling and downloading library
// 2. MVC: Model View Controller
// Model is the data that the need to display. 
// View how the model is gonna display.
// Controller like the bridge from the model and the view.
// 3. Activity. Each Screen represent one thing that you want to do.
// 4. Resources. All the other stuff that is not Java stuff. For example: XML.
// 5. Intents
// 6. Recycle Views. Gonna load the things that are allowed to display on the views.