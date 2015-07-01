Grit is asynchronous reactive library.

Consists of following parts:
* collections with synchronous access
* asynchronous emission of stream (or train) of values
* promise or value that may not be available yet 
* triggering operations
* secondary thread manager
* tasks deploying on secondary thread  and exchange data between tasks in asynchronous way.
Only one additional to main thread is used to run any number of tasks.
Any task must run in non-blocking way to get another tasks be performed




