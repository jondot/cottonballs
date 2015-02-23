#!/usr/bin/env coffee

express = require 'express'
bodyParser = require 'body-parser'
fs = require 'fs'
sys = require 'sys'
program = require 'commander'
https = require("https")
winston = require 'winston'
_ = require 'underscore'



version = '0.0.1'
program
  .version(version)
  .option('-d, --debug', 'Show various internal messages', false)
  .option('-f, --failure-ratio [float]', 'Failure ratio, 0 to 1. e.g. 0.3 to indicate 30% of IDs are failures', 0)
  .option('-l, --latency [milliseconds]', 'Simlated processing latency', 100)
  .option('-x, --latency-flux [number]', 'Random number from 0..flux to add to latency to simulate variance', 100)
  .option('-c, --crash-ratio [float]', 'Crash ratio 0 to 1 to. e.g. 0.2 to indicate 20% of requests end with 500', 0)
  .option('-p, --port [number]', 'Port to listen on.', 7333)
  .parse(process.argv)

log = new (winston.Logger)({
    transports: [
      new (winston.transports.Console)(timestamp:true, handleExceptions: true)
    ]})

console.log("== CottonBalls v#{version}. Puffy clouds for your GCM. ==") 
console.log("* Running in debug mode.") if program.debug?
console.log("* Listening on port #{program.port}.")
log.info("Starting with f:#{program.failureRatio} l:#{program.latency} x:#{program.latencyFlux} c:#{program.crashRatio}")


app = express({key: privateKey, cert: certificate})
app.use bodyParser.urlencoded({extended: true})
app.use bodyParser.json()


error_types = ['NotRegistered', 'MismatchSenderId']

failed_message = ()->
  { error: _.find error_types, ()-> error_types[Math.floor(Math.random()*error_types.length)] }

passed_message = ()->
  { message_id: "0:#{Math.floor(Math.random()*1e16)}%000000000000babe" }

trace = (x, msg)->
  log.info "[#{x}] #{msg}"

app.post '/*', (req, res)->
  idcount = req.body.registration_ids.length

  failed = Math.floor(program.failureRatio * idcount)
  passed = idcount - failed

  x = "x-#{Math.floor(Math.random()*1e6)}" #trace id

  res.header 'x-cottonballs-id', x
  if req.headers && h = req.headers['x-forwarded-for']
    origin_addr = h
  else
    origin_addr = req.connection.remoteAddress

  trace x, "Originator: #{origin_addr}"

  trace x, "Accepted #{idcount} regids. #{failed} should fail and #{passed} should pass."
  if req.body.collapse_key
    trace x, "Collapse key: [#{req.body.collapse_key}]"
  if req.body.data
    trace x, "Data ==="
    trace x, "#{JSON.stringify(req.body.data)}"
    trace x, "========"

  data = { multicast_id: Math.random()*1e19, success: passed, failure: failed, canonical_ids: 0, results: []}

  _.times failed, ()-> data.results.push failed_message()
  _.times passed, ()-> data.results.push passed_message()
  data.results = _.shuffle data.results

  cb = ()->
    trace x, "Sending out data."
    res.send data

  if Math.random() < program.crashRatio
    trace x, "Simulate: Crashing."
    res.send(500, "")
  else if program.latency > 0
    latency = program.latency+(Math.floor(Math.random()*program.latencyFlux))
    trace x, "Simulate: Latency of #{latency}ms."
    setTimeout cb, latency
  else
    cb()


app.listen(program.port)



privateKey = fs.readFileSync( 'privatekey.pem' ).toString()
certificate = fs.readFileSync( 'certificate.pem' ).toString()
options = {key: privateKey, cert: certificate}
https.createServer( options, (req,res)-> app.handle( req, res )).listen( 443 )

