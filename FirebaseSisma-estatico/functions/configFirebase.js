const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
const express = require('express');
const cors = require('cors')({origin: true});
const app = express();

admin.initializeApp(functions.config().firebase);

function fire(){
    const config = {
        apiKey: functions.config().todoservice.apikey,
        authDomain: functions.config().todoservice.authdomain,
        databaseURL: functions.config().todoservice.databaseurl,
        projectId: functions.config().todoservice.projectid,
        storageBucket: functions.config().todoservice.storagebucket,
        messagingSenderId: functions.config().todoservice.messagingsenderid,
    };
}


exports.fire = functions.https.onRequest(app);