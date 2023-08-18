exports.handler = async (event, context) => {
  try {
    const { body } = event;

    return {
      statusCode: 200,
      body: JSON.stringify({ message: 'testing4', body: event.body }),
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: error.message }),
    };
  }
};
