module.exports = {
  connections : {
   mongo: {
      adapter: 'sails-mongo',
      host: 'localhost',
      port: 27017,
      // user: 'username',
      // password: 'password',
      database: 'penny-auc-test'
    }
  }

  ,app: {
    baseUrl: "http://localhost:1337"
  }
}