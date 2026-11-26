db = db.getSiblingDB('erp');
db.clientes.insertMany([{nombre:'Minera Andina',ruc:'20100000001'},{nombre:'Textiles del Sur',ruc:'20100000002'}]);
db.secretos.insertOne({clave:'QHAPAQ{56-mongodb-sin-autenticacion}'});
