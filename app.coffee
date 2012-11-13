express = require('express')
http = require('http')
path = require('path')
engines = require('consolidate')
config = require('./config')
app = express()

app.engine('html', engines.hogan)
app.set('view engine', 'html')
app.set('views', __dirname + '/views')
app.use(express.static(__dirname + '/public'))
app.use(require('connect-assets')(src: 'public'))
app.use(express.bodyParser());
app.use((err, req, res, next) ->
  res.status(500)
  res.render('error', error: err )
)

app.get('/', (req, res) ->
  res.render('index',  js: (-> global.js), css: (-> global.css))
)

app.get('/report', (req, res) ->
  res.render('report',  js: (-> global.js), css: (-> global.css))
)

app.get('/client/:client', (req, res) ->
  db = require("redis").createClient()
  db.hgetall(req.params.client, (err, obj) ->
    res.write(JSON.stringify(obj))
    res.end()
  )
)

app.get('/transactions/:login', (req, res) ->
  connection = require('mysql').createConnection(config.database)

  connection.connect()
  connection.query("SELECT * FROM transactions", 
    [req.params.login], (err, rows) ->
      res.write(JSON.stringify(rows))
      connection.end()
      res.end()
  )
)

app.get('/ticker', (req, res) ->
  symbol = req.params.symbol
  symbol or= 'virtexCAD'

  options = 
    host: 'bitcoincharts.com', 
    path: '/t/depthcalc.json?symbol=' + symbol + '&type=bid&amount=1000&currency=true'
  
  require('http').get(options, (r) ->
    r.setEncoding('utf-8')
    r.on('data', (chunk) ->
      res.send(chunk)
    ) 
  )
)

app.post('/create', (req, res) ->
  db = require("redis").createClient()
  db.hmset(req.body.login, req.body, ->
    res.writeHead(302, 'Location': '/' + req.body.login)
    res.end()
  )
)

app.get('/:client', (req, res) ->
  res.render('calculator', 
    client: req.params.client, 
    js: (-> global.js), 
    css: (-> global.css) 
  )
)

app.use((err, req, res, next) ->
  console.log(err)
)

app.listen(3000)