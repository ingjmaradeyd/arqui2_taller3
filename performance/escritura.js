import http from 'k6/http';
import { check } from 'k6';
import exec from 'k6/execution';

import {
    AWSConfig,
    Endpoint,
    SignatureV4
} from 'https://jslib.k6.io/aws/0.14.0/signature.js';


const REGION = __ENV.AWS_REGION || 'us-east-1';

const endpoint = new Endpoint(
    `https://dynamodb.${REGION}.amazonaws.com`
);


const awsConfig = new AWSConfig({

    region: REGION,

    accessKeyId:
    __ENV.AWS_ACCESS_KEY_ID,

    secretAccessKey:
    __ENV.AWS_SECRET_ACCESS_KEY,

    sessionToken:
    __ENV.AWS_SESSION_TOKEN
});


const signer = new SignatureV4({

    service: 'dynamodb',

    region: REGION,

    credentials: {

        accessKeyId:
        awsConfig.accessKeyId,

        secretAccessKey:
        awsConfig.secretAccessKey,

        sessionToken:
        awsConfig.sessionToken
    },

    uriEscapePath: true,

    applyChecksum: true
});


export const options = {

    stages: [
        { duration: '30s', target: 10 },
        { duration: '1m',  target: 10 },
        { duration: '30s', target: 30 },
        { duration: '1m',  target: 30 },
        { duration: '30s', target: 0 }
    ],

    thresholds: {

        http_req_failed: [
            'rate<0.01'
        ],

        http_req_duration: [
            'p(95)<500',
            'p(99)<1000'
        ]
    }
};


export default function () {

    const numero =
        exec.scenario.iterationInTest;

    const idUsuario =
        `PERF${String(numero).padStart(10, '0')}`;

    const numeroTarjeta =
        `900000${String(numero).padStart(10, '0')}`;


    const body = JSON.stringify({

        TableName: 'Usuarios',

        Item: {

            idUsuario: {
                S: idUsuario
            },

            numero_tarjeta: {
                S: numeroTarjeta
            },

            nombre: {
                S: `UsuarioPerformance${numero}`
            },

            apellido: {
                S: `ApellidoPerformance${numero}`
            },

            direccion: {
                S: `Direccion Performance ${numero}`
            },

            estado: {
                S: 'ACTIVO'
            },

            poblacion: {
                S: 'GENERAL'
            }
        }
    });


    const signedRequest = signer.sign({

        method: 'POST',

        endpoint: endpoint,

        path: '/',

        headers: {

            'Content-Type':
                'application/x-amz-json-1.0',

            'X-Amz-Target':
                'DynamoDB_20120810.PutItem'
        },

        body: body
    });


    const response = http.post(

        signedRequest.url,

        body,

        {

            headers:
            signedRequest.headers,

            tags: {
                operation: 'PutItem'
            }
        }
    );


    check(response, {

        'HTTP 200':
            (r) => r.status === 200

    });
}
