# Rcayley
R client for the graph database [Cayley](https://github.com/google/cayley)

# Quick Start

## Install Cayley and Load Data

Grab the latest version of Cayley: `go get github.com/google/cayley`. From the cayley directory, load up some test data by running: `go build . && ./cayley http --dbpath=30kmoviedata.nq`. Now you have started a local Cayley server which you can access via `localhost:64210`. More information [here](https://github.com/google/cayley#getting-started).

## API Requests

You can query, write, and delete nodes within R in the Cayley database you've just created. 

To query: 
```{R}
Query("localhost", "64210", "g.V(\"a\").Out().All()")
```

(This should return "null".)

To write (and check that it's written):
```{R}
Write("localhost", "64210", "a", "relates", "b")
Query("localhost", "64210", "g.V(\"a\").Out().All()")
```

To delete (cand check that it's been deleted):
```{R}
Delete("localhost", "64210", "a", "relates", "b")
Query("localhost", "64210", "g.V(\"a\").Out().All()")
```
