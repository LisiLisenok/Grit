Grit is multithread asynchronous reactive library for the Flash platform.

Consists of following parts:
* collections with synchronous access
* asynchronous emission of stream (or train) of values
* promise or value that may not be available yet 
* triggering operations
* secondary thread (worker) manager
* tasks deploying on secondary thread and exchange data between tasks in asynchronous way.
  Only one additional to main thread (worker) is used to run any number of tasks.
  Any task must run in non-blocking way to get another tasks be performed

###project structure:
* [Examples folder](Examples) - examples of the Grit usage
* [GritWire folder](GritWire) - Grit source code
* [Lib folder](Lib) contains .swc files with Grit library and some additional libraries (tasks which may be deployed within Grit)
* [Tasks folder](Tasks) - some tasks can be deployed within Grit. Each task is compiled to separated .swc library
* [Doc folder](doc) - Grit AS3 documentation


If you are interested in wiki documentation of this project please leave a comment in [this issue](../../issues/1)
If you have an idea of enhancement with new feature please open an issue
