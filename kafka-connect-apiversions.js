const Buffermaker = require('buffermaker')

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

let req = encodeRequestHeader('meee', 0, 18)
req = encodeRequestWithLength(req)
console.log(req.toString('hex'))

let socket = require('net').connect(9092, 'localhost')
socket.on('connect', ()=> socket.write(req))
socket.on('data', data => {
  console.log('got response', data.length, data.toString('hex'), data.readUInt32BE(0))
})
