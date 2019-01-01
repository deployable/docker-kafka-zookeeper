const Buffermaker = require('buffermaker')

// https://cwiki.apache.org/confluence/display/KAFKA/A+Guide+To+The+Kafka+Protocol

const kafka_port = 9093
const API_VERSION = 0

// functions are MIT - Copyright (c) 2015 sohu.com - https://github.com/SOHU-Co/kafka-node
function encodeRequestHeader (clientId, correlationId, apiKey, apiVersion) {
  return new Buffermaker()
    .Int16BE(apiKey)
    .Int16BE(apiVersion || API_VERSION)
    .Int32BE(correlationId)
    .Int16BE(clientId.length)
    .string(clientId).make()
}

function encodeRequestWithLength (request) {
  return new Buffermaker().Int32BE(request.length).string(request).make();
}


// send an apiversions request and dump the response
// 18 is an `ApiVersions` request - https://kafka.apache.org/protocol#protocol_api_keys

let req = encodeRequestHeader('meee', 1, 18)
req = encodeRequestWithLength(req)
console.log(req.toString('hex'))

let socket = require('net').connect(kafka_port, 'localhost')
socket.on('connect', ()=> socket.write(req))
socket.on('data', data => {
  console.log('got response of %s\n%s\n%s', data.length, data.toString('hex'), data.readUInt32BE(0))
  socket.end()
})
