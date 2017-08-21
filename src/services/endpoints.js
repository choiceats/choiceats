export default {
  protocol: 'http',
  url: 'localhost',
  port: process.env.NODE_ENV === 'production' ? '80' : '4000'
}
