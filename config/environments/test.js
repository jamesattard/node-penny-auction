module.exports = {
  connections : {
   mongo: {
      adapter: 'sails-mongo',
      host: 'localhost',
      port: 27017,
      // user: 'username',
      // password: 'password',
      // database: 'your_mongo_db_name_here'
    }
  }

  ,app: {
    baseUrl: "http://localhost:1337"
  }
}