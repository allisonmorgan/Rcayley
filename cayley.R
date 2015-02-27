library(httr)
library(jsonlite)

## query, write, delete
Query <- function(host, port, query) {
	url <- paste("http://", host, sep="")
	hostport <- paste(url, port, sep=":")
	endpoint <- paste(hostport, "/api/v1", "/query/gremlin", sep="")
	r <- POST(endpoint, body = query, encode = "json")
	return(fromJSON(content(r)))
}
Query("localhost", "64210", "g.V(\"a\").Out().All()")

Write <- function(host, port, a, b, c) {
	url <- paste("http://", host, sep="")
	hostport <- paste(url, port, sep=":")
	endpoint <- paste(hostport, "/api/v1", "/write", sep="")

	y <- list(list(subject = "a", predicate = "relates", object = "b", label = "."))
	r <- POST(endpoint, body = toJSON(y, auto_unbox=TRUE), encode = "json")
	return(fromJSON(content(r)))
}
Write("localhost", "64210", "a", "relates", "b")
Query("localhost", "64210", "g.V(\"a\").Out().All()")

Delete <-function(host, port, a, b, c) {
	url <- paste("http://", host, sep="")
	hostport <- paste(url, port, sep=":")
	endpoint <- paste(hostport, "/api/v1", "/delete", sep="")

	y <- list(list(subject = a, predicate = b, object = c, label = "."))
	r <- POST(endpoint, body = toJSON(y, auto_unbox=TRUE), encode = "json")
	return(fromJSON(content(r)))
}
Delete("localhost", "64210", "a", "relates", "b")
Query("localhost", "64210", "g.V(\"a\").Out().All()")
