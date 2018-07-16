const kafka = require('kafka-node')
const Producer = kafka.Producer
const client = new kafka.Client()
const producer = new Producer(client)


const HighLevelConsumer = kafka.HighLevelConsumer
const consumer = new HighLevelConsumer(
  client,
  [ { topic: 'topic1' }, { topic: 'topic2' } ],
  { groupId: 'my-group' }
)
consumer.addTopics(['topic1', 'topic2'], (err, added) => console.log(err, added))
consumer.on('message', msg => console.log('consume msg', JSON.stringify(msg)))

let i=0
let payloads = [
  { topic: 'topic1', messages: `hi ${i}`, partition: 0 },
  { topic: 'topic2', messages: ['hello', 'world', i] }
]

function producerSend(){
  producer.send(payloads, (err, data) => {
    console.log('producer send', err, data)
    i++
  })
}

producer.on('ready', function(){
  setInterval(producerSend, 5000)
})

producer.on('error', (err) => console.error('producer err', err))

