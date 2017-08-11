import AWS from 'aws-sdk';
import request from 'superagent';

AWS.config.update({region: 'us-west-1'});
var sqs = new AWS.SQS();

function addJobResolver(fileName) {
  var params = {
   MessageBody: `{"op": "InvokeAction", "action": "add_site", "site_name": "${fileName}"}`,
   QueueUrl: process.env.JOB_QUEUE_URL
  };
  
  sqs.sendMessage(params, (err, data) => {
    if (err) {
      callback(err);
    }
  });
}

function  sitesResolver(user) {
  return new Promise( (resolve,reject) => {
    let sites = [];
    request
    .get('/api/nav')
    .set('Accept', 'application/json')
    .end((err, res) => {
      if( err ) {
        reject(err);
      } else {
        res.body.rows.map( (row) => {
          sites.push(row.id.replace(/[a-z]\:/,''));
        });
        resolve(sites);
      }
    })
  });
}

function startSimulationResolver(siteRef) {
  return new Promise( (resolve,reject) => {
    request
    .post('/api/invokeAction')
    .set('Accept', 'application/json')
    .set('Content-Type', 'application/json')
    .send({
      "meta": {
        "ver": "2.0",
        "id": `r:${siteRef}`,
        "action": "s:start_simulation"
      },
      "cols": [
        {
          "name": "foo"
        },
        {
          "name": "time_scale"
        }
      ],
      "rows": [
        {
          "foo": "s:bar",
          "time_scale": "s:50000"
        }
      ]
    })
    .end((err, res) => {
      if( err ) {
        reject(err);
      } else {
        resolve(res.body);
      }
    })
  });
}

module.exports = { addJobResolver, sitesResolver, startSimulationResolver };
