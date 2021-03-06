#!/usr/bin/env Rscript


## ---- load packages ----

library(RestRserve)


## ---- create application -----

app = Application$new(content_type = "application/json", middleware = list())


## ---- register endpoints and corresponding R handlers ----

app$add_get("/json", function(request, response) {
  response$body = list(answer = "json")
})

app$add_get("/text", function(request, response) {
  response$content_type = "text/plain"
  response$body = list(answer = "text")
})

app$add_get("/unknown-content-type", function(request, response) {
  response$content_type = "application/x-unknown-content-type"
  # content types which are not registered in ContentHandlers
  # will be encoded as character!
  response$body = serialize("unknown-content-type", NULL)
})

app$add_get("/rds", function(request, response) {
  response$content_type = "application/rds"
  response$body = serialize(list(answer = "rds"), NULL)
  # to prevent default `as.character()` encoding for unknown content type
  # we need to provide `identity()` as encode function
  response$encode = identity
})

app$add_get("/rds2", function(request, response) {
  response$content_type = "application/rds2"
  response$body = serialize(list(answer = "rds2"), NULL)
})

app$add_post("/json", function(request, response) {
  response$content_type = "application/rds"
  response$body = serialize(request$body, NULL)
})


## ---- register custom content handlers ----

# Note that new content handler can be registered at any time before application start
enc_dec_mw = EncodeDecodeMiddleware$new()
enc_dec_mw$ContentHandlers$set_encode("application/rds2", identity)
enc_dec_mw$ContentHandlers$set_encode("application/rds", identity)
app$append_middleware(enc_dec_mw)

## ---- start application ----
backend = BackendRserve$new()
# backend$start(app, http_port = 8080)
