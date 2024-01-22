#  Swift library test automation

## Description

Due the lack of BDD frameworks that allows swift libraries to be tested this framework was built using concepts of:

- Cucumber
- SerenityBDD

## Getting started

The lifecycle of the framework is based on XCTest lifecycle.

The `TestFramework` provides a base configuration class named `TestConfiguration` which must be extended.

For now, only `1` child class is supported and we'll refer to that class as `Configuration`.

```swift
class MyConfig: TestConfiguration {
    // ...
}
```

### Defining the actors

To create the `actors`, in the `Configuration` file you should override the base class method `createActors()`

```swift
    override func createActors() async throws -> [Actor]  {
        let actor1 = Actor("Bob").whoCanUse(MyCustomAbility.self)
        let actor2 = Actor("Alice").whoCanUse(OtherCustomAbility.self )
        return [actor1, actor2]
    }
```

### Defining parsers

Parsers are a method that enable us to convert the data provided in step to parameterized arguments in steps

To parameterize a step we use curly brackets and the type inside (`{type}`). For example: `{actor} counts to {int}`

If no `type` is inside the curly brackets, the framework will use `string` as default.

Parsers that are native to the framework:

- String: converts the value to `string`
- Int: converts the value to `int`
- Actor: converts the value to an existing `actor`. Note: the actor must exist.

To declare new parsers in the `Configuration` class you can add a new parser as the following example:

```swift
    @ParameterParser
    var test = { (data: String) in
        return MyCustomType(data: data)
    }
```

### Defining reporter

In the `Configuration` file you have to setup the reporters you want. By default it's `JunitReporter` and `HtmlReporter`.

Example:

```swift
    override func createReporters() async throws -> [Reporter] {
        return [DotReporter(), HtmlReporter()]
    }
```

### Defining the steps

To create steps using the framework you should extend the `Steps` class and define the `Step` variables through annotation.

Here's an example:

```swift
class MyCustomSteps: Steps {
    @Step("The {actor} counts to {int}")
    var theActorCountsToANumber = { (myActor: Actor, number: Int) in
        <#code#>
    }
    // ...
}
```

### Defining the feature

Extends `Feature` class and override the `title` and optionally the `description`.

```swift
class MyFeature: Feature {
    override func title() -> String {
        "My custom feature"
    }
    
    override func description() -> String {
        "My custom feature description"
    }
    
    // ...
}
```

### Defining the scenario

Inside the `Feature` we define the scenarios that will be executed.

```swift
class MyFeature: Feature {
    // ...
    
    func myTestCase() async throws {
        currentScenario = Scenario("My custom scenario")
            .given("Bob knows how to count")
            .when("Bob counts to 10")
            .then("The system should have waited at least 10 seconds")
    }
}
```

## Additional information

### Defining the abilities

Abilities are a concept inherited from `Serenity BDD`. This allows the `actors` to execute commands only if they have the ability to.

#### Adding the ability to the actor

You can add an ability to the `Actor` using the method `whoCanUse`

```swift
    let myActor = Actor("My Actor").whoCanUse(MyAbility.self)
```

or adding to an existing `Actor`:

```swift
    myActor.whoCanUse(MyAbility.self)
```

### Defining reporters

For now we currently have these reporters built-in:

- DotReporter
- JunitReporter
- HtmlReporter

#### Dot reporter

Simple reporter that prints `.` for the actions taken during the test and prints the overall results.

#### Junit reporter

Generates the result in a `junit.xml` format. That can be used in CI/CD tools.

The result is available in ``.

Example output:

```xml
```

#### HTML reporter

Generates a readable report with the steps executed and its results.

Note: For now it's a plain txt file.

#### Creating a custom reporter

To create a custom reporter you have to create the class and extend the `Reporter` base class and implement the protocol methods.

```swift
class MyCustomReporter: Reporter {
    func beforeFeature(_ feature: Feature) async throws {
        <#code#>
    }
    
    // ...
}
```

## Disclaimer

The framework is still evolving

## References

Cucumber - https://cucumber.io/docs/cucumber/
Serenity screenplay - https://serenity-bdd.github.io/docs/screenplay/screenplay_fundamentals
