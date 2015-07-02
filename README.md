Grit is multithread asynchronous reactive library written on AS3.

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
* <a href="https://github.com/LisiLisenok/Grit/tree/master/Examples">Examples folder</a> contains examples of the Grit usage
* <a href="https://github.com/LisiLisenok/Grit/tree/master/GritWire">GritWire folder</a> contains Grit source code
* <a href="https://github.com/LisiLisenok/Grit/tree/master/Lib">Lib folder</a> contains .swc files with Grit library and some additional libraries (tasks which may be deployed within Grit)
* <a href="https://github.com/LisiLisenok/Grit/tree/master/Tasks">Tasks folder</a> some tasks can be deployed within Grit. Each task is compiled to separated .swc library
* <a href="https://github.com/LisiLisenok/Grit/tree/master/doc">doc folder</a> Grit AS3 documentation


