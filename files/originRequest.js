'use strict';
const environment = require('./environment.js').env;

const r = JSON.parse(environment.redirectsJson);
const redirects = {};
for (let i = 0; i < r.length; i++) {
    redirects[r[i].source] = r[i].target;
}
console.info(redirects);


exports.redirect = (event, context, callback) => {
    let request = event.Records[0].cf.request;

    //if URI matches to 'pretty-url' then redirect to a different URI
    const target = redirects[request.uri];
    if (target) {
        //Generate HTTP redirect response to a different landing page.
        const redirectResponse = {
            status: '301',
            statusDescription: 'Moved Permanently',
            headers: {
                'location': [{
                    key: 'Location',
                    value: target,
                }],
                'cache-control': [{
                    key: 'Cache-Control',
                    value: "max-age=3600"
                }],
            },
        };
        callback(null, redirectResponse);
    } else {
        // for all other requests proceed to fetch the resources
        callback(null, request);
    }
};
