const http = require('http');
const express = require('express')
const multer = require('multer');
const url = require('url')

const app = express()
const port = process.env.PORT || 3000

// Configurar la rebuda d'arxius a través de POST
const storage = multer.memoryStorage(); // Guardarà l'arxiu a la memòria
const upload = multer({ storage: storage });

// Tots els arxius de la carpeta 'public' estàn disponibles a través del servidor
// http://localhost:3000/
// http://localhost:3000/images/imgO.png
app.use(express.static('public'))

// Configurar per rebre dades POST en format JSON
app.use(express.json());

// Activar el servidor HTTP
const httpServer = app.listen(port, appListen)
async function appListen() {
  console.log(`Listening for HTTP queries on: http://localhost:${port}`)
}

// Tancar adequadament les connexions quan el servidor es tanqui
process.on('SIGTERM', shutDown);
process.on('SIGINT', shutDown);
function shutDown() {
  console.log('Received kill signal, shutting down gracefully');
  httpServer.close()
  process.exit(0);
}

// Configurar direcció tipus 'GET' amb la URL ‘/itei per retornar codi HTML
// http://localhost:3000/ieti
app.get('/ieti', getIeti)
async function getIeti(req, res) {

  // Aquí s'executen totes les accions necessaries
  // - fer una petició a un altre servidor
  // - consultar la base de dades
  // - calcular un resultat
  // - cridar la linia de comandes
  // - etc.

  res.writeHead(200, { 'Content-Type': 'text/html' })
  res.end('<html><head><meta charset="UTF-8"></head><body><b>El millor</b> institut del món!</body></html>')
}

// Configurar direcció tipus 'GET' amb la URL ‘/llistat’ i paràmetres URL 
// http://localhost:3000/llistat?cerca=cotxes&color=blau
// http://localhost:3000/llistat?cerca=motos&color=vermell
app.get('/llistat', getLlistat)
async function getLlistat(req, res) {
  let query = url.parse(req.url, true).query;

  // Aquí s'executen totes les accions necessaries
  // però tenint en compte els valors dels variables de la URL
  // que guardem a l'objecte 'query'

  if (query.cerca && query.color) {
    // Així es retorna un text per parts (chunks)
    res.writeHead(200, { 'Content-Type': 'text/plain; charset=UTF-8' });
    await new Promise(resolve => setTimeout(resolve, 1000))
    res.write(`result: "Aquí tens el llistat de ${query.cerca} de color ${query.color}"`)
    await new Promise(resolve => setTimeout(resolve, 1000))
    res.write(`\n list: ["item0", "item1", "item2"]`)
    await new Promise(resolve => setTimeout(resolve, 1000))
    res.end(`\n end: "Això és tot"`)
  } else {
    // Així es retorna un objecte JSON directament
    res.status(400).json({ result: "Paràmetres incorrectes" })
  }
}

// Configurar direcció tipus 'POST' amb la URL ‘/data'
// Enlloc de fer una crida des d'un navegador, fer servir 'curl'
// curl -X POST -F "data={\"type\":\"test\"}" -F "file=@package.json" http://localhost:3000/data
app.post('/data', upload.single('file'), async (req, res) => {
  // Processar les dades del formulari i l'arxiu adjunt
  const textPost = req.body;
  const uploadedFile = req.file;
  let objPost = {}

  try {
    objPost = JSON.parse(textPost.data)
  } catch (error) {
    res.status(400).send('Sol·licitud incorrecta.')
    console.log(error)
    return
  }

  if (objPost.type === 'text') {
    if (uploadedFile) {
      let fileContent = uploadedFile.buffer.toString('utf-8')
      console.log('Contingut de l\'arxiu adjunt:')
      console.log(fileContent)
    }
    await callMistral(res, objPost.info)
    res.end("")
  } else if (objPost.type === 'img') {
    if (uploadedFile) {
      let fileContent = uploadedFile.buffer.toString('utf-8')
      console.log('Contingut de l\'arxiu adjunt:')
      console.log(fileContent)
    }
    await callLlava(res, "Describe la imagen", objPost.info)
    res.end("")
  } else {
    res.status(400).send('Sol·licitud incorrecta.')
  }
})

async function callMistral(userResponse, query) {

  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 11434,
      path: '/api/generate',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      rejectUnauthorized: false
    }

    const data = JSON.stringify({
      model: "mistral",
      prompt: query
    })

    const req = http.request(options, (res) => {
      res.on('data', (chunk) => {
        let obj = JSON.parse(chunk)
        console.log(obj.response)
        userResponse.write(obj.response);
      });
      res.on('end', () => {
        console.log("done")
        resolve()
      })
    })

    req.on('error', (error) => {
      console.error("Error en la sol·licitud: ", error)
      reject(error)
    })

    req.write(data)
    req.end()
  })
}

async function callLlava(userResponse, query, imageBase64) {

  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 11434,
      path: '/api/generate',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      rejectUnauthorized: false
    }

    const data = JSON.stringify({
      model: "llava",
      prompt: query,
      images: [imageBase64]
    })

    const req = http.request(options, (res) => {
      res.on('data', (chunk) => {
        let obj = JSON.parse(chunk)
        console.log(obj.response)
        userResponse.write(obj.response);
      });
      res.on('end', () => {
        console.log("done")
        resolve()
      })
    })

    req.on('error', (error) => {
      console.error("Error en la sol·licitud: ", error)
      reject(error)
    })

    req.write(data)
    req.end()
  })
}