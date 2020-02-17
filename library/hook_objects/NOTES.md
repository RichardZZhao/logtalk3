________________________________________________________________________

This file is part of Logtalk <https://logtalk.org/>  
Copyright 1998-2020 Paulo Moura <pmoura@logtalk.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
________________________________________________________________________


`hook_objects`
==============

This library provides a set of convenient hook objects for defining custom
expansion workflows (using e.g. the `hook_flows` library).


API documentation
-----------------

Open the [../../docs/library_index.html#hook_objects](../../docs/library_index.html#hook_objects)
link in a web browser.


Loading
-------

To load all hook objects in this library, load the `loader.lgt` file:

	| ?- logtalk_load(hook_objects(loader)).

To load a specific hook object, e.g. the `backend_adapter_hook` object:

	| ?- logtalk_load(hook_objects(backend_adapter_hook)).


Testing
-------

To test this library hook objects, load the `tester.lgt` file:

	| ?- logtalk_load(hook_objects(tester)).


Usage
-----

The provided hook objects cover different expansion scenarios as follows:

1. Using the Prolog backend adapter file expansion rules when defining
a custom expansion workflow. This can be accomplished by loading the
`backend_adapter_hook.lgt` file, which defines a `backend_adapter_hook`
hook object that can be used as a workflow step.

2. Restore the default compiler expansion workflow. In this case, load the
`default_workflow_hook.lgt` file, which defines a `default_workflow_hook`
hook object, and use the following **goal** to set the default hook object:

		| ?- set_logtalk_flag(hook, default_workflow_hook).

3. Prevent applying any (other) user-defined expansion rules when compiling
a source file. Simply load the `identity_hook.lgt` file, which defines the
`identity_hook` hook object, whose expansion rules simply succeed without
changing the terms and goals, and set it as the file specific hook object
writing as the first term in the file the **directive**:

		:- set_logtalk_flag(hook, identity_hook).

Note that the compiler will always convert any grammar rules defined in
the file into clauses. Although this conversion can also be performed as
an expansion, grammar rules are part of the Logtalk language. If you to
preserve the grammar rules, use the hook objects described below to write
them to a stream.

4. Expand grammar rules into clauses independently of the compiler by
loading the `grammar_rules_hook.lgt` and using the term-expansion rules
in the `grammar_rules_hook` object. For example:

		| ?- grammar_rules_hook::term_expansion((a --> [b],c), Clause).
		
		Clause = (a([b|T], C) :- c(T, C))
		yes

5. Use the expansion rules defined in a Prolog module (which can be `user`)
by loading the `prolog_module_hook.lgt`, which defines the parametric hook
object `prolog_module_hook(Module)`. to use this hook object, you need to
instantiate the parameter to the name of the module. For example:

		:- set_logtalk_flag(hook, prolog_module_hook(user)).

6. Output term-expansion results to a stream by loading the
`write_to_stream_hook.lgt` file and using the `write_to_stream_hook(Stream)`
or `write_to_stream_hook(Stream, Options)` hook object. The terms are not
modified and thus these hook objects may be used at any point in an expansion
workflow.