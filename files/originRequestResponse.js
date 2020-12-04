'use strict';
const fs = require('fs');
const environment = JSON.parse(fs.readFileSync('environment.json', 'utf8'));

let csp = [];
for (let p in environment.cspData) {
    csp.push(p + "-src " + environment.cspData[p].join(" "));
}
csp = csp.join("; ");

exports.addHeaders = (event, context, callback) => {
    //Get contents of response
    const request = event.Records[0].cf.request;
    const response = event.Records[0].cf.response;
    const headers = response.headers;

    //Set new headers
    addSecurityHeaders(headers);

    //Return modified response
    callback(null, response);
};


const addSecurityHeaders = (headers) => {
    //Set new headers
    headers['strict-transport-security'] = [{key: 'Strict-Transport-Security', value: 'max-age=63072000; includeSubdomains; preload'}];
    headers['content-security-policy'] = [{key: 'Content-Security-Policy', value: csp}];
    headers['x-content-type-options'] = [{key: 'X-Content-Type-Options', value: 'nosniff'}];
    headers['x-frame-options'] = [{key: 'X-Frame-Options', value: 'DENY'}];
    headers['x-xss-protection'] = [{key: 'X-XSS-Protection', value: '1; mode=block'}];
    headers['referrer-policy'] = [{key: 'Referrer-Policy', value: 'strict-origin'}];

};
