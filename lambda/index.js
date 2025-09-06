exports.handler = async (event) => {
  console.log("📩 Mensaje recibido:", JSON.stringify(event));
  return {
    statusCode: 200,
    body: JSON.stringify('Hola desde Lambda via RabbitMQ!'),
  };
};
