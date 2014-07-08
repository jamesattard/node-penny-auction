path = require('path')
//appDir = path.dirname(require.main.filename)

module.exports.app = {
  baseUrl: "http://postcodechat.com",
  socket: {
    port: 1337
  },

  tmpDir: path.normalize(__dirname + "/../.tmp"),
  auth: {
    defaultAdmin: {
      id:    '12def-admin425674ad-def2',
      email: 'admin@example.com',
      username: 'defaultadmin',
      password: 'suckmyduck',
      roles: ['login', 'admin']
    }
  }
}