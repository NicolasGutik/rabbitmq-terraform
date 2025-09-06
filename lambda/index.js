// index.js
const amqp = require("amqplib");

exports.handler = async () => {
  const connection = await amqp.connect("amqps://usuario:clave@host/vhost");
  const channel = await connection.createChannel();
  const queue = "nombre_de_la_cola";

  await channel.assertQueue(queue, { durable: true });

  console.log("Esperando mensaje...");

  channel.consume(queue, (msg) => {
    console.log("HOLA");
    channel.ack(msg);
  });
};
