# Flutter Mobx State Management Example

# Introduction

MobX is a state-management library that makes it simple to connect the reactive data of your application with the UI. This wiring is completely automatic and feels very natural. As the application-developer, you focus purely on what reactive-data needs to be consumed in the UI (and elsewhere) without worrying about keeping the two in sync.

It's not really magic but it does have some smarts around what is being consumed (observables) and where (reactions), and automatically tracks it for you. When the observables change, all reactions are re-run. What's interesting is that these reactions can be anything from a simple console log, a network call to re-rendering the UI.

MobX has been a very effective library for the JavaScript apps and this port to the Dart language aims to bring the same levels of productivity.
Go deep

For a deeper coverage of MobX, do check out MobX Quick Start Guide. Although the book uses the JavaScript version of MobX, nearly all of the concepts are applicable to Dart and Flutter.

## Core Concepts

At the heart of MobX are three important concepts: Observables, Actions and Reactions.

Observables

Observables represent the reactive-state of your application. They can be simple scalars to complex object trees. By defining the state of the application as a tree of observables, you can expose a reactive-state-tree that the UI (or other observers in the app) consume.

A simple reactive-counter is represented by the following observable:

   `import 'package:mobx/mobx.dart';
    final counter = Observable(0);`

More complex observables, such as classes, can be created as well.

   `class Counter {
   Counter() {
   increment = Action(_increment);
   }
   final _value = Observable(0);
   int get value => _value.value;
   set value(int newValue) => _value.value = newValue;
   Action increment;
   void _increment() {
   _value.value++;
   }
   }`

On first sight, this does look like some boilerplate code which can quickly go out of hand! This is why we added mobx_codegen to the mix that allows you to replace the above code with the following:

   `import 'package:mobx/mobx.dart';
    part 'counter.g.dart';
    class Counter = CounterBase with _$Counter;
    abstract class CounterBase with Store {
    @observable
    int value = 0;
    @action
    void increment() {
    value++;
    }
    }`

Note the use of annotations to mark the observable properties of the class. Yes, there is some header boilerplate here but its fixed for any class. As you build more complex classes this boilerplate will fade away and you will mostly focus on the code within the braces.

Note: Annotations are available via the mobx_codegen package.

Readonly

If you want to reduce your code you may want to swap @observable for @readonly. For every private variable it generates a public getter such that the client of your store can't change its value. Read more about it here

Computed Observables

What can be derived, should be derived. Automatically.
The state of your application consists of core-state and derived-state. The core-state is state inherent to the domain you are dealing with. For example, if you have a Contact entity, the firstName and lastName form the core-state of Contact. However, fullName is derived-state, obtained by combining firstName and lastName.

Such derived state, that depends on core-state or other derived-state is called a Computed Observable. It is automatically kept in sync when its underlying observables change.

State in MobX = Core-State + Derived-State

   `import 'package:mobx/mobx.dart';
    part 'counter.g.dart';
    class Contact = ContactBase with _$Contact;
    abstract class ContactBase with Store { 
    @observable
    String firstName;
    @observable
    String lastName;
    @computed
    String get fullName => '$firstName, $lastName';
    }`

In the example above fullName is automatically kept in sync if either firstName and/or lastName changes.

Actions

Actions are how you mutate the observables. Rather than mutating them directly, actions add a semantic meaning to the mutations. For example, instead of just doing value++, firing an increment() action carries more meaning. Besides, actions also batch up all the notifications and ensure the changes are notified only after they complete. Thus the observers are notified only upon the atomic completion of the action.

Note that actions can also be nested, in which case the notifications go out when the top-most action has completed.

   `final counter = Observable(0);
    final increment = Action((){
    counter.value++;
    });`

When creating actions inside a class, you can take advantage of annotations!

   `import 'package:mobx/mobx.dart';
    part 'counter.g.dart';
    class Counter = CounterBase with _$Counter;
    abstract class CounterBase with Store { 
    @observable 
    int value = 0;
    @action
    void increment() {
    value++;
    }
    }`

Reactions

Reactions complete the MobX triad of observables, actions and reactions. They are the observers of the reactive-system and get notified whenever an observable they track is changed. Reactions come in few flavors as listed below. All of them return a ReactionDisposer, a function that can be called to dispose the reaction.

One striking feature of reactions is that they automatically track all the observables without any explicit wiring. The act of reading an observable within a reaction is enough to track it!

The code you write with MobX appears to be literally ceremony-free!
ReactionDisposer autorun(Function(Reaction) fn)

Runs the reaction immediately and also on any change in the observables used inside fn.


   `import 'package:mobx/mobx.dart';
    final greeting = Observable('Hello World'); 
    final dispose = autorun((_){
    print(greeting.value);
    }); 
    greeting.value = 'Hello MobX';
    // Done with the autorun()
    dispose();
    // Prints:
    // Hello World
    // Hello MobX`

   `ReactionDisposer reaction<T>(T Function(Reaction) fn, void Function(T) effect)`

Monitors the observables used inside the fn() function and runs the effect() when the fn() function returns a different value. Only the observables inside fn() are tracked.

   `import 'package:mobx/mobx.dart';
    final greeting = Observable('Hello World');
    final dispose = reaction((_) => greeting.value, (msg) => print(msg));
    greeting.value = 'Hello MobX'; // Cause a change
    // Done with the reaction()
    dispose();
    // Prints:
    // Hello MobX`

   `ReactionDisposer when(bool Function(Reaction) predicate, void Function() effect)`

Monitors the observables used inside predicate() and runs the effect() when it returns true. After the effect() is run, when automatically disposes itself. So you can think of when as a one-time reaction. You can also dispose when() pre-maturely.


   `import 'package:mobx/mobx.dart';
    final greeting = Observable('Hello World'); 
    final dispose = when((_) => greeting.value == 'Hello MobX', () => print('Someone greeted MobX')); 
    greeting.value = 'Hello MobX'; // Causes a change, runs effect and disposes
    // Prints:
    // Someone greeted MobX`


Observer

One of the most visual reactions in the app is the UI. The Observer widget (which is part of the flutter_mobx package), provides a granular observer of the observables used in its builder function. Whenever these observables change, Observer rebuilds and renders.

Below is the Counter example in its entirety.

   `import 'package:flutter/material.dart';
    import 'package:flutter_mobx/flutter_mobx.dart';
    import 'package:mobx/mobx.dart';
    part 'counter.g.dart';
    class Counter = CounterBase with _$Counter;
    abstract class CounterBase with Store {
    @observable
    int value = 0;
    @action
    void increment() {
    value++;
    }
    }
    class CounterExample extends StatefulWidget {
    const CounterExample({Key key}) : super(key: key);
    @override 
    _CounterExampleState createState() => _CounterExampleState();
    }
    class _CounterExampleState extends State<CounterExample> { 
    final _counter = Counter();
    @override
    Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
    title: const Text('Counter'),
    ),
    body: Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
    const Text(
    'You have pushed the button this many times:',
    ),
    Observer(
    builder: (_) => Text(
    '${_counter.value}',
     style: const TextStyle(fontSize: 20),
     )),
    ],
    ),
    ),
    floatingActionButton: FloatingActionButton(
    onPressed: _counter.increment,
    tooltip: 'Increment',
    child: const Icon(Icons.add),
    ),
    );
    }`


